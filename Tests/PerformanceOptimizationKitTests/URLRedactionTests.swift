import Foundation
import Testing
@testable import PerformanceOptimizationKit

private func redacted(_ string: String, with redaction: URLRedaction = .standard) throws -> String {
    redaction.redact(try #require(URL(string: string)))
}

@Suite("URLRedaction")
struct URLRedactionTests {
    @Test("drops credentials, query and fragment and replaces identifiers", arguments: [
        ("https://user:secret@API.Example.com/users/12345/avatar?token=abc#top", "https://api.example.com/users/:id/avatar"),
        ("https://example.com:8443/v1/orders/3F2504E0-4F89-11D3-9A0C-0305E82C3301", "https://example.com:8443/v1/orders/:id"),
        ("https://example.com/files/9f86d081884c7d659a2feaa0c55ad015", "https://example.com/files/:id"),
        ("https://example.com/users/jane.doe@example.org/profile", "https://example.com/users/:id/profile"),
        ("https://example.com/users/%E5%BC%A0%E4%BC%9F@example.cn/profile", "https://example.com/users/:id/profile"),
        ("https://example.com/s/eyJhbGciOiJIUzI1NiJ9abc123xyz", "https://example.com/s/:id"),
        ("https://example.com/s/Bearer%20abcdef", "https://example.com/s/:id"),
        ("https://example.com/users/12345.json", "https://example.com/users/:id.json"),
        ("https://example.com/reports/2024.pdf", "https://example.com/reports/:id.pdf"),
        ("https://example.com/s/Ab3dEf5Gh7Jk9Lm1", "https://example.com/s/:id"),
        ("https://example.com/p/ipad-pro-12-9-2024", "https://example.com/p/:id"),
        ("https://example.com/k/user_123456", "https://example.com/k/:id"),
        ("https://example.com/k/123-45-6789", "https://example.com/k/:id"),
        ("https://example.com/users/+905551234567/calls", "https://example.com/users/:id/calls"),
        ("https://example.com/users/%2B905551234567", "https://example.com/users/:id"),
        ("https://example.com/pay/4111%201111%201111%201111", "https://example.com/pay/:id"),
        ("https://example.com/pay/DE89%203704%200044%200532%200130%2000", "https://example.com/pay/:id"),
        ("https://example.com/b/" + String(repeating: "abcdefgh", count: 4), "https://example.com/b/:id"),
    ])
    func identifiers(input: String, expected: String) throws {
        #expect(try redacted(input) == expected)
    }

    @Test("keeps plain paths", arguments: [
        "https://example.com",
        "https://example.com/",
        "https://example.com/search",
        "https://example.com/v1.2/items/logo.png",
        "https://example.com/photos/My%20Trip%202024/cover",
        "https://example.com/docs/release%20notes",
        "https://example.com/k/order-12345/item_4",
        "http://127.0.0.1:8080/health",
        "https://example.com/ping/keyboard/signup",
    ])
    func keepsPlainPaths(input: String) throws {
        #expect(try redacted(input) == input)
    }

    @Test("hides the segment after a secret name", arguments: [
        ("https://example.com/reset/token/abc", "https://example.com/reset/token/:id"),
        ("https://example.com/api_key/hunter/next", "https://example.com/api_key/:id/next"),
        ("https://example.com/Password/hunter", "https://example.com/Password/:id"),
        ("https://example.com/API%20KEY/hunter", "https://example.com/API%20KEY/:id"),
        ("https://example.com/api.key/hunter", "https://example.com/api.key/:id"),
        ("https://example.com/%74oken/hunter", "https://example.com/%74oken/:id"),
        ("https://example.com/sessions/hunter", "https://example.com/sessions/:id"),
        ("https://example.com/resetToken/hunter", "https://example.com/:id/:id"),
        ("https://example.com/reset/token-hunter22", "https://example.com/reset/:id"),
        ("https://example.com/reset/token_k9Xq2z/next", "https://example.com/reset/:id/:id"),
        ("https://example.com/api/passwordhunter2", "https://example.com/api/:id"),
        ("https://example.com/v/passwords-hunter", "https://example.com/v/:id"),
        ("https://example.com/v/sessionabcdef", "https://example.com/v/:id"),
        ("https://example.com/reset/pin_4831/next", "https://example.com/reset/:id/:id"),
        ("https://example.com/k/Key%20hunter", "https://example.com/k/:id"),
        ("https://example.com/pin//4831", "https://example.com/pin//:id"),
        ("https://example.com/token/password/hunter", "https://example.com/token/:id/:id"),
    ])
    func secretNames(input: String, expected: String) throws {
        #expect(try redacted(input) == expected)
    }

    // Look-alike letters (Cyrillic, Greek, mathematical, circled, full-width), format characters
    // (zero-width joiner and non-joiner, soft hyphen), combining marks, Unicode line separators,
    // emoji and symbols: a name that is not plain ASCII is hidden, and so is the next segment.
    @Test("hides names it cannot read and the segment after them", arguments: [
        "p%D0%B0ssword", "t%CE%BFken", "%F0%9D%90%A9in", "%E2%93%9Fin", "%EF%BD%94%EF%BD%8F%EF%BD%8B%EF%BD%85%EF%BD%8E",
        "to%E2%80%8Dken", "to%E2%80%8Cken", "to%C2%ADken", "to%CC%81ken", "%E2%80%A8token", "%F0%9F%94%91",
        "%C5%9Eifre", "c++", "api+key", "(token)", "order:12345", "~", "!",
    ])
    func unreadableNames(name: String) throws {
        #expect(try redacted("https://example.com/v1/\(name)/hunter/tail") == "https://example.com/v1/:id/:id/tail")
    }

    @Test("records scheme and host only for paths servers read differently", arguments: [
        "https://example.com/a/./b", "https://example.com/a/../b", "https://example.com/a/%2E%2E/b", "https://example.com/a/%2e/b",
        "https://example.com/v1%2E2/b", "https://example.com/cart;jsessionid=ABC123/checkout", "https://example.com/cart%3Bsid=x",
        "https://example.com/cart%3bsid=x", "https://example.com/cart%253Bsid=x", "https://example.com/a%2Fb",
        "https://example.com/callback%3Ftoken=abc", "https://example.com/page%23access_token=abc", "https://example.com/a%5Cb",
        "https://example.com/a%0Ab", "https://example.com/a%0D%0Ab", "https://example.com/a%7F", "https://example.com/a%2",
        "https://example.com/files/%25252541bc", "https://example.com/a\\token",
        "https://example.com:8443/a/../b",
    ])
    func hostOnly(input: String) throws {
        #expect(try redacted(input) == "https://example.com")
    }

    @Test("records scheme and host only when the host names a secret", arguments: [
        ("myapp://pin/4831", "myapp://pin"),
        ("https://token.example.com/x/y?z=1", "https://token.example.com"),
    ])
    func secretHost(input: String, expected: String) throws {
        #expect(try redacted(input) == expected)
    }

    @Test("records only the scheme of hosts it cannot read and of URLs without a host", arguments: [
        ("https://a1b2c3d4e5f6a7b8c9d0.example.com/x", "https:"),
        ("https://1234567.tenants.example.com/x", "https:"),
        ("https://my_host.example.com/x", "https:"),
        ("https://-bad.example.com/x", "https:"),
        ("myapp://pin-4831/x", "myapp:"),
        ("myapp://tokenhunter22/x", "myapp:"),
        ("https://oauth2.example.com/x", "https:"),
        ("https://pass.wordhunter2.example.com/x", "https:"),
        ("data:text/plain;base64,c2VjcmV0", "data:"),
        ("mailto:jane@example.org?subject=hi", "mailto:"),
        ("file:///Users/jane/Documents/report.pdf", "file:"),
        ("users/12345", "<unparsed URL>"),
    ])
    func schemeOnly(input: String, expected: String) throws {
        #expect(try redacted(input) == expected)
    }

    @Test("brackets IPv6 hosts")
    func ipv6() throws {
        #expect(try redacted("http://[::1]:8080/health?x=1") == "http://[::1]:8080/health")
    }

    @Test("can record the host only")
    func hostOnlyOption() throws {
        let redaction = URLRedaction(recordsHostOnly: true)
        #expect(try redacted("https://example.com:8443/users/1?page=2", with: redaction) == "https://example.com:8443")
    }

    @Test("cuts long results")
    func truncates() throws {
        let path = Array(repeating: "segment", count: 64).joined(separator: "/")
        let result = try redacted("https://example.com/\(path)")
        #expect(result.count == URLRedaction.maximumLength)
        #expect(result.hasSuffix("…"))
    }

    @Test("records scheme and host only past the caps")
    func caps() throws {
        let segments = Array(repeating: "a", count: URLRedaction.maximumPathSegments + 1).joined(separator: "/")
        #expect(try redacted("https://example.com/\(segments)") == "https://example.com")
        let longSegment = String(repeating: "a", count: URLRedaction.maximumComponentBytes)
        #expect(try redacted("https://example.com/\(longSegment)") == "https://example.com")
        let parameters = (0...URLRedaction.maximumQueryParameters).map { "p\($0)=1" }.joined(separator: "&")
        #expect(try redacted("https://example.com/a?\(parameters)") == "https://example.com")
        let fewer = (1..<URLRedaction.maximumQueryParameters).map { "p\($0)=1" }.joined(separator: "&")
        #expect(try redacted("https://example.com/a?\(fewer)") == "https://example.com/a")
    }
}

@Suite("URLRedaction query parameters")
struct URLRedactionQueryTests {
    let redaction = URLRedaction(allowedQueryParameters: ["page", "Sort", "token", "Şifre", "api-key"])

    @Test("ignores secret and non-ASCII names in the allowlist")
    func allowlist() {
        #expect(redaction.allowedQueryParameters == ["page", "sort"])
        #expect(URLRedaction.standard.allowedQueryParameters.isEmpty)
    }

    @Test("keeps the plain values of allowed parameters only", arguments: [
        ("https://api.example.com/v1/items/search?page=2&sort=asc&q=jane", "https://api.example.com/v1/items/search?page=2&sort=asc"),
        ("https://api.example.com/v1/items?Page=2", "https://api.example.com/v1/items?Page=2"),
        ("https://api.example.com/v1/items?page=2&page=3", "https://api.example.com/v1/items?page=2&page=3"),
        ("https://api.example.com/v1/items?page", "https://api.example.com/v1/items?page"),
        ("https://api.example.com/v1/items?token=abc&p%C3%A4ge=2", "https://api.example.com/v1/items"),
        ("https://api.example.com/v1/items?sort=%7B%22token%22%3A%22x%22%7D", "https://api.example.com/v1/items?sort=<redacted>"),
        ("https://api.example.com/v1/items?sort=jane%40example.com", "https://api.example.com/v1/items?sort=<redacted>"),
        ("https://api.example.com/v1/items?sort=password", "https://api.example.com/v1/items?sort=<redacted>"),
        ("https://api.example.com/v1/items?sort=token-hunter", "https://api.example.com/v1/items?sort=<redacted>"),
        ("https://api.example.com/v1/items?sort=9f86d081884c7d659a2f", "https://api.example.com/v1/items?sort=<redacted>"),
        ("https://api.example.com/v1/items?sort=a%0Ab", "https://api.example.com/v1/items"),
    ])
    func values(input: String, expected: String) throws {
        #expect(try redacted(input, with: redaction) == expected)
    }

    @Test("drops the query when servers could read it differently", arguments: [
        "https://api.example.com/v1/items?page=2&PAGE=3",
        "https://api.example.com/v1/items?pa%67e=2&page=3",
        "https://api.example.com/v1/items?page=2;token=abc",
        "https://api.example.com/v1/items?page=%252",
        "https://api.example.com/v1/items?page=%2",
    ])
    func ambiguous(input: String) throws {
        #expect(try redacted(input, with: redaction) == "https://api.example.com/v1/items")
    }

    @Test("keeps a URL with only plain names and values as it is")
    func usefulness() throws {
        let url = "https://api.example.com/v1/items/search?page=2&sort=name"
        #expect(try redacted(url, with: redaction) == url)
    }
}
