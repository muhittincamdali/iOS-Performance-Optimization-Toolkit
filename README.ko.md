<!-- i18n-source: README.md@7713e35c837f2f5de2312d94c19d1af745744d0e status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg" alt="Performance Toolkit: Find hangs, hitches, memory growth, slow launches and leaks in Swift apps, and check them in tests."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg" alt="최신 버전: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

앱이 느리게 느껴지는 원인을 측정하는 Swift 패키지입니다. iOS 17+, macOS 14+, tvOS 17+, watchOS 10+, visionOS 1+를 지원하며 의존성이 없습니다. 메인 스레드 멈춤(hang)과 그 원인이 된 콜 스택, Apple의 hitch time ratio로 나타낸 프레임 지연, 시스템이 앱의 한도와 비교하는 메모리 풋프린트, 프로세스가 시작된 시점부터 잰 실행 시간, 화면이 사라진 뒤에도 남아 있는 view model을 보고합니다. 같은 수치를 사용자 기기에서도 MetricKit을 통해 받을 수 있고, 예산(budget)을 설정하면 그중 무엇이든 실패하는 테스트로 바꿀 수 있습니다.

## 주요 기능

- **콜 스택이 포함된 hang 감지** — 메인 스레드가 250 ms 이상 응답하지 않으면 `HangDetector`가 알려 주고, 아직 막혀 있는 동안 디맹글(demangle)된 Swift 이름으로 콜 스택을 기록합니다.
- **Apple이 세는 방식 그대로의 hitch** — `FrameTimeline`은 각 프레임이 얼마나 늦었는지 측정하고 hitch time ratio를 ms/s 단위로 보고하며, Apple 문서의 기준값으로 등급을 매깁니다.
- **정말 중요한 메모리 수치** — `MemorySnapshot`은 시스템이 제한을 적용하는 기준인 물리 풋프린트와 그 최댓값을 읽고, 실제 기기에서는 한도까지 남은 메모리도 읽습니다.
- **실행과 누수** — `LaunchTimer`는 프로세스가 생성된 시점(`main` 이전)부터 측정하며 프리워밍(prewarmed)된 실행을 구별합니다. `LeakTracker`는 화면이 닫힌 뒤에도 여전히 살아 있는 객체를 보고합니다.
- **실사용 데이터와 예산** — `FieldMetricsReceiver`는 iOS 17부터 27까지 MetricKit의 일일 리포트를 읽고, `PerformanceBudget`은 테스트에서 모든 측정값을 한도와 대조합니다.
- **하루 종일 돌아가도록 설계** — 모든 버퍼에는 한도가 있고, 커널이나 페이로드에서 온 값은 사용하기 전에 검증하며, 네트워크 타이밍에는 헤더나 본문이 들어 있지 않고 가려진 URL만 담깁니다. Swift Testing 테스트 115개가 macOS에서 실행되고 그중 114개는 iPhone 시뮬레이터에서도 실행되며, 실제 hang, 메모리 할당, HTTP 요청을 대상으로 합니다.

### 포함된 구성 요소

| 영역            | API                                                                     |
| --------------- | ----------------------------------------------------------------------- |
| 라이브 오버레이 | `PerformanceMonitor`, `PerformanceHUD`, `PerformanceSnapshot`           |
| Hang            | `HangDetector`, `HangEvent`, `HangSeverity`, `StackFrame`               |
| 프레임          | `FrameRateMonitor`, `FrameTimeline`, `FrameStatistics`, `HitchRating`   |
| 메모리와 CPU    | `MemorySnapshot`, `CPUSnapshot`, `ProcessCPUTime`                       |
| 실행            | `LaunchTimer`, `LaunchMeasurement`, `ProcessLaunch`, `measuresLaunch()` |
| 누수            | `LeakTracker`, `LeakReport`                                             |
| 작업            | `PerformanceTracer` (Instruments용 signpost), `SampleStatistics`        |
| 네트워크        | `NetworkMetricsCollector`, `NetworkTiming`, `URLRedaction`              |
| 실사용 데이터   | `FieldMetricsReceiver`, `FieldMetrics`, `FieldHistogram`                |
| 예산            | `PerformanceBudget`, `PerformanceMeasurements`, `BudgetViolation`       |

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

