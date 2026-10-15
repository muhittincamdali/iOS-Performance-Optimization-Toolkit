/// Turns display refresh callbacks into ``FrameStatistics``.
///
/// Feed it the `timestamp` and `targetTimestamp` of each `CADisplayLink` callback (or any other
/// source of presentation times). A frame is late when it is shown after the time the previous
/// callback announced as its target; the difference is its hitch duration. The timeline keeps
/// only running totals, so it uses the same memory after an hour as after a second.
///
/// ```swift
/// var timeline = FrameTimeline()
/// timeline.record(timestamp: link.timestamp, targetTimestamp: link.targetTimestamp)
/// let window = timeline.takeStatistics() // statistics since the last call, then starts over
/// ```
public struct FrameTimeline: Sendable {
    /// A gap longer than this, in seconds, is a pause (the app was in the background or the
    /// display link was paused), not a hitch: the timeline starts again after it.
    public let pauseThreshold: Double

    private var previousTimestamp: Double?
    private var previousTarget: Double?
    private var frameCount = 0
    private var duration = 0.0
    private var hitchTime = 0.0
    private var droppedFrameCount = 0
    private var longestFrame = 0.0
    private var shortestTargetInterval = 0.0

    /// The number of callbacks left out because their times were not finite or went backwards.
    public private(set) var rejectedCount = 0

    /// Creates an empty timeline.
    ///
    /// - Parameter pauseThreshold: The longest interval, in seconds, that still counts as a
    ///   frame. Values that are not finite or below 0.1 s become 0.5 s.
    public init(pauseThreshold: Double = 0.5) {
        self.pauseThreshold = pauseThreshold.isFinite && pauseThreshold >= 0.1 ? pauseThreshold : 0.5
    }

    /// The statistics of the frames recorded since the timeline was created or last taken.
    public var statistics: FrameStatistics {
        FrameStatistics(
            frameCount: frameCount,
            duration: duration,
            hitchTime: hitchTime,
            droppedFrameCount: droppedFrameCount,
            longestFrame: longestFrame,
            shortestTargetInterval: shortestTargetInterval
        )
    }

    /// Returns the current statistics and starts a new window. The next frame is still measured
    /// against the last one recorded.
    public mutating func takeStatistics() -> FrameStatistics {
        let result = statistics
        frameCount = 0
        duration = 0
        hitchTime = 0
        droppedFrameCount = 0
        longestFrame = 0
        shortestTargetInterval = 0
        return result
    }

    /// Records one refresh callback.
    ///
    /// - Parameters:
    ///   - timestamp: When the last frame was shown, in seconds on a monotonic clock.
    ///   - targetTimestamp: When the next frame should be shown, on the same clock.
    public mutating func record(timestamp: Double, targetTimestamp: Double) {
        guard timestamp.isFinite, targetTimestamp.isFinite else {
            rejectedCount = rejectedCount.saturatingAdd(1)
            return
        }
        defer {
            previousTimestamp = timestamp
            previousTarget = targetTimestamp > timestamp ? targetTimestamp : nil
        }
        guard let previousTimestamp else { return }
        let interval = timestamp - previousTimestamp
        guard interval > 0 else {
            rejectedCount = rejectedCount.saturatingAdd(1)
            return
        }
        guard interval <= pauseThreshold else { return }
        addFrame(interval: interval, timestamp: timestamp, expectedAt: previousTarget, startedAt: previousTimestamp)
    }

    private mutating func addFrame(interval: Double, timestamp: Double, expectedAt target: Double?, startedAt start: Double) {
        frameCount = frameCount.saturatingAdd(1)
        duration += interval
        longestFrame = max(longestFrame, interval)
        guard let target else { return }
        let expected = target - start
        shortestTargetInterval = shortestTargetInterval == 0 ? expected : min(shortestTargetInterval, expected)
        // Display link times jitter by a fraction of a millisecond; a frame counts as late only
        // when it misses its target by more than a quarter of a refresh.
        let lateness = timestamp - target
        guard lateness > expected / 4 else { return }
        hitchTime += lateness
        let skipped = (lateness / expected).rounded().clampedInt ?? 0
        droppedFrameCount = droppedFrameCount.saturatingAdd(max(skipped, 1))
    }
}
