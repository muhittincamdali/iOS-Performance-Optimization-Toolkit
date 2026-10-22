<!-- i18n-source: README.md@7713e35c837f2f5de2312d94c19d1af745744d0e status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg" alt="Performance Toolkit: Find hangs, hitches, memory growth, slow launches and leaks in Swift apps, and check them in tests."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

Ein Swift-Paket, das misst, was eine App langsam wirken lässt – auf iOS 17+, macOS 14+, tvOS 17+, watchOS 10+ und visionOS 1+ und ohne Abhängigkeiten. Es meldet Hangs des Main Threads zusammen mit dem Call Stack, der sie verursacht hat, verspätete Frames als Apples Hitch Time Ratio, den Speicher-Footprint, den das System mit dem Limit deiner App vergleicht, die Startzeit ab dem Moment, in dem der Prozess gestartet wurde, und View Models, die ihren Screen überleben. Dieselben Werte kommen über MetricKit von den Geräten deiner Nutzer, und ein Budget macht aus jedem davon einen fehlschlagenden Test.

## Highlights

- **Hangs mit Call Stacks** — `HangDetector` meldet, wenn der Main Thread 250 ms oder länger nicht mehr reagiert, und zeichnet, solange er noch blockiert ist, seinen Call Stack mit demangelten Swift-Namen auf.
- **Hitches so, wie Apple sie zählt** — `FrameTimeline` misst, wie spät jeder Frame dran ist, und gibt die Hitch Time Ratio in ms/s an, bewertet mit den Grenzwerten aus Apples Dokumentation.
- **Der Speicherwert, auf den es ankommt** — `MemorySnapshot` liest den physischen Footprint, den das System durchsetzt, dessen Spitzenwert und auf Geräten den Speicher, der bis zum Limit noch bleibt.
- **Start und Leaks** — `LaunchTimer` misst ab der Erstellung des Prozesses (vor `main`) und erkennt vorgewärmte (prewarmed) Starts; `LeakTracker` meldet Objekte, die nach dem Schließen ihres Screens noch leben.
- **Felddaten und Budgets** — `FieldMetricsReceiver` liest die täglichen MetricKit-Berichte auf iOS 17 bis 27; `PerformanceBudget` prüft jede Messung in einem Test gegen Grenzwerte.
- **Für den Dauerbetrieb gebaut** — jeder Puffer hat ein Limit, Werte aus dem Kernel oder einem Payload werden vor der Verwendung geprüft, und Netzwerk-Timings enthalten weder Header noch Bodies, sondern nur eine unkenntlich gemachte URL. 124 Swift-Testing-Tests laufen auf macOS, 123 davon auch in einem iPhone-Simulator, gegen echte Hangs, Speicherallokationen und HTTP-Anfragen.

### Was enthalten ist

| Bereich          | API                                                                     |
| ---------------- | ----------------------------------------------------------------------- |
| Live-Overlay     | `PerformanceMonitor`, `PerformanceHUD`, `PerformanceSnapshot`           |
| Hangs            | `HangDetector`, `HangEvent`, `HangSeverity`, `StackFrame`               |
| Frames           | `FrameRateMonitor`, `FrameTimeline`, `FrameStatistics`, `HitchRating`   |
| Speicher und CPU | `MemorySnapshot`, `CPUSnapshot`, `ProcessCPUTime`                       |
| Start            | `LaunchTimer`, `LaunchMeasurement`, `ProcessLaunch`, `measuresLaunch()` |
| Leaks            | `LeakTracker`, `LeakReport`                                             |
| Operationen      | `PerformanceTracer` (Signposts für Instruments), `SampleStatistics`     |
| Netzwerk         | `NetworkMetricsCollector`, `NetworkTiming`, `URLRedaction`              |
| Felddaten        | `FieldMetricsReceiver`, `FieldMetrics`, `FieldHistogram`                |
| Budgets          | `PerformanceBudget`, `PerformanceMeasurements`, `BudgetViolation`       |

## Schnellstart

**1. Paket hinzufügen**

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

Füge sie in das Suchfeld oben rechts im Fenster ein. Lass **Dependency Rule** auf **Up to Next Major Version** ab `2.0.0` stehen und klicke auf **Add Package**. Wähle im nächsten Fenster neben **PerformanceOptimizationKit** dein App-Target aus und klicke erneut auf **Add Package**.

