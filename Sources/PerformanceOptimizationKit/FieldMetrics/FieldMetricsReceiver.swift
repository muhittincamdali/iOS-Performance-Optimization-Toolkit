#if canImport(MetricKit) && !os(tvOS) && !os(watchOS)
import Foundation
import MetricKit
import os

/// Receives MetricKit's daily reports and turns each into ``FieldMetrics``.
///
/// On iOS 27 and macOS 27 and later it reads `MetricManager.metricReports`; on earlier systems
/// and on visionOS it subscribes to `MXMetricManager`. Start it early in the app's launch, so
/// the system can deliver the reports it holds:
///
/// ```swift
/// let receiver = FieldMetricsReceiver()
/// receiver.start()
/// Task {
///     for await metrics in receiver.updates() {
///         try await upload(JSONEncoder().encode(metrics))
///     }
/// }
/// ```
///
/// MetricKit delivers reports at most once a day and only on devices where the person shares
/// analytics with app developers. In development, use Xcode's Debug › Simulate MetricKit
/// Payloads on a device.
public final class FieldMetricsReceiver: NSObject, MXMetricManagerSubscriber, Sendable {
    private let state = OSAllocatedUnfairLock(initialState: ReceiverState())
    private let broadcaster = Broadcaster<FieldMetrics>(bufferSize: 16)

    /// The most recent metrics received, or `nil` before the first report.
    public var latest: FieldMetrics? { state.withLock { $0.latest } }

    /// A stream of metrics as reports arrive. Each call returns a new stream; it keeps the 16
    /// newest reports when its reader falls behind.
    public func updates() -> AsyncStream<FieldMetrics> {
        broadcaster.stream()
    }

    /// Starts receiving reports. Calling it again does nothing.
    public func start() {
        let alreadyStarted = state.withLock { state -> Bool in
            defer { state.started = true }
            return state.started
        }
        guard !alreadyStarted else { return }
        #if compiler(>=6.4) && !os(visionOS)
        if #available(iOS 27.0, macOS 27.0, *) {
            // The task holds the receiver weakly and ends once it is gone; `deinit` cancels it
            // so it does not wait for the next report, which can be a day away.
            let task = Task { [weak self] in
                for await report in MetricManager().metricReports {
                    guard let self else { return }
                    self.receive(FieldMetrics(report))
                }
            }
            state.withLock { $0.task = task }
            return
        }
        #endif
        MXMetricManager.shared.add(self)
    }

    deinit {
        state.withLock { $0.task }?.cancel()
    }

    /// Stops receiving reports.
    public func stop() {
        let task = state.withLock { state -> Task<Void, Never>? in
            defer {
                state.started = false
                state.task = nil
            }
            return state.task
        }
        task?.cancel()
        MXMetricManager.shared.remove(self)
    }

    /// Called by MetricKit with the payloads of the last reporting periods.
    public func didReceive(_ payloads: [MXMetricPayload]) {
        payloads.forEach { receive(FieldMetrics($0)) }
    }

    private func receive(_ metrics: FieldMetrics) {
        state.withLock { $0.latest = metrics }
        broadcaster.yield(metrics)
    }
}

private struct ReceiverState: Sendable {
    var started = false
    var task: Task<Void, Never>?
    var latest: FieldMetrics?
}
#endif
