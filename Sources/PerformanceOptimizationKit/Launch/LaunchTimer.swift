import Foundation

/// The launch of the current process: how long it took to show the first frame and to become
/// usable.
public struct LaunchMeasurement: Sendable, Equatable, Codable {
    /// When the kernel created the process, or `nil` when it could not be read.
    public let processStart: Date?
    /// The time from the process start to the first frame, once ``LaunchTimer/markFirstFrame(at:)``
    /// has been called.
    public let timeToFirstFrame: Duration?
    /// The time from the process start to the point the app called usable, once
    /// ``LaunchTimer/markInteractive(at:)`` has been called.
    public let timeToInteractive: Duration?
    /// A Boolean value that indicates whether the system prewarmed the process; the durations
    /// then include time the process spent suspended and do not describe the launch.
    public let wasPrewarmed: Bool

    /// Creates a measurement from known values, for tests and previews.
    public init(processStart: Date?, timeToFirstFrame: Duration? = nil, timeToInteractive: Duration? = nil, wasPrewarmed: Bool = false) {
        self.processStart = processStart
        self.timeToFirstFrame = timeToFirstFrame
        self.timeToInteractive = timeToInteractive
        self.wasPrewarmed = wasPrewarmed
    }

    /// The time from `start` to `end`, or `nil` when `start` is missing or `end` comes before it
    /// (the wall clock was set back during launch).
    public static func elapsed(from start: Date?, to end: Date) -> Duration? {
        guard let start else { return nil }
        return Duration.validSeconds(end.timeIntervalSince(start))
    }
}

/// Records the moments of the app's launch.
///
/// Call ``markFirstFrame(at:)`` when the first screen appears (or attach
/// `measuresLaunch()` to the root view) and ``markInteractive(at:)`` when the app has loaded
/// what people need to use it. Each mark is kept the first time only, so calling it from a view
/// that appears again later does not change the result.
///
/// ```swift
/// WindowGroup {
///     ContentView()
///         .measuresLaunch()
/// }
/// ```
@MainActor
public enum LaunchTimer {
    private static let processStart = ProcessLaunch.startDate()
    private static let wasPrewarmed = ProcessLaunch.wasPrewarmed
    private static var firstFrame: Duration?
    private static var interactive: Duration?

    /// The launch measured so far.
    public static var measurement: LaunchMeasurement {
        LaunchMeasurement(processStart: processStart, timeToFirstFrame: firstFrame, timeToInteractive: interactive, wasPrewarmed: wasPrewarmed)
    }

    /// Records the first frame, the first time it is called.
    @discardableResult
    public static func markFirstFrame(at date: Date = Date()) -> LaunchMeasurement {
        if firstFrame == nil {
            firstFrame = LaunchMeasurement.elapsed(from: processStart, to: date)
        }
        return measurement
    }

    /// Records the moment the app became usable, the first time it is called.
    @discardableResult
    public static func markInteractive(at date: Date = Date()) -> LaunchMeasurement {
        if interactive == nil {
            interactive = LaunchMeasurement.elapsed(from: processStart, to: date)
        }
        return measurement
    }
}
