import Darwin
import Foundation
import os

/// Reports periods in which the main queue (or another serial queue) does not run new work.
///
/// A background thread submits a small block to the watched queue and measures how long the
/// queue takes to run it. When that takes at least `threshold`, the detector reports a
/// ``HangEvent``. The duration is measured from the moment the block was submitted, so a hang
/// that began shortly before can be reported up to one `checkInterval` short.
///
/// ```swift
/// let detector = HangDetector()
/// detector.start()
/// for await hang in detector.events() {
///     logger.warning("Main thread blocked for \(hang.duration)")
/// }
/// ```
///
/// The detector cannot tell what the queue was busy with. To find the code, record the app
/// with the Hangs instrument, or read the hang diagnostics MetricKit delivers from the field.
public final class HangDetector: Sendable {
    /// The shortest unresponsive period that is reported.
    public let threshold: Duration
    /// How often the background thread checks the queue.
    public let checkInterval: Duration

    private let queue: DispatchQueue
    private let state = OSAllocatedUnfairLock(initialState: WatchState())
    private let broadcaster = Broadcaster<HangEvent>()

    /// Creates a detector that is not running yet.
    ///
    /// - Parameters:
    ///   - threshold: The shortest period to report. Values under 50 ms become 50 ms.
    ///   - checkInterval: How often to check, from 10 ms to `threshold`. Shorter intervals
    ///     notice hangs sooner and wake the background thread more often.
    ///   - queue: The serial queue to watch.
    public init(threshold: Duration = .milliseconds(250), checkInterval: Duration = .milliseconds(50), queue: DispatchQueue = .main) {
        self.threshold = max(threshold, .milliseconds(50))
        self.checkInterval = min(max(checkInterval, .milliseconds(10)), self.threshold)
        self.queue = queue
    }

    deinit {
        stop()
    }

    /// A Boolean value that indicates whether the detector is running.
    public var isRunning: Bool { state.withLock { $0.runID != nil } }

    /// A stream of the hangs found while the detector runs. Each call returns a new stream; it
    /// keeps the 64 newest events when its reader falls behind.
    public func events() -> AsyncStream<HangEvent> {
        broadcaster.stream()
    }

    /// Starts watching the queue. Calling it while running does nothing.
    public func start() {
        let runID = UUID()
        let started = state.withLock { state -> Bool in
            guard state.runID == nil else { return false }
            state = WatchState(runID: runID)
            return true
        }
        guard started else { return }
        let thread = Thread { [state, queue, threshold, checkInterval, broadcaster] in
            Self.watch(runID: runID, state: state, queue: queue, threshold: threshold, checkInterval: checkInterval, broadcaster: broadcaster)
        }
        thread.name = "PerformanceOptimizationKit.HangDetector"
        thread.qualityOfService = .userInitiated
        thread.start()
    }

    /// Stops watching. A hang in progress is not reported.
    public func stop() {
        state.withLock { $0.runID = nil }
    }

    // The thread function only touches Sendable values, so the detector can be released while
    // it runs; the thread ends at its next check.
    private static func watch(runID: UUID, state: OSAllocatedUnfairLock<WatchState>, queue: DispatchQueue, threshold: Duration, checkInterval: Duration, broadcaster: Broadcaster<HangEvent>) {
        let pause = checkInterval.seconds
        while state.withLock({ $0.runID == runID }) {
            let ping = Ping(submitted: uptimeNanoseconds(), date: Date())
            let alreadyWaiting = state.withLock { state -> Bool in
                guard state.waiting == nil else { return true }
                state.waiting = ping
                return false
            }
            if !alreadyWaiting {
                queue.async {
                    let answered = uptimeNanoseconds()
                    // Only the ping this block belongs to may be cleared: after stop() and
                    // start() a block from the previous run can still be in the queue.
                    let current = state.withLock { state -> Bool in
                        guard state.runID == runID, state.waiting?.id == ping.id else { return false }
                        state.waiting = nil
                        return true
                    }
                    guard current else { return }
                    let elapsed = answered >= ping.submitted ? answered - ping.submitted : 0
                    let duration = Duration.nanoseconds(Int64(clamping: elapsed))
                    if duration >= threshold {
                        broadcaster.yield(HangEvent(start: ping.date, duration: duration))
                    }
                }
            }
            Thread.sleep(forTimeInterval: pause)
        }
    }

    private static func uptimeNanoseconds() -> UInt64 {
        clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
    }
}

private struct Ping: Sendable {
    let id = UUID()
    let submitted: UInt64
    let date: Date
}

private struct WatchState: Sendable {
    var runID: UUID?
    var waiting: Ping?
}
