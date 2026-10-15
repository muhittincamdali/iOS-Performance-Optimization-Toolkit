# Setting Performance Budgets

Turn measurements into checks that fail a test when the app gets slower.

## Overview

A performance budget is a set of limits: the largest memory footprint, the highest hitch time
ratio, the longest hang, the slowest 95th percentile of an operation. ``PerformanceBudget``
holds them and ``PerformanceBudget/evaluate(_:)`` returns every limit that a set of
``PerformanceMeasurements`` exceeds.

### Check an operation in a unit test

Run the operation a few times with a ``PerformanceTracer`` and check the 95th percentile:

```swift
import PerformanceOptimizationKit
import Testing

@Test func parsingStaysFast() throws {
    let tracer = PerformanceTracer()
    let data = try fixture("feed.json")
    for _ in 0..<20 {
        _ = try tracer.measure("Parse feed") { try FeedParser().parse(data) }
    }

    let budget = PerformanceBudget(traceLimits: ["Parse feed": .milliseconds(30)])
    let measurements = PerformanceMeasurements(traces: ["Parse feed": try #require(tracer.statistics(for: "Parse feed"))])
    let violations = budget.evaluate(measurements)
    #expect(violations.isEmpty, "\(violations)")
}
```

When the limit is exceeded, the test fails with a message such as
`Parse feed p95 41 ms exceeds 30 ms`.

### Check memory and hangs at run time

``PerformanceMonitor/measurements`` collects the monitor's current figures. Checking them
when a screen closes catches regressions while you use the app:

```swift
let budget = PerformanceBudget(
    maximumFootprintBytes: 250 * 1_048_576,
    maximumHitchTimeRatio: HitchRating.goodLimit,
    maximumHangDuration: .milliseconds(250)
)

for violation in budget.evaluate(monitor.measurements) {
    logger.error("Over budget: \(violation.description)")
}
```

### Choose the limits

- Start from what the app does today, measured on the oldest device you support, and lower
  the limits as you improve.
- Use the 95th percentile, not the mean, for operations: people remember the slow cases.
- Keep budgets in a JSON file (``PerformanceBudget`` is `Codable`) when several test targets
  or a CI script share them.
- Timing in unit tests depends on the machine. Leave room for slower CI runners, or check
  timing budgets only on known hardware and keep the other limits everywhere.
