//
//  PerformanceOptimizationKit.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//
//  The world's most comprehensive iOS performance optimization toolkit.
//  Production-ready tools for memory, CPU, network, and UI profiling.
//

import Foundation
@_exported import PerformanceCore

/// PerformanceOptimizationKit - World's #1 iOS Performance Toolkit
///
/// A comprehensive, production-ready performance optimization toolkit for iOS applications.
/// Provides real-time monitoring, profiling, and actionable insights for:
///
/// - **Memory**: Real-time usage tracking, leak detection, pressure monitoring
/// - **CPU**: Process and system-wide usage, thread analysis
/// - **Frame Rate**: FPS monitoring, hitch detection, jank analysis
/// - **Network**: Request profiling, latency tracking, bandwidth monitoring
/// - **Startup**: Cold/warm start analysis, phase breakdown
/// - **Threads**: Deadlock detection, main thread blocking
/// - **Core Data**: Fetch/save profiling, query optimization
///
/// ## Quick Start
///
/// ```swift
/// // Start comprehensive monitoring
/// await PerformanceDashboard.shared.startMonitoring()
///
/// // Get real-time metrics
/// let metrics = PerformanceDashboard.shared.currentMetrics
/// print("Memory: \(metrics.memoryUsage)%")
/// print("CPU: \(metrics.cpuUsage)%")
/// print("FPS: \(metrics.frameRate)")
///
/// // Get detailed performance report
/// let report = await PerformanceDashboard.shared.getPerformanceReport()
/// print("Health Score: \(report.healthScore)")
/// ```
///
public enum PerformanceOptimizationKit {
    
    /// Current version of the toolkit
    public static let version = "2.0.0"
    
    /// Build configuration
    public static let buildConfiguration: String = {
        #if DEBUG
        return "Debug"
        #else
        return "Release"
        #endif
    }()
    
    /// Whether the toolkit is running in DEBUG mode
    public static let isDebug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    /// Initialize all profilers with default configuration
    public static func initialize() {
        // Configure components with sensible defaults
        MemoryLeakDetector.shared.configure(.init())
        NetworkProfiler.shared.configure(.init())
        ThreadAnalyzer.shared.configure(.init())
        CoreDataProfiler.shared.configure(.init())
        StartupTimeAnalyzer.shared.configure(.init())
    }
    
    /// Initialize with custom configuration
    public static func initialize(configuration: Configuration) {
        // Memory Leak Detector
        var leakConfig = MemoryLeakDetector.Configuration()
        leakConfig.trackingInterval = configuration.monitoringInterval
        MemoryLeakDetector.shared.configure(leakConfig)
        
        // Network Profiler
        var networkConfig = NetworkProfiler.Configuration()
        networkConfig.slowRequestThreshold = configuration.slowRequestThreshold
        NetworkProfiler.shared.configure(networkConfig)
        
        // Thread Analyzer
        var threadConfig = ThreadAnalyzer.Configuration()
        threadConfig.monitoringInterval = configuration.monitoringInterval
        threadConfig.mainThreadBlockThresholdMs = configuration.mainThreadBlockThresholdMs
        ThreadAnalyzer.shared.configure(threadConfig)
        
        // Core Data Profiler
        var coreDataConfig = CoreDataProfiler.Configuration()
        coreDataConfig.slowFetchThresholdMs = configuration.slowFetchThresholdMs
        CoreDataProfiler.shared.configure(coreDataConfig)
    }
    
    /// Configuration for the toolkit
    public struct Configuration {
        /// Monitoring update interval in seconds
        public var monitoringInterval: TimeInterval = 1.0
        
        /// Threshold for slow network requests (seconds)
        public var slowRequestThreshold: TimeInterval = 3.0
        
        /// Threshold for main thread blocking (milliseconds)
        public var mainThreadBlockThresholdMs: Double = 16.67
        
        /// Threshold for slow Core Data fetches (milliseconds)
        public var slowFetchThresholdMs: Double = 100.0
        
        /// Enable automatic optimization when performance degrades
        public var enableAutoOptimization: Bool = false
        
        /// Enable detailed logging
        public var enableDetailedLogging: Bool = false
        
        public init() {}
    }
    
    /// Quick diagnostic summary
    @MainActor
    public static func quickDiagnostic() -> String {
        let memory = SystemMetrics.shared.getMemoryUsage()
        let cpu = SystemMetrics.shared.getCPUUsage()
        let device = SystemMetrics.shared.getDeviceInfo()
        
        return """
        ═══════════════════════════════════════════
        📊 Performance Diagnostic Summary
        ═══════════════════════════════════════════
        
        🖥️ Device: \(device.model)
        📱 iOS: \(device.systemVersion)
        🔋 Low Power Mode: \(device.isLowPowerModeEnabled ? "ON" : "OFF")
        🌡️ Thermal State: \(device.thermalState.description)
        
        💾 Memory
        ├─ Used: \(memory.formattedResidentSize)
        ├─ Usage: \(String(format: "%.1f", memory.usagePercentage))%
        └─ Pressure: \(SystemMetrics.shared.getMemoryPressure().rawValue)
        
        ⚡ CPU
        ├─ Process: \(String(format: "%.1f", cpu.processUsage))%
        ├─ System: \(String(format: "%.1f", cpu.systemWideUsage))%
        └─ Threads: \(cpu.threadCount) (\(cpu.activeThreads) active)
        
        💿 Disk
        └─ Free: \(SystemMetrics.shared.getDiskUsage().formattedFreeSpace)
        
        ═══════════════════════════════════════════
        """
    }
}

// MARK: - Convenience Extensions

public extension PerformanceOptimizationKit {
    
    /// Get current memory usage percentage
    static var memoryUsage: Double {
        SystemMetrics.shared.getMemoryUsage().usagePercentage
    }
    
    /// Get current CPU usage percentage
    static var cpuUsage: Double {
        SystemMetrics.shared.getCPUUsage().processUsage
    }
    
    /// Get current thread count
    static var threadCount: Int {
        SystemMetrics.shared.getCPUUsage().threadCount
    }
    
    /// Check if device is under memory pressure
    static var isUnderMemoryPressure: Bool {
        SystemMetrics.shared.getMemoryPressure() != .normal
    }
    
    /// Check if device is thermal throttling
    static var isThermalThrottling: Bool {
        SystemMetrics.shared.getDeviceInfo().thermalState != .nominal
    }
}
