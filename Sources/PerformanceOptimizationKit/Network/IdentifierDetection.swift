import Foundation

// Recognizes values that identify a person, an account or a session: the parts of a URL that
// are replaced with `:id`. It works on Unicode scalars, never on `Character`s, so combining
// marks cannot join a delimiter to the characters around it.
enum IdentifierDetection {
    /// A Boolean value that indicates whether a percent-decoded value is an identifier or a
    /// secret token.
    static func isIdentifier(_ value: String) -> Bool {
        let scalars = Array(value.unicodeScalars)
        guard !scalars.isEmpty else { return false }
        if scalars.contains("@") { return true }
        // A UUID string is always 36 characters long; only those are parsed.
        if scalars.count == 36, UUID(uuidString: value) != nil { return true }
        if isNumber(scalars) || longestDigitRun(scalars) >= minimumDigitRun { return true }
        if isJSONWebToken(scalars) || isBearerToken(scalars) { return true }
        if isCardNumber(scalars) || isIBAN(scalars) { return true }
        return isLongToken(scalars)
    }

    // Six digits or more, also split by separators, as in "123-45-6789" or "+90 555 123 45 67".
    static let minimumDigitRun = 6

    // The symbols are compared one by one rather than looked up in a set, since these checks run
    // on every scalar of every path segment.
    private static func isSeparator(_ scalar: Unicode.Scalar) -> Bool {
        scalar == "-" || scalar == "_" || scalar == "." || scalar == " "
    }

    private static func isTokenSymbol(_ scalar: Unicode.Scalar) -> Bool {
        scalar == "-" || scalar == "_" || scalar == "=" || scalar == "+" || scalar == "." || scalar == "~" || scalar == "/"
    }

    private static func isASCIIDigit(_ scalar: Unicode.Scalar) -> Bool {
        ("0"..."9").contains(scalar)
    }

    private static func isASCIILetter(_ scalar: Unicode.Scalar) -> Bool {
        ("a"..."z").contains(scalar) || ("A"..."Z").contains(scalar)
    }

    private static func asciiLowercased(_ scalar: Unicode.Scalar) -> Unicode.Scalar {
        ("A"..."Z").contains(scalar) ? Unicode.Scalar(UInt8(scalar.value) + 32) : scalar
    }

    private static func isHexDigit(_ scalar: Unicode.Scalar) -> Bool {
        isASCIIDigit(scalar) || ("a"..."f").contains(scalar) || ("A"..."F").contains(scalar)
    }

    // "12345" or "+905551234567": a number of any length.
    private static func isNumber(_ scalars: [Unicode.Scalar]) -> Bool {
        let digits = scalars.first == "+" ? scalars.dropFirst() : scalars[...]
        return !digits.isEmpty && digits.allSatisfy(isASCIIDigit)
    }

    private static func longestDigitRun(_ scalars: [Unicode.Scalar]) -> Int {
        var longest = 0
        var current = 0
        for scalar in scalars {
            if isASCIIDigit(scalar) {
                current += 1
                longest = max(longest, current)
            } else if !isSeparator(scalar) {
                current = 0
            }
        }
        return longest
    }

    // A JSON Web Token starts with the Base64 form of `{"`.
    private static func isJSONWebToken(_ scalars: [Unicode.Scalar]) -> Bool {
        scalars.count >= 10 && scalars.starts(with: ["e", "y", "J"])
    }

    private static func isBearerToken(_ scalars: [Unicode.Scalar]) -> Bool {
        scalars.count > 6 && scalars.prefix(6).lazy.map(asciiLowercased).elementsEqual("bearer".unicodeScalars)
    }

    // 13 to 19 digits, also split by spaces or dashes, that pass the Luhn check.
    private static func isCardNumber(_ scalars: [Unicode.Scalar]) -> Bool {
        var digits: [Int] = []
        for scalar in scalars {
            if isASCIIDigit(scalar) {
                digits.append(Int(scalar.value) - 48)
            } else if scalar != " " && scalar != "-" {
                return false
            }
            if digits.count > 19 { return false }
        }
        guard digits.count >= 13 else { return false }
        var sum = 0
        for (offset, digit) in digits.reversed().enumerated() {
            let doubled = offset.isMultiple(of: 2) ? digit : digit * 2
            sum += doubled > 9 ? doubled - 9 : doubled
        }
        return sum.isMultiple(of: 10)
    }

    // A country code, two check digits and 11 to 30 letters or digits, also split by spaces,
    // that pass the ISO 13616 mod-97 check.
    private static func isIBAN(_ scalars: [Unicode.Scalar]) -> Bool {
        let compact = scalars.filter { $0 != " " }
        guard (15...34).contains(compact.count),
              compact.prefix(2).allSatisfy(isASCIILetter),
              compact.dropFirst(2).prefix(2).allSatisfy(isASCIIDigit),
              compact.allSatisfy({ isASCIILetter($0) || isASCIIDigit($0) }) else { return false }
        var remainder = 0
        for scalar in compact.dropFirst(4) + compact.prefix(4) {
            let value = Int(asciiLowercased(scalar).value) - (isASCIIDigit(scalar) ? 48 : 87)
            remainder = (remainder * (value > 9 ? 100 : 10) + value) % 97
        }
        return remainder == 1
    }

    // 16 or more hexadecimal digits; 16 or more letters, digits and Base64 symbols that mix
    // letters and digits; or 32 or more of them in any mix.
    private static func isLongToken(_ scalars: [Unicode.Scalar]) -> Bool {
        guard scalars.count >= 16 else { return false }
        if scalars.allSatisfy(isHexDigit) { return true }
        let isTokenLike = scalars.allSatisfy { isASCIILetter($0) || isASCIIDigit($0) || isTokenSymbol($0) }
        guard isTokenLike else { return false }
        if scalars.count >= 32 { return true }
        return scalars.contains(where: isASCIILetter) && scalars.contains(where: isASCIIDigit)
    }
}
