/// How smooth a run of frames was: frame rate, hitches and dropped frames.
///
/// A *hitch* is a frame that reached the screen later than the display expected it; the time by
/// which it was late is its hitch duration. Apple's tools report the hitch time ratio, the
/// milliseconds of hitch per second, and ``HitchRating`` grades it with Apple's limits.
public struct FrameStatistics: Sendable, Equatable, Codable {
    /// The number of frames.
    public let frameCount: Int
    /// The time the frames covered, in seconds.
    public let duration: Double
    /// The time by which frames were late, in seconds, summed.
    public let hitchTime: Double
    /// The number of refreshes that showed an old frame again because the new one was late.
    public let droppedFrameCount: Int
    /// The longest frame interval, in seconds.
    public let longestFrame: Double
    /// The shortest expected frame interval seen, in seconds, such as `1/120` on a ProMotion
    /// display running at full speed.
    public let shortestTargetInterval: Double

    /// Creates statistics from known values, for tests and previews.
    public init(frameCount: Int, duration: Double, hitchTime: Double, droppedFrameCount: Int, longestFrame: Double, shortestTargetInterval: Double) {
        self.frameCount = max(frameCount, 0)
        self.duration = Self.nonNegative(duration)
        self.hitchTime = Self.nonNegative(hitchTime)
        self.droppedFrameCount = max(droppedFrameCount, 0)
        self.longestFrame = Self.nonNegative(longestFrame)
        self.shortestTargetInterval = Self.nonNegative(shortestTargetInterval)
    }

    /// Decodes statistics and corrects values like ``init(frameCount:duration:hitchTime:droppedFrameCount:longestFrame:shortestTargetInterval:)``.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            frameCount: try container.decode(Int.self, forKey: .frameCount),
            duration: try container.decode(Double.self, forKey: .duration),
            hitchTime: try container.decode(Double.self, forKey: .hitchTime),
            droppedFrameCount: try container.decode(Int.self, forKey: .droppedFrameCount),
            longestFrame: try container.decode(Double.self, forKey: .longestFrame),
            shortestTargetInterval: try container.decode(Double.self, forKey: .shortestTargetInterval)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case frameCount, duration, hitchTime, droppedFrameCount, longestFrame, shortestTargetInterval
    }

    /// Frames per second, or `0` when no time has passed.
    public var framesPerSecond: Double {
        duration > 0 ? Double(frameCount) / duration : 0
    }

    /// The refresh rate the display aimed for, in frames per second.
    public var targetFramesPerSecond: Double {
        shortestTargetInterval > 0 ? 1 / shortestTargetInterval : 0
    }

    /// Milliseconds of hitch per second, the measure Instruments and MetricKit report.
    public var hitchTimeRatio: Double {
        duration > 0 ? hitchTime * 1000 / duration : 0
    }

    /// The rating of ``hitchTimeRatio``.
    public var rating: HitchRating { HitchRating(hitchTimeRatio: hitchTimeRatio) }

    private static func nonNegative(_ value: Double) -> Double {
        value.isFinite ? max(value, 0) : 0
    }
}

/// How serious hitches are, from the hitch time ratio in milliseconds per second.
///
/// The limits are the ones in Apple's "Understanding hitches in your app": at or below 10 ms/s
/// is good, at or below 25 ms/s a warning, at or below 50 ms/s critical, and above that it
/// needs immediate attention.
public enum HitchRating: String, Sendable, Codable, CaseIterable, Comparable {
    /// At or below 10 ms/s.
    case good
    /// Above 10 and at or below 25 ms/s.
    case warning
    /// Above 25 and at or below 50 ms/s.
    case critical
    /// Above 50 ms/s.
    case severe

    /// The upper bound of ``good``, in milliseconds per second.
    public static var goodLimit: Double { 10 }
    /// The upper bound of ``warning``, in milliseconds per second.
    public static var warningLimit: Double { 25 }
    /// The upper bound of ``critical``, in milliseconds per second.
    public static var criticalLimit: Double { 50 }

    /// The rating of a hitch time ratio. NaN counts as ``severe``, negative values as ``good``.
    public init(hitchTimeRatio: Double) {
        switch hitchTimeRatio {
        case ...Self.goodLimit: self = .good
        case ...Self.warningLimit: self = .warning
        case ...Self.criticalLimit: self = .critical
        default: self = .severe
        }
    }

    public static func < (lhs: HitchRating, rhs: HitchRating) -> Bool {
        lhs.rank < rhs.rank
    }

    private var rank: Int {
        switch self {
        case .good: 0
        case .warning: 1
        case .critical: 2
        case .severe: 3
        }
    }
}