창 오른쪽 위의 검색 필드에 붙여 넣으세요. **Dependency Rule**은 `2.0.0`부터 **Up to Next Major Version**으로 둔 채 **Add Package**를 클릭합니다. 다음 창에서 **PerformanceOptimizationKit** 옆에 앱 타깃을 선택하고 **Add Package**를 다시 클릭하세요.

**2. 모듈 가져오기**

```swift
import PerformanceOptimizationKit
```

**3. 오버레이 표시**

첫 번째 뷰를 `PerformanceMonitor`를 시작하고 그 `PerformanceHUD`를 표시하는 뷰로 감싸세요.

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

`App`에서 `ContentView()` 대신 `RootView()`를 표시하고 앱을 실행하세요. 오른쪽 위 모서리의 오버레이에 프레임 레이트, hitch 비율, CPU, 메모리, 마지막 hang이 표시되며 1초마다 갱신됩니다. 프레임 모니터는 디스플레이를 최대 주사율로 유지하므로 오버레이는 디버그 빌드에서만 표시하세요(`#if DEBUG`).

## 설치

### Swift Package Manager

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

또는 `Package.swift`의 `dependencies`에 추가하세요.

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

2.0.0 이상을 사용하세요. 1.0.0 릴리스는 빌드되지 않았고, 2.0.0에서 API가 교체되었습니다.

## 사용법

### 메인 스레드를 막는 원인 찾기

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

가장 안쪽 프레임은 hang이 250 ms에 도달했을 때 메인 스레드가 실행 중이던 코드를 보여 줍니다. 심볼이 없는 release 빌드에서는 프레임에 주소와 바이너리 이름이 담깁니다. dSYM으로 심볼화하세요.

### 실행 시간 측정

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

시간은 커널이 프로세스를 만든 시점부터 시작하므로 `main` 이전의 dynamic linker와 static initializer 시간도 포함됩니다. 프리워밍된 프로세스는 사용자가 앱을 열기 전에 일시 중단된 상태로 기다린 것입니다. `wasPrewarmed`는 그 실행을 제외해야 한다는 것을 알려 줍니다.

### 예산 확인

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

각 위반은 `hang of 900 ms exceeds 250 ms`처럼 표시됩니다. 단위 테스트에서는 `PerformanceTracer` 통계를 넘기고 `#expect(violations.isEmpty)`로 검증하세요. 방법은 [예산 문서](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)에 나와 있습니다.

### MetricKit에서 실사용 데이터 읽기

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

MetricKit은 기기 소유자가 개발자와 분석 데이터를 공유하는 기기에서 하루에 한 번 정도 리포트를 전달합니다. `FieldMetrics`는 `Codable`이고 MetricKit에 의존하지 않으므로 서버로 업로드해 디코딩할 수 있습니다. iOS 27과 macOS 27에서는 새로운 `MetricManager`를, 그 이전 시스템에서는 `MXMetricManager`를 사용합니다.

### 네트워크 요청 시간 측정

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

각 `NetworkTiming`은 요청을 DNS 조회, 연결, TLS, 전송, 첫 바이트까지의 대기, 수신으로 나눕니다. URL은 저장하기 전에 가려집니다. 원본 URL이 `https://api.example.com/v1/users/48213/orders?page=2&token=abc` 인 경우 기록되는 값은 `https://api.example.com/v1/users/:id/orders?page=2`.

## 기록되는 내용

이 패키지는 실제 사용자가 쓰는 내부 빌드와 베타 빌드를 위한 것이므로, 리포트에 사용자의 데이터가 들어가서는 안 됩니다.

- **기록되는 것:** 소요 시간, 프레임과 hitch 수치, 메모리와 CPU 수치, hang 동안 메인 스레드의 콜 스택(바이너리와 심볼 이름), MetricKit의 수치와 앱 빌드, 화면보다 오래 살아남는 객체의 타입 이름, 그리고 각 요청의 가려진 URL, 메서드, 상태 코드, 프로토콜, 단계별 소요 시간, 응답 크기. `PerformanceTracer`와 `LeakTracker`에 넘기는 이름은 넘긴 그대로 기록되므로 고정된 이름을 사용하세요.
- **절대 기록되지 않는 것:** 요청과 응답의 헤더(`Authorization`, 쿠키), 요청과 응답의 본문, URL의 사용자 이름, 비밀번호, 프래그먼트, 그리고 쿼리(이름으로 허용한 파라미터는 제외).
- **URL:** 식별자처럼 보이는 경로 세그먼트(숫자, UUID, 이메일 주소, 여섯 자리 이상의 숫자, 카드 번호, IBAN, 토큰)는 `:id`가 되며, `token`이나 `password` 같은 이름 다음에 오는 세그먼트도 마찬가지입니다. 퍼센트 디코딩 뒤에 순수 ASCII가 아닌 세그먼트, 예를 들어 `Şifre`나 다른 문자 체계의 비슷하게 생긴 글자가 섞인 단어는 의도적으로 다음 세그먼트와 함께 가려집니다. 서버마다 다르게 해석할 수 있는 경로(`..`, `;`, 이중 퍼센트 인코딩)는 스킴과 호스트만 기록됩니다.

