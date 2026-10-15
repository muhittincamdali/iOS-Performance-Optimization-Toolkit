import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("PerformanceBudget")
struct PerformanceBudgetTests {
    private let measurements = PerformanceMeasurements(
        memory: MemorySnapshot(footprintBytes: 200 * 1_048_576),
        cpu: CPUSnapshot(usage: 150, threadCount: 12),
        frames: FrameStatistics(frameCount: 50, duration: 1, hitchTime: 0.03, droppedFrameCount: 3, longestFrame: 0.05, shortestTargetInterval: 1.0 / 60),
        hangs: [HangEvent(start: Date(), duration: .milliseconds(300)), HangEvent(start: Date(), duration: .milliseconds(900))],
        launch: LaunchMeasurement(processStart: Date(), timeToFirstFrame: .milliseconds(700)),
        traces: ["Load feed": SampleStatistics([0.1, 0.2, 0.5])!]
    )

    @Test("an empty budget has no violations")
    func emptyBudget() {
        #expect(PerformanceBudget().evaluate(measurements).isEmpty)
    }

    @Test("reports every exceeded limit in a fixed order")
    func allViolations() {
        let budget = PerformanceBudget(
            maximumFootprintBytes: 150 * 1_048_576,
            maximumCPUUsage: 100,
            maximumHitchTimeRatio: 10,
            minimumFramesPerSecond: 55,
            maximumHangDuration: .milliseconds(500),
            maximumTimeToFirstFrame: .milliseconds(400),
            traceLimits: ["Load feed": .milliseconds(300)]
        )
        let violations = budget.evaluate(measurements)
        #expect(violations.map(\.metric) == [.footprint, .cpuUsage, .hitchTimeRatio, .framesPerSecond, .hangDuration, .timeToFirstFrame, .trace("Load feed")])
        #expect(abs(violations[4].measured - 0.9) < 1e-9)
        #expect(violations.map(\.description) == [
            "footprint 200 MB exceeds 150 MB",
            "CPU 150% exceeds 100%",
            "hitch time ratio 30 ms/s exceeds 10 ms/s",
            "50 fps is below 55 fps",
            "hang of 900 ms exceeds 500 ms",
            "first frame after 700 ms exceeds 400 ms",
            "Load feed p95 470 ms exceeds 300 ms",
        ])
    }

    @Test("limits that are met are not reported")
    func withinBudget() {
        let budget = PerformanceBudget(maximumFootprintBytes: 300 * 1_048_576, maximumHangDuration: .seconds(1), traceLimits: ["Load feed": .seconds(1)])
        #expect(budget.evaluate(measurements).isEmpty)
    }

    @Test("NaN limits, missing measurements and unknown traces are skipped")
    func skipsUnknowns() {
        let budget = PerformanceBudget(maximumCPUUsage: .nan, maximumHitchTimeRatio: 1, minimumFramesPerSecond: 60, traceLimits: ["Unknown": .milliseconds(1)])
        #expect(budget.evaluate(PerformanceMeasurements(cpu: CPUSnapshot(usage: 999, threadCount: 1))).isEmpty)
    }

    @Test("an empty frame window is not a frame rate violation")
    func emptyFrames() {
        let budget = PerformanceBudget(minimumFramesPerSecond: 60)
        let empty = FrameStatistics(frameCount: 0, duration: 0, hitchTime: 0, droppedFrameCount: 0, longestFrame: 0, shortestTargetInterval: 0)
        #expect(budget.evaluate(PerformanceMeasurements(frames: empty)).isEmpty)
    }

    @Test("round-trips through JSON, so budgets can live in a file")
    func codable() throws {
        let budget = PerformanceBudget(maximumFootprintBytes: 1, maximumHangDuration: .milliseconds(250), traceLimits: ["a": .seconds(1)])
        #expect(try JSONDecoder().decode(PerformanceBudget.self, from: JSONEncoder().encode(budget)) == budget)
    }
}
