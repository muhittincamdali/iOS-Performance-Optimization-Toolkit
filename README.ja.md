<!-- i18n-source: README.md@7713e35c837f2f5de2312d94c19d1af745744d0e status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg" alt="Performance Toolkit: Find hangs, hitches, memory growth, slow launches and leaks in Swift apps, and check them in tests."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg" alt="最新バージョン: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

アプリが遅く感じられる原因を計測する Swift パッケージです。iOS 17+、macOS 14+、tvOS 17+、watchOS 10+、visionOS 1+ に対応し、依存ライブラリはありません。メインスレッドのハング（hang）とその原因となったコールスタック、Apple の hitch time ratio で表したフレームの遅れ、アプリの上限と比較されるメモリフットプリント、プロセス開始の時点から測った起動時間、画面が閉じられたあとも残り続ける view model を報告します。同じ数値はユーザーの端末からも MetricKit 経由で取得でき、バジェット（budget）を使えばそのいずれもテストの失敗条件にできます。

## 主な特長

- **コールスタック付きのハング検出** — メインスレッドが 250 ms 以上応答しなくなると `HangDetector` が通知し、ブロックされている間にそのコールスタックを、デマングル済みの Swift 名で記録します。
- **Apple と同じ数え方の hitch** — `FrameTimeline` は各フレームがどれだけ遅れたかを計測し、hitch time ratio を ms/s で報告します。評価には Apple のドキュメントにある基準値を使います。
- **本当に重要なメモリの値** — `MemorySnapshot` は、システムが制限の根拠とする物理フットプリントとそのピーク値を読み取り、実機では上限までの残りメモリも取得します。
- **起動とリーク** — `LaunchTimer` はプロセス作成時（`main` より前）から計測し、プリウォーム（prewarmed）された起動を見分けます。`LeakTracker` は画面が閉じられたあともまだ生きているオブジェクトを報告します。
- **実環境のデータとバジェット** — `FieldMetricsReceiver` は iOS 17 から 27 までの MetricKit の日次レポートを読み取ります。`PerformanceBudget` はテストの中で、あらゆる計測値を上限と照合します。
- **一日中動かし続けられる設計** — すべてのバッファには上限があり、カーネルやペイロードから得た値は使う前に検証され、ネットワークのタイミングにはヘッダーもボディも含まれず、マスクされた URL だけが残ります。115 件の Swift Testing テストが macOS で動作し、そのうち 114 件は iPhone シミュレータでも動作します。テストは実際のハング、メモリ割り当て、HTTP リクエストを対象にしています。

### 含まれるもの

| 領域               | API                                                                     |
| ------------------ | ----------------------------------------------------------------------- |
| ライブオーバーレイ | `PerformanceMonitor`, `PerformanceHUD`, `PerformanceSnapshot`           |
| ハング             | `HangDetector`, `HangEvent`, `HangSeverity`, `StackFrame`               |
| フレーム           | `FrameRateMonitor`, `FrameTimeline`, `FrameStatistics`, `HitchRating`   |
| メモリと CPU       | `MemorySnapshot`, `CPUSnapshot`, `ProcessCPUTime`                       |
| 起動               | `LaunchTimer`, `LaunchMeasurement`, `ProcessLaunch`, `measuresLaunch()` |
| リーク             | `LeakTracker`, `LeakReport`                                             |
| 処理               | `PerformanceTracer`（Instruments 用の signpost）, `SampleStatistics`    |
| ネットワーク       | `NetworkMetricsCollector`, `NetworkTiming`, `URLRedaction`              |
| 実環境のデータ     | `FieldMetricsReceiver`, `FieldMetrics`, `FieldHistogram`                |
| バジェット         | `PerformanceBudget`, `PerformanceMeasurements`, `BudgetViolation`       |

## クイックスタート

**1. パッケージを追加する**

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

ウィンドウ右上の検索欄に貼り付けます。**Dependency Rule** は `2.0.0` からの **Up to Next Major Version** のままにして、**Add Package** をクリックします。次のウィンドウで **PerformanceOptimizationKit** の横にあるアプリのターゲットを選び、もう一度 **Add Package** をクリックします。

**2. モジュールをインポートする**

```swift
import PerformanceOptimizationKit
```

**3. オーバーレイを表示する**

最初のビューを、`PerformanceMonitor` を開始してその `PerformanceHUD` を表示するビューで包みます。

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

`App` で `ContentView()` の代わりに `RootView()` を表示してアプリを実行すると、右上のオーバーレイにフレームレート、hitch ratio、CPU、メモリ、直近のハングが表示され、1 秒ごとに更新されます。フレームモニターはディスプレイを最大のリフレッシュレートに保つため、オーバーレイはデバッグビルドでのみ表示してください（`#if DEBUG`）。

## インストール

### Swift Package Manager

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

または `Package.swift` の `dependencies` に追加します。

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

2.0.0 以降を使用してください。1.0.0 のリリースはビルドできず、2.0.0 でその API が置き換えられています。

## 使い方

### メインスレッドを何がブロックしているかを調べる

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

最も内側のフレームは、ハングが 250 ms に達した時点でメインスレッドが何を実行していたかを示します。シンボルのない release ビルドでは、フレームにはアドレスとバイナリ名が入ります。dSYM を使ってシンボル化してください。

### 起動を計測する

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

時間はカーネルがプロセスを作成した時点から始まるため、`main` より前の dynamic linker と static initializer の時間も含まれます。プリウォームされたプロセスは、ユーザーがアプリを開く前にサスペンド状態で待機していたものです。`wasPrewarmed` は、その起動を集計から除外すべきことを示します。

### バジェットを確認する

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

