import Foundation
import Testing
@testable import PerformanceOptimizationKit

/// Tests that block a thread or depend on timing run one at a time, so one cannot block the
/// thread another one measures.
@Suite(.serialized)
struct TimingSensitiveTests {}

extension TimingSensitiveTests {
    @Suite("HangDetector")
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

        @Test("captures the main thread's call stack during a hang")
        @MainActor
        func capturesBacktrace() async throws {
            let detector = HangDetector(threshold: .milliseconds(150), checkInterval: .milliseconds(20), capturesBacktraces: true)
            let (collector, task) = collect(detector)
            detector.start()
            try await Task.sleep(for: .milliseconds(100))
            spinOnMainThreadForBacktraceTest(seconds: 0.4)
            for _ in 0..<50 where collector.all.isEmpty {
                try await Task.sleep(for: .milliseconds(20))
            }
            detector.stop()
            task.cancel()
            let hang = try #require(collector.all.first)
            let frames = try #require(hang.backtrace)
            #expect(frames.count >= 3)
            #expect(frames.contains { $0.symbol?.contains("spinOnMainThreadForBacktraceTest") == true })
            #expect(frames.contains { $0.image != nil })
        }

        #if os(macOS)
        @Test("time in which the whole process was stopped is not a hang")
        func stoppedProcess() async throws {
            let queue = DispatchQueue(label: "stop-process-test")
            let detector = HangDetector(threshold: .milliseconds(150), checkInterval: .milliseconds(20), queue: queue)
            let (collector, task) = collect(detector)
            detector.start()
            try await Task.sleep(for: .milliseconds(100))
            // A helper process resumes this one 0.6 s after it stops itself, as the system does
            // with an app that returns from the background. The queue is busy at that moment, so
            // a check is waiting for it while nothing runs.
            let resumer = Process()
            resumer.executableURL = URL(fileURLWithPath: "/bin/sh")
            resumer.arguments = ["-c", "sleep 0.6; kill -CONT \(getpid())"]
            try resumer.run()
            queue.async { Thread.sleep(forTimeInterval: 0.08) }
            usleep(30_000)
            kill(getpid(), SIGSTOP)
            try await Task.sleep(for: .milliseconds(400))
            detector.stop()
            task.cancel()
            resumer.waitUntilExit()
            #expect(collector.all.isEmpty)
        }
        #endif

        @Test("captures backtraces only for the main queue")
        func backtracesNeedMainQueue() {
            #expect(!HangDetector(queue: DispatchQueue(label: "other"), capturesBacktraces: true).capturesBacktraces)
            #expect(HangDetector(capturesBacktraces: true).capturesBacktraces)
            #expect(!HangDetector().capturesBacktraces)
        }

        @Test("a thread cannot read its own stack this way")
        func ownThread() {
            let port = mach_thread_self()
            defer { mach_port_deallocate(mach_task_self_, port) }
            #expect(ThreadBacktrace.addresses(of: port) == nil)
        }

        @Test("clamps threshold and check interval")
        func clampsSettings() {
            let detector = HangDetector(threshold: .milliseconds(1), checkInterval: .seconds(5))
            #expect(detector.threshold == .milliseconds(50))
            #expect(detector.checkInterval == .milliseconds(50))
            #expect(HangDetector(checkInterval: .zero).checkInterval == .milliseconds(10))
            let huge = HangDetector(threshold: .seconds(Int64.max), checkInterval: .seconds(Int64.max))
            #expect(huge.threshold == .seconds(3600))
            #expect(huge.checkInterval == .seconds(1))
        }

        @Test("classifies durations with Apple's limits", arguments: [
            (Duration.milliseconds(99), HangSeverity.unnoticeable), (.milliseconds(100), .delay),
            (.milliseconds(249), .delay), (.milliseconds(250), .hang), (.seconds(5), .hang),
        ])
        func severity(duration: Duration, expected: HangSeverity) {
            #expect(HangSeverity(duration: duration) == expected)
        }
    }
}

// A function with a name the backtrace test can look for. Busy-waiting keeps the frame on
// the stack the whole time.
@inline(never)
func spinOnMainThreadForBacktraceTest(seconds: Double) {
    let deadline = ContinuousClock.now + .seconds(seconds)
    var value = 0.0
    while ContinuousClock.now < deadline { value += sin(value + 1) }
    precondition(value.isFinite)
}
