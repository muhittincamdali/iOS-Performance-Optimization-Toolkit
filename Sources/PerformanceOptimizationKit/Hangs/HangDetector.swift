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
/// let detector = HangDetector(capturesBacktraces: true)
/// detector.start()
/// for await hang in detector.events() {
///     logger.warning("Main thread blocked for \(hang.duration)")
/// }
/// ```
///
/// With `capturesBacktraces`, the detector also records what the main thread was running once
/// it has been blocked for `threshold` (see ``HangEvent/backtrace``). For the full picture,
/// record the app with the Hangs instrument, or read the hang diagnostics MetricKit delivers.
public final class HangDetector: Sendable {
    /// The shortest unresponsive period that is reported.
    public let threshold: Duration
    /// How often the background thread checks the queue.
    public let checkInterval: Duration
    /// A Boolean value that indicates whether hangs of the main queue come with a backtrace.
    public let capturesBacktraces: Bool

    private let queue: DispatchQueue
    private let state = OSAllocatedUnfairLock(initialState: WatchState())
    private let broadcaster = Broadcaster<HangEvent>()

    /// Creates a detector that is not running yet.
    ///
    /// - Parameters:
    ///   - threshold: The shortest period to report, from 50 ms to one hour.
    ///   - checkInterval: How often to check, from 10 ms to one second and at most `threshold`.
    ///     Shorter intervals notice hangs sooner and wake the background thread more often.
    ///   - queue: The serial queue to watch.
    ///   - capturesBacktraces: Whether to record the main thread's call stack during a hang.
    ///     Only the main queue runs on a known thread, so this has no effect on other queues.
    public init(threshold: Duration = .milliseconds(250), checkInterval: Duration = .milliseconds(50), queue: DispatchQueue = .main, capturesBacktraces: Bool = false) {
        self.threshold = min(max(threshold, .milliseconds(50)), .seconds(3600))
        self.checkInterval = min(max(checkInterval, .milliseconds(10)), self.threshold, .seconds(1))
        self.queue = queue
        self.capturesBacktraces = capturesBacktraces && queue === DispatchQueue.main
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
        if capturesBacktraces { registerMainThread(runID: runID) }
        let watcher = Watcher(runID: runID, state: state, queue: queue, threshold: threshold, checkInterval: checkInterval, broadcaster: broadcaster)
        let thread = Thread { watcher.run() }
        thread.name = "PerformanceOptimizationKit.HangDetector"
        thread.qualityOfService = .userInitiated
        thread.start()
    }

    /// Stops watching. A hang in progress is not reported.
    public func stop() {
        let port = state.withLock { state -> thread_t? in
            defer {
                state.runID = nil
                state.mainThread = nil
            }
            return state.mainThread
        }
        if let port { mach_port_deallocate(mach_task_self_, port) }
    }

    // mach_thread_self() has to run on the thread it names. From another thread, the main
    // thread registers itself the next time it is free.
    private func registerMainThread(runID: UUID) {
        let register: @Sendable () -> Void = { [state] in
            let port = mach_thread_self()
            let kept = state.withLock { state -> Bool in
                guard state.runID == runID, state.mainThread == nil else { return false }
                state.mainThread = port
                return true
            }
            if !kept { mach_port_deallocate(mach_task_self_, port) }
        }
        if Thread.isMainThread { register() } else { DispatchQueue.main.async(execute: register) }
    }
}

// The watching thread's work. It holds only Sendable values, so the detector can be released
// while it runs; the thread ends at its next check.
private struct Watcher: Sendable {
    let runID: UUID
    let state: OSAllocatedUnfairLock<WatchState>
    let queue: DispatchQueue
    let threshold: Duration
    let checkInterval: Duration
    let broadcaster: Broadcaster<HangEvent>

    func run() {
        let pause = checkInterval.seconds
        while state.withLock({ $0.runID == runID }) {
            submitPingIfIdle()
            let before = Self.uptimeNanoseconds()
            Thread.sleep(forTimeInterval: pause)
            recordHeartbeat(sleptSince: before)
            captureBacktraceIfOverdue()
        }
    }

    // How long the watching thread may go without running before its measurement is
    // discarded. A blocked main thread does not delay this thread; a process that was
    // suspended (an app in the background, a debugger pause) delays both, and the time it spent
    // stopped is not a hang.
    // Four missed checks, and at least 100 ms, so ordinary scheduling delays do not count.
    private var staleLimit: UInt64 {
        UInt64(max(0.1, checkInterval.seconds * 4) * 1_000_000_000)
    }

    private func recordHeartbeat(sleptSince before: UInt64) {
        let now = Self.uptimeNanoseconds()
        let overslept = now >= before && now - before > staleLimit
        state.withLock { state in
            state.heartbeat = now
            guard overslept else { return }
            state.waiting = nil
            state.backtrace = nil
        }
    }

    private func submitPingIfIdle() {
        let ping = Ping(submitted: Self.uptimeNanoseconds(), date: Date())
        let submitted = state.withLock { state -> Bool in
            guard state.waiting == nil else { return false }
            state.waiting = ping
            return true
        }
        guard submitted else { return }
        queue.async { answer(ping) }
    }

    // Runs on the watched queue once it is free again.
    private func answer(_ ping: Ping) {
        let answered = Self.uptimeNanoseconds()
        // Only the ping this block belongs to may be cleared: after stop() and start() a block
        // from the previous run can still be in the queue.
        let staleLimit = staleLimit
        let backtrace = state.withLock { state -> [StackFrame]?? in
            guard state.runID == runID, state.waiting?.id == ping.id else { return .none }
            state.waiting = nil
            defer { state.backtrace = nil }
            // The watching thread has not run for a while: the process was suspended, so the
            // wait includes time in which nothing ran at all.
            let lastHeartbeat = max(state.heartbeat ?? ping.submitted, ping.submitted)
            guard answered < lastHeartbeat || answered - lastHeartbeat <= staleLimit else { return .none }
            return .some(state.backtrace?.pingID == ping.id ? state.backtrace?.frames : nil)
        }
        guard case .some(let frames) = backtrace else { return }
        let elapsed = answered >= ping.submitted ? answered - ping.submitted : 0
        let duration = Duration.nanoseconds(Int64(clamping: elapsed))
        guard duration >= threshold else { return }
        broadcaster.yield(HangEvent(start: ping.date, duration: duration, backtrace: frames))
    }

    private func captureBacktraceIfOverdue() {
        let now = Self.uptimeNanoseconds()
        let target = state.withLock { state -> (thread: thread_t, pingID: UUID)? in
            guard let thread = state.mainThread, let ping = state.waiting, state.backtrace?.pingID != ping.id else { return nil }
            let age = Duration.nanoseconds(Int64(clamping: now >= ping.submitted ? now - ping.submitted : 0))
            return age >= threshold ? (thread, ping.id) : nil
        }
        guard let target, let addresses = ThreadBacktrace.addresses(of: target.thread) else { return }
        let frames = ThreadBacktrace.symbolicate(addresses)
        state.withLock { state in
            if state.waiting?.id == target.pingID { state.backtrace = (target.pingID, frames) }
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
    var mainThread: thread_t?
    var backtrace: (pingID: UUID, frames: [StackFrame])?
    var heartbeat: UInt64?
}