各違反は `hang of 900 ms exceeds 250 ms` のような形式で表示されます。ユニットテストでは `PerformanceTracer` の統計を渡し、`#expect(violations.isEmpty)` で検証します。方法は[バジェットの記事](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)で説明しています。

### MetricKit から実環境のデータを読み取る

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

MetricKit は、所有者が開発者との分析データの共有を許可している端末から、およそ 1 日に 1 回レポートを配信します。`FieldMetrics` は `Codable` で、MetricKit への依存はないため、アップロードしてサーバー側でデコードできます。iOS 27 と macOS 27 では新しい `MetricManager` を、それ以前のシステムでは `MXMetricManager` を使用します。

### ネットワークリクエストの所要時間を計測する

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

`NetworkTiming` は、リクエストを DNS 解決、接続、TLS、送信、最初のバイトまでの待機、受信に分けて記録します。URL は保存する前にマスクされます。`https://api.example.com/v1/users/48213/orders?page=2&token=abc` は次のように記録されます: `https://api.example.com/v1/users/:id/orders?page=2`.

## 記録される内容

このパッケージは、実際のユーザーが使う社内向けビルドやベータ版ビルドでの利用を想定しています。そのため、レポートにユーザーのデータが含まれてはなりません。

- **記録されるもの:** 所要時間、フレームと hitch の値、メモリと CPU の値、ハング中のメインスレッドのコールスタック（バイナリ名とシンボル名）、MetricKit の値とアプリのビルド、画面が閉じられたあとも残っているオブジェクトの型名、そして各リクエストについてマスクされた URL、メソッド、ステータスコード、プロトコル、フェーズごとの所要時間、レスポンスのサイズ。`PerformanceTracer` と `LeakTracker` に渡した名前は渡したとおりに記録されるため、固定の名前を使ってください。
- **記録されないもの:** リクエストとレスポンスのヘッダー（`Authorization`、cookie）、リクエストとレスポンスのボディ、URL のユーザー名・パスワード・フラグメント、およびクエリ（名前で許可したパラメータを除く）。
- **URL:** 識別子のように見えるパスセグメント（数字、UUID、メールアドレス、6 桁以上の数字、カード番号、IBAN、トークン）は `:id` になります。`token` や `password` のような名前の次のセグメントも同様です。パーセントデコードしたあとに ASCII だけではないセグメント、たとえば `Şifre` や、別の文字体系の似た文字を含む単語は、意図的に次のセグメントとともに隠されます。サーバーによって解釈が分かれうるパス（`..`、`;`、二重のパーセントエンコード）は、スキームとホストだけが記録されます。

マスク処理は安全網であり、保証ではありません。パスの中にある普通の単語、たとえば招待コードの `sunflower` が秘密であることは判別できません。秘密情報は URL に含めないか、`URLRedaction(recordsHostOnly: true)` でホストだけを記録してください。すべてのルールとその限界は、[ネットワークのタイミングに関する記事](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)にまとめています。

## サンプルアプリ

[`Examples/PerformanceLab`](Examples/) は、各問題をあえて発生させる iOS / macOS アプリで、計測値がどう反応するかを確認できます。左から順に、コールスタックがアプリの関数を指す 600 ms のメインスレッドのハング、処理の遅い行を含むリストをフルスピードでスクロールした状態、closure によって生かされ続ける view model、そしてハングを検出するバジェットのチェックです。

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-hangs-dark.png"><img src="docs/images/example-hangs-light.png" width="200" alt="Hangs 画面：コールスタックが PerformanceLab.blockMainThread を指す約 600 ms のハング"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-frames-dark.png"><img src="docs/images/example-frames-light.png" width="200" alt="Frames 画面：処理の遅い行をスクロール中のフレームレートは 60 fps のところ約 40 fps で、hitch ratio は深刻"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-leaks-dark.png"><img src="docs/images/example-leaks-light.png" width="200" alt="Leaks 画面：PerformanceLab.ProfileModel に対するレポート「Profile (leaks)」"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-budget-dark.png"><img src="docs/images/example-budget-light.png" width="200" alt="Budget 画面：5 つの上限と違反「hang exceeds 250 ms」"></picture>
</p>

スクリーンショットは [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) が、iPhone シミュレータ上で実行中のアプリから取得したものです。数値は描いたものではなく、実測値です。

## ドキュメント

[DocC ドキュメント](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/)はすべての公開型を網羅しており、次の記事があります。

- [Getting Started](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/gettingstarted)
- [Finding Hangs and Hitches](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/findinghangsandhitches)
- [Reading Field Metrics](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/readingfieldmetrics)
- [Setting Performance Budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)
- [Recording Network Timings](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)

## 動作要件

| プラットフォーム | 最小バージョン |
| ---------------- | -------------- |
| iOS              | 17.0           |
| macOS            | 14.0           |
| tvOS             | 17.0           |
| watchOS          | 10.0           |
| visionOS         | 1.0            |

Swift 6.2 以降（Xcode 26 以降）。パッケージは Swift 6 言語モードでビルドされます。フレームモニターには display link が必要なため watchOS では利用できません。MetricKit は tvOS と watchOS では利用できません。ハングのコールスタックは arm64 と x86_64 で、watchOS を除くすべてのプラットフォームで取得できます。watchOS では、アプリが自身のスレッドをサスペンドすることが許可されていないためです。

## コントリビューション

バグ報告や pull request を歓迎します。ビルド、テスト、スクリーンショットの再生成の方法は [CONTRIBUTING.md](CONTRIBUTING.md) をご覧ください。セキュリティ上の問題を非公開で報告する場合は、[SECURITY.md](SECURITY.md) を参照してください。

## ライセンス

MIT ライセンスです。詳細は [LICENSE](LICENSE) を参照してください。
