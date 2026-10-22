import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("PerformanceTracer")
struct PerformanceTracerTests {
    @Test("records the duration of synchronous work")
    func measuresSync() throws {
        let tracer = PerformanceTracer(subsystem: "tests", samplesPerName: 10)
        let result = tracer.measure("sleep") { () -> Int in
            Thread.sleep(forTimeInterval: 0.05)
            return 7
        }
        #expect(result == 7)
        let statistics = try #require(tracer.statistics(for: "sleep"))
        #expect(statistics.count == 1)
        #expect(statistics.minimum >= 0.045)
    }

    @Test("records asynchronous work, including time suspended")
    func measuresAsync() async throws {
        let tracer = PerformanceTracer(subsystem: "tests")
        try await tracer.measure("wait") { try await Task.sleep(for: .milliseconds(60)) }
        let statistics = try #require(tracer.statistics(for: "wait"))
        #expect(statistics.minimum >= 0.055)
    }

    @Test("records work that throws")
    func measuresThrowing() {
        struct Failure: Error {}
        let tracer = PerformanceTracer(subsystem: "tests")
        #expect(throws: Failure.self) { try tracer.measure("fails") { () throws -> Void in throw Failure() } }
        #expect(tracer.statistics(for: "fails")?.count == 1)
    }

    @Test("keeps only the newest samples per name")
    func boundedSamples() throws {
        let tracer = PerformanceTracer(subsystem: "tests", samplesPerName: 3)
        for milliseconds in [100, 200, 300, 400, 500] {
            tracer.record("op", duration: .milliseconds(milliseconds))
        }
        let statistics = try #require(tracer.statistics(for: "op"))
        #expect(statistics.count == 3)
        #expect(abs(statistics.minimum - 0.3) < 1e-9)
    }

    @Test("stops adding names at the limit and counts the rest")
    func boundedNames() {
        let tracer = PerformanceTracer(subsystem: "tests", maximumNames: 2)
        for index in 0..<5 {
            tracer.record("name \(index)", duration: .milliseconds(1))
        }
        tracer.record("name 0", duration: .milliseconds(2))
        #expect(tracer.names == ["name 0", "name 1"])
        #expect(tracer.droppedCount == 3)
        #expect(tracer.statistics(for: "name 0")?.count == 2)
    }

    @Test("ignores negative durations and can be emptied")
    func negativeAndRemoveAll() {
        let tracer = PerformanceTracer(subsystem: "tests")
        tracer.record("op", duration: .milliseconds(-5))
        #expect(tracer.statistics(for: "op") == nil)
        tracer.record("op", duration: .milliseconds(5))
        tracer.removeAll()
        #expect(tracer.names.isEmpty)
    }

    @Test("does not record names longer than the limit")
    func longNames() {
        let tracer = PerformanceTracer(subsystem: "tests")
        let longest = String(repeating: "n", count: PerformanceTracer.maximumNameLength)
        tracer.record(longest, duration: .milliseconds(1))
        tracer.record(longest + "n", duration: .milliseconds(1))
        // "é" takes two bytes in UTF-8, so this name is over the limit with fewer characters.
        tracer.record(String(repeating: "é", count: PerformanceTracer.maximumNameLength / 2 + 1), duration: .milliseconds(1))
        #expect(tracer.names == [longest])
        #expect(tracer.droppedCount == 2)
    }

    @Test("clamps its limits")
    func clampsLimits() {
        let tracer = PerformanceTracer(subsystem: "tests", samplesPerName: 0, maximumNames: 1_000_000)
        #expect(tracer.samplesPerName == 1)
        #expect(tracer.maximumNames == 10_000)
    }
}
