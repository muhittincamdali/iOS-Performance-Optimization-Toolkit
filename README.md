```
╔══════════════════════════════════════════════════════════════════════════════════╗
║                                                                                  ║
║   ██████╗ ███████╗██████╗ ███████╗ ██████╗ ██████╗ ███╗   ███╗ █████╗ ███╗   ██╗║
║   ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗██╔══██╗████╗ ████║██╔══██╗████╗  ██║║
║   ██████╔╝█████╗  ██████╔╝█████╗  ██║   ██║██████╔╝██╔████╔██║███████║██╔██╗ ██║║
║   ██╔═══╝ ██╔══╝  ██╔══██╗██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║██╔══██║██║╚██╗██║║
║   ██║     ███████╗██║  ██║██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║║
║   ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝║
║                                                                                  ║
║                         ██╗  ██╗██╗████████╗                                     ║
║                         ██║ ██╔╝██║╚══██╔══╝                                     ║
║                         █████╔╝ ██║   ██║                                        ║
║                         ██╔═██╗ ██║   ██║                                        ║
║                         ██║  ██╗██║   ██║                                        ║
║                         ╚═╝  ╚═╝╚═╝   ╚═╝                                        ║
║                                                                                  ║
╚══════════════════════════════════════════════════════════════════════════════════╝
```

<div align="center">

**Comprehensive iOS performance optimization toolkit. Measure, profile, optimize.**

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![CI](https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/actions)

