// The one decision, shared by URL hosts, path segments and query parameter names, of whether a
// name is ordinary, names a secret, or cannot be understood. Anything that is not understood
// counts as a secret: the value that belongs to it is hidden.
enum NameClassification {
    enum Kind: Equatable {
        /// A plain ASCII name that is not a secret, in its folded form (lowercase, without
        /// `_`, `-`, `.` and spaces), which is the form allowlists are compared in.
        case ordinary(String)
        /// A plain ASCII name on the list of secret names, such as `token` or `api_key`.
        case listedSecret
        /// A name that is not plain ASCII, contains other symbols or control characters, or has
        /// no letter or digit at all.
        case unclear
    }

    // Longer names are not compared; they count as unclear.
    static let maximumNameLength = 256

    /// Classifies a name that has already been percent-decoded.
    ///
    /// Folding removes case and the separators `_`, `-`, `.` and space. Normalization to NFKC is
    /// not needed: it only turns non-ASCII characters into ASCII ones, and any non-ASCII scalar
    /// already makes a name unclear. So do format characters such as a zero-width joiner, look-
    /// alike letters from other scripts, full-width letters and combining marks.
    static func classify(_ name: some StringProtocol) -> Kind {
        var folded: [UInt8] = []
        for byte in name.utf8 {
            switch byte {
            case UInt8(ascii: "A")...UInt8(ascii: "Z"):
                folded.append(byte + 32)
            case UInt8(ascii: "a")...UInt8(ascii: "z"), UInt8(ascii: "0")...UInt8(ascii: "9"):
                folded.append(byte)
            case UInt8(ascii: "_"), UInt8(ascii: "-"), UInt8(ascii: "."), UInt8(ascii: " "):
                continue
            default:
                return .unclear
            }
            if folded.count > maximumNameLength { return .unclear }
        }
        guard !folded.isEmpty else { return .unclear }
        let foldedName = String(decoding: folded, as: UTF8.self)
        return isSecretName(foldedName) ? .listedSecret : .ordinary(foldedName)
    }

    /// The folded names of secrets: the shared list of the redaction rules plus `bearer`, `jwt`,
    /// `passcode`, `passphrase`, `credential`, `csrf`, `xsrf`, `totp` and `sig`.
    static let secretNames: Set<String> = [
        "password", "passwd", "pwd", "secret", "token", "accesstoken", "refreshtoken", "idtoken",
        "apikey", "key", "auth", "authorization", "cookie", "setcookie", "session", "sid", "otp",
        "pin", "cvv", "card", "iban", "ssn", "privatekey", "clientsecret", "signature",
        "bearer", "jwt", "passcode", "passphrase", "credential", "csrf", "xsrf", "totp", "sig",
    ]

    /// Parts that make any name that contains them a secret, such as `resettoken` or
    /// `sessionid`. `auth` also matches `author` and `oauth`; hiding too much is intended.
    static let secretNameParts = [
        "password", "passwd", "passphrase", "passcode", "secret", "token", "apikey", "auth",
        "session", "signature", "cookie", "credential", "bearer", "privatekey",
    ]

    static func isSecretName(_ folded: String) -> Bool {
        if secretNames.contains(folded) { return true }
        if folded.hasSuffix("s"), secretNames.contains(String(folded.dropLast())) { return true }
        return secretNameParts.contains { folded.contains($0) }
    }
}
