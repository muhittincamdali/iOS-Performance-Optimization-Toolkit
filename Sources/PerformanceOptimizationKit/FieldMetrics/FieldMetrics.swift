import Foundation

/// The performance of the app on people's devices over one reporting period, as MetricKit
/// delivered it (usually once a day).
///
/// ``FieldMetricsReceiver`` builds these from MetricKit; the type itself has no MetricKit
/// dependency, so it can also be decoded on a server or in tests. Durations are in seconds.
public struct FieldMetrics: Sendable, Equatable, Codable {
    /// The start of the period the figures cover.
    public let periodStart: Date?
    /// The end of the period.
    public let periodEnd: Date?
    /// The app's build version during the period.
    public let appBuild: String?
    /// The time from launch to the first frame.
    public let timeToFirstDraw: FieldHistogram?
    /// The time to return to the foreground from the background.
    public let resumeTime: FieldHistogram?
    /// The durations of hangs.
    public let hangTime: FieldHistogram?
    /// Milliseconds of hitch per second of scrolling (before iOS 27) or of animation (iOS 27
    /// and later).
    public let hitchTimeRatio: Double?
    /// The highest memory footprint in the period, in bytes.
    public let peakMemoryBytes: UInt64?
    /// The CPU time used in the period, in seconds.
    public let cpuTime: Double?
    /// How the app ended while it was in the foreground.
    public let foregroundTerminations: Terminations?

    /// Creates field metrics from known values.
    public init(periodStart: Date? = nil, periodEnd: Date? = nil, appBuild: String? = nil, timeToFirstDraw: FieldHistogram? = nil, resumeTime: FieldHistogram? = nil, hangTime: FieldHistogram? = nil, hitchTimeRatio: Double? = nil, peakMemoryBytes: UInt64? = nil, cpuTime: Double? = nil, foregroundTerminations: Terminations? = nil) {
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.appBuild = appBuild
        self.timeToFirstDraw = timeToFirstDraw
        self.resumeTime = resumeTime
        self.hangTime = hangTime
        self.hitchTimeRatio = Self.finiteNonNegative(hitchTimeRatio)
        self.peakMemoryBytes = peakMemoryBytes
        self.cpuTime = Self.finiteNonNegative(cpuTime)
        self.foregroundTerminations = foregroundTerminations
    }

    /// Decodes field metrics and checks the values like ``init(periodStart:periodEnd:appBuild:timeToFirstDraw:resumeTime:hangTime:hitchTimeRatio:peakMemoryBytes:cpuTime:foregroundTerminations:)``.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            periodStart: try container.decodeIfPresent(Date.self, forKey: .periodStart),
            periodEnd: try container.decodeIfPresent(Date.self, forKey: .periodEnd),
            appBuild: try container.decodeIfPresent(String.self, forKey: .appBuild),
            timeToFirstDraw: try container.decodeIfPresent(FieldHistogram.self, forKey: .timeToFirstDraw),
            resumeTime: try container.decodeIfPresent(FieldHistogram.self, forKey: .resumeTime),
            hangTime: try container.decodeIfPresent(FieldHistogram.self, forKey: .hangTime),
            hitchTimeRatio: try container.decodeIfPresent(Double.self, forKey: .hitchTimeRatio),
            peakMemoryBytes: try container.decodeIfPresent(UInt64.self, forKey: .peakMemoryBytes),
            cpuTime: try container.decodeIfPresent(Double.self, forKey: .cpuTime),
            foregroundTerminations: try container.decodeIfPresent(Terminations.self, forKey: .foregroundTerminations)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case periodStart, periodEnd, appBuild, timeToFirstDraw, resumeTime, hangTime, hitchTimeRatio, peakMemoryBytes, cpuTime, foregroundTerminations
    }

    static func finiteNonNegative(_ value: Double?) -> Double? {
        guard let value, value.isFinite, value >= 0 else { return nil }
        return value
    }
}

extension FieldMetrics {
    /// How often the app ended in the foreground, by cause. Negative counts become 0.
    public struct Terminations: Sendable, Equatable, Codable {
        /// The app quit normally.
        public let normal: Int
        /// The system ended the app because it used more memory than allowed.
        public let memoryLimit: Int
        /// The watchdog ended the app, usually because it hung during launch, resume or
        /// suspension.
        public let watchdog: Int
        /// The app accessed invalid memory.
        public let badAccess: Int
        /// The app ran an illegal instruction, such as a Swift runtime trap.
        public let illegalInstruction: Int
        /// The app ended for another abnormal reason.
        public let abnormal: Int

        /// Creates termination counts.
        public init(normal: Int = 0, memoryLimit: Int = 0, watchdog: Int = 0, badAccess: Int = 0, illegalInstruction: Int = 0, abnormal: Int = 0) {
            self.normal = max(normal, 0)
            self.memoryLimit = max(memoryLimit, 0)
            self.watchdog = max(watchdog, 0)
            self.badAccess = max(badAccess, 0)
            self.illegalInstruction = max(illegalInstruction, 0)
            self.abnormal = max(abnormal, 0)
        }

        /// Decodes counts and turns negative ones into 0.
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            func count(_ key: CodingKeys) throws -> Int { try container.decodeIfPresent(Int.self, forKey: key) ?? 0 }
            self.init(normal: try count(.normal), memoryLimit: try count(.memoryLimit), watchdog: try count(.watchdog), badAccess: try count(.badAccess), illegalInstruction: try count(.illegalInstruction), abnormal: try count(.abnormal))
        }

        private enum CodingKeys: String, CodingKey {
            case normal, memoryLimit, watchdog, badAccess, illegalInstruction, abnormal
        }

        /// All terminations that were not a normal quit. Stops at `Int.max` instead of
        /// overflowing.
        public var unexpected: Int {
            [memoryLimit, watchdog, badAccess, illegalInstruction, abnormal].reduce(0) { $0.saturatingAdd($1) }
        }
    }
}
