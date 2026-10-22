<!-- i18n-source: README.md@7713e35c837f2f5de2312d94c19d1af745744d0e status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg" alt="Performance Toolkit: Find hangs, hitches, memory growth, slow launches and leaks in Swift apps, and check them in tests."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg" alt="Последняя версия: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

Пакет Swift, который измеряет, из-за чего приложение кажется медленным, на iOS 17+, macOS 14+, tvOS 17+, watchOS 10+ и visionOS 1+, без зависимостей. Он сообщает о зависаниях (hangs) главного потока вместе со стеком вызовов, который их вызвал, о запоздавших кадрах в виде hitch time ratio по Apple, об объёме занятой памяти (memory footprint), который система сравнивает с лимитом вашего приложения, о времени запуска с момента старта процесса и о view model, которые живут дольше своего экрана. Те же показатели приходят с устройств пользователей через MetricKit, а бюджет (budget) превращает любой из них в падающий тест.

## Основные возможности

- **Зависания со стеками вызовов** — `HangDetector` сообщает, когда главный поток перестаёт отвечать на 250 мс и дольше, и, пока он ещё заблокирован, записывает его стек вызовов с деманглированными именами Swift.
- **Hitch в том виде, как их считает Apple** — `FrameTimeline` измеряет, насколько опаздывает каждый кадр, и выдаёт hitch time ratio в мс/с, оценивая его по пороговым значениям из документации Apple.
- **Показатель памяти, который действительно важен** — `MemorySnapshot` считывает физический объём занятой памяти, на который опирается система, его пик и, на устройствах, объём памяти, оставшийся до лимита.
- **Запуск и утечки** — `LaunchTimer` измеряет время от создания процесса (до `main`) и распознаёт прогретые (prewarmed) запуски; `LeakTracker` сообщает об объектах, которые остались живы после закрытия их экрана.
- **Данные из реальной эксплуатации и бюджеты** — `FieldMetricsReceiver` читает ежедневные отчёты MetricKit на iOS с 17 по 27; `PerformanceBudget` сверяет любое измерение с лимитами в тесте.
- **Рассчитан на работу в течение всего дня** — у каждого буфера есть предел, значения из ядра или payload проверяются перед использованием, а сетевые тайминги не содержат ни заголовков, ни тел запросов и ответов, только замаскированный URL. 122 тестов Swift Testing выполняются на macOS, 121 из них — ещё и на симуляторе iPhone, на реальных зависаниях, выделениях памяти и HTTP-запросах.

### Что входит

| Область                    | API                                                                     |
| -------------------------- | ----------------------------------------------------------------------- |
| Оверлей в реальном времени | `PerformanceMonitor`, `PerformanceHUD`, `PerformanceSnapshot`           |
| Зависания                  | `HangDetector`, `HangEvent`, `HangSeverity`, `StackFrame`               |
| Кадры                      | `FrameRateMonitor`, `FrameTimeline`, `FrameStatistics`, `HitchRating`   |
| Память и CPU               | `MemorySnapshot`, `CPUSnapshot`, `ProcessCPUTime`                       |
| Запуск                     | `LaunchTimer`, `LaunchMeasurement`, `ProcessLaunch`, `measuresLaunch()` |
| Утечки                     | `LeakTracker`, `LeakReport`                                             |
| Операции                   | `PerformanceTracer` (signpost для Instruments), `SampleStatistics`      |
| Сеть                       | `NetworkMetricsCollector`, `NetworkTiming`, `URLRedaction`              |
| Данные из эксплуатации     | `FieldMetricsReceiver`, `FieldMetrics`, `FieldHistogram`                |
| Бюджеты                    | `PerformanceBudget`, `PerformanceMeasurements`, `BudgetViolation`       |

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

Вставьте его в поле поиска в правом верхнем углу окна. Оставьте **Dependency Rule** равным **Up to Next Major Version** от `2.0.0` и нажмите **Add Package**. В следующем окне выберите таргет вашего приложения рядом с **PerformanceOptimizationKit** и снова нажмите **Add Package**.

**2. Импортируйте модуль**

```swift
import PerformanceOptimizationKit
```

**3. Покажите оверлей**

Оберните ваше первое представление (view) в представление, которое запускает `PerformanceMonitor` и показывает его `PerformanceHUD`:

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

Покажите `RootView()` вместо `ContentView()` в вашем `App` и запустите приложение: оверлей в правом верхнем углу показывает частоту кадров, hitch ratio, CPU, память и последнее зависание и обновляется каждую секунду. Монитор кадров удерживает дисплей на максимальной частоте обновления, поэтому показывайте оверлей только в debug-сборках (`#if DEBUG`).

## Установка

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

Или добавьте его в `dependencies` вашего `Package.swift`:

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

Используйте версию 2.0.0 или новее: релиз 1.0.0 не собирался, а 2.0.0 заменяет его API.

## Использование

### Выясните, что блокирует главный поток

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

Самые внутренние кадры стека показывают, что выполнял главный поток, когда зависание достигло 250 мс. В release-сборке без символов кадры содержат адреса и имена бинарных файлов; символизируйте их с помощью dSYM.

### Измерьте запуск

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

Отсчёт начинается с момента, когда ядро создало процесс, поэтому в него входят dynamic linker и статические инициализаторы до `main`. Прогретый процесс ждал в приостановленном состоянии, пока человек не открыл приложение; `wasPrewarmed` подсказывает, что такой запуск нужно исключить.

### Проверьте бюджет

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

