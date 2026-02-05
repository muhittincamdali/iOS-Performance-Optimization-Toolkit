//
//  PerformanceDashboard.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import Foundation
import Combine
#if canImport(UIKit)
import UIKit
#endif

/// Real-time performance dashboard with comprehensive monitoring
@MainActor
public final class PerformanceDashboard: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = PerformanceDashboard()
    
    // MARK: - Published Properties
    @Published public private(set) var currentMetrics: DashboardMetrics = DashboardMetrics()
    @Published public private(set) var isMonitoring: Bool = false
    @Published public private(set) var alerts: [PerformanceAlert] = []
    @Published public private(set) var healthScore: Double = 100.0
    
    // MARK: - Properties
    private var config = Configuration()
    private var updateTimer: Timer?
    private var metricsHistory: [DashboardMetrics] = []
    private let maxHistorySize = 3600 // 1 hour at 1 sample/second
    
    // Component references
    private let systemMetrics = SystemMetrics.shared
    private let memoryLeakDetector = MemoryLeakDetector.shared
    private let startupAnalyzer = StartupTimeAnalyzer.shared
    private let networkProfiler = NetworkProfiler.shared
    private let threadAnalyzer = ThreadAnalyzer.shared
    private let coreDataProfiler = CoreDataProfiler.shared
    
    // Callbacks
    public var onMetricsUpdate: ((DashboardMetrics) -> Void)?
    public var onAlertTriggered: ((PerformanceAlert) -> Void)?
    public var onHealthScoreChanged: ((Double) -> Void)?
    
    // MARK: - Configuration
    public struct Configuration {
        public var updateInterval: TimeInterval = 1.0
        public var memoryWarningThreshold: Double = 80.0 // percentage
        public var cpuWarningThreshold: Double = 80.0
        public var frameRateWarningThreshold: Double = 45.0
        public var enableAlerts: Bool = true
        public var enableHistory: Bool = true
        public var enableAutoOptimization: Bool = false
        
        public init() {}
    }
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Configure the dashboard
    public func configure(_ configuration: Configuration) {
        self.config = configuration
    }
    
    /// Start real-time monitoring
    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        // Start component monitors
        memoryLeakDetector.startTracking()
        networkProfiler.enable()
        threadAnalyzer.startMonitoring()
        coreDataProfiler.enable()
        
        #if canImport(UIKit)
        Task { @MainActor in
            FrameRateMonitor.shared.startMonitoring()
        }
        #endif
        
        // Start update timer
        updateTimer = Timer.scheduledTimer(withTimeInterval: config.updateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMetrics()
            }
        }
    }
    
    /// Stop monitoring
    public func stopMonitoring() {
        isMonitoring = false
        updateTimer?.invalidate()
        updateTimer = nil
        
        // Stop component monitors
        memoryLeakDetector.stopTracking()
        networkProfiler.disable()
        threadAnalyzer.stopMonitoring()
        coreDataProfiler.disable()
        
        #if canImport(UIKit)
        Task { @MainActor in
            FrameRateMonitor.shared.stopMonitoring()
        }
        #endif
    }
    
    /// Get comprehensive performance report
    public nonisolated func getPerformanceReport() async -> PerformanceReport {
        let memoryInfo = systemMetrics.getMemoryUsage()
        let cpuInfo = systemMetrics.getCPUUsage()
        let diskInfo = systemMetrics.getDiskUsage()
        let networkInfo = systemMetrics.getNetworkStats()
        let deviceInfo = systemMetrics.getDeviceInfo()
        
        let leakStats = memoryLeakDetector.getStatistics()
        let networkStats = networkProfiler.getStatistics()
        let threadHealth = threadAnalyzer.analyzeThreadHealth()
        let coreDataReport = coreDataProfiler.getPerformanceReport()
        let startupReport = startupAnalyzer.generateReport()
        
        // Calculate overall health
        let health = calculateHealthScore(
            memoryInfo: memoryInfo,
            cpuInfo: cpuInfo,
            threadHealth: threadHealth,
            networkStats: networkStats
        )
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            memoryInfo: memoryInfo,
            cpuInfo: cpuInfo,
            threadHealth: threadHealth,
            networkStats: networkStats,
            coreDataReport: coreDataReport
        )
        
        return PerformanceReport(
            timestamp: Date(),
            healthScore: health,
            memory: MemoryReport(
                usage: memoryInfo,
                footprint: systemMetrics.getMemoryFootprint(),
                pressure: systemMetrics.getMemoryPressure(),
                leakStats: leakStats
            ),
            cpu: CPUReport(
                usage: cpuInfo,
                threadHealth: threadHealth
            ),
            disk: DiskReport(
                usage: diskInfo
            ),
            network: NetworkReport(
                stats: networkStats,
                analysis: networkProfiler.getPerformanceAnalysis()
            ),
            coreData: coreDataReport,
            startup: startupReport,
            device: deviceInfo,
            recommendations: recommendations
        )
    }
    
    /// Get metrics history
    public func getMetricsHistory() -> [DashboardMetrics] {
        return metricsHistory
    }
    
    /// Clear alerts
    public func clearAlerts() {
        alerts.removeAll()
    }
    
    /// Clear history
    public func clearHistory() {
        metricsHistory.removeAll()
    }
    
    /// Export report as JSON
    public nonisolated func exportReport() async -> Data? {
        let report = await getPerformanceReport()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(report)
    }
    
    // MARK: - Private Methods
    
    private func updateMetrics() {
        let memoryInfo = systemMetrics.getMemoryUsage()
        let cpuInfo = systemMetrics.getCPUUsage()
        let diskInfo = systemMetrics.getDiskUsage()
        let networkInfo = systemMetrics.getNetworkStats()
        
        #if canImport(UIKit)
        let frameRateInfo = FrameRateMonitor.shared.getCurrentFrameRate()
        #else
        let frameRateInfo = FrameRateInfo()
        #endif
        
        let metrics = DashboardMetrics(
            timestamp: Date(),
            memoryUsage: memoryInfo.usagePercentage,
            memoryUsed: memoryInfo.residentSize,
            memoryTotal: memoryInfo.totalPhysicalMemory,
            cpuUsage: cpuInfo.processUsage,
            cpuSystemWide: cpuInfo.systemWideUsage,
            threadCount: cpuInfo.threadCount,
            activeThreads: cpuInfo.activeThreads,
            frameRate: frameRateInfo.currentFPS,
            droppedFrames: frameRateInfo.droppedFrames,
            diskUsage: diskInfo.usagePercentage,
            networkBytesReceived: networkInfo.bytesReceived,
            networkBytesSent: networkInfo.bytesSent
        )
        
        currentMetrics = metrics
        
        // Update health score
        let threadHealth = threadAnalyzer.analyzeThreadHealth()
        let networkStats = networkProfiler.getStatistics()
        healthScore = calculateHealthScore(
            memoryInfo: memoryInfo,
            cpuInfo: cpuInfo,
            threadHealth: threadHealth,
            networkStats: networkStats
        )
        onHealthScoreChanged?(healthScore)
        
        // Store history
        if config.enableHistory {
            metricsHistory.append(metrics)
            if metricsHistory.count > maxHistorySize {
                metricsHistory.removeFirst()
            }
        }
        
        // Check for alerts
        if config.enableAlerts {
            checkForAlerts(metrics)
        }
        
        // Notify callback
        onMetricsUpdate?(metrics)
        
        // Auto-optimization
        if config.enableAutoOptimization && healthScore < 50 {
            performAutoOptimization()
        }
    }
    
    private func checkForAlerts(_ metrics: DashboardMetrics) {
        // Memory alert
        if metrics.memoryUsage > config.memoryWarningThreshold {
            let alert = PerformanceAlert(
                type: .memoryWarning,
                message: "Memory usage is \(String(format: "%.0f", metrics.memoryUsage))%",
                severity: metrics.memoryUsage > 90 ? .critical : .warning,
                timestamp: Date()
            )
            addAlert(alert)
        }
        
        // CPU alert
        if metrics.cpuUsage > config.cpuWarningThreshold {
            let alert = PerformanceAlert(
                type: .cpuWarning,
                message: "CPU usage is \(String(format: "%.0f", metrics.cpuUsage))%",
                severity: metrics.cpuUsage > 90 ? .critical : .warning,
                timestamp: Date()
            )
            addAlert(alert)
        }
        
        // Frame rate alert
        if metrics.frameRate > 0 && metrics.frameRate < config.frameRateWarningThreshold {
            let alert = PerformanceAlert(
                type: .frameRateWarning,
                message: "Frame rate dropped to \(String(format: "%.0f", metrics.frameRate)) FPS",
                severity: metrics.frameRate < 30 ? .critical : .warning,
                timestamp: Date()
            )
            addAlert(alert)
        }
    }
    
    private func addAlert(_ alert: PerformanceAlert) {
        // Avoid duplicate alerts within 5 seconds
        let recentAlerts = alerts.filter {
            $0.type == alert.type &&
            Date().timeIntervalSince($0.timestamp) < 5
        }
        
        if recentAlerts.isEmpty {
            alerts.append(alert)
            onAlertTriggered?(alert)
            
            // Limit alerts
            if alerts.count > 100 {
                alerts.removeFirst()
            }
        }
    }
    
    private nonisolated func calculateHealthScore(
        memoryInfo: MemoryInfo,
        cpuInfo: CPUInfo,
        threadHealth: ThreadHealthReport,
        networkStats: NetworkStatistics
    ) -> Double {
        var score = 100.0
        
        // Memory impact (30% weight)
        let memoryScore = max(0, 100 - memoryInfo.usagePercentage)
        score -= (100 - memoryScore) * 0.3
        
        // CPU impact (30% weight)
        let cpuScore = max(0, 100 - cpuInfo.processUsage)
        score -= (100 - cpuScore) * 0.3
        
        // Thread health impact (20% weight)
        score -= (100 - threadHealth.healthScore) * 0.2
        
        // Network impact (20% weight)
        let networkScore = networkStats.successRate
        score -= (100 - networkScore) * 0.2
        
        return max(0, min(100, score))
    }
    
    private nonisolated func generateRecommendations(
        memoryInfo: MemoryInfo,
        cpuInfo: CPUInfo,
        threadHealth: ThreadHealthReport,
        networkStats: NetworkStatistics,
        coreDataReport: CoreDataPerformanceReport
    ) -> [PerformanceRecommendation] {
        var recommendations: [PerformanceRecommendation] = []
        
        // Memory recommendations
        if memoryInfo.usagePercentage > 70 {
            recommendations.append(PerformanceRecommendation(
                category: .memory,
                title: "Reduce memory usage",
                description: "Memory usage is at \(String(format: "%.0f", memoryInfo.usagePercentage))%. Consider clearing caches and optimizing image loading.",
                impact: .high,
                effort: .medium
            ))
        }
        
        // CPU recommendations
        if cpuInfo.processUsage > 50 {
            recommendations.append(PerformanceRecommendation(
                category: .cpu,
                title: "Optimize CPU-intensive operations",
                description: "CPU usage is \(String(format: "%.0f", cpuInfo.processUsage))%. Profile with Instruments to identify hot spots.",
                impact: .high,
                effort: .high
            ))
        }
        
        // Thread recommendations
        if threadHealth.threadCount > 32 {
            recommendations.append(PerformanceRecommendation(
                category: .threading,
                title: "Reduce thread count",
                description: "You have \(threadHealth.threadCount) threads. Use GCD or OperationQueue with limited concurrency.",
                impact: .medium,
                effort: .medium
            ))
        }
        
        // Network recommendations
        if networkStats.averageResponseTime > 2.0 {
            recommendations.append(PerformanceRecommendation(
                category: .network,
                title: "Optimize network requests",
                description: "Average response time is \(String(format: "%.1f", networkStats.averageResponseTime))s. Consider caching and request batching.",
                impact: .high,
                effort: .medium
            ))
        }
        
        // Core Data recommendations
        for recommendation in coreDataReport.recommendations {
            recommendations.append(PerformanceRecommendation(
                category: .coreData,
                title: recommendation.title,
                description: recommendation.description,
                impact: recommendation.impact,
                effort: .medium
            ))
        }
        
        return recommendations
    }
    
    private func performAutoOptimization() {
        // Clear image caches
        #if canImport(UIKit)
        URLCache.shared.removeAllCachedResponses()
        #endif
        
        // Trigger garbage collection hints
        autoreleasepool { }
    }
}

