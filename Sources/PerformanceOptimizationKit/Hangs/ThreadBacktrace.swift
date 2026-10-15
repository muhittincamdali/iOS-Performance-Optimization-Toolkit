import Darwin
import Foundation

/// One frame of a backtrace: an address in the code and, when it can be found, the binary and
/// function it belongs to.
public struct StackFrame: Sendable, Equatable, Codable {
    /// The code address. For frames after the first, the return address of the call.
    public let address: UInt
    /// The file name of the binary, such as `MyApp` or `UIKitCore`.
    public let image: String?
    /// The function name, demangled when it is a Swift name, or `nil` when the binary has no
    /// symbols for it (a stripped release build; symbolicate those with the dSYM).
    public let symbol: String?
    /// The distance from the start of `symbol`, in bytes.
    public let offset: UInt?

    /// Creates a frame from known values, for tests and previews.
    public init(address: UInt, image: String? = nil, symbol: String? = nil, offset: UInt? = nil) {
        self.address = address
        self.image = image
        self.symbol = symbol
        self.offset = offset
    }
}

/// Reads the call stack of another thread of this process.
///
/// The thread is suspended for as long as it takes to copy its frame pointers (a few
/// microseconds) and resumed before anything that could take a lock, such as allocating or
/// looking up symbols, so a thread suspended inside `malloc` cannot deadlock the reader.
enum ThreadBacktrace {
    static let maximumFrames = 128
    private static let asyncFrameFlag: UInt = 1 << 60

    /// The addresses of `thread`'s frames, innermost first, or `nil` when the thread cannot be
    /// suspended or read, or on architectures whose frames cannot be walked this way.
    static func addresses(of thread: thread_t) -> [UInt]? {
        guard thread != currentThreadPort() else { return nil }
        let buffer = UnsafeMutablePointer<UInt>.allocate(capacity: maximumFrames)
        defer { buffer.deallocate() }
        guard thread_suspend(thread) == KERN_SUCCESS else { return nil }
        let count = walk(thread, into: buffer)
        thread_resume(thread)
        guard count > 0 else { return nil }
        return Array(UnsafeBufferPointer(start: buffer, count: count))
    }

    /// Resolves addresses to binaries and symbols with `dladdr`.
    static func symbolicate(_ addresses: [UInt]) -> [StackFrame] {
        addresses.enumerated().map { index, address in
            // A return address points after the call; one byte back is inside the calling line.
            let lookup = index == 0 ? address : address &- 1
            var info = Dl_info()
            guard let pointer = UnsafeRawPointer(bitPattern: lookup), dladdr(pointer, &info) != 0 else {
                return StackFrame(address: address)
            }
            let image = info.dli_fname.map { (String(cString: $0) as NSString).lastPathComponent }
            let symbol = info.dli_sname.map { demangle(String(cString: $0)) }
            let start = UInt(bitPattern: info.dli_saddr)
            return StackFrame(address: address, image: image, symbol: symbol, offset: start > 0 && lookup >= start ? lookup - start : nil)
        }
    }

    // Runs while the thread is suspended: no allocation, no locks, only kernel calls and reads
    // of this process's memory through vm_read_overwrite, which fails instead of crashing on a
    // bad address.
    private static func walk(_ thread: thread_t, into buffer: UnsafeMutablePointer<UInt>) -> Int {
        guard let registers = registers(of: thread) else { return 0 }
        var count = 0
        buffer[count] = strip(registers.pc)
        count += 1
        var framePointer = registers.fp
        while count < maximumFrames, framePointer != 0, framePointer % UInt(MemoryLayout<UInt>.alignment) == 0 {
            var frame: (previous: UInt, returnAddress: UInt) = (0, 0)
            var copied: vm_size_t = 0
            let size = vm_size_t(MemoryLayout<(UInt, UInt)>.size)
            let result = withUnsafeMutablePointer(to: &frame) { pointer in
                vm_read_overwrite(mach_task_self_, vm_address_t(framePointer), size, vm_address_t(UInt(bitPattern: pointer)), &copied)
            }
            guard result == KERN_SUCCESS, copied == size, frame.returnAddress != 0 else { break }
            buffer[count] = strip(frame.returnAddress)
            count += 1
            // Swift marks the frame of an async function by setting bit 60; its caller lives in
            // a heap-allocated context with another layout, so the walk ends there.
            guard frame.previous & asyncFrameFlag == 0 else { break }
            // The stack grows down, so each caller's frame is at a higher address.
            guard frame.previous > framePointer else { break }
            framePointer = frame.previous
        }
        return count
    }

    private static func registers(of thread: thread_t) -> (pc: UInt, fp: UInt)? {
        #if arch(arm64) && !_ptrauth(_arm64e)
        var state = arm_thread_state64_t()
        var count = mach_msg_type_number_t(MemoryLayout<arm_thread_state64_t>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &state) { pointer in
            pointer.withMemoryRebound(to: natural_t.self, capacity: Int(count)) {
                thread_get_state(thread, ARM_THREAD_STATE64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        return (UInt(state.__pc), UInt(state.__fp))
        #elseif arch(x86_64)
        var state = x86_thread_state64_t()
        var count = mach_msg_type_number_t(MemoryLayout<x86_thread_state64_t>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &state) { pointer in
            pointer.withMemoryRebound(to: natural_t.self, capacity: Int(count)) {
                thread_get_state(thread, x86_THREAD_STATE64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        return (UInt(state.__rip), UInt(state.__rbp))
        #else
        return nil
        #endif
    }

    // System code on Apple silicon signs return addresses (pointer authentication); the
    // signature sits in the high bits and has to go before the address can be looked up.
    private static func strip(_ address: UInt) -> UInt {
        #if arch(arm64)
        return address & 0x0000_000F_FFFF_FFFF
        #else
        return address
        #endif
    }

    private static func currentThreadPort() -> thread_t {
        let port = mach_thread_self()
        mach_port_deallocate(mach_task_self_, port)
        return port
    }

    private static func demangle(_ name: String) -> String {
        guard name.hasPrefix("$s") || name.hasPrefix("_$s") else { return name }
        guard let demangled = swiftDemangle(name, UInt(name.utf8.count), nil, nil, 0) else { return name }
        defer { free(demangled) }
        return String(cString: demangled)
    }
}

// The Swift runtime's demangler, the one the standard library uses for type names. It returns
// a malloc'ed string that the caller frees.
@_silgen_name("swift_demangle")
private func swiftDemangle(
    _ mangledName: UnsafePointer<CChar>?,
    _ mangledNameLength: UInt,
    _ outputBuffer: UnsafeMutablePointer<CChar>?,
    _ outputBufferSize: UnsafeMutablePointer<UInt>?,
    _ flags: UInt32
) -> UnsafeMutablePointer<CChar>?
