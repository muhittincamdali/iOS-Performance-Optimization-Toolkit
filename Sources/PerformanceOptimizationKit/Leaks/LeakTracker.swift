import Foundation
import os

/// An object that was expected to be released but was still alive after the grace period.
public struct LeakReport: Sendable, Equatable, Codable {
    /// The name given when the object was tracked, such as the screen's name.
    public let name: String
    /// The object's type.
    public let typeName: String
    /// When the object was expected to start going away.
    public let trackedAt: Date
    /// How long the tracker waited before reporting it.
    public let gracePeriod: Duration

    /// Creates a report from known values, for tests and previews.
    public init(name: String, typeName: String, trackedAt: Date, gracePeriod: Duration) {
        self.name = name
        self.typeName = typeName
        self.trackedAt = trackedAt
        self.gracePeriod = gracePeriod
    }
}

/// Finds objects that outlive the moment they should have been released, such as a view model
/// kept alive by a closure that captures `self` after its screen closed.
///
/// Call ``expectRelease(of:name:)`` when the object's owner lets it go: in `onDisappear`, in
/// `viewDidDisappear` when the controller is being dismissed, or in `deinit` of the owner. The
/// tracker holds the object weakly and reports it if it is still alive after `gracePeriod`.
///
/// ```swift
/// let leaks = LeakTracker()
/// Task { for await leak in leaks.reports() { print("Leak: \(leak.name)") } }
/// // When the screen closes:
/// leaks.expectRelease(of: viewModel, name: "Profile screen")
/// ```
///
/// The tracker finds that an object leaked, not why. Use Xcode's memory graph or the Leaks
/// instrument to find the reference that keeps it alive.
public final class LeakTracker: Sendable {
    /// How long an object may stay alive after ``expectRelease(of:name:)``.
    public let gracePeriod: Duration
    /// The most objects waited for at once. Further calls are counted in ``skippedCount`` and
    /// not tracked.
    public let maximumPending: Int
    /// The longest name tracked, in UTF-8 bytes, the same limit as
    /// ``PerformanceTracer/maximumNameLength``.
    public static var maximumNameLength: Int { 256 }

    private let state = OSAllocatedUnfairLock(initialState: TrackerState())
    private let broadcaster = Broadcaster<LeakReport>()

    /// Creates a tracker.
    ///
    /// - Parameters:
    ///   - gracePeriod: The time to wait, from 0.1 to 600 seconds. Animations and pending
    ///     tasks can keep an object alive for a moment after its screen closes.
    ///   - maximumPending: The most objects waited for at once, from 1 to 10,000.
    public init(gracePeriod: Duration = .seconds(2), maximumPending: Int = 1_000) {
        self.gracePeriod = min(max(gracePeriod, .milliseconds(100)), .seconds(600))
        self.maximumPending = min(max(maximumPending, 1), 10_000)
    }

    /// A stream of reports. Each call returns a new stream; it keeps the 64 newest reports when
    /// its reader falls behind.
    public func reports() -> AsyncStream<LeakReport> {
        broadcaster.stream()
    }

    /// The number of objects not tracked because ``maximumPending`` were already waited for or
    /// their name was longer than ``maximumNameLength``.
    public var skippedCount: Int { state.withLock { $0.skipped } }

    /// The number of objects being waited for.
    public var pendingCount: Int { state.withLock { $0.pending } }

    /// Starts waiting for `object` to be released and reports it if it is still alive after
    /// ``gracePeriod``.
    ///
    /// The name is reported as it is given, so use a fixed name such as the screen's, never text
    /// that came from a user.
    ///
    /// - Returns: A task whose value is the report, or `nil` when the object was released, the
    ///   task was cancelled, or the object was not tracked because ``maximumPending`` objects
    ///   were already waited for or `name` is longer than ``maximumNameLength`` bytes. Awaiting
    ///   it is optional.
    @discardableResult
    public func expectRelease(of object: AnyObject, name: String) -> Task<LeakReport?, Never> {
        let isNameKept = name.utf8.count <= Self.maximumNameLength
        let reserved = state.withLock { state -> Bool in
            guard isNameKept, state.pending < maximumPending else {
                state.skipped = state.skipped.saturatingAdd(1)
                return false
            }
            state.pending += 1
            return true
        }
        guard reserved else { return Task { nil } }
        let reference = WeakReference(object)
        let typeName = String(reflecting: type(of: object))
        let trackedAt = Date()
        return Task { [gracePeriod, state, broadcaster] in
            defer { state.withLock { $0.pending -= 1 } }
            // Cancelling the returned task stops the tracking without a report.
            do { try await Task.sleep(for: gracePeriod) } catch { return nil }
            guard reference.isAlive else { return nil }
            let report = LeakReport(name: name, typeName: typeName, trackedAt: trackedAt, gracePeriod: gracePeriod)
            broadcaster.yield(report)
            return report
        }
    }
}

private struct TrackerState: Sendable {
    var pending = 0
    var skipped = 0
}

// Reading a weak reference is thread-safe in Swift; the box only stores it.
private final class WeakReference: @unchecked Sendable {
    private weak var object: AnyObject?

    init(_ object: AnyObject) {
        self.object = object
    }

    var isAlive: Bool { object != nil }
}
