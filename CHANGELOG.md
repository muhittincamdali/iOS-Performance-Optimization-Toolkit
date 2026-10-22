# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-22

A rebuilt package. The 1.0.0 sources did not build: `PerformanceDashboard.swift` and
`StartupTimeAnalyzer.swift` both declared `RecommendationCategory`, the test targets referred
to types that had been removed, and the README described features the code did not have.
This release replaces them with a dependency-free package in the Swift 6 language mode for
iOS 17, macOS 14, tvOS 17, watchOS 10 and visionOS 1 and later.

### Added

- Hangs: `HangDetector` watches the main queue (or any serial queue) from a background thread
  and reports `HangEvent`s from a threshold (250 ms by default). With `capturesBacktraces`, it
  records the main thread's call stack while the hang is still going on, as `StackFrame`s
  with binary and demangled symbol names. Time in which the whole process was stopped, such
  as an app in the background, is not reported as a hang. `HangSeverity` follows the limits
  in Apple's "Understanding hangs in your app".
- Frames: `FrameTimeline` turns display link callbacks into `FrameStatistics` (frame rate,
  hitch time, hitch time ratio in ms/s, dropped frames), treating jitter and pauses correctly;
  `FrameRateMonitor` runs the display link (also on macOS 14 through `NSScreen`);
  `HitchRating` uses the limits in Apple's "Understanding hitches in your app".
- Memory and CPU: `MemorySnapshot` reads the physical footprint, its peak, the resident size
  and the memory left before the app's limit; `CPUSnapshot` reads the usage of every thread;
  `ProcessCPUTime` measures CPU time over an interval and on the calling thread.
- Launch: `ProcessLaunch` reads the process start time from the kernel and detects prewarmed
  launches; `LaunchTimer` and `measuresLaunch()` record the first frame and the moment the app
  became usable.
- Leaks: `LeakTracker` reports objects that are still alive after a grace period.
- Operations: `PerformanceTracer` runs work in `OSSignposter` intervals and keeps statistics
  (`SampleStatistics`, p50 to p99) per name.
- Network: `NetworkMetricsCollector` records the phases of each request as `NetworkTiming`,
  with URLs redacted by `URLRedaction`; query parameters can be kept by name with
  `URLRedaction(allowedQueryParameters:)`, or everything but the host dropped with
  `recordsHostOnly`.
- Field data: `FieldMetricsReceiver` turns MetricKit's reports into `FieldMetrics`, using
  `MetricManager` on iOS 27 and macOS 27 and `MXMetricManager` before; `FieldHistogram`
  estimates percentiles from MetricKit's histograms.
- Budgets: `PerformanceBudget` checks `PerformanceMeasurements` and returns
  `BudgetViolation`s.
- Overlay: `PerformanceMonitor` (`@Observable`) and `PerformanceHUD`.
- The PerformanceLab example app, a DocC catalog with five articles, and 115 Swift Testing
  tests that run on macOS, 114 of them also on an iPhone simulator.

### Removed

- The 1.0.0 API (`PerformanceCore`, the optimizer and profiler singletons, the dashboard)
  and its dependencies on swift-log and swift-metrics.
- The CocoaPods podspec, which pointed at a pod that was never published.

### Security

- Every buffer has a limit, and values read from the kernel or decoded from JSON are checked
  before they reach integer conversions or arithmetic. `PerformanceTracer` does not record,
  and `LeakTracker` does not track, names longer than 256 bytes.
- Network timings never hold headers or bodies, and a method or protocol name only when it is
  a short plain word. `URLRedaction` hides whatever it does not fully understand: credentials,
  the fragment and the query (except allowed parameters with short plain values, checked part
  by part when they hold commas) are always dropped; identifiers, the segment after a secret
  name, and names that are not plain ASCII (look-alike letters, a single letter from another
  script inside a word, invisible characters, combining marks) or hold a secret name together
  with more (`token-hunter22`) and the segment after them become `:id`; paths that servers read
  differently (dot segments, `;`, double or encoded delimiters) and hosts that name a secret
  keep scheme and host only; unreadable hosts, IPv6 hosts with a zone and hosts that hold a
  secret name together with more (`myapp://pin.ab12cd`, `token.example.com`) keep the scheme
  only.
  Paths, queries and results have documented caps, and URLs of 1 MB are redacted in well under
  a second on a 512 KiB stack.

## [1.0.0] - 2026-02-02

First tagged release. Its sources did not build.

[Unreleased]: https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/releases/tag/v1.0.0
