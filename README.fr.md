<!-- i18n-source: README.md@7713e35c837f2f5de2312d94c19d1af745744d0e status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/banner-light.svg" alt="Performance Toolkit: Find hangs, hitches, memory growth, slow launches and leaks in Swift apps, and check them in tests."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-version-light.svg" alt="Dernière version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/blob/master/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/tree/master/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/master/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

Un paquet Swift qui mesure ce qui rend une app lente, sur iOS 17+, macOS 14+, tvOS 17+, watchOS 10+ et visionOS 1+, sans aucune dépendance. Il signale les blocages (hangs) du thread principal avec la pile d’appels qui les a causés, les images en retard sous la forme du hitch time ratio d’Apple, l’empreinte mémoire (memory footprint) que le système compare à la limite de votre app, le temps de lancement à partir du moment où le processus a démarré, et les view models qui survivent à leur écran. Les mêmes chiffres proviennent des appareils des utilisateurs via MetricKit, et un budget transforme n’importe lequel d’entre eux en test qui échoue.

## Points forts

- **Des blocages avec pile d’appels** — `HangDetector` signale que le thread principal ne répond plus depuis 250 ms ou plus et, tant qu’il est encore bloqué, enregistre sa pile d’appels avec des noms Swift démanglés.
- **Des hitches comptés comme Apple les compte** — `FrameTimeline` mesure le retard de chaque image et indique le hitch time ratio en ms/s, évalué avec les seuils de la documentation d’Apple.
- **La mesure mémoire qui compte** — `MemorySnapshot` lit l’empreinte physique que le système applique, son pic et, sur appareil, la mémoire restante avant la limite.
- **Lancement et fuites** — `LaunchTimer` mesure depuis la création du processus (avant `main`) et reconnaît les lancements préchauffés (prewarmed) ; `LeakTracker` signale les objets encore en vie après la fermeture de leur écran.
- **Données de terrain et budgets** — `FieldMetricsReceiver` lit les rapports quotidiens de MetricKit sur iOS 17 à 27 ; `PerformanceBudget` vérifie n’importe quelle mesure par rapport à des limites dans un test.
- **Conçu pour tourner toute la journée** — chaque tampon a une limite, les valeurs issues du noyau ou d’un payload sont vérifiées avant d’être utilisées, et les mesures réseau ne contiennent ni en-têtes ni corps, seulement une URL masquée. 124 tests Swift Testing s’exécutent sur macOS, dont 123 également sur un simulateur d’iPhone, face à de vrais blocages, de vraies allocations et de vraies requêtes HTTP.

### Contenu

| Domaine             | API                                                                     |
| ------------------- | ----------------------------------------------------------------------- |
| Surcouche en direct | `PerformanceMonitor`, `PerformanceHUD`, `PerformanceSnapshot`           |
| Blocages            | `HangDetector`, `HangEvent`, `HangSeverity`, `StackFrame`               |
| Images              | `FrameRateMonitor`, `FrameTimeline`, `FrameStatistics`, `HitchRating`   |
| Mémoire et CPU      | `MemorySnapshot`, `CPUSnapshot`, `ProcessCPUTime`                       |
| Lancement           | `LaunchTimer`, `LaunchMeasurement`, `ProcessLaunch`, `measuresLaunch()` |
| Fuites              | `LeakTracker`, `LeakReport`                                             |
| Opérations          | `PerformanceTracer` (signposts pour Instruments), `SampleStatistics`    |
| Réseau              | `NetworkMetricsCollector`, `NetworkTiming`, `URLRedaction`              |
| Données de terrain  | `FieldMetricsReceiver`, `FieldMetrics`, `FieldHistogram`                |
| Budgets             | `PerformanceBudget`, `PerformanceMeasurements`, `BudgetViolation`       |

## Démarrage rapide

**1. Ajouter le paquet**

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

Collez-la dans le champ de recherche en haut à droite de la fenêtre. Laissez **Dependency Rule** sur **Up to Next Major Version** à partir de `2.0.0`, puis cliquez sur **Add Package**. Dans la fenêtre suivante, choisissez la cible de votre app à côté de **PerformanceOptimizationKit** et cliquez de nouveau sur **Add Package**.

