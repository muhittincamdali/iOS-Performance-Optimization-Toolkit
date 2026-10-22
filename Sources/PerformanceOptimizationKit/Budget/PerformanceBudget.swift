import Foundation

/// Limits for the measurements of an app, checked in tests, in CI or at run time.
///
/// Set only the limits you care about; a limit that is `nil` (or NaN) is not checked, and a
/// measurement that is missing is not a violation.
///
/// ```swift
/// let budget = PerformanceBudget(
///     maximumFootprintBytes: 150 * 1_048_576,
///     maximumHitchTimeRatio: HitchRating.goodLimit,
///     traceLimits: ["Load feed": .milliseconds(300)]
/// )
/// let violations = budget.evaluate(measurements)
/// #expect(violations.isEmpty, "\(violations)")
/// ```
public struct PerformanceBudget: Sendable, Equatable, Codable {
    /// The largest memory footprint, in bytes.
    public var maximumFootprintBytes: UInt64?
    /// The highest CPU usage, in percent of one core (see ``CPUSnapshot/usage``).
    public var maximumCPUUsage: Double?
    /// The highest hitch time ratio, in milliseconds per second.
    public var maximumHitchTimeRatio: Double?
    /// The lowest frame rate, in frames per second.
    public var minimumFramesPerSecond: Double?
    /// The longest hang.
    public var maximumHangDuration: Duration?
    /// The longest time to the first frame.
    public var maximumTimeToFirstFrame: Duration?
    /// The highest 95th-percentile duration per traced operation name.
    public var traceLimits: [String: Duration]

    /// Creates a budget.
    public init(
        maximumFootprintBytes: UInt64? = nil,
        maximumCPUUsage: Double? = nil,
        maximumHitchTimeRatio: Double? = nil,
        minimumFramesPerSecond: Double? = nil,
        maximumHangDuration: Duration? = nil,
        maximumTimeToFirstFrame: Duration? = nil,
        traceLimits: [String: Duration] = [:]
    ) {
        self.maximumFootprintBytes = maximumFootprintBytes
        self.maximumCPUUsage = maximumCPUUsage
        self.maximumHitchTimeRatio = maximumHitchTimeRatio
        self.minimumFramesPerSecond = minimumFramesPerSecond
        self.maximumHangDuration = maximumHangDuration
        self.maximumTimeToFirstFrame = maximumTimeToFirstFrame
        self.traceLimits = traceLimits
    }

    /// The limits the measurements exceed, in a fixed order (memory, CPU, frames, hangs, launch,
    /// then traces by name). Empty when everything is within budget.
    public func evaluate(_ measurements: PerformanceMeasurements) -> [BudgetViolation] {
        var violations: [BudgetViolation] = []
        func check(_ metric: BudgetViolation.Metric, measured: Double?, limit: Double?, isMinimum: Bool = false) {
            guard let measured, let limit, measured.isFinite, limit.isFinite else { return }
            let exceeded = isMinimum ? measured < limit : measured > limit
            if exceeded { violations.append(BudgetViolation(metric: metric, measured: measured, limit: limit)) }
        }
        check(.footprint, measured: measurements.memory.map { Double($0.footprintBytes) }, limit: maximumFootprintBytes.map { Double($0) })
        check(.cpuUsage, measured: measurements.cpu?.usage, limit: maximumCPUUsage)
        check(.hitchTimeRatio, measured: measurements.frames?.hitchTimeRatio, limit: maximumHitchTimeRatio)
        let frameRate = measurements.frames.flatMap { $0.frameCount > 0 ? $0.framesPerSecond : nil }
        check(.framesPerSecond, measured: frameRate, limit: minimumFramesPerSecond, isMinimum: true)
        check(.hangDuration, measured: measurements.hangs.map(\.duration.seconds).max(), limit: maximumHangDuration?.seconds)
        check(.timeToFirstFrame, measured: measurements.launch?.timeToFirstFrame?.seconds, limit: maximumTimeToFirstFrame?.seconds)
        for (name, limit) in traceLimits.sorted(by: { $0.key < $1.key }) {
            check(.trace(name), measured: measurements.traces[name]?.p95, limit: limit.seconds)
        }
        return violations
    }
}

/// The measurements a ``PerformanceBudget`` checks. Leave out what you did not measure.
public struct PerformanceMeasurements: Sendable, Equatable {
    /// A memory reading.
    public var memory: MemorySnapshot?
    /// A CPU reading.
    public var cpu: CPUSnapshot?
    /// Frame statistics, such as those of a scroll test.
    public var frames: FrameStatistics?
    /// The hangs found.
    public var hangs: [HangEvent]
    /// The launch measurement.
    public var launch: LaunchMeasurement?
    /// Trace statistics by operation name, in seconds.
    public var traces: [String: SampleStatistics]

    /// Creates measurements.
    public init(memory: MemorySnapshot? = nil, cpu: CPUSnapshot? = nil, frames: FrameStatistics? = nil, hangs: [HangEvent] = [], launch: LaunchMeasurement? = nil, traces: [String: SampleStatistics] = [:]) {
        self.memory = memory
        self.cpu = cpu
        self.frames = frames
        self.hangs = hangs
        self.launch = launch
        self.traces = traces
    }
}

/// A measurement outside its budget.
public struct BudgetViolation: Sendable, Equatable, CustomStringConvertible {
    /// What was measured.
    public enum Metric: Sendable, Hashable {
        /// ``PerformanceBudget/maximumFootprintBytes``, in bytes.
        case footprint
        /// ``PerformanceBudget/maximumCPUUsage``, in percent of one core.
        case cpuUsage
        /// ``PerformanceBudget/maximumHitchTimeRatio``, in ms/s.
        case hitchTimeRatio
        /// ``PerformanceBudget/minimumFramesPerSecond``.
        case framesPerSecond
        /// ``PerformanceBudget/maximumHangDuration``, in seconds.
        case hangDuration
        /// ``PerformanceBudget/maximumTimeToFirstFrame``, in seconds.
        case timeToFirstFrame
        /// A traced operation's 95th percentile, in seconds.
        case trace(String)
    }

    /// What was measured.
    public let metric: Metric
    /// The measured value, in the metric's unit.
    public let measured: Double
    /// The limit, in the metric's unit.
    public let limit: Double

    public var description: String {
        switch metric {
        case .footprint: "footprint \(Self.megabytes(measured)) exceeds \(Self.megabytes(limit))"
        case .cpuUsage: "CPU \(Self.number(measured))% exceeds \(Self.number(limit))%"
        case .hitchTimeRatio: "hitch time ratio \(Self.number(measured)) ms/s exceeds \(Self.number(limit)) ms/s"
        case .framesPerSecond: "\(Self.number(measured)) fps is below \(Self.number(limit)) fps"
        case .hangDuration: "hang of \(Self.milliseconds(measured)) exceeds \(Self.milliseconds(limit))"
        case .timeToFirstFrame: "first frame after \(Self.milliseconds(measured)) exceeds \(Self.milliseconds(limit))"
        case .trace(let name): "\(name) p95 \(Self.milliseconds(measured)) exceeds \(Self.milliseconds(limit))"
        }
    }

    private static func number(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)).locale(.init(identifier: "en_US_POSIX")))
    }

    private static func megabytes(_ bytes: Double) -> String { "\(number(bytes / 1_048_576)) MB" }
    private static func milliseconds(_ seconds: Double) -> String { "\(number(seconds * 1000)) ms" }
}
