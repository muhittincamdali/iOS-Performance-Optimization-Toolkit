/// Summary statistics of a set of measurements, such as the durations of a traced operation.
///
/// Percentiles use linear interpolation between the two nearest ranks (the method spreadsheets
/// call `PERCENTILE.INC`), so `p50` of `[1, 2, 3, 4]` is `2.5`. NaN and infinite values are
/// left out, because one broken measurement would otherwise turn every figure into NaN.
public struct SampleStatistics: Sendable, Equatable, Codable {
    /// The number of finite values the statistics were computed from.
    public let count: Int
    /// The smallest value.
    public let minimum: Double
    /// The largest value.
    public let maximum: Double
    /// The arithmetic mean.
    public let mean: Double
    /// The population standard deviation.
    public let standardDeviation: Double
    /// The median.
    public let p50: Double
    /// The 90th percentile.
    public let p90: Double
    /// The 95th percentile.
    public let p95: Double
    /// The 99th percentile.
    public let p99: Double

    /// Computes statistics from values, or returns `nil` when none of them is finite.
    public init?(_ values: some Sequence<Double>) {
        let sorted = values.filter(\.isFinite).sorted()
        guard let first = sorted.first, let last = sorted.last else { return nil }
        count = sorted.count
        minimum = first
        maximum = last
        mean = Self.mean(of: sorted)
        standardDeviation = Self.standardDeviation(of: sorted, mean: mean)
        p50 = Self.percentile(0.50, ofSorted: sorted)
        p90 = Self.percentile(0.90, ofSorted: sorted)
        p95 = Self.percentile(0.95, ofSorted: sorted)
        p99 = Self.percentile(0.99, ofSorted: sorted)
    }

    /// Computes statistics from durations, in seconds.
    public init?(durations: some Sequence<Duration>) {
        self.init(durations.map(\.seconds))
    }

    /// The value below which the fraction `p` of the values fall.
    ///
    /// - Parameters:
    ///   - p: A fraction from 0 to 1. Values outside that range are clamped; NaN returns `nil`.
    ///   - values: The values. NaN and infinite values are left out.
    public static func percentile(_ p: Double, of values: some Sequence<Double>) -> Double? {
        guard !p.isNaN else { return nil }
        let sorted = values.filter(\.isFinite).sorted()
        guard !sorted.isEmpty else { return nil }
        return percentile(min(max(p, 0), 1), ofSorted: sorted)
    }

    static func percentile(_ p: Double, ofSorted sorted: [Double]) -> Double {
        let position = p * Double(sorted.count - 1)
        let lower = Int(position.rounded(.down))
        let upper = min(lower + 1, sorted.count - 1)
        let fraction = position - Double(lower)
        if fraction == 0 || sorted[lower] == sorted[upper] { return sorted[lower] }
        // Weighting both ends instead of adding a fraction of their difference keeps the result
        // finite when the values span almost the whole Double range.
        return sorted[lower] * (1 - fraction) + sorted[upper] * fraction
    }

    // Dividing each term before adding keeps the sum finite for values near the largest Double.
    private static func mean(of values: [Double]) -> Double {
        let count = Double(values.count)
        return values.reduce(0) { $0 + $1 / count }
    }

    private static func standardDeviation(of values: [Double], mean: Double) -> Double {
        let count = Double(values.count)
        let variance = values.reduce(0) { partial, value in
            let difference = value - mean
            return partial + difference * difference / count
        }
        return variance.isFinite ? variance.squareRoot() : .infinity
    }
}
