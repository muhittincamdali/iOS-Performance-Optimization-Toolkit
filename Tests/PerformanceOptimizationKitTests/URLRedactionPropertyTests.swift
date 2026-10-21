import Foundation
import Testing
@testable import PerformanceOptimizationKit

// A small seeded generator (SplitMix64), so every run checks the same secrets.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        return value ^ (value >> 31)
    }
}

private let secretNames = [
    "password", "passwd", "pwd", "secret", "token", "access_token", "refresh_token", "id_token", "api_key", "apikey",
    "key", "auth", "authorization", "cookie", "set-cookie", "session", "sid", "otp", "pin", "cvv", "card", "iban",
    "ssn", "private_key", "client_secret", "signature",
]

// Percent-encoded UTF-8 of a string, as it appears in a URL.
private func encoded(_ text: String) -> String {
    text.utf8.map { String(format: "%%%02X", $0) }.joined()
}

// Ways of writing a name that a person or an attacker could use to get it past the redaction.
private func obfuscations(of name: String) -> [String] {
    let first = String(name.prefix(1))
    let rest = String(name.dropFirst())
    let middle = name.index(name.startIndex, offsetBy: name.count / 2)
    let lookAlikes: [Character: String] = ["a": "а", "e": "е", "o": "о", "p": "р", "c": "с", "i": "і", "s": "ѕ"]
    let swapped = name.map { lookAlikes[$0].map(encoded) ?? String($0) }.joined()
    let fullWidth = String(String.UnicodeScalarView(name.unicodeScalars.compactMap {
        ("a"..."z").contains($0) ? Unicode.Scalar($0.value + 0xFEE0) : $0
    }))
    return [
        name, name.uppercased(), name.capitalized, name + "s",
        String(name[..<middle]) + "_" + String(name[middle...]),
        String(name[..<middle]) + "-" + String(name[middle...]),
        String(name[..<middle]) + "." + String(name[middle...]),
        String(name[..<middle]) + "%20" + String(name[middle...]),
        encoded(first) + rest, "%25" + encoded(first).dropFirst() + rest,
        swapped, encoded(fullWidth),
        first + encoded("\u{200D}") + rest, first + encoded("\u{00AD}") + rest, first + encoded("\u{0301}") + rest,
        encoded("\u{2028}") + name,
    ]
}

// Names short enough to be part of ordinary words ("ping", "keyboard") are recognized without a
// separator only when their value has a digit ("pin4831"); a value of letters only reads as a word.
private let shortSecretNames: Set<String> = ["pwd", "key", "sid", "otp", "pin", "cvv", "card", "iban", "ssn"]

// A secret name and its value written as one segment, such as "token-hunter22".
private func gluedSpellings(of name: String, secret: String) -> [String] {
    var spellings: [String] = []
    for separator in ["_", "-", ".", "%20"] {
        let prefixes = [name, name.uppercased(), name + "s"]
        spellings += prefixes.map { $0 + separator + secret }
        spellings.append(secret + separator + name)
    }
    return spellings + [name + secret, name.capitalized + secret, secret + name]
}