**2. Modul importieren**

```swift
import PerformanceOptimizationKit
```

**3. Overlay anzeigen**

Umhülle deine erste View mit einer View, die einen `PerformanceMonitor` startet und dessen `PerformanceHUD` anzeigt:

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

Zeige in deiner `App` `RootView()` statt `ContentView()` an und starte die App: Das Overlay oben rechts zeigt Framerate, Hitch Ratio, CPU, Speicher und den letzten Hang und aktualisiert sich jede Sekunde. Der Frame-Monitor hält das Display auf seiner vollen Bildwiederholrate; zeige das Overlay deshalb nur in Debug-Builds an (`#if DEBUG`).

## Installation

### Swift Package Manager

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

Oder füge es zu den `dependencies` in deiner `Package.swift` hinzu:

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

Verwende Version 2.0.0 oder neuer: Die Version 1.0.0 ließ sich nicht bauen, und 2.0.0 ersetzt ihre API.

## Verwendung

### Herausfinden, was den Main Thread blockiert

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

Die innersten Frames zeigen, was der Main Thread gerade ausführte, als der Hang 250 ms erreichte. In einem Release-Build ohne Symbole enthalten die Frames Adressen und Binärnamen; symbolisiere sie mit der dSYM.

### Den Start messen

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

Die Zeit beginnt, wenn der Kernel den Prozess erstellt hat, und umfasst deshalb den Dynamic Linker und statische Initialisierer vor `main`. Ein vorgewärmter Prozess hat suspendiert gewartet, bevor die Person die App geöffnet hat; `wasPrewarmed` sagt dir, dass du diesen Start weglassen solltest.

### Ein Budget prüfen

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

Jede Verletzung liest sich etwa so: `hang of 900 ms exceeds 250 ms`. Übergib in einem Unit-Test die Statistiken von `PerformanceTracer` und prüfe `#expect(violations.isEmpty)`; der [Artikel zu Budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets) zeigt, wie.

### Felddaten aus MetricKit lesen

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

MetricKit liefert etwa einmal täglich einen Bericht von Geräten, deren Besitzer Analysedaten mit Entwicklern teilen. `FieldMetrics` ist `Codable` und hat keine Abhängigkeit zu MetricKit, du kannst es also hochladen und auf einem Server dekodieren. Unter iOS 27 und macOS 27 nutzt der Receiver den neuen `MetricManager`, auf früheren Systemen `MXMetricManager`.

### Netzwerkanfragen zeitlich messen

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

Jedes `NetworkTiming` teilt die Anfrage in DNS-Auflösung, Verbindungsaufbau, TLS, Senden, Warten auf das erste Byte und Empfangen auf. Seine URL wird unkenntlich gemacht, bevor sie gespeichert wird: Aus `https://api.example.com/v1/users/48213/orders?page=2&token=abc` wird `https://api.example.com/v1/users/:id/orders?page=2`.

## Was aufgezeichnet wird

Das Paket ist für interne Builds und Beta-Builds gedacht, die echte Menschen benutzen, deshalb dürfen seine Berichte keine Daten dieser Menschen enthalten.

- **Aufgezeichnet werden:** Dauern, Frame- und Hitch-Werte, Speicher- und CPU-Werte, Call Stacks des Main Threads während eines Hangs (Binary- und Symbolnamen), die Werte von MetricKit und der App-Build, die Typnamen von Objekten, die ihren Screen überleben, und zu jeder Anfrage die unkenntlich gemachte URL, die Methode, der Statuscode, das Protokoll, die Dauer der einzelnen Phasen und die Größe der Antwort. Namen, die du an `PerformanceTracer` und `LeakTracker` übergibst, werden so aufgezeichnet, wie du sie angibst, verwende also feste Namen.
- **Nie aufgezeichnet werden:** Header von Anfragen und Antworten (`Authorization`, Cookies), Bodies von Anfragen und Antworten, Benutzername und Passwort sowie das Fragment einer URL und ihre Query, mit Ausnahme der Parameter, die du namentlich erlaubst.
- **URLs:** Pfadsegmente, die wie Kennungen aussehen (Zahlen, UUIDs, E-Mail-Adressen, mindestens sechs Ziffern, Kartennummern, IBANs, Tokens), werden zu `:id`, ebenso das Segment nach einem Namen wie `token` oder `password`. Ein Segment, das nach dem Prozent-Dekodieren nicht reines ASCII ist, etwa `Şifre` oder ein Wort mit einem ähnlich aussehenden Buchstaben aus einer anderen Schrift, wird absichtlich zusammen mit dem nächsten verborgen. Ein Pfad, den Server unterschiedlich lesen könnten (`..`, `;`, doppelte Prozent-Kodierung), wird nur als Schema und Host aufgezeichnet.

