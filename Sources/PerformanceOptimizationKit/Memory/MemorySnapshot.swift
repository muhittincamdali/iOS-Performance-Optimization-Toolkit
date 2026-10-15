import Darwin
import Foundation
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import os
#endif

/// The memory use of the current process at one moment.
///
/// ``footprintBytes`` is the figure the system compares with the app's memory limit and the one
/// Xcode's memory gauge and the Memory Report show. It counts dirty and compressed memory the
/// process owns, which is why it is usually larger than ``residentBytes`` on a device and
/// smaller on a Mac.
public struct MemorySnapshot: Sendable, Equatable, Codable {
    /// The physical footprint of the process, in bytes.
    public let footprintBytes: UInt64
    /// The highest footprint since the process started, in bytes, or `nil` when the kernel does
    /// not report it.
    public let peakFootprintBytes: UInt64?
    /// The memory currently resident in RAM, in bytes.
    public let residentBytes: UInt64
    /// How many more bytes the app can allocate before it reaches its limit, or `nil` on macOS,
    /// where apps have no such limit.
    public let availableBytes: UInt64?
    /// The physical memory of the device, in bytes.
    public let physicalMemoryBytes: UInt64

    /// Creates a snapshot from known values, for tests and previews.
    public init(
        footprintBytes: UInt64,
        peakFootprintBytes: UInt64? = nil,
        residentBytes: UInt64 = 0,
        availableBytes: UInt64? = nil,
        physicalMemoryBytes: UInt64 = ProcessInfo.processInfo.physicalMemory
    ) {
        self.footprintBytes = footprintBytes
        self.peakFootprintBytes = peakFootprintBytes
        self.residentBytes = residentBytes
        self.availableBytes = availableBytes
        self.physicalMemoryBytes = physicalMemoryBytes
    }

    /// The fraction of the app's memory budget in use, from 0 to 1: the footprint divided by
    /// footprint plus available memory. `nil` when the available memory is unknown.
    public var budgetUsage: Double? {
        guard let availableBytes else { return nil }
        let budget = Double(footprintBytes) + Double(availableBytes)
        guard budget > 0 else { return nil }
        return Double(footprintBytes) / budget
    }

    /// Reads the current process's memory use, or returns `nil` when the kernel call fails.
    public static func current() -> MemorySnapshot? {
        var info = task_vm_info_data_t()
        let capacity = MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size
        var count = mach_msg_type_number_t(capacity)
        let result = withUnsafeMutablePointer(to: &info) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: capacity) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        let filledBytes = Int(count) * MemoryLayout<natural_t>.size
        return MemorySnapshot(
            footprintBytes: covers(\.phys_footprint, filledBytes) ? info.phys_footprint : info.resident_size,
            peakFootprintBytes: peak(of: info, filledBytes: filledBytes),
            residentBytes: info.resident_size,
            availableBytes: availableMemory(),
            physicalMemoryBytes: ProcessInfo.processInfo.physicalMemory
        )
    }

    // Older kernels fill only the first part of task_vm_info; a field past `count` is garbage.
    private static func covers<Value>(_ field: KeyPath<task_vm_info_data_t, Value>, _ filledBytes: Int) -> Bool {
        guard let offset = MemoryLayout<task_vm_info_data_t>.offset(of: field) else { return false }
        return offset + MemoryLayout<Value>.size <= filledBytes
    }

    private static func peak(of info: task_vm_info_data_t, filledBytes: Int) -> UInt64? {
        guard covers(\.ledger_phys_footprint_peak, filledBytes), info.ledger_phys_footprint_peak > 0 else { return nil }
        return UInt64(info.ledger_phys_footprint_peak)
    }

    private static func availableMemory() -> UInt64? {
        #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        let available = os_proc_available_memory()
        return available > 0 ? UInt64(available) : nil
        #else
        return nil
        #endif
    }
}
