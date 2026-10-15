import Foundation

/// Removes the parts of a URL that commonly carry secrets or personal data before it is logged
/// or sent with a performance report.
///
/// The result keeps the scheme, host, port and path, which is what a timing report needs to
/// group requests. It drops the user name and password, the query, the fragment and path
/// parameters after `;` (such as `;jsessionid=`), and replaces path segments that look like
/// identifiers (numbers, UUIDs, e-mail addresses, long hexadecimal or Base64 strings) with
/// `:id`, so
/// `https://user:secret@api.example.com/users/12345/avatar?token=abc` becomes
/// `https://api.example.com/users/:id/avatar`.
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
        let segments = encodedPath.split(separator: "/", omittingEmptySubsequences: false).map { segment -> String in
            let name = withoutParameters(String(segment))
            return looksLikeIdentifier(name) ? identifierPlaceholder : name
        }
        return segments.joined(separator: "/")
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
        return segment.count >= 20 && isTokenLike && hasDigit && hasLetter
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
