# `PerformanceOptimizationKit`

Measure hangs, hitches, memory, CPU, launch time and leaks in your app, read MetricKit's field
data, and check the results against budgets in tests.

## Overview

PerformanceOptimizationKit is a Swift package without dependencies for iOS 17, macOS 14,
tvOS 17, watchOS 10 and visionOS 1 and later. It measures the figures Apple's own tools use:
the memory footprint the system compares with the app's limit, the hitch time ratio in
milliseconds per second, and hangs from 250 ms. The quickest way in is the live overlay:

```swift
import PerformanceOptimizationKit
import SwiftUI

struct RootView: View {
    @State private var monitor = PerformanceMonitor()

    var body: some View {
        ContentView()
            .overlay(alignment: .topTrailing) {
                PerformanceHUD(monitor: monitor).padding()
            }
            .task { monitor.start() }
    }
}
```

Each part also works on its own:

- **Hangs**: ``HangDetector`` reports when the main thread stops answering, with the main
  thread's call stack if you ask for it.
- **Frames**: ``FrameRateMonitor`` and ``FrameTimeline`` measure frame rate, hitches and
  dropped frames; ``HitchRating`` grades them with Apple's limits.
- **Memory and CPU**: ``MemorySnapshot``, ``CPUSnapshot`` and ``ProcessCPUTime``.
- **Launch**: ``LaunchTimer`` measures from the moment the kernel started the process.
- **Leaks**: ``LeakTracker`` reports objects that outlive the screen they belonged to.
- **Operations and requests**: ``PerformanceTracer`` emits signposts for Instruments and keeps
  statistics; ``NetworkMetricsCollector`` records the phases of each request with a redacted
  URL and never reads headers or bodies.
- **Field data**: ``FieldMetricsReceiver`` turns MetricKit's daily reports into
  ``FieldMetrics``.
- **Budgets**: ``PerformanceBudget`` checks all of these against limits in tests or at run time.

## Topics

### Essentials

- <doc:GettingStarted>
- ``PerformanceMonitor``
- ``PerformanceHUD``
- ``PerformanceSnapshot``

### Hangs

- <doc:FindingHangsAndHitches>
- ``HangDetector``
- ``HangEvent``
- ``HangSeverity``
- ``StackFrame``

### Frames

- ``FrameRateMonitor``
- ``FrameTimeline``
- ``FrameStatistics``
- ``HitchRating``

### Memory and CPU

- ``MemorySnapshot``
- ``CPUSnapshot``
- ``ProcessCPUTime``

### Launch

- ``LaunchTimer``
- ``LaunchMeasurement``
- ``ProcessLaunch``

### Leaks

- ``LeakTracker``
- ``LeakReport``

### Operations and Requests

- <doc:RecordingNetworkTimings>
- ``PerformanceTracer``
- ``SampleStatistics``
- ``NetworkMetricsCollector``
- ``NetworkTiming``
- ``URLRedaction``

### Field Data

- <doc:ReadingFieldMetrics>
- ``FieldMetricsReceiver``
- ``FieldMetrics``
- ``FieldHistogram``

### Budgets

- <doc:SettingPerformanceBudgets>
- ``PerformanceBudget``
- ``PerformanceMeasurements``
- ``BudgetViolation``

### Support

- ``PerformanceFormat``
- ``RingBuffer``
