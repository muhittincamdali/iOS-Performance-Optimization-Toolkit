import Foundation
import os

/// Times operations, shows them as signpost intervals in Instruments and keeps their statistics.
///
/// Each ``measure(_:_:)`` call emits an `OSSignposter` interval, so the operation appears in the
/// Points of Interest and os_signpost instruments, and records the duration under the
/// operation's name. ``statistics(for:)`` summarizes the recorded durations.
///
/// ```swift
/// let tracer = PerformanceTracer()
/// let feed = try await tracer.measure("Load feed") { try await api.feed() }
/// tracer.statistics(for: "Load feed")?.p95 // seconds
/// ```
///
/// Memory is bounded: each name keeps its newest `samplesPerName` durations, and names past
/// `maximumNames` are not recorded (their signposts are still emitted).
public final class PerformanceTracer: Sendable {
    /// The signposter the intervals are emitted with.
    public let signposter: OSSignposter
    /// The number of durations kept per name.
    public let samplesPerName: Int
    /// The number of distinct names kept.
    public let maximumNames: Int

    private let store = OSAllocatedUnfairLock(initialState: TraceStore())

    /// Creates a tracer.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem of the signposts, usually the bundle identifier.
    ///   - category: The category of the signposts. `.pointsOfInterest` puts them in the
    ///     Points of Interest instrument.
    ///   - samplesPerName: The durations kept per name, from 1 to 100,000.
    ///   - maximumNames: The distinct names kept, from 1 to 10,000.
    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "PerformanceOptimizationKit",
        category: OSLog.Category = .pointsOfInterest,
        samplesPerName: Int = 500,
        maximumNames: Int = 200
    ) {
        signposter = OSSignposter(subsystem: subsystem, category: category)
        self.samplesPerName = min(max(samplesPerName, 1), 100_000)
        self.maximumNames = min(max(maximumNames, 1), 10_000)
    }

    /// Runs `body` inside a signpost interval and records how long it took.
    public func measure<Result>(_ name: StaticString, _ body: () throws -> Result) rethrows -> Result {
        let state = signposter.beginInterval(name, id: signposter.makeSignpostID())
        let start = ContinuousClock.now
        defer {
            record(String(describing: name), duration: ContinuousClock.now - start)
            signposter.endInterval(name, state)
        }
        return try body()
    }

    /// Runs asynchronous `body` inside a signpost interval and records how long it took,
    /// including time spent suspended.
    public func measure<Result>(
        _ name: StaticString,
        isolation: isolated (any Actor)? = #isolation,
        _ body: () async throws -> Result
    ) async rethrows -> Result {
        let state = signposter.beginInterval(name, id: signposter.makeSignpostID())
        let start = ContinuousClock.now
        defer {
            record(String(describing: name), duration: ContinuousClock.now - start)
            signposter.endInterval(name, state)
        }
        return try await body()
    }

    /// Records a duration measured some other way, such as from a network metrics callback.
    /// Negative durations are ignored.
    public func record(_ name: String, duration: Duration) {
        guard duration >= .zero else { return }
        let seconds = duration.seconds
        store.withLock { $0.append(seconds, for: name, samplesPerName: samplesPerName, maximumNames: maximumNames) }
    }

    /// The statistics of the durations recorded under `name`, in seconds, or `nil` when there
    /// are none.
    public func statistics(for name: String) -> SampleStatistics? {
        SampleStatistics(store.withLock { $0.samples[name]?.elements ?? [] })
    }

    /// The names that have recorded durations, sorted.
    public var names: [String] {
        store.withLock { $0.samples.keys.sorted() }
    }

    /// The number of durations not kept because `maximumNames` was reached.
    public var droppedCount: Int {
        store.withLock { $0.droppedCount }
    }

    /// Removes every recorded duration.
    public func removeAll() {
        store.withLock { $0 = TraceStore() }
    }
}

private struct TraceStore: Sendable {
    var samples: [String: RingBuffer<Double>] = [:]
    var droppedCount = 0

    mutating func append(_ seconds: Double, for name: String, samplesPerName: Int, maximumNames: Int) {
        if samples[name] == nil {
            guard samples.count < maximumNames else {
                droppedCount = droppedCount.saturatingAdd(1)
                return
            }
            samples[name] = RingBuffer(capacity: samplesPerName)
        }
        samples[name]?.append(seconds)
    }
}
