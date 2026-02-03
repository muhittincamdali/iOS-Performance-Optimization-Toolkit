# Getting Started with PerformanceKit

This guide will help you get started with PerformanceKit in your iOS project.

## Installation

Add PerformanceKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git", from: "1.0.0")
]
```

## Basic Setup

### 1. Import the Framework

```swift
import PerformanceKit
```

### 2. Measure Execution Time

```swift
PerformanceKit.measure("my-operation") {
    // Your code here
    performExpensiveOperation()
}
```

### 3. Check Memory Usage

```swift
Task {
    let memory = await PerformanceKit.shared.memoryUsage
    print("Memory: \(memory.residentMB) MB")
}
```

### 4. Run Benchmarks

```swift
let benchmark = Benchmark(name: "sort", iterations: 100)
let result = benchmark.run {
    _ = array.sorted()
}
print(result.summary)
```

## Next Steps

- Read the [API Reference](API.md)
- Explore [Examples](../Examples/)
- Learn about [Benchmarking](Benchmarking.md)
