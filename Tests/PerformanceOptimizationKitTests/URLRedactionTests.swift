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
        ("https://example.com/users/%E5%BC%A0%E4%BC%9F@example.cn/profile", "https://example.com/users/:id/:id"),
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
        "https://example.com/v/pinabcd",
        "https://example.com/v/mypinabc",
        "https://example.com/v/mapping3",
        "https://cdn1.pinterest.com/x",
        "https://v2.keycdn.com/x",
        "https://s3.cardinal.io/x",
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
        ("https://example.com/reset/pin1234/next", "https://example.com/reset/:id/:id"),
        ("https://example.com/reset/1234pin", "https://example.com/reset/:id"),
        ("https://example.com/reset/Pins1234", "https://example.com/reset/:id"),
        ("https://example.com/v/otp1234", "https://example.com/v/:id"),
        ("https://example.com/v/cvv123", "https://example.com/v/:id"),
        ("https://example.com/v/pwd1234", "https://example.com/v/:id"),
        ("https://example.com/v/ssn12345", "https://example.com/v/:id"),
        ("https://example.com/v/key9abc", "https://example.com/v/:id"),
        ("https://example.com/v/keyboard2", "https://example.com/v/:id"),
        ("https://example.com/reset/mypin1234/next", "https://example.com/reset/:id/:id"),
        ("https://example.com/v/newPin4831", "https://example.com/v/:id"),
        ("https://example.com/v/userpin4831", "https://example.com/v/:id"),
        ("https://example.com/v/abcotp1234", "https://example.com/v/:id"),
        ("https://example.com/v/mykey12345", "https://example.com/v/:id"),
        ("https://example.com/v/newpins4831", "https://example.com/v/:id"),
        ("https://example.com/v/abc1234otpxyz", "https://example.com/v/:id"),
        ("https://example.com/k/Key%20hunter", "https://example.com/k/:id"),
        ("https://example.com/pin//4831", "https://example.com/pin//:id"),
        ("https://example.com/token/password/hunter", "https://example.com/token/:id/:id"),
    ])
    func secretNames(input: String, expected: String) throws {
        #expect(try redacted(input) == expected)
    }

    // An identifier used to end a label: the segment after it was kept even when the identifier
    // held a secret name, in its name or in its extension, or was not ASCII.
    @Test("hides the segment after an identifier that holds a secret name or is not ASCII", arguments: [
        ("token123456", ":id"), ("pin123456", ":id"), ("password-123456", ":id"), ("token1234567890abcdef", ":id"),
        ("apikey.12345678", ":id"), ("token:123456", ":id"), ("pin@x", ":id"), ("123456.pin", ":id"),
        ("4831.pin", ":id.pin"), ("12345.key", ":id.key"), ("1234.pwd", ":id.pwd"), ("1.token", ":id.token"),
        ("%C5%9Eifre123456", ":id"), ("%E5%AF%86%E7%A0%81123456", ":id"), ("p%D0%B0ssword123456", ":id"),
        ("p%D1%96n123456", ":id"), ("t%CD%A6ken-123456", ":id"), ("passw%E3%80%87rd123456", ":id"), ("p%D1%96n@x", ":id"),
    ])
    func identifierLabels(segment: String, redactedSegment: String) throws {
        let result = try redacted("https://example.com/v1/\(segment)/hunter2/tail")
        #expect(result == "https://example.com/v1/\(redactedSegment)/:id/tail")
    }

    // An identifier was read with its symbols as separators, so a secret name with one letter
    // replaced by a symbol was found only when the symbol did not also make the segment an
    // identifier: "/v/t!ken/x" hid "x", "/v/t@ken/x" and "/v/p!n123456/x" kept it.
    @Test("hides the segment after an identifier that is not a plain name", arguments: [
        "t@ken", "p@ssword", "k@y", "c@rd", "@uth", "p%40ssword", "passw%40rd", "s3cr3t@x", "p!n123456",
        "sess!on123456", "s!d123456", "t*ken123456", "p+n123456", "p~n123456", "t=ken0123456789abcdef",
        "to@ken.example.com", "pass@word.org",
    ])
    func symbolLabels(segment: String) throws {
        #expect(try redacted("https://api.example.com/v/\(segment)/hunter2") == "https://api.example.com/v/:id/:id")
    }

    @Test("reads a symbol in a secret name alike whether or not it makes an identifier", arguments: [
        "token", "password", "pin", "session", "key", "card", "auth", "sid",
    ])
    func symbolsReadAlike(name: String) throws {
        var results: Set<String> = []
        for symbol in ["@", "!", "*", "$", "=", "%40"] {
            let disguised = name.prefix(1) + symbol + name.dropFirst(2)
            for code in ["", "123456"] {
                results.insert(try redacted("https://api.example.com/v/\(disguised)\(code)/hunter2"))
            }
        }
        #expect(results == ["https://api.example.com/v/:id/:id"])
    }

    @Test("keeps the segment after an e-mail address of plain names or a number", arguments: [
        "jane.doe@example.org", "j_doe-2@mail.example.co.uk", "%2B905551234567", "+90%20555%20123%2045%2067",
        "123-45-6789", "4111-1111-1111-1111",
    ])
    func contactIdentifiers(segment: String) throws {
        #expect(try redacted("https://api.example.com/v/\(segment)/profile") == "https://api.example.com/v/:id/profile")
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
        ("myapp://Tokens/abc?x=1", "myapp://tokens"),
        ("myapp://pin:4831/x", "myapp://pin"),
        ("myapp://pass.word/hunter2", "myapp://pass.word"),
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
        ("myapp://pin1234/x", "myapp:"),
        ("myapp://p-in4831/x", "myapp:"),
        ("myapp://pi-n-4831/x", "myapp:"),
        ("https://p-in4831.example.com/x", "https:"),
        ("https://sid42.example.com/x", "https:"),
        ("https://newpin4831.example.com/x", "https:"),
        ("https://oauth2.example.com/x", "https:"),
        ("https://pass.wordhunter2.example.com/x", "https:"),
        ("myapp://pin.ab12cd/x", "myapp:"),
        ("myapp://password.hunter2/x", "myapp:"),
        ("myapp://hunter2.token/x", "myapp:"),
        ("https://token.example.com/x/y?z=1", "https:"),
        ("https://api.pin.example.com/x", "https:"),
        ("myapp://eyJpZCI6MX0/x", "myapp:"),
        ("https://eyJpZCI6MX0.example.com/x", "https:"),
        ("https://[fe80::1%25hunter2secret]/u", "https:"),
        ("https://[fe80::1%25en0]:8080/u", "https:"),
        ("https://exa%6Dple.com/u", "https:"),
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
        ("https://api.example.com/v1/items?page=pin1234", "https://api.example.com/v1/items?page=<redacted>"),
        ("https://api.example.com/v1/items?page=otp1234", "https://api.example.com/v1/items?page=<redacted>"),
        ("https://api.example.com/v1/items?page=mypin1234", "https://api.example.com/v1/items?page=<redacted>"),
        ("https://api.example.com/v1/items?page=ping", "https://api.example.com/v1/items?page=ping"),
        ("https://api.example.com/v1/items?sort=9f86d081884c7d659a2f", "https://api.example.com/v1/items?sort=<redacted>"),
        ("https://api.example.com/v1/items?sort=a%0Ab", "https://api.example.com/v1/items"),
    ])
    func values(input: String, expected: String) throws {
        #expect(try redacted(input, with: redaction) == expected)
    }

    // A comma used to make the whole value unreadable as a name, and an unreadable value was not
    // checked for secret names, so each of these was kept as it was.
    @Test("hides a value with a secret or an identifier among its comma-separated parts", arguments: [
        "password,hunter2", "token,abc", "pin,4831", "a,mypin1234", "4111,1111,1111,1111",
        "pass,word", "name,deadbeefcafebabe", "asc,b-token", "1,2,3,4,5,6", "jane,oauth",
    ])
    func commaSeparatedValues(value: String) throws {
        let input = "https://api.example.com/v1/items?sort=\(value)&page=2"
        #expect(try redacted(input, with: redaction) == "https://api.example.com/v1/items?sort=<redacted>&page=2")
    }

    @Test("keeps a value whose comma-separated parts are all plain", arguments: ["name,asc", "1,2,3", "price,-date", "name,", ""])
    func plainCommaSeparatedValues(value: String) throws {
        let url = "https://api.example.com/v1/items?sort=\(value)"
        #expect(try redacted(url, with: redaction) == url)
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

// The spec's one wildcard rule: a letter, mark or number outside ASCII inside an ASCII word counts
// as nothing or as any one letter (`tͦken`, `passw〇rd`, `piꞏn`).
private let namesWithOneWildcard = [
    "t\u{0366}ken", "passw\u{3007}rd", "pi\u{A78F}n", "p\u{0251}ssword", "user_p\u{0131}n", "t\u{1040}ken", "p\u{0456}n",
]

@Suite("NameClassification")
struct NameClassificationTests {
    // Every check of a name asks namesSecret, so a name that cannot be read has to count as a
    // secret there: empty, only separators or symbols, a control character, anything outside
    // ASCII, or too long.
    @Test("counts a name it cannot read as a secret", arguments: namesWithOneWildcard + [
        "", "~", "!", "---", "_. -", "c++", "a,b", "order:12345", "to\u{7}ken", "pin\n", "\u{0}", "tab\tname", "\u{7F}x",
        "to\u{200D}ken", "to\u{00AD}ken", "\u{FF54}oken", "\u{24C5}in", "\u{1D429}in", "\u{015E}ifre", "\u{1F511}",
        String(repeating: "a", count: NameClassification.maximumNameLength + 1),
    ])
    func unreadableNames(name: String) {
        #expect(NameClassification.classify(name) == .unclear)
        #expect(NameClassification.classify(name).namesSecret)
    }

    @Test("counts plain ASCII names without a secret name as ordinary", arguments: [
        "page", "Sort", "user_id", "v2.1", "per-page", "a b", "ping", "keyboard",
        "cdn1.pinterest.com", "v2.keycdn.com", "s3.cardinal.io",
    ])
    func ordinaryNames(name: String) {
        #expect(!NameClassification.classify(name).namesSecret)
    }

    // The rule for a short secret name glued to a code ran on each word between separators, so a
    // short name split by a separator was not found: "pin4831" was hidden and "p.in4831" kept.
    @Test("hides a short secret name split by separators wherever a name is read", arguments: [
        "p.in4831", "pi-n4831", "p_i_n_4831", "p-in-4831", "p.i.n.4831", "4831.p.i.n", "o.t.p.4831",
        "k.e.y.4831", "c.v.v.123", "s.i.d.abc123", "p.w.d.hunter2", "ca.rd4831", "j-wt4831",
    ])
    func splitShortNames(name: String) throws {
        #expect(NameClassification.classify(name) == .containsSecret)
        let redaction = URLRedaction(allowedQueryParameters: ["q"])
        let commas = name.replacingOccurrences(of: ".", with: ",")
        #expect(try redacted("https://example.com/reset/\(name)/next") == "https://example.com/reset/:id/:id")
        #expect(try redacted("https://example.com/v1?q=\(name)", with: redaction) == "https://example.com/v1?q=<redacted>")
        #expect(try redacted("https://example.com/v1?q=\(commas)", with: redaction) == "https://example.com/v1?q=<redacted>")
        #expect(try redacted("myapp://\(name)/x") == "myapp:")
    }

    @Test("hides a name with one wildcard letter wherever a name is read", arguments: namesWithOneWildcard)
    func wildcardNames(name: String) throws {
        let encoded = try #require(name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))
        let redaction = URLRedaction(allowedQueryParameters: [name, "page"])
        #expect(redaction.allowedQueryParameters == ["page"])
        #expect(try redacted("https://example.com/v1/\(encoded)/hunter2/tail") == "https://example.com/v1/:id/:id/tail")
        #expect(try redacted("https://example.com/v1?\(encoded)=hunter2&page=2", with: redaction) == "https://example.com/v1?page=2")
        #expect(try redacted("https://example.com/v1?page=\(encoded)", with: redaction) == "https://example.com/v1?page=<redacted>")
        #expect(try redacted("myapp://\(encoded)/hunter2") == "myapp:")
    }
}
