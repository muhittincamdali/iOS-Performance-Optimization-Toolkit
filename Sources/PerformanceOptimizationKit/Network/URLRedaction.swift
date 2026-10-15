import Foundation

/// Removes the parts of a URL that commonly carry secrets or personal data before it is logged
/// or sent with a performance report.
///
/// The result keeps the scheme, host, port and path, which is what a timing report needs to
/// group requests. It drops the user name and password, the query, the fragment and path
/// parameters after `;` (such as `;jsessionid=`), and replaces path segments that look like
/// identifiers with `:id`, so
/// `https://user:secret@api.example.com/users/12345/avatar?token=abc` becomes
/// `https://api.example.com/users/:id/avatar`.
///
/// Percent-encoding does not hide these parts: a `;`, `?` or `#` encoded once or several times
/// (`%3B`, `%253F`) also ends a segment, and the checks below run on a segment after its
/// percent-encoding has been removed, up to four times over.
///
/// A segment looks like an identifier when it, or a part of it before, after or between
/// characters that cannot appear in a token (such as spaces, `:`, `,` or parentheses), is:
///
/// - a number, also with a leading `+` (such as the phone number `+905551234567`), a UUID, or
///   contains `@` (such as an e-mail address);
/// - 16 or more hexadecimal digits;
/// - a token of letters, digits and the Base64 symbols `-_=+.~/` that mixes letters and digits
///   and is 20 or more characters long, or 16 to 19 characters long with only letters and
///   digits and at least two separate groups of digits (such as `Ab3dEf5Gh7Jk9Lm1`);
/// - one of the above followed by a file extension of up to five letters, which is kept:
///   `12345.json` becomes `:id.json`.
///
/// A segment that is still percent-encoded after four rounds of decoding is replaced as well.
/// Other segments are kept, so a secret shorter than 16 characters, or one without digits, is
/// not recognized; don't put such values in a URL path.
public enum URLRedaction {
    /// The placeholder for path segments that look like identifiers.
    public static var identifierPlaceholder: String { ":id" }

    /// The longest result returned; longer paths are cut and end in `…`.
    public static var maximumLength: Int { 512 }

