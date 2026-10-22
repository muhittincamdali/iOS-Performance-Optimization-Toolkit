import PerformanceOptimizationKit
import SwiftUI

/// Blocks the main thread on purpose and lists the hangs the monitor found, with the first
/// frame of this app in each captured call stack.
struct HangsScreen: View {
    let runsDemo: Bool
    @Environment(Lab.self) private var lab

    var body: some View {
        List {
            Section {
                Button("Block the main thread for 150 ms") { blockMainThread(milliseconds: 150) }
                Button("Block the main thread for 600 ms") { blockMainThread(milliseconds: 600) }
            } footer: {
                Text("The monitor reports hangs from 250 ms, where Apple's tools start counting them.")
            }
            Section("Hangs") {
                if lab.monitor.recentHangs.isEmpty {
                    Text("No hangs yet").foregroundStyle(.secondary)
                }
                ForEach(Array(lab.monitor.recentHangs.reversed().enumerated()), id: \.offset) { _, hang in
                    HangRow(hang: hang)
                }
            }
        }
        .task {
            guard runsDemo, lab.monitor.recentHangs.isEmpty else { return }
            try? await Task.sleep(for: .seconds(1))
            blockMainThread(milliseconds: 600)
        }
    }
}

private struct HangRow: View {
    let hang: HangEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(PerformanceFormat.milliseconds(hang.duration)).font(.headline.monospacedDigit())
                Spacer()
                Text(hang.severity.rawValue.capitalized)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.labBlue.opacity(0.15), in: Capsule())
            }
            if let frame = appFrame {
                Text(frame.symbol ?? "0x\(String(frame.address, radix: 16))")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }

    // The innermost frame in this app's own code: what kept the main thread busy. Debug
    // builds put the app's code in "PerformanceLab.debug.dylib", hence the prefix match.
    private var appFrame: StackFrame? {
        guard let binary = Bundle.main.executableURL?.lastPathComponent else { return nil }
        return hang.backtrace?.first { $0.image?.hasPrefix(binary) == true && $0.symbol != nil }
    }
}

/// Stands in for slow work on the main thread, such as decoding a large file synchronously.
@MainActor
func blockMainThread(milliseconds: Int) {
    Thread.sleep(forTimeInterval: Double(milliseconds) / 1000)
}
