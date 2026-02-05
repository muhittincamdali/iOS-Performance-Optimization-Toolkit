<p align="center">
  <img src="https://img.shields.io/badge/iOS-15.0%2B-blue?style=for-the-badge&logo=apple" alt="iOS 15+"/>
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift" alt="Swift 5.9"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License"/>
  <img src="https://img.shields.io/badge/SPM-Compatible-brightgreen?style=for-the-badge&logo=swift" alt="SPM Compatible"/>
</p>

<h1 align="center">🚀 iOS Performance Optimization Toolkit</h1>

<p align="center">
  <strong>The World's Most Comprehensive iOS Performance Profiling Framework</strong>
</p>

<p align="center">
  Production-ready tools for memory, CPU, network, UI, and Core Data profiling.<br/>
  Real-time monitoring • Actionable insights • Zero overhead in production.
</p>

---

## ✨ Features

| Module | Description | Key Capabilities |
|--------|-------------|------------------|
| 💾 **Memory Profiler** | Real-time memory analysis | Usage tracking, leak detection, pressure monitoring |
| ⚡ **CPU Profiler** | Process & system CPU monitoring | Thread analysis, usage breakdown, bottleneck detection |
| 🎯 **Frame Rate Monitor** | Smooth scrolling analysis | FPS tracking, hitch detection, jank scoring |
| 🌐 **Network Profiler** | Request performance tracking | Latency analysis, bandwidth monitoring, slow request detection |
| 🔋 **Battery Tracker** | Power consumption analysis | Drain detection, thermal monitoring |
| 💿 **Disk I/O Monitor** | Storage performance | Usage tracking, read/write analysis |
| 🚀 **Startup Analyzer** | App launch optimization | Cold/warm start analysis, phase breakdown |
| 🔍 **Memory Leak Detector** | Automatic leak detection | Object tracking, retain cycle detection |
| 🧵 **Thread Analyzer** | Concurrency analysis | Deadlock detection, main thread blocking |
| 📊 **Core Data Profiler** | Database performance | Fetch/save profiling, query optimization |
| 📈 **Real-time Dashboard** | Live performance monitoring | Health scores, alerts, recommendations |

---

## 🎯 Quick Start

### Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git", from: "2.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter the repository URL.

### Basic Usage

```swift
import PerformanceOptimizationKit

// Initialize the toolkit
PerformanceOptimizationKit.initialize()

// Start comprehensive monitoring
await PerformanceDashboard.shared.startMonitoring()

// Get real-time metrics
let metrics = PerformanceDashboard.shared.currentMetrics
print("Memory: \(metrics.memoryUsage)%")
print("CPU: \(metrics.cpuUsage)%")
print("FPS: \(metrics.frameRate)")

// Get detailed performance report
let report = await PerformanceDashboard.shared.getPerformanceReport()
print("Health Score: \(report.healthScore)/100")
```

---

## 📊 Module Deep Dive

### 💾 Memory Profiling

Real-time memory analysis using Mach kernel APIs:

```swift
// Get current memory usage
let memoryInfo = SystemMetrics.shared.getMemoryUsage()
print("Resident: \(memoryInfo.formattedResidentSize)")
print("Usage: \(memoryInfo.usagePercentage)%")

// Get memory footprint (actual impact)
let footprint = SystemMetrics.shared.getMemoryFootprint()

// Check memory pressure
let pressure = SystemMetrics.shared.getMemoryPressure()
switch pressure {
case .normal: print("Memory OK")
case .warning: print("Memory pressure warning")
case .critical: print("Critical memory pressure!")
}
```

### 🔍 Memory Leak Detection

Automatic leak detection with retain cycle analysis:

```swift
// Configure leak detector
var config = MemoryLeakDetector.Configuration()
config.leakThresholdSeconds = 30.0
config.enableRetainCycleDetection = true
MemoryLeakDetector.shared.configure(config)

// Track objects
MemoryLeakDetector.shared.track(myViewController)
MemoryLeakDetector.shared.track(myService, identifier: "NetworkService")

// Check for leaks
let leaks = MemoryLeakDetector.shared.checkForLeaks()
for leak in leaks {
    print("⚠️ Potential leak: \(leak.className)")
    print("   Age: \(leak.formattedAge)")
    print("   Severity: \(leak.severity.emoji) \(leak.severity.rawValue)")
}

// Get statistics
let stats = MemoryLeakDetector.shared.getStatistics()
print("Tracked: \(stats.totalTrackedObjects)")
print("Potential leaks: \(stats.potentialLeaks)")
```

### ⚡ CPU Profiling

Comprehensive CPU and thread analysis:

