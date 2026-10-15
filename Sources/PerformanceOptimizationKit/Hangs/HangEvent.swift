import Foundation

/// A period in which the main thread (or another watched queue) did not run new work.
public struct HangEvent: Sendable, Equatable, Codable {
    /// When the detector noticed the queue was busy.
    public let start: Date
    /// How long the queue took to run work submitted at ``start``.
    public let duration: Duration

    /// Creates an event from known values, for tests and previews.
    public init(start: Date, duration: Duration) {
        self.start = start
        self.duration = duration
    }

    /// How noticeable the hang was.
    public var severity: HangSeverity { HangSeverity(duration: duration) }
}

/// How noticeable an unresponsive period is.
///
/// Apple's "Understanding hangs in your app" says a delay under 100 ms is rarely noticeable and
/// that its tools report unresponsiveness from 250 ms; the two cases follow those limits.
public enum HangSeverity: String, Sendable, Codable, CaseIterable {
    /// Under 100 ms: rarely noticeable.
    case unnoticeable
    /// 100 ms up to 250 ms: noticeable, below the limit where Apple's tools report a hang.
    case delay
    /// 250 ms or longer: long enough for most of Apple's tools to report it as a hang.
    case hang

    /// The shortest ``delay``.
    public static var delayLimit: Duration { .milliseconds(100) }
    /// The shortest ``hang``.
    public static var hangLimit: Duration { .milliseconds(250) }

    /// The severity of an unresponsive period of the given length.
    public init(duration: Duration) {
        if duration >= Self.hangLimit {
            self = .hang
        } else if duration >= Self.delayLimit {
            self = .delay
        } else {
            self = .unnoticeable
        }
    }
}