// MARK: - Data Types

public struct DashboardMetrics: Codable, Sendable {
    public let timestamp: Date
    public let memoryUsage: Double
    public let memoryUsed: UInt64
    public let memoryTotal: UInt64
    public let cpuUsage: Double
    public let cpuSystemWide: Double
    public let threadCount: Int
    public let activeThreads: Int
    public let frameRate: Double
    public let droppedFrames: Int
    public let diskUsage: Double
    public let networkBytesReceived: UInt64
    public let networkBytesSent: UInt64
    
    public init(
        timestamp: Date = Date(),
        memoryUsage: Double = 0,
        memoryUsed: UInt64 = 0,
        memoryTotal: UInt64 = 0,
        cpuUsage: Double = 0,
        cpuSystemWide: Double = 0,
        threadCount: Int = 0,
        activeThreads: Int = 0,
        frameRate: Double = 0,
        droppedFrames: Int = 0,
        diskUsage: Double = 0,
        networkBytesReceived: UInt64 = 0,
        networkBytesSent: UInt64 = 0
    ) {
        self.timestamp = timestamp
        self.memoryUsage = memoryUsage
        self.memoryUsed = memoryUsed
        self.memoryTotal = memoryTotal
        self.cpuUsage = cpuUsage
        self.cpuSystemWide = cpuSystemWide
        self.threadCount = threadCount
        self.activeThreads = activeThreads
        self.frameRate = frameRate
        self.droppedFrames = droppedFrames
        self.diskUsage = diskUsage
        self.networkBytesReceived = networkBytesReceived
        self.networkBytesSent = networkBytesSent
    }
}

