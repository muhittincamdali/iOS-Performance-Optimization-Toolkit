import Foundation
import os

/// Collects a ``NetworkTiming`` for every task of a `URLSession`.
///
/// Pass the collector as the session's delegate, or as the delegate of single requests:
///
/// ```swift
/// let collector = NetworkMetricsCollector()
/// let session = URLSession(configuration: .default, delegate: collector, delegateQueue: nil)
/// // or, for one request on an existing session:
/// let (data, _) = try await URLSession.shared.data(from: url, delegate: collector)
///
/// collector.timings.last?.phases.waiting
/// ```
///
/// The collector keeps the newest `capacity` timings. To keep them elsewhere as they arrive,
/// read ``updates()``.
public final class NetworkMetricsCollector: NSObject, URLSessionTaskDelegate, Sendable {
    private let buffer: OSAllocatedUnfairLock<RingBuffer<NetworkTiming>>
    private let broadcaster = Broadcaster<NetworkTiming>()

    /// How the URL of each request is redacted.
    public let redaction: URLRedaction

    /// Creates a collector.
    ///
    /// - Parameters:
    ///   - capacity: The number of timings kept, from 1 to ``RingBuffer/maximumCapacity``.
    ///   - redaction: How the URL of each request is redacted. The standard redaction keeps no
    ///     query parameters; pass one with ``URLRedaction/allowedQueryParameters`` to keep some.
    public init(capacity: Int = 200, redaction: URLRedaction = .standard) {
        buffer = OSAllocatedUnfairLock(initialState: RingBuffer(capacity: capacity))
        self.redaction = redaction
    }

    /// The timings collected, oldest first.
    public var timings: [NetworkTiming] {
        buffer.withLock { $0.elements }
    }

    /// A stream of timings as tasks finish. Each call returns a new stream; it keeps the 64
    /// newest timings when its reader falls behind.
    public func updates() -> AsyncStream<NetworkTiming> {
        broadcaster.stream()
    }

    /// Removes the collected timings.
    public func removeAll() {
        buffer.withLock { $0.removeAll() }
    }

    /// Called by `URLSession` when a task's metrics are ready.
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard let timing = NetworkTiming(metrics: metrics, redaction: redaction) else { return }
        buffer.withLock { $0.append(timing) }
        broadcaster.yield(timing)
    }
}
