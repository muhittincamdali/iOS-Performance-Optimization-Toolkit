# Getting Started

Add the package, show the live overlay, and measure your first operation.

## Overview

This article takes an app from no measurements to a live overlay, a launch measurement and
statistics for one of its own operations.

### Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter
`https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git`, and add the
**PerformanceOptimizationKit** library to your app target.

In a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git", from: "2.0.0")
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "PerformanceOptimizationKit", package: "iOS-Performance-Optimization-Toolkit")
    ])
]
```

### Show the overlay

``PerformanceMonitor`` runs the hang detector and the frame monitor and reads memory and CPU
once a second. ``PerformanceHUD`` shows its figures. Keep the monitor in `@State` of your root
view and start it in `.task`:

```swift
@main
struct MyApp: App {
    @State private var monitor = PerformanceMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .overlay(alignment: .topTrailing) {
                    #if DEBUG
                    PerformanceHUD(monitor: monitor).padding()
                    #endif
                }
                .task {
                    #if DEBUG
                    monitor.start()
                    #endif
                }
        }
    }
}
```

The frame monitor runs a display link, which keeps the display at its full refresh rate, so
the overlay belongs in debug and internal builds. Pass `measuresFrames: false` to leave the
display link out.

### Measure the launch

``LaunchTimer`` measures from the moment the kernel created the process, so the result
includes the time before `main` that the dynamic linker and static initializers take. Attach
`measuresLaunch()` to the first view and read the measurement when you need it:

```swift
ContentView()
    .measuresLaunch()

// Later, for example when the first data has loaded:
let launch = LaunchTimer.markInteractive()
if !launch.wasPrewarmed, let firstFrame = launch.timeToFirstFrame {
    logger.info("First frame after \(firstFrame)")
}
```

When the system prewarmed the process, it sat suspended before the person opened the app, and
the durations do not describe the launch they saw; ``LaunchMeasurement/wasPrewarmed`` tells
you to leave those out.

### Measure an operation

``PerformanceTracer`` wraps work in an `OSSignposter` interval, so it shows up in Instruments,
and keeps the durations:

```swift
let tracer = PerformanceTracer()

func reload() async throws {
    let items = try await tracer.measure("Load feed") {
        try await api.feed()
    }
    show(items)
}

// After a few reloads:
if let statistics = tracer.statistics(for: "Load feed") {
    print("median \(statistics.p50) s, p95 \(statistics.p95) s")
}
```

### Next steps

- <doc:FindingHangsAndHitches> explains what the hang and hitch figures mean and how to find
  the code behind them.
- <doc:SettingPerformanceBudgets> turns the figures into checks that fail a test.
- <doc:ReadingFieldMetrics> collects the same kind of figures from people's devices.