Каждое нарушение выглядит как `hang of 900 ms exceeds 250 ms`. В модульном тесте передайте статистику `PerformanceTracer` и проверьте `#expect(violations.isEmpty)`; как это сделать, показано в [статье о бюджетах](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets).

### Читайте данные из эксплуатации через MetricKit

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

MetricKit доставляет отчёт примерно раз в сутки с устройств, владельцы которых делятся аналитикой с разработчиками. `FieldMetrics` соответствует `Codable` и не зависит от MetricKit, поэтому его можно отправить на сервер и декодировать там. На iOS 27 и macOS 27 получатель использует новый `MetricManager`, на более ранних системах — `MXMetricManager`.

### Измерьте время сетевых запросов

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

Каждый `NetworkTiming` делит запрос на DNS-запрос, соединение, TLS, отправку, ожидание первого байта и получение. URL маскируется до сохранения: `https://api.example.com/v1/users/48213/orders?page=2&token=abc` записывается как `https://api.example.com/v1/users/:id/orders?page=2`.

## Что записывается

Пакет предназначен для внутренних и бета-сборок, которыми пользуются реальные люди, поэтому его отчёты не должны содержать их данных.

- **Записывается:** длительности, показатели кадров и hitch, показатели памяти и CPU, стеки вызовов главного потока во время зависания (имена бинарных файлов и символов), показатели MetricKit и сборка приложения, имена типов объектов, переживших свой экран, а для каждого запроса — замаскированный URL, метод, код статуса, протокол, длительность каждой фазы и размер ответа. Имена, которые вы передаёте в `PerformanceTracer` и `LeakTracker`, записываются как есть, поэтому используйте фиксированные имена.
- **Никогда не записывается:** заголовки запросов и ответов (`Authorization`, cookie), тела запросов и ответов, имя пользователя и пароль, фрагмент URL и его query, за исключением параметров, которые вы разрешили по имени.
- **URL:** сегменты пути, похожие на идентификаторы (числа, UUID, адреса электронной почты, шесть и более цифр, номера карт, IBAN, токены), заменяются на `:id`, как и сегмент после имени вроде `token` или `password`. Сегмент, который после раскодирования процентных последовательностей не является чистым ASCII, например `Şifre` или слово с похожей буквой из другого алфавита, намеренно скрывается вместе со следующим. Путь, который серверы могут прочитать по-разному (`..`, `;`, двойное процентное кодирование), записывается только как схема и хост.

Маскирование — это страховочная сетка, а не гарантия. Оно не может понять, что обычное слово в пути, например код приглашения `sunflower`, секретно. Не помещайте секреты в URL или записывайте только хост с помощью `URLRedaction(recordsHostOnly: true)`. [Статья о сетевых таймингах](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings) перечисляет все правила и их ограничения.

## Пример приложения

[`Examples/PerformanceLab`](Examples/) — приложение для iOS и macOS, которое намеренно вызывает каждую из проблем, чтобы вы видели, как реагирует измерение. Слева направо: зависание главного потока на 600 мс с функцией приложения, на которую указывает его стек вызовов; список с медленными строками, прокручиваемый на полной скорости; view model, удерживаемая в памяти замыканием (closure); и проверка бюджета, которая ловит зависание.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-hangs-dark.png"><img src="docs/images/example-hangs-light.png" width="200" alt="Экран Hangs: зависание примерно на 600 мс, стек вызовов которого указывает на PerformanceLab.blockMainThread"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-frames-dark.png"><img src="docs/images/example-frames-light.png" width="200" alt="Экран Frames: частота кадров около 40 из 60 fps и серьёзный hitch ratio при прокрутке медленных строк"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-leaks-dark.png"><img src="docs/images/example-leaks-light.png" width="200" alt="Экран Leaks: отчёт «Profile (leaks)» для PerformanceLab.ProfileModel"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-budget-dark.png"><img src="docs/images/example-budget-light.png" width="200" alt="Экран Budget: пять лимитов и нарушение «hang exceeds 250 ms»"></picture>
</p>

Скриншоты снимаются с работающего приложения на симуляторе iPhone скриптом [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh), поэтому цифры измерены, а не нарисованы.

## Документация

[Документация DocC](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/) охватывает каждый публичный тип и включает следующие статьи:

- [Getting Started](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/gettingstarted)
- [Finding Hangs and Hitches](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/findinghangsandhitches)
- [Reading Field Metrics](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/readingfieldmetrics)
- [Setting Performance Budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)
- [Recording Network Timings](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)

## Требования

| Платформа | Минимальная версия |
| --------- | ------------------ |
| iOS       | 17.0               |
| macOS     | 14.0               |
| tvOS      | 17.0               |
| watchOS   | 10.0               |
| visionOS  | 1.0                |

Swift 6.2 или новее (Xcode 26 или новее). Пакет собирается в языковом режиме Swift 6. Монитору кадров нужен display link, поэтому он недоступен на watchOS; MetricKit недоступен на tvOS и watchOS. Стеки вызовов при зависаниях считываются на arm64 и x86_64 на всех платформах, кроме watchOS, где приложению нельзя приостанавливать собственные потоки.

## Участие в разработке

Сообщения об ошибках и pull request приветствуются; в [CONTRIBUTING.md](CONTRIBUTING.md) описано, как собрать проект, запустить тесты и заново создать скриншоты. Чтобы сообщить о проблеме безопасности конфиденциально, см. [SECURITY.md](SECURITY.md).

## Лицензия

MIT. См. [LICENSE](LICENSE).
