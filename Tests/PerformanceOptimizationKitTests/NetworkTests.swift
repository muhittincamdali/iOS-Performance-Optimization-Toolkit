import Foundation
import Network
import Testing
@testable import PerformanceOptimizationKit

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

    @Test("keeps a method or protocol name only when it is short and plain", arguments: [
        ("GET", 32, "GET"), ("PROPFIND", 32, "PROPFIND"), ("h2", 16, "h2"), ("http/1.1", 16, "http/1.1"),
        ("", 32, nil), ("GET\nX-Token: abc", 32, nil), ("GET /a?token=abc", 32, nil), ("GÉT", 32, nil),
        (String(repeating: "A", count: 33), 32, nil), (String(repeating: "h", count: 17), 16, nil),
    ] as [(String, Int, String?)])
    func plainToken(value: String, maximumLength: Int, expected: String?) {
        #expect(NetworkTiming.plainToken(value, maximumLength: maximumLength) == expected)
    }

    @Test("collects a timing with the collector's redaction")
    func collectsWithRedaction() async throws {
        let server = try await LocalHTTPServer.start(body: "ok")
        defer { server.stop() }
        let collector = NetworkMetricsCollector(capacity: 5, redaction: URLRedaction(allowedQueryParameters: ["page"]))
        let session = URLSession(configuration: .ephemeral, delegate: collector, delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        let updates = collector.updates()
        _ = try await session.data(from: try #require(URL(string: "http://127.0.0.1:\(server.port)/items/token/abc?page=2&q=jane")))
        var iterator = updates.makeAsyncIterator()
        let timing = try #require(await iterator.next())
        #expect(timing.url == "http://127.0.0.1:\(server.port)/items/token/:id?page=2")
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
