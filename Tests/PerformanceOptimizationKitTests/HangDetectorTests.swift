import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("HangDetector", .serialized)
struct HangDetectorTests {
    // Collects the events of a stream into an array that the test can read later.
    private final class Collector: @unchecked Sendable {
        private let lock = NSLock()
        private var events: [HangEvent] = []
        var all: [HangEvent] { lock.withLock { events } }
        func add(_ event: HangEvent) { lock.withLock { events.append(event) } }
    }

    private func collect(_ detector: HangDetector) -> (Collector, Task<Void, Never>) {
        let collector = Collector()
        let stream = detector.events()
        let task = Task { for await event in stream { collector.add(event) } }
        return (collector, task)
    }

    @Test("reports a blocked queue with the time it was blocked")
    func reportsHang() async throws {
        let queue = DispatchQueue(label: "hang-test")
        let detector = HangDetector(threshold: .milliseconds(150), checkInterval: .milliseconds(20), queue: queue)
        let (collector, task) = collect(detector)
        detector.start()
        try await Task.sleep(for: .milliseconds(100))
        queue.async { Thread.sleep(forTimeInterval: 0.4) }
        try await Task.sleep(for: .milliseconds(700))
        detector.stop()
        task.cancel()
        let hang = try #require(collector.all.first)
        #expect(collector.all.count == 1)
        #expect(hang.duration >= .milliseconds(300))
        // A loaded machine can start the blocking work late, so the upper bound is generous.
        #expect(hang.duration < .seconds(2))
        #expect(hang.severity == .hang)
    }

    @Test("stays quiet while the queue keeps up")
    func quietQueue() async throws {
        let queue = DispatchQueue(label: "quiet-test")
        let detector = HangDetector(threshold: .milliseconds(250), checkInterval: .milliseconds(20), queue: queue)
        let (collector, task) = collect(detector)
        detector.start()
        for _ in 0..<10 {
            queue.async { Thread.sleep(forTimeInterval: 0.01) }
            try await Task.sleep(for: .milliseconds(30))
        }
        detector.stop()
        task.cancel()
        #expect(collector.all.isEmpty)
    }

    @Test("reports nothing after stop")
    func stopEnds() async throws {
        let queue = DispatchQueue(label: "stop-test")
        let detector = HangDetector(threshold: .milliseconds(100), checkInterval: .milliseconds(20), queue: queue)
        let (collector, task) = collect(detector)
        detector.start()
        #expect(detector.isRunning)
        detector.stop()
        #expect(!detector.isRunning)
        try await Task.sleep(for: .milliseconds(60))
        queue.async { Thread.sleep(forTimeInterval: 0.3) }
        try await Task.sleep(for: .milliseconds(500))
        task.cancel()
        #expect(collector.all.isEmpty)
    }

    @Test("restarting does not report twice")
    func restart() async throws {
        let queue = DispatchQueue(label: "restart-test")
        let detector = HangDetector(threshold: .milliseconds(100), checkInterval: .milliseconds(20), queue: queue)
        let (collector, task) = collect(detector)
        detector.start()
        detector.start()
        detector.stop()
        detector.start()
        try await Task.sleep(for: .milliseconds(60))
        queue.async { Thread.sleep(forTimeInterval: 0.3) }
        try await Task.sleep(for: .milliseconds(600))
        detector.stop()
        task.cancel()
        #expect(collector.all.count == 1)
    }

    @Test("clamps threshold and check interval")
    func clampsSettings() {
        let detector = HangDetector(threshold: .milliseconds(1), checkInterval: .seconds(5))
        #expect(detector.threshold == .milliseconds(50))
        #expect(detector.checkInterval == .milliseconds(50))
        #expect(HangDetector(checkInterval: .zero).checkInterval == .milliseconds(10))
    }

    @Test("classifies durations with Apple's limits", arguments: [
        (Duration.milliseconds(99), HangSeverity.unnoticeable), (.milliseconds(100), .delay),
        (.milliseconds(249), .delay), (.milliseconds(250), .hang), (.seconds(5), .hang),
    ])
    func severity(duration: Duration, expected: HangSeverity) {
        #expect(HangSeverity(duration: duration) == expected)
    }
}
