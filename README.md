# iOS Performance Optimization Toolkit

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=flat&logo=swift&logoColor=white" alt="Swift"></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-15.0+-000000?style=flat&logo=apple&logoColor=white" alt="iOS"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"></a>
</p>

<p align="center">
  <b>Tools for measuring and improving iOS app performance: profiling, memory, and battery.</b>
</p>

---

## Features

- **Memory Profiling** — Track memory usage and leaks
- **CPU Monitoring** — Measure CPU utilization
- **Battery Impact** — Analyze battery consumption
- **Launch Time** — Optimize app startup
- **Frame Rate** — Monitor UI performance

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git", from: "1.0.0")
]
```

## Quick Start

```swift
import PerformanceKit

// Start monitoring
Performance.startMonitoring()

// Get current metrics
let metrics = Performance.currentMetrics
print("Memory: \(metrics.memoryUsage) MB")
print("CPU: \(metrics.cpuUsage)%")
print("FPS: \(metrics.frameRate)")

// Measure operation
let result = Performance.measure("dataProcessing") {
    processData()
}
print("Duration: \(result.duration)ms")

// Memory leak detection
Performance.detectLeaks { leaks in
    for leak in leaks {
        print("Potential leak: \(leak.className)")
    }
}
```

## Launch Optimization

```swift
// Measure launch time
Performance.measureLaunch { phase, duration in
    print("\(phase): \(duration)ms")
}

// Defer non-critical work
Performance.deferAfterLaunch {
    loadAnalytics()
    preloadImages()
}
```

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## License

MIT License. See [LICENSE](LICENSE).

## Author

**Muhittin Camdali** — [@muhittincamdali](https://github.com/muhittincamdali)
