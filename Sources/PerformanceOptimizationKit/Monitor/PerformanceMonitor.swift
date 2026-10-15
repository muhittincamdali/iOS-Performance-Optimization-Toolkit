import Foundation
import Observation

/// The live figures of the app at one moment.
public struct PerformanceSnapshot: Sendable, Equatable, Codable {
    /// When the memory and CPU were read.
    public let date: Date
    /// Memory use, or `nil` when it could not be read.
    public let memory: MemorySnapshot?
    /// CPU use, or `nil` when it could not be read.
    public let cpu: CPUSnapshot?
    /// The frame statistics of the last report interval, or `nil` before the first one (and
    /// on watchOS).
    public let frames: FrameStatistics?
    /// The most recent hang, or `nil` when there was none.
    public let lastHang: HangEvent?

    /// Creates a snapshot from known values, for tests and previews.
    public init(date: Date = Date(), memory: MemorySnapshot? = nil, cpu: CPUSnapshot? = nil, frames: FrameStatistics? = nil, lastHang: HangEvent? = nil) {
        self.date = date
        self.memory = memory
        self.cpu = cpu
        self.frames = frames
        self.lastHang = lastHang
    }
}

/// Watches memory, CPU, frames and hangs together and publishes them for SwiftUI.
///
/// The monitor is `@Observable`: a view that reads ``snapshot`` updates whenever a new reading
/// arrives. ``PerformanceHUD`` shows it as an overlay.
///
/// ```swift
/// @State private var monitor = PerformanceMonitor()
///
/// var body: some View {
///     ContentView()
///         .overlay(alignment: .topTrailing) { PerformanceHUD(monitor: monitor) }
///         .task { monitor.start() }
/// }
/// ```
@MainActor
@Observable
public final class PerformanceMonitor {
    /// The latest figures.
    public private(set) var snapshot = PerformanceSnapshot()
    /// The most recent hangs, oldest first, at most ``maximumRecentHangs``.
    public private(set) var recentHangs: [HangEvent] = []
    /// A Boolean value that indicates whether the monitor is running.
    public private(set) var isRunning = false

    /// How often memory and CPU are read.
    public let sampleInterval: Duration
    /// The number of hangs kept in ``recentHangs``.
    public let maximumRecentHangs = 20

    @ObservationIgnored private let hangDetector: HangDetector
    #if !os(watchOS)
    @ObservationIgnored private let frameMonitor: FrameRateMonitor?
    #endif
    @ObservationIgnored private var tasks: [Task<Void, Never>] = []

    /// Creates a monitor that is not running yet.
    ///
    /// - Parameters:
    ///   - sampleInterval: How often to read memory and CPU, and to report frames. Values under
    ///     0.1 s become 0.1 s.
    ///   - hangThreshold: The shortest main-thread hang to report.
    ///   - measuresFrames: Whether to run a display link for frame statistics. It keeps the
    ///     display at its full refresh rate while the monitor runs.
    ///   - capturesBacktraces: Whether each hang comes with the main thread's call stack (see
    ///     ``HangEvent/backtrace``).
    public init(sampleInterval: Duration = .seconds(1), hangThreshold: Duration = .milliseconds(250), measuresFrames: Bool = true, capturesBacktraces: Bool = true) {
        self.sampleInterval = max(sampleInterval, .milliseconds(100))
        hangDetector = HangDetector(threshold: hangThreshold, capturesBacktraces: capturesBacktraces)
        #if !os(watchOS)
        frameMonitor = measuresFrames ? FrameRateMonitor(reportInterval: self.sampleInterval) : nil
        #endif
    }

    /// The current figures as input for a ``PerformanceBudget``.
    public var measurements: PerformanceMeasurements {
        PerformanceMeasurements(memory: snapshot.memory, cpu: snapshot.cpu, frames: snapshot.frames, hangs: recentHangs, launch: LaunchTimer.measurement)
    }

    /// Starts all measurements. Calling it while running does nothing.
    public func start() {
        guard !isRunning else { return }
        isRunning = true
        hangDetector.start()
        let hangs = hangDetector.events()
        tasks.append(Task { [weak self] in
            for await hang in hangs { self?.add(hang) }
        })
        #if !os(watchOS)
        if let frameMonitor {
            frameMonitor.start()
            let windows = frameMonitor.updates()
            tasks.append(Task { [weak self] in
                for await window in windows { self?.update(frames: window) }
            })
        }
        #endif
        tasks.append(Task { [weak self, sampleInterval] in
            // The monitor is only borrowed for each reading, so a monitor nobody holds any more
            // is released and the loop ends.
            while !Task.isCancelled {
                if let monitor = self { monitor.sample() } else { return }
                try? await Task.sleep(for: sampleInterval)
            }
        })
    }

    /// Stops all measurements. The last figures stay in ``snapshot``.
    public func stop() {
        guard isRunning else { return }
        isRunning = false
        hangDetector.stop()
        #if !os(watchOS)
        frameMonitor?.stop()
        #endif
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }

    private func sample() {
        snapshot = PerformanceSnapshot(memory: MemorySnapshot.current(), cpu: CPUSnapshot.current(), frames: snapshot.frames, lastHang: snapshot.lastHang)
    }

    private func update(frames: FrameStatistics) {
        snapshot = PerformanceSnapshot(date: snapshot.date, memory: snapshot.memory, cpu: snapshot.cpu, frames: frames, lastHang: snapshot.lastHang)
    }

    private func add(_ hang: HangEvent) {
        recentHangs.append(hang)
        if recentHangs.count > maximumRecentHangs {
            recentHangs.removeFirst(recentHangs.count - maximumRecentHangs)
        }
        snapshot = PerformanceSnapshot(date: snapshot.date, memory: snapshot.memory, cpu: snapshot.cpu, frames: snapshot.frames, lastHang: hang)
    }
}
