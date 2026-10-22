// The one decision, shared by URL hosts, path segments, query parameter names and query values,
// of whether a name is ordinary, names a secret, or cannot be understood. Anything that is not
// understood counts as a secret: the value that belongs to it is hidden.
enum NameClassification {
    enum Kind: Equatable {
        /// A plain ASCII name that is not a secret, in its folded form (lowercase, without
        /// `_`, `-`, `.` and spaces), which is the form allowlists are compared in.
        case ordinary(String)
        /// A plain ASCII name on the list of secret names, such as `token` or `api_key`, or
        /// such a name with an `s` added, such as `tokens`.
        case listedSecret
        /// A plain ASCII name that contains a secret name without being one, such as
        /// `resetToken`, `token-hunter22`, `pin_4831`, `pin4831` or `p.in4831`. It can carry the
        /// secret itself, so it is hidden like a value.
        case containsSecret
        /// A name that is not plain ASCII, contains other symbols or control characters, or has
        /// no letter or digit at all.
        case unclear

        /// A Boolean value that indicates whether the name counts as a secret: it is or contains a
        /// secret name, or it cannot be read, so it may be one. Only an ordinary name does not.
        var namesSecret: Bool {
            if case .ordinary = self { return false }
            return true
        }
    }

    // Longer names are not compared; they count as unclear.
    static let maximumNameLength = 256

    /// Classifies a name that has already been percent-decoded.
    ///
    /// Folding removes case and the separators `_`, `-`, `.` and space. Normalization to NFKC is
    /// not needed: it only turns non-ASCII characters into ASCII ones, and any non-ASCII scalar
    /// already makes a name unclear. So do control characters, format characters such as a
    /// zero-width joiner, look-alike letters from other scripts, full-width letters and combining
    /// marks. No ASCII skeleton is needed either: the redaction rules read one letter, mark or
    /// number outside ASCII inside an ASCII word as nothing or as any one letter (`tͦken`,
    /// `passw〇rd`, `piꞏn`), and such a name is unclear, which counts as a secret, whatever its
    /// skeleton spells.
    static func classify(_ name: some StringProtocol) -> Kind {
        var folded: [UInt8] = []
        // The words between separators: "pin_4831" has a secret name as a word of its own, and
        // "pin4831" a short secret name glued to a code.
        var hasSecretWord = false
        var wordStart = 0
        var wordStarts = [0]
        for byte in name.utf8 {
            switch byte {
            case UInt8(ascii: "A")...UInt8(ascii: "Z"):
                folded.append(byte + 32)
            case UInt8(ascii: "a")...UInt8(ascii: "z"), UInt8(ascii: "0")...UInt8(ascii: "9"):
                folded.append(byte)
            case UInt8(ascii: "_"), UInt8(ascii: "-"), UInt8(ascii: "."), UInt8(ascii: " "):
                hasSecretWord = hasSecretWord || isSecretWord(folded[wordStart...])
                wordStart = folded.count
                wordStarts.append(wordStart)
                continue
            default:
                return .unclear
            }
            if folded.count > maximumNameLength { return .unclear }
        }
        guard !folded.isEmpty else { return .unclear }
        if isListedName(folded[...]) { return .listedSecret }
        hasSecretWord = hasSecretWord || isSecretWord(folded[wordStart...]) || hasSplitShortName(folded, wordStarts: wordStarts)
        let foldedName = String(decoding: folded, as: UTF8.self)
        if hasSecretWord || secretNameParts.contains(where: foldedName.contains) { return .containsSecret }
        return .ordinary(foldedName)
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
    /// `sessionid`, even without a separator. `auth` also matches `author` and `oauth`; hiding
    /// too much is intended. Short names such as `pin` or `key` are not parts, because they
    /// occur in ordinary words (`ping`, `keyboard`); they count only as a word of their own or
    /// glued to a code (`pin4831`).
    static let secretNameParts = [
        "password", "passwd", "passphrase", "passcode", "secret", "token", "apikey", "auth",
        "session", "signature", "cookie", "credential", "bearer", "privatekey",
    ]

    /// The secret names that contain no part, such as `pin`, `key` or `sid`.
    static let shortSecretNames: [[UInt8]] = secretNames
        .filter { name in !secretNameParts.contains(where: name.contains) }
        .sorted()
        .map { Array($0.utf8) }

    private static func isSecretWord(_ word: ArraySlice<UInt8>) -> Bool {
        isListedName(word) || isShortNameGluedToCode(word)
    }

    // "p.in4831", "pi-n4831" or "p_i_n_4831": a short secret name that a separator splits. The
    // words it spans are joined and checked as one word, so "p.in4831" reads as "pin4831" and
    // "p_i_n_4831" as "pin". A short name that only starts or ends at a separator is not split:
    // "cdn1.pinterest.com" and "v2.keycdn.com" stay ordinary.
    private static func hasSplitShortName(_ folded: [UInt8], wordStarts: [Int]) -> Bool {
        for name in shortSecretNames {
            var start = 0
            while start + name.count <= folded.count {
                let end = start + name.count
                if folded[start..<end].elementsEqual(name), wordStarts.contains(where: { start < $0 && $0 < end }) {
                    let first = wordStarts.last { $0 <= start } ?? 0
                    let last = wordStarts.first { $0 >= end } ?? folded.count
                    if isSecretWord(folded[first..<last]) { return true }
                }
                start += 1
            }
        }
        return false
    }

    // "pin4831", "4831pin" or "pins4831": a short secret name at one end of the word and a digit
    // in the rest, or a short secret name with a digit right next to it anywhere in the word
    // ("mypin1234", "newpins4831", "abc1234otp"), which is how a code is written next to its
    // name. "ping", "keyboard" and "signup" have no digit and stay ordinary; "keyboard2" is
    // hidden, which is intended.
    private static func isShortNameGluedToCode(_ word: ArraySlice<UInt8>) -> Bool {
        guard word.contains(where: isDigit) else { return false }
        return shortSecretNames.contains { name in
            hasShortName(name, atAnEndOf: word) || hasShortName(name, nextToDigitIn: word)
        }
    }

    private static func hasShortName(_ name: [UInt8], atAnEndOf word: ArraySlice<UInt8>) -> Bool {
        if word.starts(with: name), word.dropFirst(name.count).contains(where: isDigit) { return true }
        for suffix in [name, name + [UInt8(ascii: "s")]] where word.reversed().starts(with: suffix.reversed()) {
            if word.dropLast(suffix.count).contains(where: isDigit) { return true }
        }
        return false
    }

    // A digit right before the name, right after it, or right after its plural "s".
    private static func hasShortName(_ name: [UInt8], nextToDigitIn word: ArraySlice<UInt8>) -> Bool {
        var start = word.startIndex
        while start + name.count <= word.endIndex {
            let end = start + name.count
            if word[start..<end].elementsEqual(name) {
                if start > word.startIndex, isDigit(word[start - 1]) { return true }
                if end < word.endIndex, isDigit(word[end]) { return true }
                let isPlural = end < word.endIndex && word[end] == UInt8(ascii: "s")
                if isPlural, end + 1 < word.endIndex, isDigit(word[end + 1]) { return true }
            }
            start += 1
        }
        return false
    }

    private static func isDigit(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
    }

    // A listed name, or a listed name with an "s" added.
    private static func isListedName(_ folded: ArraySlice<UInt8>) -> Bool {
        guard !folded.isEmpty else { return false }
        let name = String(decoding: folded, as: UTF8.self)
        if secretNames.contains(name) { return true }
        return name.hasSuffix("s") && secretNames.contains(String(name.dropLast()))
    }
}
