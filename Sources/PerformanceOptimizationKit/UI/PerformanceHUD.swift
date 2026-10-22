#if canImport(SwiftUI)
import SwiftUI

/// A small overlay with the app's frame rate, hitches, CPU, memory and last hang.
///
/// Show it from a ``PerformanceMonitor``, which updates it live, or from a fixed
/// ``PerformanceSnapshot`` in previews and screenshots:
///
/// ```swift
/// ContentView()
///     .overlay(alignment: .topTrailing) {
///         PerformanceHUD(monitor: monitor).padding()
///     }
/// ```
public struct PerformanceHUD: View {
    private let source: Source

    private enum Source {
        case monitor(PerformanceMonitor)
        case snapshot(PerformanceSnapshot)
    }

    /// Creates a HUD that follows a monitor. Start the monitor to see figures.
    public init(monitor: PerformanceMonitor) {
        source = .monitor(monitor)
    }

    /// Creates a HUD that shows fixed figures.
    public init(snapshot: PerformanceSnapshot) {
        source = .snapshot(snapshot)
    }

    public var body: some View {
        switch source {
        case .monitor(let monitor): PerformanceHUDContent(snapshot: monitor.snapshot)
        case .snapshot(let snapshot): PerformanceHUDContent(snapshot: snapshot)
        }
    }
}

struct PerformanceHUDContent: View {
    let snapshot: PerformanceSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            framesRow
            row("CPU", value: snapshot.cpu.map { PerformanceFormat.cpu($0.usage) }, level: cpuLevel)
            row("MEM", value: snapshot.memory.map { PerformanceFormat.megabytes($0.footprintBytes) }, level: memoryLevel)
            row("HANG", value: snapshot.lastHang.map { PerformanceFormat.milliseconds($0.duration) } ?? "none", level: snapshot.lastHang == nil ? .normal : .alert)
        }
        .font(.system(.caption, design: .monospaced).weight(.medium))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(HUDLevel.normal.color.opacity(0.35)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Performance")
    }

    @ViewBuilder private var framesRow: some View {
        if let frames = snapshot.frames, frames.frameCount > 0 {
            row("FPS", value: PerformanceFormat.framesPerSecond(frames.framesPerSecond), level: .normal)
            row("HITCH", value: PerformanceFormat.hitchTimeRatio(frames.hitchTimeRatio), level: HUDLevel(frames.rating))
        } else {
            row("FPS", value: nil, level: .normal)
        }
    }

    private var cpuLevel: HUDLevel {
        guard let cpu = snapshot.cpu else { return .normal }
        return cpu.usage > 100 ? .warning : .normal
    }

    private var memoryLevel: HUDLevel {
        guard let usage = snapshot.memory?.budgetUsage else { return .normal }
        return usage > 0.8 ? .alert : usage > 0.6 ? .warning : .normal
    }

    private func row(_ label: String, value: String?, level: HUDLevel) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .leading)
            Text(value ?? "–")
                .foregroundStyle(level.color)
                .contentTransition(.numericText())
        }
    }
}

enum HUDLevel {
    case normal, warning, alert

    init(_ rating: HitchRating) {
        switch rating {
        case .good: self = .normal
        case .warning: self = .warning
        case .critical, .severe: self = .alert
        }
    }

    // The kit's blue for normal figures; orange and red only when something needs a look.
    var color: Color {
        switch self {
        case .normal: Color(red: 0.039, green: 0.518, blue: 1.0)
        case .warning: .orange
        case .alert: .red
        }
    }
}

extension View {
    /// Records the app's first frame with ``LaunchTimer`` when this view first appears.
    ///
    /// Attach it to the root view of the first scene. The mark is taken on the main run loop
    /// turn after the view appears, once the first frame has been committed.
    public func measuresLaunch() -> some View {
        onAppear {
            DispatchQueue.main.async {
                LaunchTimer.markFirstFrame()
            }
        }
    }
}

#Preview {
    PerformanceHUD(snapshot: PerformanceSnapshot(
        memory: MemorySnapshot(footprintBytes: 148_000_000, availableBytes: 2_800_000_000),
        cpu: CPUSnapshot(usage: 34, threadCount: 18),
        frames: FrameStatistics(frameCount: 118, duration: 1, hitchTime: 0.004, droppedFrameCount: 1, longestFrame: 0.0167, shortestTargetInterval: 1.0 / 120),
        lastHang: HangEvent(start: Date(), duration: .milliseconds(412))
    ))
    .padding()
}
#endif
