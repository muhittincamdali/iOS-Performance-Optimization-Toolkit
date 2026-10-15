<!-- i18n-source: README.md@21fa6ae667b204fc005d94d0bc728f2b5ba1e67b status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg" alt="Performance Toolkit: Find hangs, hitches, memory growth, slow launches and leaks in Swift apps, and check them in tests."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg" alt="最新版本: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

这是一个用于衡量应用为何“卡顿”的 Swift 软件包，支持 iOS 17+、macOS 14+、tvOS 17+、watchOS 10+ 和 visionOS 1+，无任何依赖。它可以报告主线程卡死（hang）及导致卡死的调用栈，以 Apple 的 hitch time ratio 报告掉帧，报告系统用来与应用上限比较的内存占用（memory footprint），报告从进程启动那一刻算起的启动时间，以及生命周期超出其界面的 view model。用户设备上的同样数据可通过 MetricKit 获取，而预算（budget）可以把其中任何一项变成会失败的测试。

## 亮点

- **带调用栈的卡死检测** — 当主线程停止响应达 250 ms 或更久时，`HangDetector` 会上报，并在主线程仍被阻塞期间记录其调用栈，Swift 符号名已还原（demangle）。
- **按 Apple 的方式统计 hitch** — `FrameTimeline` 测量每一帧延迟了多久，以 ms/s 为单位报告 hitch time ratio，并按 Apple 文档中的阈值分级。
- **真正重要的内存指标** — `MemorySnapshot` 读取系统实际执行限制所依据的物理内存占用及其峰值，在真机上还能读取距离上限所剩的内存。
- **启动与泄漏** — `LaunchTimer` 从进程创建时（早于 `main`）开始计时，并能识别预热（prewarmed）启动；`LeakTracker` 报告界面关闭后仍然存活的对象。
- **线上数据与预算** — `FieldMetricsReceiver` 读取 MetricKit 在 iOS 17 至 27 上的每日报告；`PerformanceBudget` 可在测试中用限值检查任意测量结果。
- **为长时间运行而设计** — 每个缓冲区都有上限，来自内核或 payload 的值在使用前都会校验，URL 在存储前会先脱敏。99 个 Swift Testing 测试在 macOS 上运行，其中 98 个也会在 iPhone 模拟器上运行，测试针对真实的卡死、内存分配和 HTTP 请求。

### 包含的内容

| 范围       | API                                                                     |
| ---------- | ----------------------------------------------------------------------- |
| 实时浮层   | `PerformanceMonitor`, `PerformanceHUD`, `PerformanceSnapshot`           |
| 卡死       | `HangDetector`, `HangEvent`, `HangSeverity`, `StackFrame`               |
| 帧         | `FrameRateMonitor`, `FrameTimeline`, `FrameStatistics`, `HitchRating`   |
| 内存与 CPU | `MemorySnapshot`, `CPUSnapshot`, `ProcessCPUTime`                       |
| 启动       | `LaunchTimer`, `LaunchMeasurement`, `ProcessLaunch`, `measuresLaunch()` |
| 泄漏       | `LeakTracker`, `LeakReport`                                             |
| 操作       | `PerformanceTracer`（用于 Instruments 的 signpost）, `SampleStatistics` |
| 网络       | `NetworkMetricsCollector`, `NetworkTiming`, `URLRedaction`              |
| 线上数据   | `FieldMetricsReceiver`, `FieldMetrics`, `FieldHistogram`                |
| 预算       | `PerformanceBudget`, `PerformanceMeasurements`, `BudgetViolation`       |

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

将其粘贴到窗口右上角的搜索框中。保持 **Dependency Rule** 为从 `2.0.0` 起的 **Up to Next Major Version**，然后点击 **Add Package**。在接下来的窗口中，在 **PerformanceOptimizationKit** 旁选择你的 App target，再次点击 **Add Package**。

**2. 导入模块**

```swift
import PerformanceOptimizationKit
```

**3. 显示浮层**

把你的第一个视图包在一个视图里，由它启动 `PerformanceMonitor` 并显示其 `PerformanceHUD`：

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