**2. Importer le module**

```swift
import PerformanceOptimizationKit
```

**3. Afficher la surcouche**

Enveloppez votre première vue dans une vue qui démarre un `PerformanceMonitor` et affiche son `PerformanceHUD` :

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

Affichez `RootView()` à la place de `ContentView()` dans votre `App` et lancez l’app : la surcouche en haut à droite affiche la fréquence d’images, le hitch ratio, le CPU, la mémoire et le dernier blocage, et se met à jour chaque seconde. Le moniteur d’images maintient l’écran à sa fréquence de rafraîchissement maximale ; n’affichez donc la surcouche que dans les builds de débogage (`#if DEBUG`).

## Installation

### Swift Package Manager

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git
```

Ou ajoutez-le aux `dependencies` de votre `Package.swift` :

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

Utilisez la version 2.0.0 ou ultérieure : la version 1.0.0 ne compilait pas, et la 2.0.0 remplace son API.

## Utilisation

### Trouver ce qui bloque le thread principal

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

Les images (frames) les plus internes montrent ce que le thread principal exécutait lorsque le blocage a atteint 250 ms. Dans un build release sans symboles, les frames contiennent des adresses et des noms de binaires ; symbolisez-les avec le dSYM.

### Mesurer le lancement

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

Le chronomètre démarre lorsque le noyau a créé le processus ; il inclut donc l’éditeur de liens dynamique (dynamic linker) et les initialiseurs statiques d’avant `main`. Un processus préchauffé a attendu en état suspendu avant que la personne n’ouvre l’app ; `wasPrewarmed` vous indique qu’il faut écarter ce lancement.

### Vérifier un budget

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

Chaque dépassement se lit comme `hang of 900 ms exceeds 250 ms`. Dans un test unitaire, transmettez les statistiques de `PerformanceTracer` et vérifiez `#expect(violations.isEmpty)` ; l’[article sur les budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets) montre comment faire.

### Lire les données de terrain de MetricKit

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

MetricKit livre un rapport environ une fois par jour depuis les appareils dont les propriétaires partagent leurs données d’analyse avec les développeurs. `FieldMetrics` est `Codable` et n’a aucune dépendance à MetricKit : vous pouvez donc l’envoyer et le décoder sur un serveur. Sur iOS 27 et macOS 27, le récepteur utilise le nouveau `MetricManager` ; sur les systèmes antérieurs, `MXMetricManager`.

### Mesurer la durée des requêtes réseau

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

Chaque `NetworkTiming` découpe la requête en résolution DNS, connexion, TLS, envoi, attente du premier octet et réception. Son URL est masquée avant d’être stockée : `https://api.example.com/v1/users/48213/orders?page=2&token=abc` est enregistrée comme `https://api.example.com/v1/users/:id/orders?page=2`.

## Ce qui est enregistré

Le paquet est destiné aux builds internes et bêta utilisés par de vraies personnes ; ses rapports ne doivent donc pas contenir leurs données.

- **Enregistré :** les durées, les chiffres d’images et de hitches, les chiffres de mémoire et de CPU, les piles d’appels du thread principal pendant un blocage (noms de binaires et de symboles), les chiffres de MetricKit et le build de l’app, les noms de type des objets qui survivent à leur écran et, pour chaque requête, son URL masquée, sa méthode, son code de statut, son protocole, la durée de chaque phase et la taille de la réponse. Les noms que vous passez à `PerformanceTracer` et à `LeakTracker` sont enregistrés tels que vous les donnez ; utilisez donc des noms fixes.
- **Jamais enregistré :** les en-têtes de requête et de réponse (`Authorization`, cookies), les corps de requête et de réponse, le nom d’utilisateur et le mot de passe ainsi que le fragment d’une URL, et sa query, sauf les paramètres que vous autorisez par leur nom.
- **URL :** les segments de chemin qui ressemblent à des identifiants (nombres, UUID, adresses e-mail, six chiffres ou plus, numéros de carte, IBAN, tokens) deviennent `:id`, de même que le segment qui suit un nom tel que `token` ou `password`. Un segment qui n’est pas de l’ASCII pur après décodage des pourcentages, comme `Şifre` ou un mot contenant une lettre d’un autre alphabet qui ressemble à une lettre latine, est masqué avec le suivant, volontairement. Un chemin que les serveurs pourraient lire de plusieurs façons (`..`, `;`, double encodage des pourcentages) est enregistré uniquement sous la forme du schéma et de l’hôte.

