import Darwin
import Foundation

/// The CPU use of the current process's threads at one moment.
///
/// ``usage`` is the sum of the kernel's recent-usage figure of each thread, in percent of one
/// core, the scale Xcode's CPU gauge uses: 100 means one core fully busy and the maximum is
/// 100 times ``activeProcessorCount``. The kernel smooths it over the last few seconds; for an
/// exact average over an interval, use ``ProcessCPUTime``.
public struct CPUSnapshot: Sendable, Equatable, Codable {
    /// The CPU use of all threads, in percent of one core.
    public let usage: Double
    /// The number of threads in the process.
    public let threadCount: Int
    /// The number of cores the process can use.
    public let activeProcessorCount: Int

    /// Creates a snapshot from known values, for tests and previews.
    public init(usage: Double, threadCount: Int, activeProcessorCount: Int = ProcessInfo.processInfo.activeProcessorCount) {
        self.usage = usage.isFinite ? max(usage, 0) : 0
        self.threadCount = max(threadCount, 0)
        self.activeProcessorCount = max(activeProcessorCount, 1)
    }

    /// Decodes a snapshot and corrects values like ``init(usage:threadCount:activeProcessorCount:)``.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            usage: try container.decode(Double.self, forKey: .usage),
            threadCount: try container.decode(Int.self, forKey: .threadCount),
            activeProcessorCount: try container.decode(Int.self, forKey: .activeProcessorCount)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case usage, threadCount, activeProcessorCount
    }

    /// The usage as a fraction of all cores, from 0 to 1.
    public var totalCapacityFraction: Double {
        min(usage / (100 * Double(activeProcessorCount)), 1)
    }

    /// Reads the current CPU use of every thread, or returns `nil` when the kernel call fails.
    public static func current() -> CPUSnapshot? {
        var threads: thread_act_array_t?
        var threadCount = mach_msg_type_number_t(0)
        guard task_threads(mach_task_self_, &threads, &threadCount) == KERN_SUCCESS, let threads else { return nil }
        // task_threads hands over one port right per thread and an array allocated in this task;
        // both have to be given back, or each call leaks them.
        defer {
            for index in 0..<Int(threadCount) {
                mach_port_deallocate(mach_task_self_, threads[index])
            }
            let size = vm_size_t(Int(threadCount) * MemoryLayout<thread_act_t>.stride)
            vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threads)), size)
        }
        var usage = 0.0
        for index in 0..<Int(threadCount) {
            usage += threadUsage(threads[index])
        }
        return CPUSnapshot(usage: usage, threadCount: Int(threadCount))
    }

    private static func threadUsage(_ thread: thread_act_t) -> Double {
        var info = thread_basic_info()
        let capacity = MemoryLayout<thread_basic_info>.size / MemoryLayout<natural_t>.size
        var count = mach_msg_type_number_t(capacity)
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: capacity) {
                thread_info(thread, thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS, info.flags & TH_FLAGS_IDLE == 0 else { return 0 }
        return Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100
    }
}
