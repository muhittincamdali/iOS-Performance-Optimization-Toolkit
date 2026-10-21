<!-- i18n-source: README.md@7713e35c837f2f5de2312d94c19d1af745744d0e status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg" alt="Performance Toolkit: Find hangs, hitches, memory growth, slow launches and leaks in Swift apps, and check them in tests."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg" alt="Última versión: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

Un paquete de Swift que mide lo que hace que una app se sienta lenta, en iOS 17+, macOS 14+, tvOS 17+, watchOS 10+ y visionOS 1+, sin dependencias. Informa de los bloqueos (hangs) del hilo principal junto con la pila de llamadas que los causó, de los fotogramas tardíos como el hitch time ratio de Apple, de la huella de memoria (memory footprint) que el sistema compara con el límite de tu app, del tiempo de arranque desde el momento en que empezó el proceso y de los view models que sobreviven a su pantalla. Las mismas cifras llegan desde los dispositivos de los usuarios a través de MetricKit, y un presupuesto (budget) convierte cualquiera de ellas en una prueba que falla.

## Lo más destacado

- **Bloqueos con pila de llamadas** — `HangDetector` avisa cuando el hilo principal deja de responder durante 250 ms o más y, mientras sigue bloqueado, registra su pila de llamadas con nombres de Swift ya demangled.
- **Hitches tal como los cuenta Apple** — `FrameTimeline` mide cuánto se retrasa cada fotograma e informa del hitch time ratio en ms/s, clasificado con los límites de la documentación de Apple.
- **La cifra de memoria que importa** — `MemorySnapshot` lee la huella física que aplica el sistema, su pico y, en dispositivos, la memoria que queda antes del límite.
- **Arranque y fugas** — `LaunchTimer` mide desde la creación del proceso (antes de `main`) y reconoce los arranques con precalentamiento (prewarmed); `LeakTracker` informa de los objetos que siguen vivos después de cerrar su pantalla.
- **Datos de campo y presupuestos** — `FieldMetricsReceiver` lee los informes diarios de MetricKit en iOS 17 a 27; `PerformanceBudget` comprueba cualquier medición frente a unos límites en una prueba.
- **Pensado para funcionar todo el día** — cada búfer tiene un límite, los valores que llegan del kernel o de un payload se comprueban antes de usarlos, y los tiempos de red no incluyen encabezados ni cuerpos, solo una URL con los datos ocultos. 115 pruebas de Swift Testing se ejecutan en macOS, 114 de ellas también en un simulador de iPhone, contra bloqueos, asignaciones de memoria y peticiones HTTP reales.

### Qué incluye

| Área                  | API                                                                     |
| --------------------- | ----------------------------------------------------------------------- |
| Superposición en vivo | `PerformanceMonitor`, `PerformanceHUD`, `PerformanceSnapshot`           |
| Bloqueos              | `HangDetector`, `HangEvent`, `HangSeverity`, `StackFrame`               |
| Fotogramas            | `FrameRateMonitor`, `FrameTimeline`, `FrameStatistics`, `HitchRating`   |
| Memoria y CPU         | `MemorySnapshot`, `CPUSnapshot`, `ProcessCPUTime`                       |
| Arranque              | `LaunchTimer`, `LaunchMeasurement`, `ProcessLaunch`, `measuresLaunch()` |
| Fugas                 | `LeakTracker`, `LeakReport`                                             |
| Operaciones           | `PerformanceTracer` (signposts para Instruments), `SampleStatistics`    |
| Red                   | `NetworkMetricsCollector`, `NetworkTiming`, `URLRedaction`              |
| Datos de campo        | `FieldMetricsReceiver`, `FieldMetrics`, `FieldHistogram`                |
| Presupuestos          | `PerformanceBudget`, `PerformanceMeasurements`, `BudgetViolation`       |

## Inicio rápido

**1. Añade el paquete**

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

Pégala en el campo de búsqueda de la esquina superior derecha de la ventana. Deja **Dependency Rule** en **Up to Next Major Version** desde `2.0.0` y haz clic en **Add Package**. En la ventana siguiente, elige el target de tu app junto a **PerformanceOptimizationKit** y haz clic de nuevo en **Add Package**.

**2. Importa el módulo**

```swift
import PerformanceOptimizationKit
```

**3. Muestra la superposición**

Envuelve tu primera vista en una vista que inicie un `PerformanceMonitor` y muestre su `PerformanceHUD`:

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

Muestra `RootView()` en lugar de `ContentView()` en tu `App` y ejecuta la app: la superposición de la esquina superior derecha muestra la tasa de fotogramas, el hitch ratio, la CPU, la memoria y el último bloqueo, y se actualiza cada segundo. El monitor de fotogramas mantiene la pantalla a su frecuencia de refresco máxima, así que muestra la superposición solo en compilaciones de depuración (`#if DEBUG`).

## Instalación

### Swift Package Manager

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

O añádelo a las `dependencies` de tu `Package.swift`:

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

Usa la versión 2.0.0 o posterior: la versión 1.0.0 no compilaba y la 2.0.0 sustituye su API.

## Uso

### Averigua qué bloquea el hilo principal

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

Los fotogramas más internos muestran qué estaba ejecutando el hilo principal cuando el bloqueo alcanzó los 250 ms. En una compilación de release sin símbolos, los fotogramas llevan direcciones y nombres de binarios; simbolízalos con el dSYM.

### Mide el arranque

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

El tiempo empieza cuando el kernel creó el proceso, así que incluye el dynamic linker y los inicializadores estáticos anteriores a `main`. Un proceso con precalentamiento esperó suspendido antes de que la persona abriera la app; `wasPrewarmed` te indica que debes dejar ese arranque fuera.

### Comprueba un presupuesto

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

