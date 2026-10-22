import Foundation

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
    private static let queryDelimiters: ByteSet = [UInt8(ascii: ";"), UInt8(ascii: "%")]

    // A value is free text: it is kept only when it has no character that could start a secret
    // or a nested structure, is short, and is plain words or short numbers. A comma makes a value
    // unreadable as one name, so the whole value is read with its commas as spaces, which finds
    // a secret name or a number split by commas ("pass,word", "4111,1111,1111,1111"), and each
    // part between commas is checked for an identifier ("name,deadbeefcafebabe"). The value is
    // classified once, as a whole: the words of its parts are its words.
    private static func displayedQueryValue(_ encodedValue: Substring) -> String {
        guard let value = encodedValue.removingPercentEncoding else { return valuePlaceholder }
        guard !value.isEmpty else { return value }
        let isPlain = value.unicodeScalars.count <= maximumQueryValueLength && value.unicodeScalars.allSatisfy { scalar in
            ("a"..."z").contains(scalar) || ("A"..."Z").contains(scalar) || ("0"..."9").contains(scalar)
                || scalar == "-" || scalar == "_" || scalar == "." || scalar == ","
        }
        guard isPlain else { return valuePlaceholder }
        // The value is ASCII here, so it is split and its commas are read as spaces byte by byte.
        let whole = String(decoding: value.utf8.map { $0 == UInt8(ascii: ",") ? UInt8(ascii: " ") : $0 }, as: UTF8.self)
        let parts = value.utf8.split(separator: UInt8(ascii: ",")).lazy.map { String(decoding: $0, as: UTF8.self) }
        guard isPlainWordOrShortNumber(whole),
              parts.allSatisfy({ isShortNumber($0) || !IdentifierDetection.isIdentifier($0) }) else { return valuePlaceholder }
        return value
    }

    // A short number such as a page is kept; in a path it would be an identifier. Anything else
    // has to be a name that is not an identifier and does not count as a secret: a name that
    // holds a secret name, and one that cannot be read as a name, is hidden.
    private static func isPlainWordOrShortNumber(_ text: String) -> Bool {
        if isShortNumber(text) { return true }
        return !IdentifierDetection.isIdentifier(text) && !NameClassification.classify(text).namesSecret
    }

    private static func isShortNumber(_ text: some StringProtocol) -> Bool {
        !text.isEmpty && text.utf8.count < IdentifierDetection.minimumDigitRun
            && text.utf8.allSatisfy { (UInt8(ascii: "0")...UInt8(ascii: "9")).contains($0) }
    }
}
