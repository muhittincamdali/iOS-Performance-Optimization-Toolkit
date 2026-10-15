import PerformanceOptimizationKit
import SwiftUI

/// Opens screens whose view model is either released or kept alive by a closure, and lists
/// what LeakTracker reports two seconds after each closes.
struct LeaksScreen: View {
    let runsDemo: Bool
    @Environment(Lab.self) private var lab
    @State private var presented: ProfileModel?

    var body: some View {
        List {
            Section {
                Button("Open a screen that is released") { presented = ProfileModel(leaks: false) }
                Button("Open a screen that leaks") { presented = ProfileModel(leaks: true) }
            } footer: {
                Text("When the sheet closes, the tracker waits two seconds and reports the view model if it is still alive.")
            }
            Section("Reports") {
                if lab.leakReports.isEmpty {
                    Text("No leaks reported").foregroundStyle(.secondary)
                }
                ForEach(Array(lab.leakReports.reversed().enumerated()), id: \.offset) { _, report in
                    VStack(alignment: .leading) {
                        Text(report.name).font(.headline)
                        Text(report.typeName).font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .sheet(item: $presented, onDismiss: nil) { model in
            ProfileSheet(model: model)
                .onDisappear { lab.leaks.expectRelease(of: model, name: model.title) }
        }
        .task {
            guard runsDemo, lab.leakReports.isEmpty else { return }
            // The same as opening and closing both sheets.
            lab.leaks.expectRelease(of: ProfileModel(leaks: false), name: "Profile (released)")
            lab.leaks.expectRelease(of: ProfileModel(leaks: true), name: "Profile (leaks)")
        }
    }
}

private struct ProfileSheet: View {
    let model: ProfileModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text(model.leaks ? "This view model keeps itself alive through a closure." : "This view model is released when the sheet closes.")
                .padding()
                .navigationTitle(model.title)
                .toolbar {
                    Button("Close") { dismiss() }
                }
        }
    }
}

/// A view model that, with `leaks`, stores a closure that captures itself: a retain cycle.
final class ProfileModel: Identifiable {
    let leaks: Bool
    private var onRefresh: (() -> Void)?

    init(leaks: Bool) {
        self.leaks = leaks
        if leaks {
            onRefresh = { self.refresh() }
        }
    }

    var title: String { leaks ? "Profile (leaks)" : "Profile (released)" }

    func refresh() {}
}
