import Foundation
import PerformanceOptimizationKit
import SwiftUI

/// Times a JSON decode with PerformanceTracer and shows the statistics.
struct TracingScreen: View {
    let runsDemo: Bool
    @Environment(Lab.self) private var lab
    @State private var statistics: SampleStatistics?

    var body: some View {
        List {
            Section {
                Button("Decode 2,000 records 20 times") { runTrace() }
            } footer: {
                Text("Each run is a signpost interval named \"Decode records\" in the Points of Interest instrument.")
            }
            if let statistics {
                Section("Decode records") {
                    LabeledContent("Runs", value: "\(statistics.count)")
                    LabeledContent("Median", value: PerformanceFormat.milliseconds(.seconds(statistics.p50)))
                    LabeledContent("95th percentile", value: PerformanceFormat.milliseconds(.seconds(statistics.p95)))
                    LabeledContent("Slowest", value: PerformanceFormat.milliseconds(.seconds(statistics.maximum)))
                }
                .monospacedDigit()
            }
        }
        .task {
            if runsDemo, statistics == nil { runTrace() }
        }
    }

    private func runTrace() {
        let data = SampleRecord.json(count: 2_000)
        for _ in 0..<20 {
            _ = lab.tracer.measure("Decode records") {
                try? JSONDecoder().decode([SampleRecord].self, from: data)
            }
        }
        statistics = lab.tracer.statistics(for: "Decode records")
    }
}

private struct SampleRecord: Codable {
    let id: Int
    let title: String
    let score: Double

    static func json(count: Int) -> Data {
        let records = (0..<count).map { SampleRecord(id: $0, title: "Record \($0)", score: Double($0) / 7) }
        return (try? JSONEncoder().encode(records)) ?? Data()
    }
}

/// Checks the lab's current figures against a budget.
struct BudgetScreen: View {
    let runsDemo: Bool
    @Environment(Lab.self) private var lab

    private let budget = PerformanceBudget(
        maximumFootprintBytes: 150 * 1_048_576,
        maximumHitchTimeRatio: HitchRating.goodLimit,
        maximumHangDuration: .milliseconds(250),
        maximumTimeToFirstFrame: .seconds(1),
        traceLimits: ["Decode records": .milliseconds(20)]
    )

    var body: some View {
        let violations = budget.evaluate(lab.measurements)
        List {
            Section("Limits") {
                LabeledContent("Footprint", value: "150 MB")
                LabeledContent("Hitch ratio", value: "10 ms/s")
                LabeledContent("Longest hang", value: "250 ms")
                LabeledContent("First frame", value: "1 s")
                LabeledContent("Decode records, p95", value: "20 ms")
            }
            Section("Result") {
                if violations.isEmpty {
                    Label("Within budget", systemImage: "checkmark.circle").foregroundStyle(Color.labBlue)
                }
                ForEach(violations.map(\.description), id: \.self) { violation in
                    Label(violation, systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
                }
            }
        }
        .task {
            guard runsDemo else { return }
            // Something over budget to show: one hang.
            try? await Task.sleep(for: .seconds(1))
            blockMainThread(milliseconds: 400)
        }
    }
}
