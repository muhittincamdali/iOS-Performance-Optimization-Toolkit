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
/// A segment, after its percent-encoding is removed, looks like an identifier when it is:
///
/// - a number, a UUID or contains `@` (such as an e-mail address);
/// - 16 or more hexadecimal digits;
/// - a token of letters, digits and the Base64 symbols `-_=+.~/` that mixes letters and digits
///   and is 20 or more characters long, or 16 to 19 characters long with only letters and
///   digits and at least two separate groups of digits (such as `Ab3dEf5Gh7Jk9Lm1`);
/// - one of the above followed by a file extension of up to five letters, which is kept:
///   `12345.json` becomes `:id.json`.
///
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

    static func redactedPath(_ encodedPath: String) -> String {
        guard !encodedPath.isEmpty else { return "" }
        let segments = encodedPath.split(separator: "/", omittingEmptySubsequences: false).map { segment in
            redactedSegment(withoutParameters(String(segment)))
        }
        return segments.joined(separator: "/")
    }

    static func redactedSegment(_ encodedSegment: String) -> String {
        if looksLikeIdentifier(encodedSegment) { return identifierPlaceholder }
        // "12345.json": the extension says what the resource is and is kept. It is emitted from
        // the decoded form only when it is a few ASCII letters, so it cannot carry a line break.
        let segment = encodedSegment.removingPercentEncoding ?? encodedSegment
        guard let dot = segment.lastIndex(of: "."), dot != segment.startIndex else { return encodedSegment }
        let fileExtension = segment[segment.index(after: dot)...]
        guard (1...5).contains(fileExtension.count),
              fileExtension.allSatisfy({ $0.isASCII && $0.isLetter }),
              looksLikeIdentifier(String(segment[..<dot])) else { return encodedSegment }
        return "\(identifierPlaceholder).\(fileExtension)"
    }

    // Path parameters (RFC 3986 allows ";" in a segment) often hold session identifiers. The
    // segment stays percent-encoded, so an encoded ";" (%3B) ends the name as well; decoding
    // the output instead would let %0A put a line break into a log.
    static func withoutParameters(_ encodedSegment: String) -> String {
        guard let range = encodedSegment.range(of: #";|%3[Bb]"#, options: .regularExpression) else { return encodedSegment }
        return String(encodedSegment[..<range.lowerBound])
    }

    static func looksLikeIdentifier(_ encodedSegment: String) -> Bool {
        let segment = encodedSegment.removingPercentEncoding ?? encodedSegment
        guard !segment.isEmpty else { return false }
        if segment.allSatisfy(\.isNumber) || segment.contains("@") { return true }
        if UUID(uuidString: segment) != nil { return true }
        if segment.count >= 16, segment.allSatisfy(\.isHexDigit) { return true }
        // Tokens: long runs of letters, digits and Base64 symbols that mix digits and letters.
        // The check runs on the decoded segment, where a "/" of standard Base64 sent as %2F
        // appears as itself.
        let tokenCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_=+.~/"))
        let isTokenLike = segment.unicodeScalars.allSatisfy { tokenCharacters.contains($0) }
        let hasDigit = segment.contains(where: \.isNumber)
        let hasLetter = segment.contains(where: \.isLetter)
        guard isTokenLike, hasDigit, hasLetter else { return false }
        if segment.count >= 20 { return true }
        // Shorter tokens are told apart from words such as "release2026" or "ipad-pro-12-9-2024"
        // by the digits scattered through them and the absence of separators.
        return segment.count >= 16 && segment.allSatisfy(\.isAlphanumericASCII) && digitGroupCount(segment) >= 2
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
