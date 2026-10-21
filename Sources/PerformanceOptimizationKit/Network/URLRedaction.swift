import Foundation

/// Removes the parts of a URL that can carry secrets or personal data before it is stored with a
/// performance report.
///
/// The rule is that anything the redaction does not fully understand is hidden. The result keeps
/// the scheme, the host, the port and the path, which is what a timing report needs to group
/// requests, so `https://user:secret@api.example.com/users/12345/avatar?token=abc#top` becomes
/// `https://api.example.com/users/:id/avatar`. In detail:
///
/// - **Always dropped:** the user name and password, the fragment, and the query. Only query
///   parameters named in ``allowedQueryParameters`` are kept, and none are by default.
/// - **Identifiers:** a path segment that is a number, a UUID, contains `@`, has a run of six or
///   more digits (also split by `-`, `_`, `.` or spaces), is a card number, an IBAN, a JSON Web
///   Token or a bearer token, has 16 or more hexadecimal digits, or is a token of 16 or more
///   characters that mixes letters and digits (32 or more in any mix) becomes `:id`.
///   `12345.json` becomes `:id.json`.
/// - **Secret names:** after a segment that names a secret, such as `token`, `password`, `pin` or
///   `api_key`, the next segment becomes `:id`: `/reset/token/abc` becomes `/reset/token/:id`.
///   A segment that contains such a name together with more, which can be the secret itself,
///   becomes `:id`, and so does the segment after it: `/reset/token-abc` and `/v/sessionabc`
///   become `/reset/:id` and `/v/:id`.
/// - **Names it cannot read:** a segment that is not plain ASCII letters, digits, `_`, `-`, `.`
///   and spaces after percent-decoding, such as `Şifre`, `c++` or a word with a look-alike letter
///   from another script, becomes `:id`, and so does the segment after it.
/// - **Host only:** when the path has a `.` or `..` segment, a `;`, a backslash or a double
///   percent-encoding, or encodes a `.`, `/`, `?`, `#` or control character; when the host names
///   a secret (`myapp://pin/4831`); when the path or the query is longer than the documented caps.
/// - **Scheme only:** when the host is not a plain DNS name or IP address (an IPv6 address with
///   a zone such as `%25en0` included), looks like an identifier itself, or has a label that
///   contains a secret name together with more, such as `myapp://pin-4831` or
///   `oauth2.example.com`. URLs without a host, such as `data:` and `mailto:` URLs, keep only
///   their scheme. A URL that does not parse becomes ``unparsedPlaceholder``.
///
/// Redaction is a safety net, not a guarantee: a secret that looks like an ordinary word in an
/// ordinary place of the path is not recognized. Keep secrets out of URLs; send them in headers
/// or bodies, which ``NetworkMetricsCollector`` never records.
public struct URLRedaction: Sendable, Equatable {
    /// The placeholder for path segments that look like identifiers.
    public static var identifierPlaceholder: String { ":id" }

    /// The placeholder for the value of an allowed query parameter that could hold a secret.
    public static var valuePlaceholder: String { "<redacted>" }

    /// The result for a URL that `URLComponents` cannot parse or that has no valid scheme.
    public static var unparsedPlaceholder: String { "<unparsed URL>" }

    /// The longest result returned; longer results are cut and end in `…`.
    public static var maximumLength: Int { 512 }

    /// The most path segments inspected. A longer path is recorded as scheme and host only.
    public static var maximumPathSegments: Int { 64 }

    /// The most query parameters inspected. A longer query makes the URL be recorded as scheme
    /// and host only.
    public static var maximumQueryParameters: Int { 64 }

    /// The longest percent-encoded path or query inspected, in bytes. A longer one makes the URL
    /// be recorded as scheme and host only.
    public static var maximumComponentBytes: Int { 4096 }

    /// The longest value of an allowed query parameter that is kept.
    public static var maximumQueryValueLength: Int { 64 }

    /// The redaction ``NetworkMetricsCollector`` uses unless it is given another one.
    public static let standard = URLRedaction()

    /// The query parameters whose values are kept, in their folded form: lowercase, without `_`,
    /// `-`, `.` and spaces.
    public let allowedQueryParameters: Set<String>

    /// A Boolean value that indicates whether only the scheme, host and port are recorded.
    public let recordsHostOnly: Bool

    /// Creates a redaction.
    ///
    /// - Parameters:
    ///   - allowedQueryParameters: Query parameters whose values are kept when they are short
    ///     and plain, such as `page` or `sort`. Names are compared case-insensitively and
    ///     without `_`, `-`, `.` and spaces. Names of secrets (such as `token`) and names that
    ///     are not plain ASCII are ignored.
    ///   - recordsHostOnly: Records only the scheme, host and port of every URL.
    public init(allowedQueryParameters: some Sequence<String> = [String](), recordsHostOnly: Bool = false) {
        var allowed = Set<String>()
        for name in allowedQueryParameters {
            if case .ordinary(let folded) = NameClassification.classify(name) { allowed.insert(folded) }
        }
        self.allowedQueryParameters = allowed
        self.recordsHostOnly = recordsHostOnly
    }