    /// The redacted form of `url`.
    ///
    /// URLs without a host, such as `data:` and `mailto:` URLs, carry their content in the rest
    /// of the URL; only their scheme is kept.
    public static func redact(_ url: URL) -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme?.lowercased(), Self.isPlainScheme(scheme) else {
            return "<redacted>"
        }
        guard let host = components.percentEncodedHost, !host.isEmpty else { return "\(scheme):" }
        var result = "\(scheme)://\(hostForDisplay(host))"
        if let port = components.port { result += ":\(port)" }
        result += redactedPath(components.percentEncodedPath)
        return truncated(result)
    }

    // Segments past `maximumLength` would be cut from the result, so they are not inspected;
    // a very long URL costs no more than one of about that length.
    static func redactedPath(_ encodedPath: String) -> String {
        guard !encodedPath.isEmpty else { return "" }
        var result = ""
        for (index, segment) in encodedPath.split(separator: "/", omittingEmptySubsequences: false).enumerated() {
            if index > 0 { result += "/" }
            result += redactedSegment(withoutParameters(String(segment)))
            if result.count > maximumLength { break }
        }
        return result
    }

    static func redactedSegment(_ encodedSegment: String) -> String {
        if looksLikeIdentifier(encodedSegment) { return identifierPlaceholder }
        // "12345.json": the extension says what the resource is and is kept. It is emitted from
        // the decoded form only when it is a few ASCII letters, so it cannot carry a line break.
        let segment = fullyDecoded(encodedSegment) ?? encodedSegment
        guard let dot = segment.lastIndex(of: "."), dot != segment.startIndex else { return encodedSegment }
        let fileExtension = segment[segment.index(after: dot)...]
        guard (1...5).contains(fileExtension.count),
              fileExtension.allSatisfy({ $0.isASCII && $0.isLetter }),
              looksLikeIdentifier(String(segment[..<dot])) else { return encodedSegment }
        return "\(identifierPlaceholder).\(fileExtension)"
    }

    // Path parameters (RFC 3986 allows ";" in a segment) often hold session identifiers, and a
    // "?" or "#" sent percent-encoded in a path starts what a server may read as a query or a
    // fragment. The segment stays percent-encoded, so the encoded forms (%3B, %3F, %23, and
    // %253B and so on when encoded again) end it as well; decoding the output instead would let
    // %0A put a line break into a log.
    static func withoutParameters(_ encodedSegment: String) -> String {
        let separator = #";|%(?:25)*(?:3[BbFf]|23)"#
        guard let range = encodedSegment.range(of: separator, options: .regularExpression) else { return encodedSegment }
        return String(encodedSegment[..<range.lowerBound])
    }

    // How many times percent-encoding is removed. A value encoded more often than this is not
    // inspected and is treated as an identifier.
    private static let maximumDecodingRounds = 4

    // The segment with its percent-encoding removed until nothing changes, or `nil` when it is
    // still encoded after `maximumDecodingRounds`.
    static func fullyDecoded(_ encodedSegment: String) -> String? {
        var segment = encodedSegment
        for _ in 0..<maximumDecodingRounds {
            guard segment.contains("%"), let decoded = segment.removingPercentEncoding, decoded != segment else {
                return segment
            }
            segment = decoded
        }
        let isStillEncoded = segment.contains("%") && segment.removingPercentEncoding.map { $0 != segment } == true
        return isStillEncoded ? nil : segment
    }

    static func looksLikeIdentifier(_ encodedSegment: String) -> Bool {
        guard let segment = fullyDecoded(encodedSegment) else { return true }
        guard !segment.isEmpty else { return false }
        if isIdentifier(segment) { return true }
        // "order:12345", "My Trip 2024" or "(12345)": an identifier next to other characters.
        let parts = segment.unicodeScalars.split { !tokenCharacters.contains($0) }
        return parts.contains { isIdentifier(String(String.UnicodeScalarView($0))) }
    }

    private static let tokenCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_=+.~/"))

    private static func isIdentifier(_ segment: String) -> Bool {
        if isNumber(segment) || segment.contains("@") { return true }
        if UUID(uuidString: segment) != nil { return true }
        if segment.count >= 16, segment.allSatisfy(\.isHexDigit) { return true }
        // Tokens: long runs of letters, digits and Base64 symbols that mix digits and letters.
        // The check runs on the decoded segment, where a "/" of standard Base64 sent as %2F
        // appears as itself.
        let isTokenLike = segment.unicodeScalars.allSatisfy { tokenCharacters.contains($0) }
        let hasDigit = segment.contains(where: \.isNumber)
        let hasLetter = segment.contains(where: \.isLetter)
        guard isTokenLike, hasDigit, hasLetter else { return false }
        if segment.count >= 20 { return true }
        // Shorter tokens are told apart from words such as "release2026" or "ipad-pro-12-9-2024"
        // by the digits scattered through them and the absence of separators.
        return segment.count >= 16 && segment.allSatisfy(\.isAlphanumericASCII) && digitGroupCount(segment) >= 2
    }

    // A leading "+" is part of the number: "+905551234567" is a phone number in E.164 form.
    private static func isNumber(_ segment: String) -> Bool {
        let digits = segment.hasPrefix("+") ? segment.dropFirst() : Substring(segment)
        return !digits.isEmpty && digits.allSatisfy(\.isNumber)
    }

    private static func digitGroupCount(_ segment: String) -> Int {
        var count = 0
        var previousWasDigit = false
        for character in segment {
            let isDigit = character.isNumber
            if isDigit && !previousWasDigit { count += 1 }
            previousWasDigit = isDigit
        }
        return count
    }

    private static func isPlainScheme(_ scheme: String) -> Bool {
        !scheme.isEmpty && scheme.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || "+-.".contains($0)) }
    }

    private static func hostForDisplay(_ host: String) -> String {
        guard host.contains(":"), !host.hasPrefix("[") else { return host.lowercased() }
        return "[\(host.lowercased())]"
    }

    private static func truncated(_ value: String) -> String {
        guard value.count > maximumLength else { return value }
        return String(value.prefix(maximumLength - 1)) + "…"
    }
}

private extension Character {
    var isAlphanumericASCII: Bool { isASCII && (isLetter || isNumber) }
}