Das Unkenntlichmachen ist ein Sicherheitsnetz, keine Garantie. Es kann nicht erkennen, dass ein gewöhnliches Wort in einem Pfad, etwa der Einladungscode `sunflower`, geheim ist. Halte Geheimnisse aus URLs heraus oder zeichne nur den Host mit `URLRedaction(recordsHostOnly: true)` auf. Der [Artikel zu den Netzwerk-Timings](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings) listet jede Regel und ihre Grenzen auf.

## Beispiel-App

[`Examples/PerformanceLab`](Examples/) ist eine iOS- und macOS-App, die jedes Problem absichtlich auslöst, damit du die Messung reagieren siehst. Von links nach rechts: ein 600 ms langer Hang des Main Threads mit der App-Funktion, auf die sein Call Stack zeigt, eine Liste mit langsamen Zeilen, die mit voller Geschwindigkeit gescrollt wird, ein View Model, das von einem Closure am Leben gehalten wird, und eine Budgetprüfung, die einen Hang erkennt.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-hangs-dark.png"><img src="docs/images/example-hangs-light.png" width="200" alt="Hangs-Screen: ein Hang von etwa 600 ms, dessen Call Stack auf PerformanceLab.blockMainThread zeigt"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-frames-dark.png"><img src="docs/images/example-frames-light.png" width="200" alt="Frames-Screen: Framerate von etwa 40 von 60 fps und eine schwere Hitch Ratio, während langsame Zeilen gescrollt werden"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-leaks-dark.png"><img src="docs/images/example-leaks-light.png" width="200" alt="Leaks-Screen: der Bericht „Profile (leaks)“ für PerformanceLab.ProfileModel"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-budget-dark.png"><img src="docs/images/example-budget-light.png" width="200" alt="Budget-Screen: fünf Grenzwerte und die Verletzung „hang exceeds 250 ms“"></picture>
</p>

Die Screenshots werden von [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) aus der laufenden App in einem iPhone-Simulator aufgenommen, die Werte sind also gemessen und nicht gezeichnet.

## Dokumentation

Die [DocC-Dokumentation](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/) deckt jeden öffentlichen Typ ab, mit diesen Artikeln:

- [Getting Started](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/gettingstarted)
- [Finding Hangs and Hitches](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/findinghangsandhitches)
- [Reading Field Metrics](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/readingfieldmetrics)
- [Setting Performance Budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)
- [Recording Network Timings](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)

## Voraussetzungen

| Plattform | Mindestversion |
| --------- | -------------- |
| iOS       | 17.0           |
| macOS     | 14.0           |
| tvOS      | 17.0           |
| watchOS   | 10.0           |
| visionOS  | 1.0            |

Swift 6.2 oder neuer (Xcode 26 oder neuer). Das Paket wird im Swift-6-Sprachmodus gebaut. Der Frame-Monitor benötigt einen Display Link und ist deshalb unter watchOS nicht verfügbar; MetricKit ist unter tvOS und watchOS nicht verfügbar. Call Stacks von Hangs werden auf arm64 und x86_64 gelesen, auf allen Plattformen außer watchOS, das einer App nicht erlaubt, ihre eigenen Threads anzuhalten.

## Mitwirken

Fehlerberichte und Pull Requests sind willkommen; [CONTRIBUTING.md](CONTRIBUTING.md) erklärt, wie du baust, testest und die Screenshots neu erzeugst. Wenn du ein Sicherheitsproblem vertraulich melden möchtest, findest du alles in [SECURITY.md](SECURITY.md).

## Lizenz

MIT. Siehe [LICENSE](LICENSE).
