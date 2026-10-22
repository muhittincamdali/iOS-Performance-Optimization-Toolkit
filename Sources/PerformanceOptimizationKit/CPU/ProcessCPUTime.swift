import Darwin

/// The CPU time the current process has used since it started, read with `getrusage`.
///
/// Unlike ``CPUSnapshot``, which reports the kernel's smoothed usage of the threads alive right
/// now, CPU time also counts threads that have finished. Two readings give the exact average
/// load over the interval between them:
///
/// ```swift
/// let start = ProcessCPUTime.now()
/// try await importLibrary()
/// let load = ProcessCPUTime.now().utilization(since: start) // 1.0 = one core fully busy
/// ```
public struct ProcessCPUTime: Sendable, Equatable, Codable {
    /// CPU time spent running the app's own code.
    public let user: Duration
    /// CPU time the kernel spent on the app's behalf, such as for system calls.
    public let system: Duration
    /// When the reading was taken, on the system's uptime clock, which stops while the device
    /// sleeps (as the process does).
    public let uptime: Duration

    /// Creates a reading from known values, for tests.
    public init(user: Duration, system: Duration, uptime: Duration) {
        self.user = user
        self.system = system
        self.uptime = uptime
    }

    /// The total CPU time, user plus system.
    public var total: Duration { user + system }

    /// Reads the CPU time used so far.
    public static func now() -> ProcessCPUTime {
        var usage = rusage()
        getrusage(RUSAGE_SELF, &usage)
        return ProcessCPUTime(
            user: duration(of: usage.ru_utime),
            system: duration(of: usage.ru_stime),
            uptime: .nanoseconds(Int64(clamping: clock_gettime_nsec_np(CLOCK_UPTIME_RAW)))
        )
    }

    /// The CPU time the calling thread has used so far, user and system together.
    ///
    /// Two readings on the same thread measure the CPU cost of the work between them without
    /// counting other threads, which ``now()`` includes.
    public static func currentThreadTime() -> Duration {
        .nanoseconds(Int64(clamping: clock_gettime_nsec_np(CLOCK_THREAD_CPUTIME_ID)))
    }

    /// The average number of cores the process kept busy between an earlier reading and this
    /// one: 0.5 is half of one core, 2.0 two full cores.
    ///
    /// Returns `nil` when `earlier` was not taken before this reading.
    public func utilization(since earlier: ProcessCPUTime) -> Double? {
        let wall = (uptime - earlier.uptime).seconds
        guard wall > 0 else { return nil }
        let busy = (total - earlier.total).seconds
        return max(busy, 0) / wall
    }

    private static func duration(of value: timeval) -> Duration {
        let microseconds = min(max(Int64(value.tv_usec), 0), 999_999)
        return .seconds(Int64(value.tv_sec)) + .microseconds(microseconds)
    }
}
