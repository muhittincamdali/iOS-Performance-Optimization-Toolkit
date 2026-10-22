import Darwin
import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("MemorySnapshot")
struct MemorySnapshotTests {
    @Test("reads a footprint from the kernel")
    func readsFootprint() throws {
        let snapshot = try #require(MemorySnapshot.current())
        #expect(snapshot.footprintBytes > 1_048_576)
        #expect(snapshot.physicalMemoryBytes == ProcessInfo.processInfo.physicalMemory)
        if let peak = snapshot.peakFootprintBytes {
            #expect(peak >= snapshot.footprintBytes / 2)
        }
    }

    @Test("the footprint grows by the memory the process writes to")
    func footprintFollowsAllocations() throws {
        let size = 64 * 1_048_576
        let before = try #require(MemorySnapshot.current())
        let buffer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 16)
        defer { buffer.deallocate() }
        // Only written pages count; touching every page makes them dirty.
        memset(buffer, 0xA5, size)
        let after = try #require(MemorySnapshot.current())
        #expect(after.footprintBytes >= before.footprintBytes + UInt64(size / 2))
    }

    @Test("the budget share needs the available memory", arguments: [
        (100, nil, nil), (0, 0, nil), (25, 75, 0.25),
    ] as [(UInt64, UInt64?, Double?)])
    func budgetUsage(footprint: UInt64, available: UInt64?, expected: Double?) {
        let snapshot = MemorySnapshot(footprintBytes: footprint, availableBytes: available)
        #expect(snapshot.budgetUsage == expected)
    }
}
