import Foundation

/// Deep memory allocation tracker.
public actor MemoryProfiler {
    public static let shared = MemoryProfiler()
    
    private init() {}
    
    public func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
    
    public func logCurrentUsage() {
        let bytes = getMemoryUsage()
        let megabytes = Double(bytes) / 1024.0 / 1024.0
        print("🧠 [Performance] Memory Usage: \\(String(format: \"%.2f\", megabytes)) MB")
    }
}
