#if !os(watchOS)
import Foundation
import QuartzCore
#if canImport(AppKit)
import AppKit
#endif

/// Measures the frame rate and hitches of the screen the app draws on.
///
/// The monitor attaches a `CADisplayLink` to the main run loop, feeds every refresh into a
/// ``FrameTimeline`` and reports ``FrameStatistics`` once per `reportInterval`.
///
/// ```swift
/// let monitor = FrameRateMonitor()
/// monitor.start()
/// for await window in monitor.updates() {
///     print(window.framesPerSecond, window.hitchTimeRatio)
/// }
/// ```
///
/// A display link keeps the display at its full refresh rate while it runs, which costs power.
/// Run the monitor in debug builds, internal builds or while measuring, not all the time.
@MainActor
public final class FrameRateMonitor {
    /// How often the monitor reports.
    public let reportInterval: Duration
    /// The statistics of the most recent full report interval.
    public private(set) var latest: FrameStatistics?

    private var timeline: FrameTimeline
    private var displayLink: CADisplayLink?
    private var windowStart: Double?
    private let broadcaster = Broadcaster<FrameStatistics>()

    /// Creates a monitor that is not running yet.
    ///
    /// - Parameters:
    ///   - reportInterval: How often to report. Values under 0.1 s become 0.1 s.
    ///   - pauseThreshold: Passed to ``FrameTimeline/init(pauseThreshold:)``.
    public init(reportInterval: Duration = .seconds(1), pauseThreshold: Double = 0.5) {
        self.reportInterval = max(reportInterval, .milliseconds(100))
        self.timeline = FrameTimeline(pauseThreshold: pauseThreshold)
    }

    /// A Boolean value that indicates whether the monitor is running.
    public var isRunning: Bool { displayLink != nil }

    /// A stream of the statistics of each report interval. Each call returns a new stream; it
    /// keeps the 64 newest reports when its reader falls behind.
    public func updates() -> AsyncStream<FrameStatistics> {
        broadcaster.stream()
    }

    /// Starts measuring. Calling it while running does nothing.
    public func start() {
        guard displayLink == nil, let link = makeDisplayLink() else { return }
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// Stops measuring and drops the frames of the unfinished interval.
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
        windowStart = nil
        timeline = FrameTimeline(pauseThreshold: timeline.pauseThreshold)
    }

    fileprivate func tick(timestamp: Double, targetTimestamp: Double) {
        timeline.record(timestamp: timestamp, targetTimestamp: targetTimestamp)
        guard let start = windowStart else {
            windowStart = timestamp
            return
        }
        guard timestamp - start >= reportInterval.seconds else { return }
        let window = timeline.takeStatistics()
        windowStart = timestamp
        latest = window
        broadcaster.yield(window)
    }

    private func makeDisplayLink() -> CADisplayLink? {
        let target = DisplayLinkTarget(monitor: self)
        #if os(macOS)
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return nil }
        return screen.displayLink(target: target, selector: #selector(DisplayLinkTarget.step(_:)))
        #else
        return CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.step(_:)))
        #endif
    }
}

// CADisplayLink keeps a strong reference to its target; this object holds the monitor weakly so
// a monitor that is no longer used can be released even if nobody called stop().
private final class DisplayLinkTarget: NSObject {
    private weak var monitor: FrameRateMonitor?

    init(monitor: FrameRateMonitor) {
        self.monitor = monitor
    }

    @MainActor @objc func step(_ link: CADisplayLink) {
        guard let monitor else {
            link.invalidate()
            return
        }
        monitor.tick(timestamp: link.timestamp, targetTimestamp: link.targetTimestamp)
    }
}
#endif
