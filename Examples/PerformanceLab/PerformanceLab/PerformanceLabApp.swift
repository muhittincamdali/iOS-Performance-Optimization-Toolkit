import PerformanceOptimizationKit
import SwiftUI

@main
struct PerformanceLabApp: App {
    @State private var lab = Lab()

    var body: some Scene {
        WindowGroup {
            LabView(initialScreen: Self.launchScreen)
                .environment(lab)
                .measuresLaunch()
                .overlay(alignment: .bottomTrailing) {
                    PerformanceHUD(monitor: lab.monitor)
                        .padding()
                }
                .task { lab.start() }
        }
    }

    /// The screen named after `-screen` on the command line, such as `-screen hangs`.
    /// scripts/capture-example-screens.sh uses it to open each screen and run its demo.
    private static var launchScreen: LabView.Screen? {
        UserDefaults.standard.string(forKey: "screen").flatMap(LabView.Screen.init(rawValue:))
    }
}

/// The measurements the screens share: one monitor, one tracer and one leak tracker.
@MainActor
@Observable
final class Lab {
    let monitor = PerformanceMonitor(sampleInterval: .milliseconds(500))
    let tracer = PerformanceTracer(category: .pointsOfInterest)
    let leaks = LeakTracker(gracePeriod: .seconds(2))
    private(set) var leakReports: [LeakReport] = []
    private var started = false

    func start() {
        guard !started else { return }
        started = true
        monitor.start()
        let reports = leaks.reports()
        Task { [weak self] in
            for await report in reports { self?.leakReports.append(report) }
        }
    }

    /// The monitor's figures plus the tracer's statistics, for the budget screen.
    var measurements: PerformanceMeasurements {
        var measurements = monitor.measurements
        for name in tracer.names {
            measurements.traces[name] = tracer.statistics(for: name)
        }
        return measurements
    }
}

struct LabView: View {
    enum Screen: String, CaseIterable, Identifiable {
        case hangs, frames, memory, leaks, tracing, budget

        var id: Self { self }

        var title: String {
            switch self {
            case .hangs: "Hangs"
            case .frames: "Frames and hitches"
            case .memory: "Memory"
            case .leaks: "Leaks"
            case .tracing: "Tracing"
            case .budget: "Budget"
            }
        }

        var systemImage: String {
            switch self {
            case .hangs: "hourglass"
            case .frames: "speedometer"
            case .memory: "memorychip"
            case .leaks: "drop"
            case .tracing: "timer"
            case .budget: "checklist"
            }
        }
    }

    let initialScreen: Screen?
    @State private var path: [Screen] = []

    var body: some View {
        NavigationStack(path: $path) {
            List(Screen.allCases) { screen in
                NavigationLink(value: screen) {
                    Label(screen.title, systemImage: screen.systemImage)
                }
            }
            .navigationTitle("Performance Lab")
            .navigationDestination(for: Screen.self) { screen in
                destination(for: screen)
                    .navigationTitle(screen.title)
            }
        }
        .tint(.labBlue)
        .onAppear {
            if let initialScreen, path.isEmpty { path = [initialScreen] }
        }
    }

    // A screen opened from the command line runs its demo by itself.
    @ViewBuilder private func destination(for screen: Screen) -> some View {
        let runsDemo = screen == initialScreen
        switch screen {
        case .hangs: HangsScreen(runsDemo: runsDemo)
        case .frames: FramesScreen(runsDemo: runsDemo)
        case .memory: MemoryScreen(runsDemo: runsDemo)
        case .leaks: LeaksScreen(runsDemo: runsDemo)
        case .tracing: TracingScreen(runsDemo: runsDemo)
        case .budget: BudgetScreen(runsDemo: runsDemo)
        }
    }
}

extension Color {
    /// The blue of the package's graphics.
    static let labBlue = Color(red: 0.039, green: 0.518, blue: 1.0)
}