Cada infracción se lee como `hang of 900 ms exceeds 250 ms`. En una prueba unitaria, pasa las estadísticas de `PerformanceTracer` y comprueba `#expect(violations.isEmpty)`; el [artículo sobre presupuestos](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets) explica cómo.

### Lee datos de campo de MetricKit

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

MetricKit entrega un informe aproximadamente una vez al día desde los dispositivos cuyos propietarios comparten análisis con los desarrolladores. `FieldMetrics` es `Codable` y no depende de MetricKit, así que puedes subirlo y decodificarlo en un servidor. En iOS 27 y macOS 27 el receptor usa el nuevo `MetricManager`; en sistemas anteriores, `MXMetricManager`.

### Mide el tiempo de las peticiones de red

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

Cada `NetworkTiming` divide la petición en resolución de DNS, conexión, TLS, envío, espera del primer byte y recepción. Su URL se oculta antes de guardarse: `https://api.example.com/v1/users/48213/orders?page=2&token=abc` se registra como `https://api.example.com/v1/users/:id/orders?page=2`.

## Qué se registra

El paquete está pensado para compilaciones internas y beta que usan personas reales, así que sus informes no deben llevar los datos de esas personas.

- **Se registra:** duraciones, cifras de fotogramas y hitches, cifras de memoria y CPU, pilas de llamadas del hilo principal durante un bloqueo (nombres de binarios y de símbolos), las cifras de MetricKit y la compilación de la app, los nombres de tipo de los objetos que sobreviven a su pantalla y, de cada petición, su URL ocultada, método, código de estado, protocolo, duración de cada fase y tamaño de la respuesta. Los nombres que pasas a `PerformanceTracer` y `LeakTracker` se registran tal como los das, así que usa nombres fijos.
- **Nunca se registra:** los encabezados de petición y respuesta (`Authorization`, cookies), los cuerpos de petición y respuesta, el usuario y la contraseña ni el fragmento de una URL, ni su query, salvo los parámetros que permitas por nombre.
- **URL:** los segmentos de la ruta que parecen identificadores (números, UUID, direcciones de correo, seis o más dígitos, números de tarjeta, IBAN, tokens) se convierten en `:id`, y lo mismo ocurre con el segmento que sigue a un nombre como `token` o `password`. Un segmento que, tras decodificar los porcentajes, no es ASCII puro, como `Şifre` o una palabra con una letra parecida de otro alfabeto, se oculta junto con el siguiente, a propósito. Una ruta que los servidores podrían interpretar de formas distintas (`..`, `;`, doble codificación porcentual) se registra solo como esquema y host.

La ocultación es una red de seguridad, no una garantía. No puede saber que una palabra corriente en una ruta, como el código de invitación `sunflower`, es secreta. Mantén los secretos fuera de las URL, o registra solo el host con `URLRedaction(recordsHostOnly: true)`. El [artículo sobre los tiempos de red](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings) enumera todas las reglas y sus límites.

## App de ejemplo

[`Examples/PerformanceLab`](Examples/) es una app de iOS y macOS que provoca cada problema a propósito para que veas cómo reacciona la medición. De izquierda a derecha: un bloqueo de 600 ms del hilo principal con la función de la app a la que apunta su pila de llamadas, una lista con filas lentas desplazada a toda velocidad, un view model mantenido vivo por un closure y una comprobación de presupuesto que detecta un bloqueo.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-hangs-dark.png"><img src="docs/images/example-hangs-light.png" width="200" alt="Pantalla Hangs: un bloqueo de unos 600 ms cuya pila de llamadas apunta a PerformanceLab.blockMainThread"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-frames-dark.png"><img src="docs/images/example-frames-light.png" width="200" alt="Pantalla Frames: unos 40 de 60 fps y un hitch ratio grave mientras se desplazan filas lentas"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-leaks-dark.png"><img src="docs/images/example-leaks-light.png" width="200" alt="Pantalla Leaks: el informe 'Profile (leaks)' de PerformanceLab.ProfileModel"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-budget-dark.png"><img src="docs/images/example-budget-light.png" width="200" alt="Pantalla Budget: cinco límites y la infracción 'hang exceeds 250 ms'"></picture>
</p>

Las capturas de pantalla se toman de la app en ejecución en un simulador de iPhone con [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh), así que las cifras son medidas, no dibujadas.

## Documentación

La [documentación de DocC](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/) cubre todos los tipos públicos, con estos artículos:

- [Getting Started](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/gettingstarted)
- [Finding Hangs and Hitches](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/findinghangsandhitches)
- [Reading Field Metrics](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/readingfieldmetrics)
- [Setting Performance Budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)
- [Recording Network Timings](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)

## Requisitos

| Plataforma | Versión mínima |
| ---------- | -------------- |
| iOS        | 17.0           |
| macOS      | 14.0           |
| tvOS       | 17.0           |
| watchOS    | 10.0           |
| visionOS   | 1.0            |

Swift 6.2 o posterior (Xcode 26 o posterior). El paquete se compila en el modo de lenguaje Swift 6. El monitor de fotogramas necesita un display link, por lo que no está disponible en watchOS; MetricKit no está disponible en tvOS ni en watchOS. Las pilas de llamadas de los bloqueos se leen en arm64 y x86_64, en todas las plataformas excepto watchOS, que no permite que una app suspenda sus propios hilos.

## Contribuir

Los informes de errores y las pull requests son bienvenidos; [CONTRIBUTING.md](CONTRIBUTING.md) explica cómo compilar, probar y regenerar las capturas de pantalla. Para informar de un problema de seguridad de forma privada, consulta [SECURITY.md](SECURITY.md).

## Licencia

MIT. Consulta [LICENSE](LICENSE).