public struct PerformanceAlert: Codable, Sendable, Identifiable {
    public let id = UUID()
    public let type: AlertType
    public let message: String
    public let severity: AlertSeverity
    public let timestamp: Date
}

public enum AlertType: String, Codable, Sendable {
    case memoryWarning = "Memory Warning"
    case cpuWarning = "CPU Warning"
    case frameRateWarning = "Frame Rate Warning"
    case networkWarning = "Network Warning"
    case diskWarning = "Disk Warning"
    case threadWarning = "Thread Warning"
}

public enum AlertSeverity: String, Codable, Sendable {
    case info = "Info"
    case warning = "Warning"
    case critical = "Critical"
    
    public var emoji: String {
        switch self {
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .critical: return "🔴"
        }
    }
}

public struct PerformanceReport: Codable, Sendable {
    public let timestamp: Date
    public let healthScore: Double
    public let memory: MemoryReport
    public let cpu: CPUReport
    public let disk: DiskReport
    public let network: NetworkReport
    public let coreData: CoreDataPerformanceReport
    public let startup: StartupReport
    public let device: DeviceInfo
    public let recommendations: [PerformanceRecommendation]
    
    public var grade: String {
        switch healthScore {
        case 90...: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}

public struct MemoryReport: Codable, Sendable {
    public let usage: MemoryInfo
    public let footprint: UInt64
    public let pressure: MemoryPressureLevel
    public let leakStats: LeakDetectorStatistics
}

public struct CPUReport: Codable, Sendable {
    public let usage: CPUInfo
    public let threadHealth: ThreadHealthReport
}

public struct DiskReport: Codable, Sendable {
    public let usage: DiskInfo
}

public struct NetworkReport: Codable, Sendable {
    public let stats: NetworkStatistics
    public let analysis: NetworkPerformanceAnalysis
}

public struct PerformanceRecommendation: Codable, Sendable {
    public let category: RecommendationCategory
    public let title: String
    public let description: String
    public let impact: ImpactLevel
    public let effort: EffortLevel
}

public enum RecommendationCategory: String, Codable, Sendable {
    case memory = "Memory"
    case cpu = "CPU"
    case threading = "Threading"
    case network = "Network"
    case coreData = "Core Data"
    case startup = "Startup"
    case general = "General"
}

public enum EffortLevel: String, Codable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

// Add missing FrameRateInfo for non-UIKit platforms
#if !canImport(UIKit)
public struct FrameRateInfo: Codable, Sendable {
    public let currentFPS: Double = 0
    public let droppedFrames: Int = 0
    
    public init() {}
}
#endif
