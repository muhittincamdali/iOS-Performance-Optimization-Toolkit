import PerformanceOptimizationKit
import SwiftUI

/// Allocates and frees memory in 50 MB steps and shows how the footprint follows.
struct MemoryScreen: View {
    let runsDemo: Bool
    @Environment(Lab.self) private var lab
    @State private var blocks: [MemoryBlock] = []

    var body: some View {
        List {
            Section("Footprint") {
                if let memory = lab.monitor.snapshot.memory {
                    MemoryFigures(memory: memory)
                } else {
                    Text("Reading…").foregroundStyle(.secondary)
                }
            }
            Section {
                Button("Allocate 50 MB") { blocks.append(MemoryBlock(megabytes: 50)) }
                Button("Free all (\(blocks.count * 50) MB)", role: .destructive) { blocks.removeAll() }
                    .disabled(blocks.isEmpty)
            } footer: {
                Text("Each block is written to, so its pages count toward the footprint.")
            }
        }
        .task {
            guard runsDemo, blocks.isEmpty else { return }
            for _ in 0..<3 {
                try? await Task.sleep(for: .milliseconds(400))
                blocks.append(MemoryBlock(megabytes: 50))
            }
        }
    }
}

private struct MemoryFigures: View {
    let memory: MemorySnapshot

    var body: some View {
        LabeledContent("Footprint", value: PerformanceFormat.megabytes(memory.footprintBytes))
        if let peak = memory.peakFootprintBytes {
            LabeledContent("Peak", value: PerformanceFormat.megabytes(peak))
        }
        if let available = memory.availableBytes {
            LabeledContent("Left before the limit", value: PerformanceFormat.megabytes(available))
        }
        if let usage = memory.budgetUsage {
            ProgressView(value: usage) {
                Text("\(Int((usage * 100).rounded()))% of the app's memory limit")
            }
            .tint(.labBlue)
        }
    }
}

/// A block of memory that stays allocated until it is released.
private final class MemoryBlock: Identifiable {
    private let pointer: UnsafeMutableRawPointer
    private let size: Int

    init(megabytes: Int) {
        size = megabytes * 1_048_576
        pointer = .allocate(byteCount: size, alignment: 16)
        pointer.initializeMemory(as: UInt8.self, repeating: 0xA5, count: size)
    }

    deinit {
        pointer.deallocate()
    }
}