가리기는 안전망일 뿐 보장이 아닙니다. 경로에 있는 평범한 단어, 예를 들어 초대 코드 `sunflower`가 비밀이라는 것은 알 수 없습니다. 비밀 값은 URL에 넣지 말거나, `URLRedaction(recordsHostOnly: true)`로 호스트만 기록하세요. [네트워크 타이밍 문서](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)에 모든 규칙과 그 한계가 나와 있습니다.

## 예제 앱

[`Examples/PerformanceLab`](Examples/)은 각 문제를 일부러 일으키는 iOS 및 macOS 앱으로, 측정값이 어떻게 반응하는지 직접 볼 수 있습니다. 왼쪽부터 순서대로, 콜 스택이 앱 함수를 가리키는 600 ms 메인 스레드 hang, 느린 행이 있는 목록을 최고 속도로 스크롤한 모습, 클로저가 붙잡아 살려 둔 view model, hang을 잡아내는 예산 검사입니다.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-hangs-dark.png"><img src="docs/images/example-hangs-light.png" width="200" alt="Hangs 화면: 콜 스택이 PerformanceLab.blockMainThread를 가리키는 약 600 ms의 hang"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-frames-dark.png"><img src="docs/images/example-frames-light.png" width="200" alt="Frames 화면: 느린 행을 스크롤하는 동안 프레임 레이트는 60 fps 중 약 40 fps이고 hitch 비율은 심각"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-leaks-dark.png"><img src="docs/images/example-leaks-light.png" width="200" alt="Leaks 화면: PerformanceLab.ProfileModel에 대한 리포트 'Profile (leaks)'"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-budget-dark.png"><img src="docs/images/example-budget-light.png" width="200" alt="Budget 화면: 다섯 개의 한도와 위반 'hang exceeds 250 ms'"></picture>
</p>

스크린샷은 [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh)가 iPhone 시뮬레이터에서 실행 중인 앱을 캡처한 것이므로, 수치는 그린 것이 아니라 실제로 측정한 값입니다.

## 문서

[DocC 문서](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/)는 모든 public 타입을 다루며 다음 문서를 포함합니다.

- [Getting Started](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/gettingstarted)
- [Finding Hangs and Hitches](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/findinghangsandhitches)
- [Reading Field Metrics](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/readingfieldmetrics)
- [Setting Performance Budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)
- [Recording Network Timings](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)

## 요구 사항

| 플랫폼   | 최소 버전 |
| -------- | --------- |
| iOS      | 17.0      |
| macOS    | 14.0      |
| tvOS     | 17.0      |
| watchOS  | 10.0      |
| visionOS | 1.0       |

Swift 6.2 이상(Xcode 26 이상). 패키지는 Swift 6 언어 모드로 빌드됩니다. 프레임 모니터는 display link가 필요하므로 watchOS에서는 사용할 수 없고, MetricKit은 tvOS와 watchOS에서 사용할 수 없습니다. hang의 콜 스택은 arm64와 x86_64에서 읽을 수 있으며, 앱이 자신의 스레드를 일시 중단하는 것을 허용하지 않는 watchOS를 제외한 모든 플랫폼에서 지원됩니다.

## 기여하기

버그 리포트와 pull request를 환영합니다. 빌드, 테스트, 스크린샷 재생성 방법은 [CONTRIBUTING.md](CONTRIBUTING.md)를 참고하세요. 보안 문제를 비공개로 제보하려면 [SECURITY.md](SECURITY.md)를 참고하세요.

## 라이선스

MIT입니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
