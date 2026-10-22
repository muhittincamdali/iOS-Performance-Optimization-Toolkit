<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg" alt="Performance Toolkit: Find hangs, hitches, memory growth, slow launches and leaks in Swift apps, and check them in tests."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg" alt="Latest version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

A Swift package that measures what makes an app feel slow, on iOS 17+, macOS 14+, tvOS 17+,
watchOS 10+ and visionOS 1+, with no dependencies. It reports main-thread hangs with the
call stack that caused them, late frames as Apple's hitch time ratio, the memory footprint
the system compares with your app's limit, launch time from the moment the process started,
and view models that outlive their screen. The same figures come from people's devices
through MetricKit, and a budget turns any of them into a failing test.

## Highlights

- **Hangs with call stacks** — `HangDetector` reports when the main thread stops responding
  for 250 ms or more and, while it is still blocked, records its call stack with demangled
  Swift names.
- **Hitches the way Apple counts them** — `FrameTimeline` measures how late each frame is and
  reports the hitch time ratio in ms/s, graded with the limits from Apple's documentation.
- **The memory figure that matters** — `MemorySnapshot` reads the physical footprint the
  system enforces, its peak, and on devices the memory left before the limit.
- **Launch and leaks** — `LaunchTimer` measures from process creation (before `main`) and
  recognises prewarmed launches; `LeakTracker` reports objects still alive after their screen
  closed.
- **Field data and budgets** — `FieldMetricsReceiver` reads MetricKit's daily reports on iOS
  17 to 27; `PerformanceBudget` checks any measurement against limits in a test.
- **Built to run all day** — every buffer has a limit, values from the kernel or a payload are
  checked before use, and network timings hold no headers or bodies and a redacted URL. 128
  Swift Testing tests run on macOS, 127 of them also on an iPhone simulator, against real
  hangs, allocations and HTTP requests.

### What's included

| Area | API |
| --- | --- |
| Live overlay | `PerformanceMonitor`, `PerformanceHUD`, `PerformanceSnapshot` |
| Hangs | `HangDetector`, `HangEvent`, `HangSeverity`, `StackFrame` |
| Frames | `FrameRateMonitor`, `FrameTimeline`, `FrameStatistics`, `HitchRating` |
| Memory and CPU | `MemorySnapshot`, `CPUSnapshot`, `ProcessCPUTime` |
| Launch | `LaunchTimer`, `LaunchMeasurement`, `ProcessLaunch`, `measuresLaunch()` |
| Leaks | `LeakTracker`, `LeakReport` |
| Operations | `PerformanceTracer` (signposts for Instruments), `SampleStatistics` |
| Network | `NetworkMetricsCollector`, `NetworkTiming`, `URLRedaction` |
| Field data | `FieldMetricsReceiver`, `FieldMetrics`, `FieldHistogram` |
| Budgets | `PerformanceBudget`, `PerformanceMeasurements`, `BudgetViolation` |

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

Paste it into the search field at the top right of the window. Leave **Dependency Rule** at
**Up to Next Major Version** from `2.0.0`, then click **Add Package**. In the next window,
choose your app target next to **PerformanceOptimizationKit** and click **Add Package** again.

**2. Import the module**

```swift
import PerformanceOptimizationKit
```

**3. Show the overlay**

Wrap your first view in a view that starts a `PerformanceMonitor` and shows its
`PerformanceHUD`:

```swift
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

Show `RootView()` instead of `ContentView()` in your `App` and run the app: the overlay in the
top right corner shows the frame rate, hitch ratio, CPU, memory and the last hang, and updates
every second. The frame monitor keeps the display at its full refresh rate, so show the
overlay in debug builds only (`#if DEBUG`).

## Installation

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

Or add it to the `dependencies` in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git", from: "2.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "PerformanceOptimizationKit", package: "iOS-Performance-Optimization-Toolkit")
    ])
]
```

Use 2.0.0 or later: the 1.0.0 release did not build, and 2.0.0 replaces its API.

## Usage

### Find out what blocks the main thread

```swift
func watchForHangs() {
    let detector = HangDetector(capturesBacktraces: true)
    detector.start()
    Task {
        for await hang in detector.events() {
            print("Main thread blocked for \(hang.duration)")
            for frame in hang.backtrace?.prefix(5) ?? [] {
                print("  \(frame.image ?? "?")  \(frame.symbol ?? "?")")
            }
        }
    }
}
```

The innermost frames show what the main thread was running when the hang reached 250 ms. In a
release build without symbols the frames carry addresses and binary names; symbolicate them
with the dSYM.

### Measure the launch

```swift
struct LaunchSampleApp: View {
    var body: some View {
        ContentView()
            .measuresLaunch()
            .task {
                let launch = LaunchTimer.markInteractive()
                if !launch.wasPrewarmed, let firstFrame = launch.timeToFirstFrame {
                    print("First frame after \(firstFrame)")
                }
            }
    }
}
```

The time starts when the kernel created the process, so it includes the dynamic linker and
static initializers before `main`. A prewarmed process waited suspended before the person
opened the app; `wasPrewarmed` tells you to leave that launch out.

### Check a budget

```swift
@MainActor
func checkBudget(of monitor: PerformanceMonitor) {
    let budget = PerformanceBudget(
        maximumFootprintBytes: 200 * 1_048_576,
        maximumHitchTimeRatio: HitchRating.goodLimit,
        maximumHangDuration: .milliseconds(250)
    )
    for violation in budget.evaluate(monitor.measurements) {
        print("Over budget: \(violation)")
    }
}
```

Each violation reads like `hang of 900 ms exceeds 250 ms`. In a unit test, pass
`PerformanceTracer` statistics and `#expect(violations.isEmpty)`; the
[budgets article](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets) shows how.

