// Conversions that cannot trap. `Int(_:)` and `UInt64(_:)` crash on NaN, infinity and values
// outside the integer's range, and measured values (frame intervals, MetricKit figures, sysctl
// results) can be any of those.

extension Double {
    /// The value rounded toward zero as an `Int`, or `nil` when it is NaN or infinite.
    /// Values outside `Int`'s range become `Int.min` or `Int.max`.
    var clampedInt: Int? {
        guard isFinite else { return nil }
        if self >= 9.223372036854775807e18 { return .max }
        if self <= -9.223372036854775808e18 { return .min }
        return Int(self)
    }

    /// The value rounded toward zero as a `UInt64`, or `nil` when it is NaN, infinite or
    /// negative. Values above `UInt64.max` become `UInt64.max`.
    var clampedUInt64: UInt64? {
        guard isFinite, self >= 0 else { return nil }
        if self >= 1.8446744073709551615e19 { return .max }
        return UInt64(self)
    }
}

extension Duration {
    /// The duration in seconds as a `Double`.
    var seconds: Double {
        let parts = components
        return Double(parts.seconds) + Double(parts.attoseconds) * 1e-18
    }

    /// A duration from seconds, or `nil` when the value is NaN, infinite or negative.
    static func validSeconds(_ value: Double) -> Duration? {
        guard value.isFinite, value >= 0, value < 9.2e18 else { return nil }
        return .seconds(value)
    }
}

extension Int {
    /// Adds without trapping: the result stops at `Int.max` or `Int.min`.
    func saturatingAdd(_ other: Int) -> Int {
        let (sum, overflow) = addingReportingOverflow(other)
        guard overflow else { return sum }
        return other > 0 ? .max : .min
    }
}
