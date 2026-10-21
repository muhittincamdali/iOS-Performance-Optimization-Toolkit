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
            // The detector drops a measurement when its own thread was held up for longer than
            // four checks, as can happen on a busy machine or a simulator that has just booted,
            // so the hang gets two more tries.
            for _ in 0..<3 where collector.all.isEmpty {
                try await Task.sleep(for: .milliseconds(100))
                spinOnMainThreadForBacktraceTest(seconds: 0.4)
                for _ in 0..<50 where collector.all.isEmpty {
                    try await Task.sleep(for: .milliseconds(20))
                }
            }
            detector.stop()
            task.cancel()
            let hang = try #require(collector.all.first)
            let frames = try #require(hang.backtrace)
            #expect(frames.count >= 3)
            #expect(frames.contains { $0.symbol?.contains("spinOnMainThreadForBacktraceTest") == true })
            #expect(frames.contains { $0.image != nil })
        }

        @Test("releases the main thread's port only once its watching thread has ended")
        @MainActor
        func releasesPortAfterWatcher() async throws {
            // The watching threads of earlier tests release their ports within one check
            // interval, which is at most one second, after their detector stopped.
            try await Task.sleep(for: .milliseconds(1_200))
            let before = mainThreadSendReferences()
            let detector = HangDetector(threshold: .seconds(1), checkInterval: .milliseconds(500), capturesBacktraces: true)
            detector.start()
            #expect(mainThreadSendReferences() == before + 1)
            // The watching thread is now in its first pause, which lasts 500 ms. It may read the
            // main thread's stack through the port when it wakes, so stop() leaves the port alone.
            try await Task.sleep(for: .milliseconds(100))
            detector.stop()
            #expect(mainThreadSendReferences() == before + 1)
            for _ in 0..<100 where mainThreadSendReferences() != before {
                try await Task.sleep(for: .milliseconds(20))
            }
            #expect(mainThreadSendReferences() == before)
        }

        // The number of references this process holds to the calling thread's port.
        private func mainThreadSendReferences() -> mach_port_urefs_t {
            let port = mach_thread_self()
            defer { mach_port_deallocate(mach_task_self_, port) }
            var references: mach_port_urefs_t = 0
            _ = mach_port_get_refs(mach_task_self_, port, MACH_PORT_RIGHT_SEND, &references)
            return references
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

        @Test("uses the link register when the program counter has no symbol")
        func linkRegisterWithoutSymbol() throws {
            let sine = UInt(bitPattern: dlsym(UnsafeMutableRawPointer(bitPattern: -2), "sin"))
            try #require(sine != 0)
            let heap = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
            defer { heap.deallocate() }
            let unnamed = UInt(bitPattern: heap)
            // A program counter in memory without a symbol, as in a stub, with the link
            // register pointing into a function: that function is the caller.
            #expect(ThreadBacktrace.callerOfLeafFunction(linkRegister: sine + 8, addresses: [unnamed, 0x10]) == sine + 8)
            // A link register inside the function the program counter is in adds nothing, and
            // neither does one that is already the next frame or that has no symbol itself.
            #expect(ThreadBacktrace.callerOfLeafFunction(linkRegister: sine + 8, addresses: [sine + 4, 0x10]) == nil)
            #expect(ThreadBacktrace.callerOfLeafFunction(linkRegister: sine + 8, addresses: [unnamed, sine + 8]) == nil)
            #expect(ThreadBacktrace.callerOfLeafFunction(linkRegister: unnamed + 8, addresses: [unnamed, 0x10]) == nil)
        }

        #if !os(watchOS)
        @Test("keeps the caller of a function that has no frame of its own")
        func leafFunctionCaller() throws {
            // `sin` runs without a frame record, so while the thread is inside it the frame
            // pointer still points at the caller's caller and only the link register holds the
            // return address into the caller.
            let spinner = LeafSpinner()
            let thread = Thread { spinner.run() }
            thread.start()
            defer { spinner.stop() }
            let port = try #require(spinner.waitForPort())
            var missing = 0
            for _ in 0..<300 {
                let addresses = try #require(ThreadBacktrace.addresses(of: port))
                let frames = ThreadBacktrace.symbolicate(addresses)
                if !frames.contains(where: { $0.symbol?.contains("spinWithLeafCallsForBacktraceTest") == true }) {
                    missing += 1
                }
                usleep(300)
            }
            #expect(missing == 0)
        }
        #endif

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

// Runs `spinWithLeafCallsForBacktraceTest` on its own thread until stopped.
private final class LeafSpinner: @unchecked Sendable {
    private let lock = NSLock()
    private let started = DispatchSemaphore(value: 0)
    private var isStopped = false
    private var port: mach_port_t = 0

    func run() {
        lock.withLock { port = pthread_mach_thread_np(pthread_self()) }
        started.signal()
        spinWithLeafCallsForBacktraceTest { self.lock.withLock { self.isStopped } }
    }

    func waitForPort() -> mach_port_t? {
        guard started.wait(timeout: .now() + 5) == .success else { return nil }
        return lock.withLock { port }
    }

    func stop() {
        lock.withLock { isStopped = true }
    }
}

// Spends most of its time inside `sin`, a function without a frame record, and checks
// whether to stop only now and then.
@inline(never)
func spinWithLeafCallsForBacktraceTest(isStopped: () -> Bool) {
    var value = 0.0
    while !isStopped() {
        for _ in 0..<20_000 { value = sin(value + 1) }
    }
    precondition(value.isFinite)
}