[Features](#-features) • [Quick Start](#-quick-start) • [Installation](#-installation) • [Usage](#-usage) • [API](#-api-reference) • [Docs](Documentation/)

</div>

---

## ✨ Features

- ⏱️ **Precise Timing** — Measure code execution with nanosecond precision
- 💾 **Memory Tracking** — Real-time memory usage monitoring
- 🔥 **CPU Monitoring** — Track CPU usage per thread
- 📊 **Statistical Analysis** — Mean, median, percentiles, standard deviation
- 🎯 **Benchmarking** — Compare implementations with warmup support
- 📈 **Performance Reports** — Generate comprehensive reports
- 🔗 **Signpost Integration** — Instruments timeline integration
- 🧵 **Nested Profiling** — Hierarchical timing measurements

---

## 🚀 Quick Start

```swift
import PerformanceKit

// Measure execution time
let result = PerformanceKit.measure("parse-json") {
    parseJSONData(data)
}

// Check memory usage
let memory = await PerformanceKit.shared.memoryUsage
print("Memory: \(memory.residentMB) MB")

// Run benchmarks
let benchmark = Benchmark(name: "sort-algorithm", iterations: 1000)
let result = benchmark.run {
    array.sorted()
}
print(result.summary)
```

---

## 📦 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Packages** → Enter the repository URL.

### Requirements

| Platform | Minimum Version |
|----------|-----------------|
| iOS      | 15.0+           |
| macOS    | 13.0+           |
| tvOS     | 15.0+           |
| watchOS  | 8.0+            |
| Swift    | 5.9+            |

---

## 📖 Usage

### Basic Measurement

```swift
// Measure synchronous code
PerformanceKit.measure("operation-name") {
    performExpensiveOperation()
}

// Measure with return value
let result = PerformanceKit.measure("compute") {
    return heavyComputation()
}

// Measure async code
await PerformanceKit.measureAsync("fetch-data") {
    await fetchFromServer()
}
```

### Enable Logging

```swift
// See timing logs in console
PerformanceKit.shared.isLoggingEnabled = true

// Output: [operation-name] Elapsed: 0.0234s
```

### Memory Monitoring

```swift
let memory = await PerformanceKit.shared.memoryUsage

print("Resident: \(memory.residentMB) MB")
print("Virtual: \(memory.virtualMB) MB")
print(memory.formatted)
// Output: Resident: 45.23 MB, Virtual: 128.50 MB
```

### CPU Monitoring

```swift
let cpu = await PerformanceKit.shared.cpuUsage
print("CPU: \(String(format: "%.1f%%", cpu))")
```

### Statistical Analysis

```swift
// Make multiple measurements
for _ in 0..<100 {
    PerformanceKit.measure("api-call") {
        await fetchAPI()
    }
}

// Get statistics
if let stats = PerformanceKit.shared.statistics(for: "api-call") {
    print("Count: \(stats.count)")
    print("Mean: \(stats.mean)s")
    print("Median: \(stats.median)s")
    print("Min: \(stats.min)s")
    print("Max: \(stats.max)s")
    print("Std Dev: \(stats.standardDeviation)s")
}
```

### Profiler (Scoped Timing)

```swift
// Auto-stop on scope exit
func processData() {
    let profiler = Profiler("processData")
    defer { profiler.stop() }
    
    // Nested profiling
    let parseProfiler = profiler.child("parse")
    parseData()
    parseProfiler.stop()
    
    let transformProfiler = profiler.child("transform")
    transformData()
    transformProfiler.stop()
}

// Get hierarchical report
print(profiler.report())
// Output:
// processData: 0.1234s
//   parse: 0.0456s
//   transform: 0.0778s
```

### Benchmarking

```swift
// Basic benchmark
let benchmark = Benchmark(
    name: "array-sort",
    iterations: 1000,
    warmupIterations: 100
)

let result = benchmark.run {
    _ = largeArray.sorted()
}

print(result.summary)
// Output:
// array-sort:
//   Iterations: 1000
//   Mean: 0.001234s
//   Min: 0.001100s
//   Max: 0.001500s
//   Median: 0.001200s
//   StdDev: 0.000089s
//   P95: 0.001400s
//   P99: 0.001480s
```

### Compare Implementations

```swift
let benchmark = Benchmark(name: "sort-comparison", iterations: 100)

let comparison = benchmark.compare(
    baseline: { _ = array.sorted() },
    candidate: { _ = array.sorted(by: <) }
)

print(comparison.summary)
// Output:
// Comparison:
//   Baseline: 0.001234s
//   Candidate: 0.001000s
//   Speedup: 1.23x
//   Candidate is 18.9% faster
```

### Benchmark Suite

```swift
var suite = BenchmarkSuite(name: "Collection Operations")

suite.add("Array append") {
    var arr = [Int]()
    for i in 0..<1000 { arr.append(i) }
}

suite.add("Array reserveCapacity") {
    var arr = [Int]()
    arr.reserveCapacity(1000)
    for i in 0..<1000 { arr.append(i) }
}

suite.add("Set insert") {
    var set = Set<Int>()
    for i in 0..<1000 { set.insert(i) }
}

let results = suite.run(iterations: 100)
```

### Instruments Integration

```swift
let perf = PerformanceKit.shared

// Begin interval
let signpostID = perf.beginSignpost("Network Request")

// ... perform work ...

// End interval
perf.endSignpost("Network Request", id: signpostID)

// Mark event
perf.event("Checkpoint reached")
```

### Performance Reports

```swift
let report = await PerformanceKit.shared.generateReport()

print(report.summary)
// Output:
// === Performance Report ===
// Time: 2026-02-04 12:30:45 +0000
// Memory: Resident: 45.23 MB, Virtual: 128.50 MB
// CPU: 12.5%
//
// Measurements:
//   api-call:
//     Count: 100
//     Mean: 0.0234s
//     Min: 0.0180s
//     Max: 0.0450s
```

---

## 📊 API Reference

### PerformanceKit

| Method | Description |
|--------|-------------|
| `measure(_:block:)` | Measure synchronous execution |
| `measureAsync(_:block:)` | Measure async execution |
| `memoryUsage` | Get current memory usage |
| `cpuUsage` | Get current CPU usage |
| `statistics(for:)` | Get measurement statistics |
| `generateReport()` | Generate performance report |
| `beginSignpost(_:)` | Begin Instruments interval |
| `endSignpost(_:id:)` | End Instruments interval |
| `reset()` | Clear all measurements |

### Profiler

| Method | Description |
|--------|-------------|
| `init(_:)` | Create named profiler |
| `child(_:)` | Create nested profiler |
| `stop()` | Stop and record elapsed |
| `report()` | Get hierarchical report |

### Benchmark

| Method | Description |
|--------|-------------|
| `run(block:)` | Run benchmark |
| `runAsync(block:)` | Run async benchmark |
| `compare(baseline:candidate:)` | Compare two implementations |

---

## 🧪 Testing

```bash
swift test
```

---

## 📁 Project Structure

```
iOS-Performance-Optimization-Toolkit/
├── Sources/
│   └── PerformanceKit/
│       ├── PerformanceKit.swift    # Main API
│       ├── Profiler.swift          # Scoped profiling
│       └── Benchmark.swift         # Benchmarking
├── Tests/
│   └── PerformanceKitTests/
├── Documentation/
├── Examples/
└── Package.swift
```

---

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

<div align="center">

**[⬆ Back to Top](#-features)**

Made with ❤️ by [Muhittin Camdali](https://github.com/muhittincamdali)

</div>