### Read field data from MetricKit

```swift
let fieldMetrics = FieldMetricsReceiver()

func receiveFieldMetrics() {
    fieldMetrics.start()
    Task {
        for await metrics in fieldMetrics.updates() {
            if let launches = metrics.timeToFirstDraw, let median = launches.percentile(0.5) {
                print("Median launch: \(median) s over \(launches.totalCount) launches")
            }
        }
    }
}
```

MetricKit delivers a report about once a day from devices whose owners share analytics with
developers. `FieldMetrics` is `Codable` and has no MetricKit dependency, so you can upload it
and decode it on a server. On iOS 27 and macOS 27 the receiver uses the new `MetricManager`,
on earlier systems `MXMetricManager`.

### Time network requests

```swift
let networkTimings = NetworkMetricsCollector(redaction: URLRedaction(allowedQueryParameters: ["page"]))

func loadOrders(page: Int) async throws -> Data {
    let url = URL(string: "https://api.example.com/v1/orders?page=\(page)")!
    let (data, _) = try await URLSession.shared.data(from: url, delegate: networkTimings)
    return data
}

func logSlowRequests() {
    Task {
        for await timing in networkTimings.updates() {
            if let waiting = timing.phases.waiting, waiting > .milliseconds(500) {
                print("\(timing.url) waited \(waiting) for the server")
            }
        }
    }
}
```

Each `NetworkTiming` splits the request into DNS lookup, connection, TLS, sending, waiting for
the first byte and receiving. Its URL is redacted before it is stored:
`https://api.example.com/v1/users/48213/orders?page=2&token=abc` is recorded as
`https://api.example.com/v1/users/:id/orders?page=2`.

## What is recorded

The package is meant for internal and beta builds that real people use, so its reports must not
carry their data.

- **Recorded:** durations, frame and hitch figures, memory and CPU figures, call stacks of the
  main thread during a hang (binary and symbol names), MetricKit's figures and the app build,
  the type names of objects that outlive their screen, and for each request its redacted URL,
  method, status code, protocol, phase timings and response size. Names you pass to
  `PerformanceTracer` and `LeakTracker` are recorded as you give them, so use fixed names.
- **Never recorded:** request and response headers (`Authorization`, cookies), request and
  response bodies, the user name and password and the fragment of a URL, and its query, except
  for parameters you allow by name.
- **URLs:** path segments that look like identifiers (numbers, UUIDs, e-mail addresses, six or
  more digits, card numbers, IBANs, tokens) become `:id`, and so does the segment after a name
  such as `token` or `password`. A segment that is not plain ASCII after percent-decoding, such
  as `Şifre` or a word with a look-alike letter from another script, is hidden together with the
  next one, on purpose. A path that servers could read in different ways (`..`, `;`, double
  percent-encoding) is recorded as scheme and host only.

Redaction is a safety net, not a guarantee. It cannot tell that an ordinary word in a path, such
as an invitation code `sunflower`, is secret. Keep secrets out of URLs, or record the host only
with `URLRedaction(recordsHostOnly: true)`. The
[network timings article](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)
lists every rule and its limits.

## Example app

[`Examples/PerformanceLab`](Examples/) is an iOS and macOS app that causes each problem on
purpose so you can watch the measurement react. From left to right: a 600 ms main-thread hang
with the app function its call stack points at, a list with slow rows scrolled at full speed,
a view model kept alive by a closure, and a budget check that catches a hang.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-hangs-dark.png"><img src="docs/images/example-hangs-light.png" width="200" alt="Hangs screen: a hang of about 600 ms whose call stack points at PerformanceLab.blockMainThread"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-frames-dark.png"><img src="docs/images/example-frames-light.png" width="200" alt="Frames screen: frame rate about 40 of 60 fps and a severe hitch ratio while slow rows scroll"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-leaks-dark.png"><img src="docs/images/example-leaks-light.png" width="200" alt="Leaks screen: the report 'Profile (leaks)' for PerformanceLab.ProfileModel"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-budget-dark.png"><img src="docs/images/example-budget-light.png" width="200" alt="Budget screen: five limits and the violation 'hang exceeds 250 ms'"></picture>
</p>

The screenshots are taken from the running app on an iPhone simulator by
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh), so the figures are
measured, not drawn.

## Documentation

The [DocC documentation](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/) covers every public type, with these articles:

- [Getting Started](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/gettingstarted)
- [Finding Hangs and Hitches](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/findinghangsandhitches)
- [Reading Field Metrics](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/readingfieldmetrics)
- [Setting Performance Budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)
- [Recording Network Timings](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)

## Requirements

| Platform | Minimum |
| -------- | ------- |
| iOS      | 17.0    |
| macOS    | 14.0    |
| tvOS     | 17.0    |
| watchOS  | 10.0    |
| visionOS | 1.0     |

Swift 6.2 or later (Xcode 26 or later). The package builds in the Swift 6 language mode. The
frame monitor needs a display link, so it is not available on watchOS; MetricKit is not
available on tvOS and watchOS. Call stacks of hangs are read on arm64 and x86_64, on every
platform except watchOS, which does not let an app suspend its own threads.

## Contributing

Bug reports and pull requests are welcome; [CONTRIBUTING.md](CONTRIBUTING.md) explains how to
build, test and regenerate the screenshots. To report a security issue privately, see
[SECURITY.md](SECURITY.md).

## License

MIT. See [LICENSE](LICENSE).
