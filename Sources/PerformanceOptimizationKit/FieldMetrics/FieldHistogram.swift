/// A histogram from MetricKit, such as the launch times or hang times of a day of use.
///
/// MetricKit reports these figures as buckets (for example "40 of the launches took 200 to
/// 300 ms") rather than single values. The histogram estimates percentiles by assuming the
/// values are spread evenly inside each bucket, which is as precise as the buckets allow.
///
/// Buckets with bounds that are not finite (or beyond ±1e300), an upper bound below the lower
/// one or a count below 1 are left out, also when a histogram is decoded, so a damaged
/// payload cannot produce NaN or a crash.
public struct FieldHistogram: Sendable, Equatable, Codable {
    /// One range of values and how many fell into it.
    public struct Bucket: Sendable, Equatable, Codable {
        /// The lowest value of the range, in the histogram's unit (seconds for durations).
        public let lowerBound: Double
        /// The highest value of the range.
        public let upperBound: Double
        /// How many values fell into the range.
        public let count: Int

        /// Creates a bucket.
        public init(lowerBound: Double, upperBound: Double, count: Int) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
            self.count = count
        }

        // Bounds beyond ±1e300 are left out with the non-finite ones: their difference would
        // overflow to infinity and turn the estimates into NaN.
        var isValid: Bool {
            abs(lowerBound) <= 1e300 && abs(upperBound) <= 1e300 && upperBound >= lowerBound && count > 0
        }
    }

    /// The most buckets kept. MetricKit sends a few dozen; the limit only guards against
    /// damaged input.
    public static var maximumBucketCount: Int { 10_000 }

    /// The valid buckets, sorted by lower bound.
    public let buckets: [Bucket]

    /// Creates a histogram, leaving out invalid buckets and any past ``maximumBucketCount``.
    public init(buckets: some Sequence<Bucket>) {
        self.buckets = buckets.lazy.filter(\.isValid).prefix(Self.maximumBucketCount).sorted { $0.lowerBound < $1.lowerBound }
    }

    /// Decodes a histogram and checks its buckets like ``init(buckets:)``.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(buckets: try container.decode([Bucket].self, forKey: .buckets))
    }

    private enum CodingKeys: String, CodingKey {
        case buckets
    }

    /// The number of values in all buckets. Stops at `Int.max` instead of overflowing.
    public var totalCount: Int {
        buckets.reduce(0) { $0.saturatingAdd($1.count) }
    }

    /// A Boolean value that indicates whether the histogram holds no values.
    public var isEmpty: Bool { buckets.isEmpty }

    /// The estimated value below which the fraction `p` of the values fall, or `nil` when the
    /// histogram is empty or `p` is NaN. `p` is clamped to 0...1.
    public func percentile(_ p: Double) -> Double? {
        guard !p.isNaN, !buckets.isEmpty else { return nil }
        let fraction = min(max(p, 0), 1)
        let target = fraction * Double(totalCount)
        var seen = 0.0
        for bucket in buckets {
            let count = Double(bucket.count)
            if seen + count >= target {
                let inside = count > 0 ? (target - seen) / count : 0
                let weight = min(max(inside, 0), 1)
                return bucket.lowerBound * (1 - weight) + bucket.upperBound * weight
            }
            seen += count
        }
        return buckets.last?.upperBound
    }

    /// The estimated mean, taking the middle of each bucket, or `nil` when the histogram is
    /// empty.
    public var mean: Double? {
        let total = Double(totalCount)
        guard total > 0 else { return nil }
        return buckets.reduce(0) { sum, bucket in
            let middle = bucket.lowerBound / 2 + bucket.upperBound / 2
            return sum + middle * (Double(bucket.count) / total)
        }
    }

    /// The fraction of values at or above `value`, from 0 to 1, counting a bucket that contains
    /// `value` in proportion. Useful for "share of launches slower than 400 ms".
    public func fraction(atOrAbove value: Double) -> Double? {
        let total = Double(totalCount)
        guard total > 0, value.isFinite else { return nil }
        let above = buckets.reduce(0.0) { sum, bucket in
            if bucket.lowerBound >= value { return sum + Double(bucket.count) }
            guard bucket.upperBound > value else { return sum }
            let share = (bucket.upperBound - value) / (bucket.upperBound - bucket.lowerBound)
            return sum + Double(bucket.count) * share
        }
        return min(above / total, 1)
    }
}
