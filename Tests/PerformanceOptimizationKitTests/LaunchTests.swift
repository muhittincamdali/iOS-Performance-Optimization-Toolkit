import Darwin
import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("Launch")
struct LaunchTests {
    @Test("the process start is in the recent past")
    func processStart() throws {
        let start = try #require(ProcessLaunch.startDate())
        #expect(start <= Date())
        #expect(Date().timeIntervalSince(start) < 3_600)
    }

    @Test("rejects time values the kernel never reports", arguments: [
        timeval(tv_sec: 0, tv_usec: 0), timeval(tv_sec: -5, tv_usec: 0),
        timeval(tv_sec: 1_700_000_000, tv_usec: -1), timeval(tv_sec: 1_700_000_000, tv_usec: 1_000_000),
    ])
    func invalidTime(value: timeval) {
        #expect(ProcessLaunch.date(from: value) == nil)
    }

    @Test("converts a valid time value")
    func validTime() {
        let date = ProcessLaunch.date(from: timeval(tv_sec: 1_700_000_000, tv_usec: 500_000))
        #expect(date == Date(timeIntervalSince1970: 1_700_000_000.5))
    }

    @Test("elapsed time is nil when the clock went backwards")
    func elapsed() throws {
        let start = Date(timeIntervalSince1970: 1_000)
        let elapsed = try #require(LaunchMeasurement.elapsed(from: start, to: start.addingTimeInterval(0.35)))
        #expect(abs(elapsed.seconds - 0.35) < 1e-6)
        #expect(LaunchMeasurement.elapsed(from: start, to: start.addingTimeInterval(-1)) == nil)
        #expect(LaunchMeasurement.elapsed(from: nil, to: start) == nil)
    }

    @Test("keeps the first mark only")
    @MainActor
    func marksOnce() throws {
        let first = LaunchTimer.markFirstFrame()
        let firstFrame = try #require(first.timeToFirstFrame)
        let again = LaunchTimer.markFirstFrame(at: Date().addingTimeInterval(60))
        #expect(again.timeToFirstFrame == firstFrame)
        let interactive = LaunchTimer.markInteractive()
        #expect(try #require(interactive.timeToInteractive) >= firstFrame)
    }
}
