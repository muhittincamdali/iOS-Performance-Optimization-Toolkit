import Darwin
import Foundation

/// When the current process started, read from the kernel.
public enum ProcessLaunch {
    /// The time the kernel created the process, or `nil` when it cannot be read.
    ///
    /// Read with `sysctl(KERN_PROC_PID)`. This is before `main` and before the dynamic linker
    /// loaded the app's libraries, so it covers the whole launch as people experience it.
    public static func startDate() -> Date? {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let result = name.withUnsafeMutableBufferPointer { buffer in
            sysctl(buffer.baseAddress, u_int(buffer.count), &info, &size, nil, 0)
        }
        guard result == 0, size == MemoryLayout<kinfo_proc>.stride else { return nil }
        return date(from: info.kp_proc.p_un.__p_starttime)
    }

    /// A Boolean value that indicates whether the system started the process ahead of time
    /// (prewarming, iOS 15 and later).
    ///
    /// A prewarmed process can sit idle for a long time before the person opens the app, so the
    /// time since ``startDate()`` says nothing about the launch they saw. The system sets the
    /// `ActivePrewarm` environment variable to `1` in that case.
    public static var wasPrewarmed: Bool {
        ProcessInfo.processInfo.environment["ActivePrewarm"] == "1"
    }

    /// Converts a `timeval` to a date, or returns `nil` for values the kernel never reports
    /// (zero, negative or out-of-range microseconds).
    static func date(from time: timeval) -> Date? {
        guard time.tv_sec > 0, (0..<1_000_000).contains(Int64(time.tv_usec)) else { return nil }
        return Date(timeIntervalSince1970: Double(time.tv_sec) + Double(time.tv_usec) / 1_000_000)
    }
}