```swift
// Get CPU usage
let cpuInfo = SystemMetrics.shared.getCPUUsage()
print("Process CPU: \(cpuInfo.processUsage)%")
print("System CPU: \(cpuInfo.systemWideUsage)%")
print("Threads: \(cpuInfo.threadCount)")
print("Active: \(cpuInfo.activeThreads)")

// Per-thread breakdown
for thread in cpuInfo.threads {
    print("Thread \(thread.threadId): \(thread.formattedCPUUsage)")
    print("  State: \(thread.state.emoji) \(thread.state.description)")
}
```

### 🎯 Frame Rate Monitoring

Smooth UI performance analysis:

```swift
// Configure monitoring
var config = FrameRateMonitor.Configuration()
config.targetFrameRate = 60
config.hitchThresholdMs = 16.67
FrameRateMonitor.shared.configure(config)

// Set up callbacks
FrameRateMonitor.shared.onFrameRateUpdate = { info in
    print("FPS: \(Int(info.currentFPS)) \(info.grade.emoji)")
}

FrameRateMonitor.shared.onHitchDetected = { hitch in
    print("⚠️ Hitch: \(hitch.duration)ms (\(hitch.severity.rawValue))")
}

// Start monitoring
await FrameRateMonitor.shared.startMonitoring()

// Get analytics
let analytics = FrameRateMonitor.shared.getAnalytics()
print("Average FPS: \(analytics.averageFPS)")
print("95th percentile: \(analytics.percentile95)")
print("Smoothness score: \(analytics.smoothnessScore)")
```

### 🌐 Network Profiling

Request performance tracking:

```swift
// Enable network profiling
NetworkProfiler.shared.enable()

// Or create a profiled session
let session = NetworkProfiler.shared.createProfiledSession()

// Set up callbacks
NetworkProfiler.shared.onSlowRequestDetected = { request in
    print("🐌 Slow request: \(request.url)")
    print("   Duration: \(request.formattedDuration)")
}

// Get statistics
let stats = NetworkProfiler.shared.getStatistics()
print("Total requests: \(stats.totalRequests)")
print("Success rate: \(stats.successRate)%")
print("Avg response: \(stats.averageResponseTime)s")

// Get performance analysis
let analysis = NetworkProfiler.shared.getPerformanceAnalysis()
print("Network health: \(analysis.grade)")
for issue in analysis.issues {
    print("⚠️ \(issue.description)")
}
```

### 🚀 Startup Time Analysis

App launch optimization:

```swift
// In main.swift (as early as possible)
StartupTimeAnalyzer.shared.markMainFunction()

// In AppDelegate
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    StartupTimeAnalyzer.shared.markDidFinishLaunching()
    // ...
}

// After first frame renders
StartupTimeAnalyzer.shared.markFirstFrame()

// When app is fully interactive
StartupTimeAnalyzer.shared.markInteractive()

// Get report
let report = StartupTimeAnalyzer.shared.generateReport()
print(report.summary)
// Output:
// Startup Report
// ==============
// Total Time: 850 ms
// Type: Cold Start
// Grade: Good 🔵
//
// Breakdown:
// - Pre-main: 120ms
// - Main → didFinishLaunching: 280ms
// - didFinishLaunching → First Frame: 320ms
// - First Frame → Interactive: 130ms

// Get recommendations
for rec in report.recommendations {
    print("💡 \(rec.title)")
    print("   \(rec.description)")
    print("   Impact: \(rec.impact.rawValue)")
}
```

### 🧵 Thread Analysis

Concurrency and deadlock detection:

```swift
// Configure analyzer
var config = ThreadAnalyzer.Configuration()
config.mainThreadBlockThresholdMs = 16.67
config.enableDeadlockDetection = true
ThreadAnalyzer.shared.configure(config)

// Set up callbacks
ThreadAnalyzer.shared.onMainThreadBlocked = { event in
    print("🔴 Main thread blocked: \(event.formattedDuration)")
    print("Stack trace:")
    event.stackTrace.prefix(5).forEach { print("  \($0)") }
}

ThreadAnalyzer.shared.onDeadlockDetected = { deadlock in
    print("💀 Potential deadlock detected!")
    print("Involved threads: \(deadlock.involvedThreads)")
}

// Start monitoring
ThreadAnalyzer.shared.startMonitoring()

// Get health report
let health = ThreadAnalyzer.shared.analyzeThreadHealth()
print("Thread health: \(health.grade)")
print("Thread count: \(health.threadCount)")
for issue in health.issues {
    print("⚠️ \(issue.description)")
}
```

### 📊 Core Data Profiling

Database performance optimization:

