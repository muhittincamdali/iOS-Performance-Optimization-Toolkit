# Getting Started Guide

<!-- TOC START -->
## Table of Contents
- [Getting Started Guide](#getting-started-guide)
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
  - [CocoaPods](#cocoapods)
- [Quick Start](#quick-start)
  - [1. Import the Framework](#1-import-the-framework)
  - [2. Initialize Performance Monitor](#2-initialize-performance-monitor)
  - [3. Start Monitoring](#3-start-monitoring)
  - [4. Configure Optimization Settings](#4-configure-optimization-settings)
- [Basic Usage](#basic-usage)
  - [Memory Optimization](#memory-optimization)
  - [Battery Optimization](#battery-optimization)
  - [CPU Optimization](#cpu-optimization)
- [Next Steps](#next-steps)
- [Support](#support)
<!-- TOC END -->


## Overview

This guide will help you get started with the iOS Performance Optimization Toolkit. You'll learn how to integrate the toolkit into your iOS project and begin optimizing your app's performance.

## Prerequisites

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- Basic understanding of iOS development

## Installation

### Swift Package Manager

Add the toolkit to your project:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git", from: "2.1.0")
]
```

### CocoaPods

Add to your Podfile:

```ruby
pod 'PerformanceOptimizationKit', '~> 2.1.0'
```

## Quick Start

### 1. Import the Framework

```swift
import PerformanceOptimizationKit
```

### 2. Initialize Performance Monitor

```swift
let performanceMonitor = PerformanceMonitor()
performanceMonitor.enableMemoryMonitoring = true
performanceMonitor.enableBatteryMonitoring = true
performanceMonitor.enableCPUMonitoring = true
```

### 3. Start Monitoring

```swift
performanceMonitor.startMonitoring()
```

### 4. Configure Optimization Settings

```swift
let optimizationSettings = OptimizationSettings()
optimizationSettings.memoryThreshold = 200 * 1024 * 1024 // 200MB
optimizationSettings.batteryThreshold = 20.0 // 20%
optimizationSettings.cpuThreshold = 80.0 // 80%
```

## Basic Usage

### Memory Optimization

```swift
let memoryOptimizer = MemoryOptimizer()
memoryOptimizer.enableAutomaticCleanup = true
memoryOptimizer.startMonitoring()
```

### Battery Optimization

```swift
let batteryOptimizer = BatteryOptimizer()
batteryOptimizer.enablePowerSavingMode = true
batteryOptimizer.startMonitoring()
```

### CPU Optimization

```swift
let cpuOptimizer = CPUOptimizer()
cpuOptimizer.enableProfiling = true
cpuOptimizer.startMonitoring()
```

## Next Steps

- Read the [Memory Optimization Guide](MemoryOptimizationGuide.md)
- Explore [Battery Optimization](BatteryOptimizationGuide.md)
- Learn about [CPU Optimization](CPUOptimizationGuide.md)
- Check out the [Examples](../Examples/) directory

## Support

For questions and support, please open an issue on GitHub or check the documentation. 