    /// The redacted form of `url`, using ``standard``.
    public static func redact(_ url: URL) -> String {
        standard.redact(url)
    }

    /// The redacted form of `url`.
    public func redact(_ url: URL) -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme.flatMap(Self.normalizedScheme) else {
            return Self.unparsedPlaceholder
        }
        guard let encodedHost = components.percentEncodedHost, !encodedHost.isEmpty,
              let host = HostClassification.classify(encodedHost) else {
            return "\(scheme):"
        }
        let origin = "\(scheme)://\(host.text)"
        guard !host.namesSecret else { return origin }
        var authority = origin
        if let port = components.port, (0...65_535).contains(port) { authority += ":\(port)" }
        guard !recordsHostOnly else { return authority }
        let query = redactedQuery(components.percentEncodedQuery)
        guard let path = Self.redactedPath(components.percentEncodedPath), let query else { return origin }
        return Self.truncated(authority + path + query)
    }

    private static func normalizedScheme(_ scheme: String) -> String? {
        let lowercased = scheme.lowercased()
        let isPlain = (1...32).contains(lowercased.utf8.count) && lowercased.utf8.allSatisfy { byte in
            (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(byte) || (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
                || byte == UInt8(ascii: "+") || byte == UInt8(ascii: "-") || byte == UInt8(ascii: ".")
        }
        return isPlain ? lowercased : nil
    }

    private static func truncated(_ value: String) -> String {
        guard value.count > maximumLength else { return value }
        return String(value.prefix(maximumLength - 1)) + "…"
    }
}

// MARK: - Path

extension URLRedaction {
    /// The redacted path, or `nil` when the URL is to be recorded as scheme and host only.
    static func redactedPath(_ encodedPath: String) -> String? {
        guard !encodedPath.isEmpty else { return "" }
        guard encodedPath.utf8.count <= maximumComponentBytes,
              encodedPath.utf8.count(where: { $0 == UInt8(ascii: "/") }) <= maximumPathSegments,
              PercentEncoding.isUnambiguous(encodedPath, forbidding: pathDelimiters) else { return nil }
        var segments: [String] = []
        var afterLabel = false
        for segment in encodedPath.split(separator: "/", omittingEmptySubsequences: false) {
            if segment == "." || segment == ".." { return nil }
            let redacted = redactedSegment(segment, afterLabel: afterLabel)
            segments.append(redacted.text)
            afterLabel = redacted.hidesNext
        }
        return segments.joined(separator: "/")
    }

    // Path parameters after ";" are parsed differently by different servers, and dot segments
    // are resolved by some (RFC 3986, section 5.2.4) and not by others. Rather than guess, such
    // a path is not recorded.
    private static let pathDelimiters: Set<UInt8> = [
        UInt8(ascii: ";"), UInt8(ascii: "\\"), UInt8(ascii: "."), UInt8(ascii: "/"),
        UInt8(ascii: "?"), UInt8(ascii: "#"), UInt8(ascii: "%"),
    ]

    private static func redactedSegment(_ encoded: Substring, afterLabel: Bool) -> (text: String, hidesNext: Bool) {
        // An empty segment ("//") passes a pending label on to the next segment.
        guard !encoded.isEmpty else { return ("", afterLabel) }
        guard let decoded = encoded.removingPercentEncoding else { return (identifierPlaceholder, true) }
        let kind = NameClassification.classify(decoded)
        if afterLabel { return (identifierPlaceholder, !kind.isOrdinary) }
        if IdentifierDetection.isIdentifier(decoded) { return (identifierPlaceholder, false) }
        if let file = FileName(decoded), IdentifierDetection.isIdentifier(file.name) {
            return ("\(identifierPlaceholder).\(file.fileExtension)", false)
        }
        switch kind {
        case .ordinary: return (String(encoded), false)
        case .listedSecret: return (String(encoded), true)
        // "token-hunter22" or "passwordhunter2": the name and its value in one segment.
        case .containsSecret, .unclear: return (identifierPlaceholder, true)
        }
    }
}

// "12345.json": the name and an extension of one to five ASCII letters.
private struct FileName {
    let name: String
    let fileExtension: String

    init?(_ segment: String) {
        let scalars = Array(segment.unicodeScalars)
        guard let dot = scalars.lastIndex(of: "."), dot > 0 else { return nil }
        let fileExtension = scalars[(dot + 1)...]
        guard (1...5).contains(fileExtension.count),
              fileExtension.allSatisfy({ ("a"..."z").contains($0) || ("A"..."Z").contains($0) }) else { return nil }
        name = String(String.UnicodeScalarView(scalars[..<dot]))
        self.fileExtension = String(String.UnicodeScalarView(fileExtension))
    }
}

private extension NameClassification.Kind {
    var isOrdinary: Bool {
        if case .ordinary = self { return true }
        return false
    }
}

// MARK: - Query

extension URLRedaction {
    /// The kept part of the query, starting with `?`, an empty string when nothing is kept, or
    /// `nil` when the URL is to be recorded as scheme and host only.
    func redactedQuery(_ encodedQuery: String?) -> String? {
        guard let encodedQuery, !encodedQuery.isEmpty else { return "" }
        guard encodedQuery.utf8.count <= Self.maximumComponentBytes,
              encodedQuery.utf8.count(where: { $0 == UInt8(ascii: "&") }) < Self.maximumQueryParameters else { return nil }
        guard !allowedQueryParameters.isEmpty,
              PercentEncoding.isUnambiguous(encodedQuery, forbidding: Self.queryDelimiters) else { return "" }
        var kept: [String] = []
        var spellings: [String: Substring] = [:]
        for item in encodedQuery.split(separator: "&") {
            let parts = item.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            let encodedName = parts[0]
            guard let name = encodedName.removingPercentEncoding,
                  case .ordinary(let folded) = NameClassification.classify(name),
                  allowedQueryParameters.contains(folded) else { continue }
            // "page" and "Page" or "pa%67e": servers differ in which one they read.
            if let spelling = spellings[folded], spelling != encodedName { return "" }
            spellings[folded] = encodedName
            let displayName = name.replacingOccurrences(of: " ", with: "%20")
            guard parts.count == 2 else {
                kept.append(displayName)
                continue
            }
            kept.append("\(displayName)=\(Self.displayedQueryValue(parts[1]))")
        }
        return kept.isEmpty ? "" : "?" + kept.joined(separator: "&")
    }

    // A ";" splits parameters on some servers and not on others.
    private static let queryDelimiters: Set<UInt8> = [UInt8(ascii: ";"), UInt8(ascii: "%")]

    // A value is free text: it is kept only when it has no character that could start a secret
    // or a nested structure, is short, is not an identifier and does not name a secret.
    private static func displayedQueryValue(_ encodedValue: Substring) -> String {
        guard let value = encodedValue.removingPercentEncoding else { return valuePlaceholder }
        let isPlain = value.unicodeScalars.count <= maximumQueryValueLength && value.unicodeScalars.allSatisfy { scalar in
            ("a"..."z").contains(scalar) || ("A"..."Z").contains(scalar) || ("0"..."9").contains(scalar)
                || scalar == "-" || scalar == "_" || scalar == "." || scalar == ","
        }
        guard isPlain else { return valuePlaceholder }
        // A short number such as a page is kept; in a path it would be an identifier.
        let isShortNumber = value.utf8.count < IdentifierDetection.minimumDigitRun
            && value.utf8.allSatisfy { (UInt8(ascii: "0")...UInt8(ascii: "9")).contains($0) }
        guard isShortNumber || !IdentifierDetection.isIdentifier(value), !NameClassification.classify(value).namesSecret else {
            return valuePlaceholder
        }
        return value
    }
}

// MARK: - Percent-encoding

enum PercentEncoding {
    /// A Boolean value that indicates whether `encoded` has only well-formed percent-encodings,
    /// none of which encodes a control character or a byte in `forbidden`, and no raw byte in
    /// `forbidden` other than `.` and `/`, which are only forbidden in encoded form.
    static func isUnambiguous(_ encoded: String, forbidding forbidden: Set<UInt8>) -> Bool {
        let bytes = Array(encoded.utf8)
        var index = 0
        while index < bytes.count {
            let byte = bytes[index]
            if byte < 0x20 || byte == 0x7F { return false }
            if byte == UInt8(ascii: "%") {
                guard index + 2 < bytes.count, let high = hexValue(bytes[index + 1]), let low = hexValue(bytes[index + 2]) else {
                    return false
                }
                let decoded = high << 4 | low
                if decoded < 0x20 || decoded == 0x7F || forbidden.contains(decoded) { return false }
                index += 3
                continue
            }
            if byte != UInt8(ascii: ".") && byte != UInt8(ascii: "/") && forbidden.contains(byte) { return false }
            index += 1
        }
        return true
    }

    private static func hexValue(_ byte: UInt8) -> UInt8? {
        switch byte {
        case UInt8(ascii: "0")...UInt8(ascii: "9"): byte - UInt8(ascii: "0")
        case UInt8(ascii: "a")...UInt8(ascii: "f"): byte - UInt8(ascii: "a") + 10
        case UInt8(ascii: "A")...UInt8(ascii: "F"): byte - UInt8(ascii: "A") + 10
        default: nil
        }
    }
}
