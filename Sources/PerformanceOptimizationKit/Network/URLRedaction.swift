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
///   `12345.json` becomes `:id.json`. An identifier also hides the next segment by the rules
///   below, when it holds a secret name or is not a plain name: `/v/token123456/x`,
///   `/v/4831.pin/x`, `/v/t@ken/x`, `/v/p!n123456/x` and `/u/张伟@example.cn/x` become
///   `/v/:id/:id`, `/v/:id.pin/:id`, `/v/:id/:id`, `/v/:id/:id` and `/u/:id/:id`. Only an e-mail
///   address of plain names and a number keep it: `/u/jane@example.org/x` and
///   `/u/+905551234567/x` become `/u/:id/x`.
/// - **Secret names:** after a segment that names a secret, such as `token`, `password`, `pin` or
///   `api_key`, the next segment becomes `:id`: `/reset/token/abc` becomes `/reset/token/:id`.
///   A segment that contains such a name together with more, which can be the secret itself,
///   becomes `:id`, and so does the segment after it: `/reset/token-abc` and `/v/sessionabc`
///   become `/reset/:id` and `/v/:id`.
/// - **Names it cannot read:** a segment that is not plain ASCII letters, digits, `_`, `-`, `.`
///   and spaces after percent-decoding, such as `Şifre`, `c++` or a word with a look-alike letter
///   from another script, becomes `:id`, and so does the segment after it, also when it is an
///   identifier. Only an e-mail address whose parts are plain names without a secret name and a
///   number written with `+`, spaces, `.` or `-` keep the next segment.
/// - **Host only:** when the path has a `.` or `..` segment, a `;`, a backslash or a double
///   percent-encoding, or encodes a `.`, `/`, `?`, `#` or control character; when the host names
///   a secret (`myapp://pin/4831`); when the path or the query is longer than the documented caps.
/// - **Scheme only:** when the host is not a plain DNS name or IP address (an IPv6 address with
///   a zone such as `%25en0` included), has a label that looks like an identifier, or holds a
///   secret name together with more, also in another label, such as `myapp://pin-4831`,
///   `myapp://pin.ab12cd`, `token.example.com` or `oauth2.example.com`. URLs without a host,
///   such as `data:` and `mailto:` URLs, keep only their scheme. A URL that does not parse
///   becomes ``unparsedPlaceholder``.
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
        if afterLabel { return (identifierPlaceholder, kind.namesSecret) }
        if IdentifierDetection.isIdentifier(decoded) { return (identifierPlaceholder, isLabel(identifier: decoded, kind: kind)) }
        if let file = FileName(decoded), IdentifierDetection.isIdentifier(file.name) {
            return ("\(identifierPlaceholder).\(file.fileExtension)", isLabel(identifier: decoded, kind: kind))
        }
        switch kind {
        case .ordinary: return (String(encoded), false)
        case .listedSecret: return (String(encoded), true)
        // "token-hunter22" or "passwordhunter2": the name and its value in one segment.
        case .containsSecret, .unclear: return (identifierPlaceholder, true)
        }
    }

    // An identifier is a label by the rule for any other segment, read from the same
    // classification: unless it is a plain name without a secret name, it may be one in
    // disguise ("token123456", "4831.pin", "t@ken", "p!n123456", "张伟@example.cn"). Reading its
    // symbols as separators made "t@ken" an ordinary name while "t!ken" was a label. The only
    // symbols that do not make a label are those of the two identifiers that need them: an
    // e-mail address of plain names ("jane.doe@example.org") and a number ("+905551234567").
    private static func isLabel(identifier decoded: String, kind: NameClassification.Kind) -> Bool {
        guard kind.namesSecret else { return false }
        return !isEmailAddress(decoded) && !isNumber(decoded)
    }

    // "jane.doe@example.org": a local part, one "@" and a domain of two or more labels that
    // ends in letters. The whole address is read as one name with its "@" as a separator, so it
    // has to be plain ASCII and a secret name split by the "@" or a "." is found ("to@ken.com").
    private static func isEmailAddress(_ decoded: String) -> Bool {
        let parts = decoded.utf8.split(separator: UInt8(ascii: "@"), omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        let labels = parts[1].split(separator: UInt8(ascii: "."), omittingEmptySubsequences: false)
        guard labels.count >= 2, labels.allSatisfy({ !$0.isEmpty }),
              let topLevel = labels.last, topLevel.allSatisfy(isASCIILetter) else { return false }
        let name = String(decoding: parts[0], as: UTF8.self) + "." + String(decoding: parts[1], as: UTF8.self)
        return !NameClassification.classify(name).namesSecret
    }

    // "+905551234567", "+90 555 123 45 67" or "123-45-6789": digits, "+", spaces, "." and "-",
    // which spell no name.
    private static func isNumber(_ decoded: String) -> Bool {
        decoded.utf8.allSatisfy { byte in
            (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte) || byte == UInt8(ascii: "+")
                || byte == UInt8(ascii: " ") || byte == UInt8(ascii: ".") || byte == UInt8(ascii: "-")
        }
    }

    private static func isASCIILetter(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(byte) || (UInt8(ascii: "A")...UInt8(ascii: "Z")).contains(byte)
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