@Suite("URLRedaction properties")
struct URLRedactionPropertyTests {
    @Test("no generated secret survives next to any spelling of a secret name")
    func secretsNeverSurvive() throws {
        var generator = SeededGenerator(state: 0x5EC2_E7)
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        let alphanumerics = letters + Array("0123456789")
        let redaction = URLRedaction(allowedQueryParameters: ["page"])
        var checked = 0
        for name in secretNames {
            for spelling in obfuscations(of: name) {
                let alphabet = Bool.random(using: &generator) ? letters : alphanumerics
                let secret = String((0..<Int.random(in: 8...16, using: &generator)).map { _ in alphabet.randomElement(using: &generator)! })
                let urls = [
                    "https://example.com/v1/\(spelling)/\(secret)/tail",
                    "https://example.com/v1/\(spelling)//\(secret)",
                    "https://example.com/v1/items?\(spelling)=\(secret)&page=2",
                    "https://example.com/v1/items?page=2&\(spelling)=\(secret)",
                    "https://\(secret):\(secret)@example.com/v1#\(spelling)=\(secret)",
                    "myapp://\(spelling)/\(secret)",
                ]
                for string in urls {
                    guard let url = URL(string: string) else { continue }
                    let result = redaction.redact(url)
                    #expect(!result.lowercased().contains(secret), "\(string) became \(result)")
                    #expect(!result.contains("\n") && !result.contains("\r"))
                    checked += 1
                }
            }
            var secret = String((0..<Int.random(in: 8...16, using: &generator)).map { _ in alphanumerics.randomElement(using: &generator)! })
            if shortSecretNames.contains(name), !secret.contains(where: \.isNumber) {
                secret = String(secret.dropLast()) + String(Int.random(in: 0...9, using: &generator))
            }
            for glued in gluedSpellings(of: name, secret: secret) {
                var urls = [
                    "https://example.com/v1/\(glued)",
                    "https://example.com/v1/\(glued)/tail",
                    "https://example.com/v1/items?page=\(glued)",
                ]
                // In a host, "." separates labels, and a label that is a secret name keeps the
                // host as it is ("token.example.com").
                if !glued.contains(".") {
                    urls += ["myapp://\(glued)/tail", "https://\(glued).example.com/tail"]
                }
                for string in urls {
                    guard let url = URL(string: string) else { continue }
                    let result = redaction.redact(url)
                    #expect(!result.lowercased().contains(secret), "\(string) became \(result)")
                    checked += 1
                }
            }
        }
        #expect(checked > 3_000)
    }
}

// Redaction runs on URLs the app does not control, so it must stay fast and must not need a deep
// stack. The cases below are each about 1 MB.
private let largeInputs: [(name: String, url: String, expected: String)] = {
    let megabyte = 1 << 20
    let manySegments = Array(repeating: "ab", count: megabyte / 3).joined(separator: "/")
    let manyParameters = (0..<(megabyte / 8)).map { "p\($0)=1" }.joined(separator: "&")
    let emptySegments = String(repeating: "/", count: megabyte)
    let encodedText = String(repeating: "%41", count: megabyte / 3)
    return [
        ("many segments", "https://example.com/\(manySegments)", "https://example.com"),
        ("one long segment", "https://example.com/" + String(repeating: "a", count: megabyte), "https://example.com"),
        ("many parameters", "https://example.com/a?\(manyParameters)", "https://example.com"),
        ("empty segments", "https://example.com\(emptySegments)", "https://example.com"),
        ("encoded text", "https://example.com/\(encodedText)", "https://example.com"),
        ("long host", "https://" + String(repeating: "a.", count: megabyte / 2) + "com/x", "https:"),
    ]
}()

extension TimingSensitiveTests {
    @Suite("URLRedaction limits")
    struct URLRedactionLimitTests {
        @Test("redacts 1 MB URLs in under a second each")
        func speed() throws {
            for input in largeInputs {
                let url = try #require(URL(string: input.url), "\(input.name)")
                let clock = ContinuousClock()
                var result = ""
                let elapsed = clock.measure { result = URLRedaction.standard.redact(url) }
                #expect(result == input.expected, "\(input.name)")
                #expect(elapsed < .seconds(1), "\(input.name) took \(elapsed)")
            }
        }

        @Test("runs on a thread with a 512 KiB stack")
        func smallStack() async throws {
            let urls = try largeInputs.map { try #require(URL(string: $0.url)) }
            let results: [String] = await withCheckedContinuation { continuation in
                let thread = Thread {
                    continuation.resume(returning: urls.map(URLRedaction.standard.redact))
                }
                thread.stackSize = 512 * 1024
                thread.start()
            }
            #expect(results == largeInputs.map(\.expected))
        }
    }
}