```swift
// Enable profiling
CoreDataProfiler.shared.enable()

// Profile a fetch request
let request = NSFetchRequest<User>(entityName: "User")
request.predicate = NSPredicate(format: "isActive == true")
let users = try CoreDataProfiler.shared.profileFetch(request, in: context)

// Analyze fetch request for optimization
let analysis = CoreDataProfiler.shared.analyzeFetchRequest(request)
print("Fetch optimization score: \(analysis.grade)")
for issue in analysis.issues {
    print("⚠️ \(issue.description)")
}
for rec in analysis.recommendations {
    print("💡 \(rec.title)")
    if let code = rec.code {
        print("   Code: \(code)")
    }
}

// Profile save operations
try CoreDataProfiler.shared.profileSave(in: context, label: "User update")

// Get statistics
let stats = CoreDataProfiler.shared.getStatistics()
print("Total fetches: \(stats.totalFetches)")
print("Avg fetch time: \(stats.averageFetchTime)ms")
print("Slow fetches: \(stats.slowFetchCount)")
```

### 📈 Real-time Dashboard

Comprehensive monitoring with health scores:

```swift
import SwiftUI

struct PerformanceView: View {
    @ObservedObject var dashboard = PerformanceDashboard.shared
    
    var body: some View {
        VStack {
            // Health Score
            Text("Health: \(Int(dashboard.healthScore))%")
                .font(.largeTitle)
            
            // Real-time metrics
            HStack {
                MetricView(title: "Memory", value: "\(Int(dashboard.currentMetrics.memoryUsage))%")
                MetricView(title: "CPU", value: "\(Int(dashboard.currentMetrics.cpuUsage))%")
                MetricView(title: "FPS", value: "\(Int(dashboard.currentMetrics.frameRate))")
            }
            
            // Alerts
            ForEach(dashboard.alerts) { alert in
                AlertView(alert: alert)
            }
        }
        .onAppear {
            Task {
                await dashboard.startMonitoring()
            }
        }
    }
}

// Get comprehensive report
let report = await PerformanceDashboard.shared.getPerformanceReport()
print("Overall grade: \(report.grade)")

// Export as JSON
if let json = await PerformanceDashboard.shared.exportReport() {
    // Save or send report
}
```

---

## 🏗️ Architecture

```
PerformanceOptimizationKit/
├── Core/
│   ├── SystemMetrics.swift          # Mach kernel metrics
│   ├── FrameRateMonitor.swift       # CADisplayLink FPS monitoring
│   ├── MemoryLeakDetector.swift     # Object tracking & leak detection
│   ├── StartupTimeAnalyzer.swift    # App launch analysis
│   ├── NetworkProfiler.swift        # URL request profiling
│   ├── ThreadAnalyzer.swift         # Thread & deadlock analysis
│   ├── CoreDataProfiler.swift       # Core Data performance
│   └── PerformanceDashboard.swift   # Real-time monitoring hub
└── PerformanceOptimizationKit/
    └── PerformanceOptimizationKit.swift  # Public API
```

---

## 📋 Requirements

| Platform | Minimum Version |
|----------|-----------------|
| iOS | 15.0+ |
| macOS | 12.0+ |
| watchOS | 8.0+ |
| tvOS | 15.0+ |
| visionOS | 1.0+ |
| Swift | 5.9+ |

---

## 🔧 Best Practices

### Production vs Debug

```swift
#if DEBUG
// Full monitoring in debug builds
PerformanceOptimizationKit.initialize(configuration: .init(
    enableDetailedLogging: true,
    enableAutoOptimization: false
))
await PerformanceDashboard.shared.startMonitoring()
#else
// Minimal monitoring in production
// Or disable entirely for zero overhead
#endif
```

### Memory-Efficient Monitoring

```swift
// Only enable what you need
var config = PerformanceDashboard.Configuration()
config.enableHistory = false  // Don't store history
config.updateInterval = 5.0   // Less frequent updates
PerformanceDashboard.shared.configure(config)
```

### CI/CD Integration

```swift
// Generate performance report for CI
let report = await PerformanceDashboard.shared.getPerformanceReport()

// Fail build if health score is too low
if report.healthScore < 70 {
    fatalError("Performance regression detected: \(report.healthScore)")
}

// Export metrics
if let json = await PerformanceDashboard.shared.exportReport() {
    try json.write(to: URL(fileURLWithPath: "performance-report.json"))
}
```

---

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Apple's Instruments team for inspiration
- The Swift community for feedback and contributions

---

<p align="center">
  <strong>Built with ❤️ for the iOS community</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/stargazers">⭐ Star this repo</a> •
  <a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/issues">🐛 Report Bug</a> •
  <a href="https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit/issues">💡 Request Feature</a>
</p>
