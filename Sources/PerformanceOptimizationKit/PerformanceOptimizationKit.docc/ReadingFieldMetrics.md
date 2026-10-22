# Reading Field Metrics

Collect MetricKit's daily reports from people's devices and read launch times and hangs from
them.

## Overview

Measurements on your own device show what you can reproduce. MetricKit reports what happened
on the devices of people who use your app: once a day, on devices where the person shares
analytics with app developers, the system delivers launch times, hang times, hitches, memory
and terminations of the previous day. ``FieldMetricsReceiver`` receives these reports and turns
each into ``FieldMetrics``.

### Receive the reports

Start the receiver early in the launch, so the system can deliver the reports it holds:

```swift
@main
struct MyApp: App {
    private let fieldMetrics = FieldMetricsReceiver()

    init() {
        fieldMetrics.start()
        let updates = fieldMetrics.updates()
        Task {
            for await metrics in updates {
                try? await upload(JSONEncoder().encode(metrics))
            }
        }
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

On iOS 27 and macOS 27 and later the receiver reads `MetricManager.metricReports`; on earlier
systems and on visionOS it subscribes to `MXMetricManager`. ``FieldMetrics`` is `Codable` and
has no MetricKit dependency, so you can decode it on a server written in Swift.

To try it without waiting a day, run the app on a device from Xcode and choose
**Debug › Simulate MetricKit Payloads**.

### Read the histograms

MetricKit reports launch times, resume times and hang times as histograms: how many values fell
into each range. ``FieldHistogram`` estimates percentiles from them by assuming the values are
spread evenly inside each range:

```swift
if let launches = metrics.timeToFirstDraw {
    let median = launches.percentile(0.5)       // seconds
    let slow = launches.fraction(atOrAbove: 0.4) // share of launches of 400 ms or more
}
```

The estimates are only as precise as the ranges. Compare them between app versions rather than
reading single values to the millisecond.

### Damaged input

A histogram decoded from a report or from your own upload format passes the same checks as one
created in code: ranges that are not finite, reversed or empty are left out, totals stop at
`Int.max` instead of overflowing, and at most ``FieldHistogram/maximumBucketCount`` ranges are
kept. A damaged upload cannot make the estimates NaN or crash the server that reads it.
