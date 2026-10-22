import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("FrameTimeline")
struct FrameTimelineTests {
    private let frame60 = 1.0 / 60

    private func steady(_ timeline: inout FrameTimeline, frames: Int, from start: Double = 100, interval: Double) -> Double {
        var time = start
        for _ in 0...frames {
            timeline.record(timestamp: time, targetTimestamp: time + interval)
            time += interval
        }
        return time - interval
    }

    @Test("a steady 60 Hz display has no hitches")
    func steadyFrames() {
        var timeline = FrameTimeline()
        _ = steady(&timeline, frames: 120, interval: frame60)
        let statistics = timeline.statistics
        #expect(statistics.frameCount == 120)
        #expect(abs(statistics.framesPerSecond - 60) < 0.01)
        #expect(statistics.hitchTime == 0)
        #expect(statistics.droppedFrameCount == 0)
        #expect(abs(statistics.targetFramesPerSecond - 60) < 0.01)
        #expect(statistics.rating == .good)
    }

    @Test("a frame shown one refresh late is a hitch of one refresh")
    func oneLateFrame() {
        var timeline = FrameTimeline()
        let last = steady(&timeline, frames: 10, interval: frame60)
        // The previous callback announced last + frame60; the frame came one refresh later.
        let late = last + 2 * frame60
        timeline.record(timestamp: late, targetTimestamp: late + frame60)
        let statistics = timeline.statistics
        #expect(statistics.droppedFrameCount == 1)
        #expect(abs(statistics.hitchTime - frame60) < 1e-9)
        #expect(abs(statistics.longestFrame - 2 * frame60) < 1e-9)
    }

    @Test("jitter below a quarter refresh is not a hitch")
    func jitter() {
        var timeline = FrameTimeline()
        let last = steady(&timeline, frames: 5, interval: frame60)
        let slightlyLate = last + frame60 + 0.002
        timeline.record(timestamp: slightlyLate, targetTimestamp: slightlyLate + frame60)
        #expect(timeline.statistics.hitchTime == 0)
    }

    @Test("a gap longer than the pause threshold is a pause, not a hitch")
    func pauseIsNotHitch() {
        var timeline = FrameTimeline(pauseThreshold: 0.5)
        let last = steady(&timeline, frames: 10, interval: frame60)
        let resumed = last + 30
        timeline.record(timestamp: resumed, targetTimestamp: resumed + frame60)
        _ = steady(&timeline, frames: 10, from: resumed + frame60, interval: frame60)
        let statistics = timeline.statistics
        #expect(statistics.hitchTime == 0)
        #expect(statistics.duration < 1)
    }

    @Test("rejects times that are not finite or go backwards")
    func rejectsInvalidTimes() {
        var timeline = FrameTimeline()
        timeline.record(timestamp: 10, targetTimestamp: 10 + frame60)
        timeline.record(timestamp: .nan, targetTimestamp: 11)
        timeline.record(timestamp: 10, targetTimestamp: .infinity)
        timeline.record(timestamp: 9, targetTimestamp: 9 + frame60)
        #expect(timeline.rejectedCount == 3)
        #expect(timeline.statistics.frameCount == 0)
    }

    @Test("a tiny target interval cannot overflow the dropped frame count")
    func hugeLatenessRatio() {
        var timeline = FrameTimeline()
        timeline.record(timestamp: 0, targetTimestamp: 1e-300)
        timeline.record(timestamp: 0.4, targetTimestamp: 0.5)
        let statistics = timeline.statistics
        #expect(statistics.droppedFrameCount == .max)
        #expect(statistics.hitchTime > 0.39)
    }

    @Test("takeStatistics starts a new window and keeps measuring from the last frame")
    func takeStatistics() {
        var timeline = FrameTimeline()
        let last = steady(&timeline, frames: 60, interval: frame60)
        let first = timeline.takeStatistics()
        #expect(first.frameCount == 60)
        #expect(timeline.statistics.frameCount == 0)
        timeline.record(timestamp: last + frame60, targetTimestamp: last + 2 * frame60)
        #expect(timeline.statistics.frameCount == 1)
    }

    @Test("an invalid pause threshold falls back to half a second", arguments: [Double.nan, 0, -1, 0.05])
    func pauseThresholdFallback(value: Double) {
        #expect(FrameTimeline(pauseThreshold: value).pauseThreshold == 0.5)
    }
}

@Suite("FrameStatistics and HitchRating")
struct FrameStatisticsTests {
    @Test("rates hitch time ratios with Apple's limits", arguments: [
        (-1, .good), (0, .good), (10, .good), (10.01, .warning), (25, .warning),
        (25.5, .critical), (50, .critical), (50.1, .severe), (Double.nan, .severe),
    ] as [(Double, HitchRating)])
    func rating(ratio: Double, expected: HitchRating) {
        #expect(HitchRating(hitchTimeRatio: ratio) == expected)
    }

    @Test("ratings are ordered by severity")
    func ordering() {
        #expect(HitchRating.allCases.sorted() == [.good, .warning, .critical, .severe])
        #expect(HitchRating.warning < .critical)
    }

    @Test("computes the hitch time ratio in ms per second")
    func ratio() {
        let statistics = FrameStatistics(frameCount: 600, duration: 10, hitchTime: 0.2, droppedFrameCount: 12, longestFrame: 0.05, shortestTargetInterval: 1.0 / 60)
        #expect(abs(statistics.hitchTimeRatio - 20) < 1e-9)
        #expect(statistics.rating == .warning)
    }

    @Test("an empty window has no rate instead of dividing by zero")
    func emptyWindow() {
        let statistics = FrameStatistics(frameCount: 0, duration: 0, hitchTime: 0, droppedFrameCount: 0, longestFrame: 0, shortestTargetInterval: 0)
        #expect(statistics.framesPerSecond == 0)
        #expect(statistics.hitchTimeRatio == 0)
        #expect(statistics.targetFramesPerSecond == 0)
    }

    @Test("decoding corrects negative values")
    func decodingCorrects() throws {
        let json = Data(#"{"frameCount":-1,"duration":-2,"hitchTime":-3,"droppedFrameCount":-4,"longestFrame":-5,"shortestTargetInterval":-6}"#.utf8)
        let statistics = try JSONDecoder().decode(FrameStatistics.self, from: json)
        #expect(statistics == FrameStatistics(frameCount: 0, duration: 0, hitchTime: 0, droppedFrameCount: 0, longestFrame: 0, shortestTargetInterval: 0))
    }
}
