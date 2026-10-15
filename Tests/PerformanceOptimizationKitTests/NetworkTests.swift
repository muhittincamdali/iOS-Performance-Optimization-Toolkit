import Foundation
import Network
import Testing
@testable import PerformanceOptimizationKit

@Suite("URLRedaction")
struct URLRedactionTests {
    @Test("removes credentials, query, fragment and identifiers", arguments: [
        ("https://user:secret@API.Example.com/users/12345/avatar?token=abc#top", "https://api.example.com/users/:id/avatar"),
        ("https://example.com:8443/v1/orders/3F2504E0-4F89-11D3-9A0C-0305E82C3301", "https://example.com:8443/v1/orders/:id"),
        ("https://example.com/files/9f86d081884c7d659a2feaa0c55ad015", "https://example.com/files/:id"),
        ("https://example.com/users/jane.doe@example.org/profile", "https://example.com/users/:id/profile"),
        ("https://example.com/s/eyJhbGciOiJIUzI1NiJ9abc123xyz", "https://example.com/s/:id"),
        ("https://api.example.com/files/abc123%2Fdef456ghijk7890xyz/raw", "https://api.example.com/files/:id/raw"),
        ("https://example.com/search", "https://example.com/search"),
        ("https://example.com", "https://example.com"),
    ])
    func redacts(input: String, expected: String) throws {
        let url = try #require(URL(string: input))
        #expect(URLRedaction.redact(url) == expected)
    }

    @Test("drops path parameters, also when their separator is percent-encoded", arguments: [
        ("https://example.com/cart;jsessionid=ABC123/checkout", "https://example.com/cart/checkout"),
        ("https://example.com/cart%3Bjsessionid=ABC123/checkout", "https://example.com/cart/checkout"),
        ("https://example.com/cart%3bsid=x", "https://example.com/cart"),
    ])
    func pathParameters(input: String, expected: String) throws {
        let url = try #require(URL(string: input))
        #expect(URLRedaction.redact(url) == expected)
    }

    @Test("keeps encoded line breaks encoded so they cannot split a log line")
    func noLineBreaks() throws {
        let url = try #require(URL(string: "https://example.com/a%0Ab%0D%0Ac"))
        let redacted = URLRedaction.redact(url)
        #expect(!redacted.contains("\n"))
        #expect(!redacted.contains("\r"))
        #expect(redacted == "https://example.com/a%0Ab%0D%0Ac")
    }

    @Test("keeps only the scheme of URLs without a host", arguments: [
        ("data:text/plain;base64,c2VjcmV0", "data:"),
        ("mailto:jane@example.org?subject=hi", "mailto:"),
        ("file:///Users/jane/Documents/report.pdf", "file:"),
    ])
    func hostless(input: String, expected: String) throws {
        let url = try #require(URL(string: input))
        #expect(URLRedaction.redact(url) == expected)
    }

    @Test("brackets IPv6 hosts")
    func ipv6() throws {
        let url = try #require(URL(string: "http://[::1]:8080/health?x=1"))
        #expect(URLRedaction.redact(url) == "http://[::1]:8080/health")
    }

    @Test("cuts very long results")
    func truncates() throws {
        let path = Array(repeating: "segment", count: 200).joined(separator: "/")
        let url = try #require(URL(string: "https://example.com/\(path)"))
        let redacted = URLRedaction.redact(url)
        #expect(redacted.count == URLRedaction.maximumLength)
        #expect(redacted.hasSuffix("…"))
    }
}

@Suite("NetworkTiming", .serialized)
struct NetworkTimingTests {
    @Test("a phase is nil when a time is missing or out of order")
    func span() {
        let start = Date(timeIntervalSince1970: 100)
        #expect(NetworkTiming.Phases.span(start, start.addingTimeInterval(0.25)) == .milliseconds(250))
        #expect(NetworkTiming.Phases.span(start, start.addingTimeInterval(-0.25)) == nil)
        #expect(NetworkTiming.Phases.span(nil, start) == nil)
        #expect(NetworkTiming.Phases.span(start, nil) == nil)
    }

    @Test("collects a redacted timing for a real request")
    func collectsTiming() async throws {
        let server = try await LocalHTTPServer.start(body: "hello")
        defer { server.stop() }
        let collector = NetworkMetricsCollector(capacity: 5)
        let session = URLSession(configuration: .ephemeral, delegate: collector, delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        let url = try #require(URL(string: "http://127.0.0.1:\(server.port)/users/12345/avatar?token=secret"))
        let updates = collector.updates()
        let (data, _) = try await session.data(from: url)
        #expect(String(decoding: data, as: UTF8.self) == "hello")
        var iterator = updates.makeAsyncIterator()
        let timing = try #require(await iterator.next())
        #expect(timing.url == "http://127.0.0.1:\(server.port)/users/:id/avatar")
        #expect(timing.method == "GET")
        #expect(timing.statusCode == 200)
        #expect(timing.fromCache == false)
        #expect(timing.phases.connect != nil)
        #expect(timing.phases.secureConnection == nil)
        #expect(timing.total != nil)
        #expect(collector.timings == [timing])
    }

    @Test("keeps the newest timings up to its capacity")
    func boundedCollector() async throws {
        let server = try await LocalHTTPServer.start(body: "ok")
        defer { server.stop() }
        let collector = NetworkMetricsCollector(capacity: 2)
        let session = URLSession(configuration: .ephemeral, delegate: collector, delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        for index in 0..<3 {
            _ = try await session.data(from: try #require(URL(string: "http://127.0.0.1:\(server.port)/item-\(index)")))
        }
        // The metrics callback can arrive just after the response; wait for it.
        for _ in 0..<50 where collector.timings.last?.url.hasSuffix("/item-2") != true {
            try await Task.sleep(for: .milliseconds(20))
        }
        #expect(collector.timings.map { $0.url.components(separatedBy: "/").last } == ["item-1", "item-2"])
        collector.removeAll()
        #expect(collector.timings.isEmpty)
    }
}

/// A one-file HTTP/1.1 server on the loopback interface that answers every request with 200.
final class LocalHTTPServer: Sendable {
    let port: UInt16
    private let listener: NWListener

    private init(listener: NWListener, port: UInt16) {
        self.listener = listener
        self.port = port
    }

    static func start(body: String) async throws -> LocalHTTPServer {
        let parameters = NWParameters.tcp
        parameters.requiredInterfaceType = .loopback
        let listener = try NWListener(using: parameters, on: .any)
        let queue = DispatchQueue(label: "LocalHTTPServer")
        listener.newConnectionHandler = { connection in
            connection.start(queue: queue)
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { _, _, _, _ in
                let response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: \(body.utf8.count)\r\nConnection: close\r\n\r\n\(body)"
                connection.send(content: Data(response.utf8), completion: .contentProcessed { _ in connection.cancel() })
            }
        }
        let port: UInt16 = try await withCheckedThrowingContinuation { continuation in
            let resumed = NSLock()
            nonisolated(unsafe) var done = false
            listener.stateUpdateHandler = { state in
                resumed.withLock {
                    guard !done else { return }
                    switch state {
                    case .ready:
                        done = true
                        continuation.resume(returning: listener.port?.rawValue ?? 0)
                    case .failed(let error):
                        done = true
                        continuation.resume(throwing: error)
                    default:
                        break
                    }
                }
            }
            listener.start(queue: queue)
        }
        return LocalHTTPServer(listener: listener, port: port)
    }

    func stop() {
        listener.cancel()
    }
}
