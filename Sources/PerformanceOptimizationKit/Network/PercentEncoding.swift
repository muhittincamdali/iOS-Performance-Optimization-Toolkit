enum PercentEncoding {
    /// A Boolean value that indicates whether `encoded` has only well-formed percent-encodings,
    /// none of which encodes a control character or a byte in `forbidden`, and no raw byte in
    /// `forbidden` other than `.` and `/`, which are only forbidden in encoded form.
    static func isUnambiguous(_ encoded: String, forbidding forbidden: ByteSet) -> Bool {
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

/// A set of bytes that answers `contains` by index instead of by hashing, for the checks that
/// run on every byte of a path or a query.
struct ByteSet: Sendable, ExpressibleByArrayLiteral {
    private var members = [Bool](repeating: false, count: 256)

    init(arrayLiteral bytes: UInt8...) {
        for byte in bytes { members[Int(byte)] = true }
    }

    func contains(_ byte: UInt8) -> Bool {
        members[Int(byte)]
    }
}
