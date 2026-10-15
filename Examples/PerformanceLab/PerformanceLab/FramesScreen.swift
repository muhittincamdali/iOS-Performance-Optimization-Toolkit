import PerformanceOptimizationKit
import SwiftUI

/// A long list whose rows can be made slow, to show hitches while scrolling.
struct FramesScreen: View {
    let runsDemo: Bool
    @Environment(Lab.self) private var lab
    @State private var slowRows = false

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(0..<400, id: \.self) { index in
                    FrameRow(index: index, isSlow: slowRows)
                        .id(index)
                }
            }
            .safeAreaInset(edge: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    FrameSummary(frames: lab.monitor.snapshot.frames)
                    Toggle("Slow rows (8 ms of work each)", isOn: $slowRows)
                }
                .padding()
                .background(.bar)
            }
            .task {
                guard runsDemo else { return }
                slowRows = true
                try? await Task.sleep(for: .seconds(1))
                for target in stride(from: 10, through: 200, by: 10) {
                    withAnimation(.linear(duration: 0.2)) { proxy.scrollTo(target, anchor: .bottom) }
                    try? await Task.sleep(for: .milliseconds(200))
                }
            }
        }
    }
}

private struct FrameSummary: View {
    let frames: FrameStatistics?

    var body: some View {
        if let frames, frames.frameCount > 0 {
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 6) {
                GridRow {
                    Text("Frame rate").foregroundStyle(.secondary)
                    Text("\(PerformanceFormat.framesPerSecond(frames.framesPerSecond)) of \(PerformanceFormat.framesPerSecond(frames.targetFramesPerSecond))")
                }
                GridRow {
                    Text("Hitch ratio").foregroundStyle(.secondary)
                    Text("\(PerformanceFormat.hitchTimeRatio(frames.hitchTimeRatio)) · \(frames.rating.rawValue)")
                }
                GridRow {
                    Text("Dropped").foregroundStyle(.secondary)
                    Text("\(frames.droppedFrameCount) frames in the last interval")
                }
            }
            .font(.callout.monospacedDigit())
        } else {
            Text("Measuring frames…").foregroundStyle(.secondary)
        }
    }
}

private struct FrameRow: View {
    let index: Int
    let isSlow: Bool

    var body: some View {
        HStack {
            Image(systemName: "square.stack.3d.up")
                .foregroundStyle(Color.labBlue)
            Text("Row \(index + 1)")
            Spacer()
            Text(isSlow ? "slow" : "fast").font(.caption).foregroundStyle(.secondary)
        }
        .onAppear {
            // Stands in for expensive work while a row appears, such as decoding an image on
            // the main thread. 8 ms per row leaves too little of each frame for scrolling.
            if isSlow { Thread.sleep(forTimeInterval: 0.008) }
        }
    }
}