在 `App` 中用 `RootView()` 取代 `ContentView()` 并运行应用：右上角的浮层会显示帧率、hitch 比率、CPU、内存和最近一次卡死，并且每秒刷新一次。帧监视器会让屏幕保持在完整刷新率，因此请只在 debug 构建中显示该浮层（`#if DEBUG`）。

## 安装

### Swift Package Manager

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

或者将其添加到 `Package.swift` 的 `dependencies` 中：

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

请使用 2.0.0 或更高版本：1.0.0 版本无法构建，而 2.0.0 替换了它的 API。

## 使用方法

### 找出是什么阻塞了主线程

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

最内层的栈帧显示卡死达到 250 ms 时主线程正在运行的内容。在没有符号的 release 构建中，栈帧只带有地址和二进制文件名，请用 dSYM 对其符号化。

### 测量启动时间

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

计时从内核创建进程时开始，因此包含 `main` 之前的动态链接器（dynamic linker）和静态初始化器。预热的进程在用户打开应用之前一直处于挂起等待状态；`wasPrewarmed` 用来告诉你应把这次启动排除在外。

### 检查预算

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

每条违规信息形如 `hang of 900 ms exceeds 250 ms`。在单元测试中，传入 `PerformanceTracer` 的统计数据，并断言 `#expect(violations.isEmpty)`；具体做法见[预算文章](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)。

### 通过 MetricKit 读取线上数据

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

MetricKit 大约每天送达一份报告，来源是其所有者同意与开发者共享分析数据的设备。`FieldMetrics` 遵循 `Codable`，且不依赖 MetricKit，因此你可以把它上传并在服务器上解码。在 iOS 27 和 macOS 27 上，接收器使用新的 `MetricManager`，更早的系统则使用 `MXMetricManager`。

## 示例应用

[`Examples/PerformanceLab`](Examples/) 是一个 iOS 和 macOS 应用，它会故意制造每一种问题，让你观察测量值如何变化。从左到右依次是：一次 600 ms 的主线程卡死（其调用栈指向对应的应用函数）、以全速滚动的带慢速行的列表、被 closure 保持存活的 view model，以及能捕获卡死的预算检查。

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-hangs-dark.png"><img src="docs/images/example-hangs-light.png" width="200" alt="Hangs 界面：一次约 600 ms 的卡死，其调用栈指向 PerformanceLab.blockMainThread"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-frames-dark.png"><img src="docs/images/example-frames-light.png" width="200" alt="Frames 界面：滚动慢速行时帧率约为 40 fps（满帧为 60 fps），hitch 比率为严重"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-leaks-dark.png"><img src="docs/images/example-leaks-light.png" width="200" alt="Leaks 界面：PerformanceLab.ProfileModel 的报告“Profile (leaks)”"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-budget-dark.png"><img src="docs/images/example-budget-light.png" width="200" alt="Budget 界面：五项限值以及违规“hang exceeds 250 ms”"></picture>
</p>

这些截图由 [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) 在 iPhone 模拟器上从运行中的应用截取，因此图中的数值是实测得到的，而不是画出来的。

## 文档

[DocC 文档](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/)涵盖每一个公开类型，并包含以下文章：

- [Getting Started](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/gettingstarted)
- [Finding Hangs and Hitches](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/findinghangsandhitches)
- [Reading Field Metrics](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/readingfieldmetrics)
- [Setting Performance Budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)

## 系统要求

| 平台     | 最低版本 |
| -------- | -------- |
| iOS      | 17.0     |
| macOS    | 14.0     |
| tvOS     | 17.0     |
| watchOS  | 10.0     |
| visionOS | 1.0      |

Swift 6.2 或更高版本（Xcode 26 或更高版本）。该软件包使用 Swift 6 语言模式构建。帧监视器需要 display link，因此在 watchOS 上不可用；MetricKit 在 tvOS 和 watchOS 上不可用。卡死的调用栈可在 arm64 和 x86_64 上读取，除 watchOS 外的所有平台均支持，因为 watchOS 不允许应用挂起自己的线程。

## 参与贡献

欢迎提交 bug 报告和 pull request；[CONTRIBUTING.md](CONTRIBUTING.md) 说明了如何构建、测试以及重新生成截图。如需私下报告安全问题，请参阅 [SECURITY.md](SECURITY.md)。

## 许可证

MIT。详见 [LICENSE](LICENSE)。
