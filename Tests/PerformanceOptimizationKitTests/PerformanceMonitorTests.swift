import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("PerformanceFormat")
struct PerformanceFormatTests {
    private let english = Locale(identifier: "en_US")

    @Test("formats each figure with its unit")
    func formats() {
        #expect(PerformanceFormat.megabytes(148_000_000, locale: english) == "141.1 MB")
        #expect(PerformanceFormat.cpu(34.4, locale: english) == "34%")
        #expect(PerformanceFormat.framesPerSecond(119.6, locale: english) == "120 fps")
        #expect(PerformanceFormat.hitchTimeRatio(3.26, locale: english) == "3.3 ms/s")
        #expect(PerformanceFormat.milliseconds(.milliseconds(412), locale: english) == "412 ms")
    }

    @Test("shows a dash for values that are not finite")
    func nonFinite() {
        #expect(PerformanceFormat.cpu(.nan, locale: english) == "–%")
        #expect(PerformanceFormat.framesPerSecond(.infinity, locale: english) == "– fps")
    }

    @Test("uses the locale's decimal separator")
    func locale() {
        #expect(PerformanceFormat.hitchTimeRatio(3.26, locale: Locale(identifier: "de_DE")) == "3,3 ms/s")
    }
}

@Suite("PerformanceMonitor", .serialized)
@MainActor
struct PerformanceMonitorTests {
    @Test("publishes memory and CPU readings while running")
    func samples() async throws {
        let monitor = PerformanceMonitor(sampleInterval: .milliseconds(100), measuresFrames: false)
        monitor.start()
        #expect(monitor.isRunning)
        for _ in 0..<50 where monitor.snapshot.memory == nil {
            try await Task.sleep(for: .milliseconds(20))
        }
        monitor.stop()
        #expect(!monitor.isRunning)
        let memory = try #require(monitor.snapshot.memory)
        #expect(memory.footprintBytes > 0)
        #expect(monitor.snapshot.cpu != nil)
        #expect(monitor.measurements.memory == memory)
    }

    @Test("records a blocked main thread as a hang")
    func detectsMainThreadHang() async throws {
        let monitor = PerformanceMonitor(sampleInterval: .seconds(1), hangThreshold: .milliseconds(150), measuresFrames: false)
        monitor.start()
        try await Task.sleep(for: .milliseconds(150))
        blockMainThread(seconds: 0.4)
        for _ in 0..<50 where monitor.recentHangs.isEmpty {
            try await Task.sleep(for: .milliseconds(20))
        }
        monitor.stop()
        let hang = try #require(monitor.recentHangs.first)
        #expect(hang.duration >= .milliseconds(250))
        #expect(monitor.snapshot.lastHang == hang)
    }

    // Synchronous on purpose: this is the kind of work that freezes an app's interface.
    private func blockMainThread(seconds: Double) {
        Thread.sleep(forTimeInterval: seconds)
    }

    @Test("clamps the sample interval")
    func clampsInterval() {
        #expect(PerformanceMonitor(sampleInterval: .zero, measuresFrames: false).sampleInterval == .milliseconds(100))
    }
}
