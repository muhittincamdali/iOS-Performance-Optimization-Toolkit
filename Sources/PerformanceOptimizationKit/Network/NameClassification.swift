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
        folded.reserveCapacity(min(name.utf8.count, maximumNameLength + 1))
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
        if hasSecretWord || secretNamePartBytes.contains(where: { occurs($0, in: folded) }) { return .containsSecret }
        return .ordinary(String(decoding: folded, as: UTF8.self))
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

    // The tables the checks below read, built once from the lists above, so that classifying a
    // name builds no name, plural or string for each of its words.
    private static let secretNamePartBytes: [[UInt8]] = secretNameParts.map { Array($0.utf8) }
    // The short secret names by their first byte: at each place in a name, only the names that
    // start with the byte there are compared.
    private static let shortSecretNamesByFirstByte: [[[UInt8]]] = {
        var table = [[[UInt8]]](repeating: [], count: 256)
        for name in shortSecretNames { table[Int(name[0])].append(name) }
        return table
    }()
    // The secret names by length in bytes: a word is compared only with names as long as it is.
    private static let secretNamesByLength: [[[UInt8]]] = {
        let names = secretNames.map { Array($0.utf8) }
        var table = [[[UInt8]]](repeating: [], count: (names.map(\.count).max() ?? 0) + 1)
        for name in names { table[name.count].append(name) }
        return table
    }()

    private static func isSecretWord(_ word: ArraySlice<UInt8>) -> Bool {
        isListedName(word) || isShortNameGluedToCode(word)
    }

    // "p.in4831", "pi-n4831" or "p_i_n_4831": a short secret name that a separator splits. The
    // words it spans are joined and checked as one word, so "p.in4831" reads as "pin4831" and
    // "p_i_n_4831" as "pin". A short name that only starts or ends at a separator is not split:
    // "cdn1.pinterest.com" and "v2.keycdn.com" stay ordinary.
    private static func hasSplitShortName(_ folded: [UInt8], wordStarts: [Int]) -> Bool {
        hasShortName(in: folded[...]) { start, end in
            guard wordStarts.contains(where: { start < $0 && $0 < end }) else { return false }
            let first = wordStarts.last { $0 <= start } ?? 0
            let last = wordStarts.first { $0 >= end } ?? folded.count
            return isSecretWord(folded[first..<last])
        }
    }

    // "pin4831", "4831pin" or "pins4831": a short secret name at one end of the word and a digit
    // in the rest, or a short secret name with a digit right next to it anywhere in the word
    // ("mypin1234", "newpins4831", "abc1234otp"), which is how a code is written next to its
    // name. "ping", "keyboard" and "signup" have no digit and stay ordinary; "keyboard2" is
    // hidden, which is intended.
    private static func isShortNameGluedToCode(_ word: ArraySlice<UInt8>) -> Bool {
        guard let firstDigit = word.firstIndex(where: isDigit), let lastDigit = word.lastIndex(where: isDigit) else {
            return false
        }
        return hasShortName(in: word) { start, end in
            let isPlural = end < word.endIndex && word[end] == UInt8(ascii: "s")
            if start == word.startIndex, lastDigit >= end { return true }
            if end == word.endIndex || (isPlural && end + 1 == word.endIndex), firstDigit < start { return true }
            // A digit right before the name, right after it, or right after its plural "s".
            if start > word.startIndex, isDigit(word[start - 1]) { return true }
            if end < word.endIndex, isDigit(word[end]) { return true }
            return isPlural && end + 1 < word.endIndex && isDigit(word[end + 1])
        }
    }

    // Whether a short secret name occurs in `bytes` at a place, from `start` up to `end`, that
    // `matches`. One pass over the bytes, whatever the number of names.
    private static func hasShortName(in bytes: ArraySlice<UInt8>, where matches: (_ start: Int, _ end: Int) -> Bool) -> Bool {
        for start in bytes.indices {
            for name in shortSecretNamesByFirstByte[Int(bytes[start])] {
                let end = start + name.count
                if end <= bytes.endIndex, bytes[start..<end].elementsEqual(name), matches(start, end) { return true }
            }
        }
        return false
    }

    private static func isDigit(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
    }

    // A listed name, or a listed name with an "s" added.
    private static func isListedName(_ folded: ArraySlice<UInt8>) -> Bool {
        if isSecretName(folded) { return true }
        return folded.last == UInt8(ascii: "s") && isSecretName(folded.dropLast())
    }

    private static func isSecretName(_ folded: ArraySlice<UInt8>) -> Bool {
        guard folded.count < secretNamesByLength.count else { return false }
        return secretNamesByLength[folded.count].contains { $0.elementsEqual(folded) }
    }

    private static func occurs(_ part: [UInt8], in folded: [UInt8]) -> Bool {
        guard part.count <= folded.count else { return false }
        for start in 0...(folded.count - part.count) where folded[start] == part[0] {
            if folded[start..<(start + part.count)].elementsEqual(part) { return true }
        }
        return false
    }
}
