import Foundation

// Decides how the host of a URL is recorded. Only plain DNS names and IP addresses are shown;
// anything else, such as a percent-encoded or non-ASCII host, is not understood and is hidden.
enum HostClassification {
    struct Host: Equatable {
        /// The host as it is recorded: lowercase, IPv6 addresses in brackets.
        let text: String
        /// A Boolean value that indicates whether a label of the host names a secret, as `pin`
        /// does in `myapp://pin/4831`, so the rest of the URL is its value.
        let namesSecret: Bool
    }

    // RFC 1035: at most 253 characters in labels of 1 to 63.
    private static let maximumHostLength = 253
    private static let maximumLabelLength = 63

    /// The host to record, or `nil` when only the scheme may be recorded.
    static func classify(_ encodedHost: String) -> Host? {
        guard encodedHost.utf8.count <= maximumHostLength + 2 else { return nil }
        // inet_pton accepts an IPv6 zone ("fe80::1%25en0"), whose text can be anything.
        guard !encodedHost.utf8.contains(UInt8(ascii: "%")) else { return nil }
        let unbracketed = encodedHost.hasPrefix("[") && encodedHost.hasSuffix("]")
            ? String(encodedHost.dropFirst().dropLast())
            : encodedHost
        if isIPAddress(unbracketed, family: AF_INET6) { return Host(text: "[\(unbracketed.lowercased())]", namesSecret: false) }
        if isIPAddress(unbracketed, family: AF_INET) { return Host(text: unbracketed, namesSecret: false) }
        let host = encodedHost.lowercased()
        guard host.utf8.count <= maximumHostLength else { return nil }
        let labels = host.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.allSatisfy(isDNSLabel) else { return nil }
        // A label such as "a1b2c3d4e5f6a7b8" or "1234567" names a tenant or a user.
        guard !labels.contains(where: { IdentifierDetection.isIdentifier(String($0)) }) else { return nil }
        // "pin-4831" or "tokenhunter22": a label that holds a secret name and more can hold the
        // secret, so the host is not recorded.
        let labelKinds = labels.map { NameClassification.classify($0) }
        guard !labelKinds.contains(.containsSecret) else { return nil }
        // "pass.word" folds to "password": the host as a whole is classified as well as each
        // label. A secret name that runs across labels ("pass.wordhunter2") hides the host too.
        let labelNamesSecret = labelKinds.contains(.listedSecret)
        let hostKind = NameClassification.classify(host)
        guard hostKind != .containsSecret || labelNamesSecret else { return nil }
        return Host(text: host, namesSecret: labelNamesSecret || hostKind == .listedSecret)
    }

    // Letters, digits and hyphens, not starting or ending with a hyphen.
    private static func isDNSLabel(_ label: Substring) -> Bool {
        guard (1...maximumLabelLength).contains(label.utf8.count),
              label.utf8.first != UInt8(ascii: "-"), label.utf8.last != UInt8(ascii: "-") else { return false }
        return label.utf8.allSatisfy { byte in
            (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(byte) || (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
                || byte == UInt8(ascii: "-")
        }
    }

    private static func isIPAddress(_ text: String, family: Int32) -> Bool {
        var buffer = [UInt8](repeating: 0, count: 16)
        return text.withCString { inet_pton(family, $0, &buffer) } == 1
    }
}