Le masquage est un filet de sécurité, pas une garantie. Il ne peut pas savoir qu’un mot ordinaire dans un chemin, comme le code d’invitation `sunflower`, est secret. Gardez les secrets hors des URL, ou n’enregistrez que l’hôte avec `URLRedaction(recordsHostOnly: true)`. L’[article sur les mesures réseau](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings) énumère chaque règle et ses limites.

## App d’exemple

[`Examples/PerformanceLab`](Examples/) est une app iOS et macOS qui provoque chaque problème exprès, pour que vous puissiez voir la mesure réagir. De gauche à droite : un blocage du thread principal de 600 ms, avec la fonction de l’app que désigne sa pile d’appels ; une liste aux lignes lentes défilée à pleine vitesse ; un view model maintenu en vie par une closure ; et une vérification de budget qui détecte un blocage.

<p align="center">
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-hangs-dark.png"><img src="docs/images/example-hangs-light.png" width="200" alt="Écran Hangs : un blocage d’environ 600 ms dont la pile d’appels désigne PerformanceLab.blockMainThread"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-frames-dark.png"><img src="docs/images/example-frames-light.png" width="200" alt="Écran Frames : fréquence d’images d’environ 40 sur 60 fps et hitch ratio sévère pendant le défilement de lignes lentes"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-leaks-dark.png"><img src="docs/images/example-leaks-light.png" width="200" alt="Écran Leaks : le rapport « Profile (leaks) » pour PerformanceLab.ProfileModel"></picture>
<picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/example-budget-dark.png"><img src="docs/images/example-budget-light.png" width="200" alt="Écran Budget : cinq limites et le dépassement « hang exceeds 250 ms »"></picture>
</p>

Les captures d’écran sont prises depuis l’app en cours d’exécution sur un simulateur d’iPhone par [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) ; les chiffres sont donc mesurés, pas dessinés.

## Documentation

La [documentation DocC](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/) couvre chaque type public, avec ces articles :

- [Getting Started](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/gettingstarted)
- [Finding Hangs and Hitches](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/findinghangsandhitches)
- [Reading Field Metrics](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/readingfieldmetrics)
- [Setting Performance Budgets](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/settingperformancebudgets)
- [Recording Network Timings](https://muhittincamdali.github.io/iOS-Performance-Optimization-Toolkit/documentation/performanceoptimizationkit/recordingnetworktimings)

## Prérequis

| Plateforme | Version minimale |
| ---------- | ---------------- |
| iOS        | 17.0             |
| macOS      | 14.0             |
| tvOS       | 17.0             |
| watchOS    | 10.0             |
| visionOS   | 1.0              |

Swift 6.2 ou ultérieur (Xcode 26 ou ultérieur). Le paquet se compile en mode de langage Swift 6. Le moniteur d’images a besoin d’un display link ; il n’est donc pas disponible sur watchOS. MetricKit n’est pas disponible sur tvOS ni sur watchOS. Les piles d’appels des blocages sont lues sur arm64 et x86_64, sur toutes les plateformes sauf watchOS, qui ne permet pas à une app de suspendre ses propres threads.

## Contribuer

Les rapports de bugs et les pull requests sont les bienvenus ; [CONTRIBUTING.md](CONTRIBUTING.md) explique comment compiler, tester et régénérer les captures d’écran. Pour signaler un problème de sécurité en privé, consultez [SECURITY.md](SECURITY.md).

## Licence

MIT. Voir [LICENSE](LICENSE).
