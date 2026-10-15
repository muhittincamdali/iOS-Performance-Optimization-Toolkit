import Darwin
import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("CPU")
struct CPUTests {
    @Test("reads the threads of the process")
    func readsThreads() throws {
        let snapshot = try #require(CPUSnapshot.current())
        #expect(snapshot.threadCount >= 1)
        #expect(snapshot.usage >= 0)
        #expect(snapshot.activeProcessorCount >= 1)
    }

    @Test("does not leak thread ports")
    func noPortLeak() throws {
        let before = try #require(Self.portCount())
        for _ in 0..<2_000 {
            _ = CPUSnapshot.current()
        }
        let after = try #require(Self.portCount())
        // Without mach_port_deallocate each call would leave one right per thread behind,
        // thousands in total. Other tests running in parallel open a few ports of their own.
        #expect(after < before + 200)
    }

    @Test("corrects invalid values, also when decoding")
    func correctsValues() throws {
        let snapshot = CPUSnapshot(usage: .nan, threadCount: -3, activeProcessorCount: 0)
        #expect(snapshot.usage == 0)
        #expect(snapshot.threadCount == 0)
        #expect(snapshot.activeProcessorCount == 1)
        let json = Data(#"{"usage":-50,"threadCount":-1,"activeProcessorCount":-8}"#.utf8)
        let decoded = try JSONDecoder().decode(CPUSnapshot.self, from: json)
        #expect(decoded == CPUSnapshot(usage: 0, threadCount: 0, activeProcessorCount: 1))
    }

    @Test("caps the share of all cores at 1")
    func capacityFraction() {
        #expect(CPUSnapshot(usage: 200, threadCount: 4, activeProcessorCount: 4).totalCapacityFraction == 0.5)
        #expect(CPUSnapshot(usage: 900, threadCount: 4, activeProcessorCount: 4).totalCapacityFraction == 1)
    }

    @Test("CPU time grows while the process computes")
    func cpuTimeGrows() throws {
        let start = ProcessCPUTime.now()
        let ownThread = ProcessCPUTime.currentThreadTime()
        // Spin until this thread alone has used 100 ms of CPU, however busy the machine is.
        var value = 0.0
        while ProcessCPUTime.currentThreadTime() - ownThread < .milliseconds(100) { value += sin(value + 1) }
        #expect(value.isFinite)
        let end = ProcessCPUTime.now()
        #expect(end.total - start.total >= .milliseconds(100))
        let load = try #require(end.utilization(since: start))
        #expect(load > 0)
        #expect(load <= Double(ProcessInfo.processInfo.activeProcessorCount) + 0.5)
    }

    @Test("a sleeping thread uses no CPU time")
    func sleepingThread() {
        let before = ProcessCPUTime.currentThreadTime()
        Thread.sleep(forTimeInterval: 0.1)
        #expect(ProcessCPUTime.currentThreadTime() - before < .milliseconds(20))
    }

    @Test("utilization needs an earlier reading")
    func utilizationOrder() {
        let earlier = ProcessCPUTime(user: .seconds(1), system: .zero, uptime: .seconds(10))
        let later = ProcessCPUTime(user: .seconds(2), system: .seconds(1), uptime: .seconds(12))
        #expect(later.utilization(since: earlier) == 1)
        #expect(earlier.utilization(since: later) == nil)
        #expect(later.utilization(since: later) == nil)
    }

    private static func portCount() -> Int? {
        var names: mach_port_name_array_t?
        var nameCount = mach_msg_type_number_t(0)
        var types: mach_port_type_array_t?
        var typeCount = mach_msg_type_number_t(0)
        guard mach_port_names(mach_task_self_, &names, &nameCount, &types, &typeCount) == KERN_SUCCESS else { return nil }
        if let names {
            vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: names)), vm_size_t(Int(nameCount) * MemoryLayout<mach_port_name_t>.stride))
        }
        if let types {
            vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: types)), vm_size_t(Int(typeCount) * MemoryLayout<mach_port_type_t>.stride))
        }
        return Int(nameCount)
    }
}
