//
//  StartupTimeAnalyzer.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Comprehensive app startup time analysis and optimization recommendations
public final class StartupTimeAnalyzer {
    
    // MARK: - Singleton
    public static let shared = StartupTimeAnalyzer()
    
    // MARK: - Properties
    private var processStartTime: CFAbsoluteTime = 0
    private var mainFunctionTime: CFAbsoluteTime = 0
    private var didFinishLaunchingTime: CFAbsoluteTime = 0
    private var firstFrameTime: CFAbsoluteTime = 0
    private var interactiveTime: CFAbsoluteTime = 0
    
    private var phases: [StartupPhase] = []
    private var customMilestones: [Milestone] = []
    private var isTracking = false
    
    // Thresholds (in seconds)
    private var config = Configuration()
    
    // Callbacks
    public var onPhaseCompleted: ((StartupPhase) -> Void)?
    public var onStartupCompleted: ((StartupReport) -> Void)?
    
    // MARK: - Configuration
    public struct Configuration {
        public var coldStartThreshold: TimeInterval = 2.0
        public var warmStartThreshold: TimeInterval = 0.5
        public var preLaunchThreshold: TimeInterval = 0.4
        public var launchThreshold: TimeInterval = 0.8
        public var postLaunchThreshold: TimeInterval = 0.8
        public var enableDetailedProfiling: Bool = true
        public var trackDyldPhases: Bool = true
        
        public init() {}
    }
    
    // MARK: - Initialization
    private init() {
        captureProcessStartTime()
    }
    
    // MARK: - Public Methods
    
    /// Configure the startup analyzer
    public func configure(_ configuration: Configuration) {
        self.config = configuration
    }
    
    /// Call this as early as possible in main()
    public func markMainFunction() {
        mainFunctionTime = CFAbsoluteTimeGetCurrent()
        recordPhase(.preMain, startTime: processStartTime, endTime: mainFunctionTime)
    }
    
    /// Call this in application(_:didFinishLaunchingWithOptions:)
    public func markDidFinishLaunching() {
        didFinishLaunchingTime = CFAbsoluteTimeGetCurrent()
        
        if mainFunctionTime > 0 {
            recordPhase(.mainToDidFinishLaunching, startTime: mainFunctionTime, endTime: didFinishLaunchingTime)
        }
    }
    
    /// Call this when the first UI frame is rendered
    public func markFirstFrame() {
        firstFrameTime = CFAbsoluteTimeGetCurrent()
        
        if didFinishLaunchingTime > 0 {
            recordPhase(.didFinishLaunchingToFirstFrame, startTime: didFinishLaunchingTime, endTime: firstFrameTime)
        }
    }
    
    /// Call this when the app becomes interactive (all async loading done)
    public func markInteractive() {
        interactiveTime = CFAbsoluteTimeGetCurrent()
        
        if firstFrameTime > 0 {
            recordPhase(.firstFrameToInteractive, startTime: firstFrameTime, endTime: interactiveTime)
        }
        
        // Generate startup report
        let report = generateReport()
        onStartupCompleted?(report)
    }
    
    /// Add a custom milestone during startup
    public func addMilestone(_ name: String, details: String? = nil) {
        let milestone = Milestone(
            name: name,
            time: CFAbsoluteTimeGetCurrent(),
            details: details,
            threadName: Thread.current.name ?? "Unknown"
        )
        customMilestones.append(milestone)
    }
    
    /// Measure a specific operation during startup
    public func measure<T>(_ name: String, operation: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try operation()
        let end = CFAbsoluteTimeGetCurrent()
        
        let milestone = Milestone(
            name: name,
            time: end,
            details: "Duration: \(String(format: "%.2f", (end - start) * 1000))ms",
            threadName: Thread.current.name ?? "Unknown",
            duration: end - start
        )
        customMilestones.append(milestone)
        
        return result
    }
    
    /// Async version of measure
    public func measureAsync<T>(_ name: String, operation: () async throws -> T) async rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let end = CFAbsoluteTimeGetCurrent()
        
        let milestone = Milestone(
            name: name,
            time: end,
            details: "Duration: \(String(format: "%.2f", (end - start) * 1000))ms",
            threadName: Thread.current.name ?? "Unknown",
            duration: end - start
        )
        customMilestones.append(milestone)
        
        return result
    }
    
    /// Generate a startup performance report
    public func generateReport() -> StartupReport {
        let totalTime = (interactiveTime > 0 ? interactiveTime : CFAbsoluteTimeGetCurrent()) - processStartTime
        
        // Calculate phase times
        let preMainTime = mainFunctionTime > 0 ? mainFunctionTime - processStartTime : 0
        let mainToLaunchTime = didFinishLaunchingTime > 0 && mainFunctionTime > 0 ? didFinishLaunchingTime - mainFunctionTime : 0
        let launchToFirstFrameTime = firstFrameTime > 0 && didFinishLaunchingTime > 0 ? firstFrameTime - didFinishLaunchingTime : 0
        let firstFrameToInteractiveTime = interactiveTime > 0 && firstFrameTime > 0 ? interactiveTime - firstFrameTime : 0
        
        // Determine startup type
        let startupType: StartupType = totalTime < config.warmStartThreshold ? .warm : .cold
        
        // Calculate grade
        let grade = calculateGrade(totalTime: totalTime, startupType: startupType)
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            preMainTime: preMainTime,
            mainToLaunchTime: mainToLaunchTime,
            launchToFirstFrameTime: launchToFirstFrameTime,
            firstFrameToInteractiveTime: firstFrameToInteractiveTime
        )
        
        // Get dyld info if available
        let dyldInfo = getDyldInfo()
        
        return StartupReport(
            totalTime: totalTime,
            preMainTime: preMainTime,
            mainToDidFinishLaunchingTime: mainToLaunchTime,
            didFinishLaunchingToFirstFrameTime: launchToFirstFrameTime,
            firstFrameToInteractiveTime: firstFrameToInteractiveTime,
            startupType: startupType,
            grade: grade,
            phases: phases,
            milestones: customMilestones,
            recommendations: recommendations,
            dyldInfo: dyldInfo,
            timestamp: Date()
        )
    }
    
    /// Get current startup timing
    public func getCurrentTiming() -> StartupTiming {
        let now = CFAbsoluteTimeGetCurrent()
        
        return StartupTiming(
            processStart: processStartTime,
            mainFunction: mainFunctionTime,
            didFinishLaunching: didFinishLaunchingTime,
            firstFrame: firstFrameTime,
            interactive: interactiveTime,
            current: now,
            elapsedSinceProcessStart: now - processStartTime
        )
    }
    
    /// Reset all tracking data
    public func reset() {
        processStartTime = 0
        mainFunctionTime = 0
        didFinishLaunchingTime = 0
        firstFrameTime = 0
        interactiveTime = 0
        phases.removeAll()
        customMilestones.removeAll()
        captureProcessStartTime()
    }
    
    // MARK: - Private Methods
    
    private func captureProcessStartTime() {
        // Get process start time from kernel
        var kinfo = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        
        sysctl(&mib, u_int(mib.count), &kinfo, &size, nil, 0)
        
        let startTime = kinfo.kp_proc.p_starttime
        let processStartTimeInterval = TimeInterval(startTime.tv_sec) + TimeInterval(startTime.tv_usec) / 1_000_000
        
        // Convert to CFAbsoluteTime
        // Note: CFAbsoluteTime uses a different epoch (Jan 1, 2001)
        // Unix time uses Jan 1, 1970
        let unixEpochToCFEpoch: TimeInterval = 978307200 // Seconds between 1970 and 2001
        processStartTime = processStartTimeInterval - unixEpochToCFEpoch
    }
    
    private func recordPhase(_ type: StartupPhaseType, startTime: CFAbsoluteTime, endTime: CFAbsoluteTime) {
        let duration = endTime - startTime
        let phase = StartupPhase(
            type: type,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            isOverThreshold: isPhaseOverThreshold(type, duration: duration)
        )
        
        phases.append(phase)
        onPhaseCompleted?(phase)
    }
    
    private func isPhaseOverThreshold(_ type: StartupPhaseType, duration: TimeInterval) -> Bool {
        switch type {
        case .preMain:
            return duration > config.preLaunchThreshold
        case .mainToDidFinishLaunching:
            return duration > config.launchThreshold
        case .didFinishLaunchingToFirstFrame:
            return duration > config.postLaunchThreshold
        case .firstFrameToInteractive:
            return duration > config.postLaunchThreshold
        case .custom:
            return false
        }
    }
    
    private func calculateGrade(totalTime: TimeInterval, startupType: StartupType) -> StartupGrade {
        let threshold = startupType == .warm ? config.warmStartThreshold : config.coldStartThreshold
        let ratio = totalTime / threshold
        
        switch ratio {
        case 0..<0.5:
            return .excellent
        case 0.5..<0.75:
            return .good
        case 0.75..<1.0:
            return .fair
        case 1.0..<1.5:
            return .poor
        default:
            return .critical
        }
    }
    
    private func generateRecommendations(
        preMainTime: TimeInterval,
        mainToLaunchTime: TimeInterval,
        launchToFirstFrameTime: TimeInterval,
        firstFrameToInteractiveTime: TimeInterval
    ) -> [StartupRecommendation] {
        var recommendations: [StartupRecommendation] = []
        
        // Pre-main recommendations
        if preMainTime > config.preLaunchThreshold {
            recommendations.append(StartupRecommendation(
                category: .preMain,
                title: "Reduce pre-main time",
                description: "Pre-main time is \(String(format: "%.0f", preMainTime * 1000))ms. Consider reducing dylib dependencies, removing unused frameworks, and optimizing static initializers.",
                impact: .high,
                estimatedSavings: "Up to \(String(format: "%.0f", preMainTime * 500))ms"
            ))
            
            recommendations.append(StartupRecommendation(
                category: .preMain,
                title: "Review +load methods",
                description: "Move +load method work to +initialize or later in the app lifecycle.",
                impact: .medium,
                estimatedSavings: "Varies"
            ))
        }
        
        // Main to launch recommendations
        if mainToLaunchTime > config.launchThreshold {
            recommendations.append(StartupRecommendation(
                category: .launch,
                title: "Optimize didFinishLaunching",
                description: "Launch phase is \(String(format: "%.0f", mainToLaunchTime * 1000))ms. Defer non-critical initialization.",
                impact: .high,
                estimatedSavings: "Up to \(String(format: "%.0f", mainToLaunchTime * 300))ms"
            ))
            
            recommendations.append(StartupRecommendation(
                category: .launch,
                title: "Use lazy loading",
                description: "Initialize services and managers lazily instead of at launch.",
                impact: .medium,
                estimatedSavings: "50-200ms"
            ))
        }
        
        // First frame recommendations
        if launchToFirstFrameTime > config.postLaunchThreshold {
            recommendations.append(StartupRecommendation(
                category: .postLaunch,
                title: "Optimize initial view hierarchy",
                description: "First frame rendering is slow. Simplify initial view hierarchy and reduce Auto Layout complexity.",
                impact: .high,
                estimatedSavings: "Up to \(String(format: "%.0f", launchToFirstFrameTime * 400))ms"
            ))
        }
        
        // Interactive recommendations
        if firstFrameToInteractiveTime > config.postLaunchThreshold {
            recommendations.append(StartupRecommendation(
                category: .postLaunch,
                title: "Defer background work",
                description: "Move async initialization to after first frame. Use DispatchQueue.main.async for non-critical setup.",
                impact: .medium,
                estimatedSavings: "100-500ms"
            ))
        }
        
        // General recommendations
        recommendations.append(StartupRecommendation(
            category: .general,
            title: "Enable App Launch Profiling",
            description: "Use Instruments 'App Launch' template for detailed profiling.",
            impact: .low,
            estimatedSavings: "N/A"
        ))
        
        return recommendations
    }
    
    private func getDyldInfo() -> DyldInfo? {
        // Get dyld statistics if available
        var count: UInt32 = _dyld_image_count()
        var frameworks: [String] = []
        
        for i in 0..<count {
            if let name = _dyld_get_image_name(i) {
                frameworks.append(String(cString: name))
            }
        }
        
        return DyldInfo(
            imageCount: Int(count),
            frameworks: frameworks,
            systemFrameworks: frameworks.filter { $0.contains("/System/") }.count,
            appFrameworks: frameworks.filter { !$0.contains("/System/") }.count
        )
    }
}

// MARK: - Data Types

public struct StartupReport: Codable, Sendable {
    public let totalTime: TimeInterval
    public let preMainTime: TimeInterval
    public let mainToDidFinishLaunchingTime: TimeInterval
    public let didFinishLaunchingToFirstFrameTime: TimeInterval
    public let firstFrameToInteractiveTime: TimeInterval
    public let startupType: StartupType
    public let grade: StartupGrade
    public let phases: [StartupPhase]
    public let milestones: [Milestone]
    public let recommendations: [StartupRecommendation]
    public let dyldInfo: DyldInfo?
    public let timestamp: Date
    
    public var formattedTotalTime: String {
        String(format: "%.0f ms", totalTime * 1000)
    }
    
    public var summary: String {
        """
        Startup Report
        ==============
        Total Time: \(formattedTotalTime)
        Type: \(startupType.rawValue)
        Grade: \(grade.rawValue) \(grade.emoji)
        
        Breakdown:
        - Pre-main: \(String(format: "%.0f", preMainTime * 1000))ms
        - Main → didFinishLaunching: \(String(format: "%.0f", mainToDidFinishLaunchingTime * 1000))ms
        - didFinishLaunching → First Frame: \(String(format: "%.0f", didFinishLaunchingToFirstFrameTime * 1000))ms
        - First Frame → Interactive: \(String(format: "%.0f", firstFrameToInteractiveTime * 1000))ms
        """
    }
}

public struct StartupPhase: Codable, Sendable {
    public let type: StartupPhaseType
    public let startTime: CFAbsoluteTime
    public let endTime: CFAbsoluteTime
    public let duration: TimeInterval
    public let isOverThreshold: Bool
    
    public var formattedDuration: String {
        String(format: "%.0f ms", duration * 1000)
    }
}

public enum StartupPhaseType: String, Codable, Sendable {
    case preMain = "Pre-main"
    case mainToDidFinishLaunching = "Main → didFinishLaunching"
    case didFinishLaunchingToFirstFrame = "didFinishLaunching → First Frame"
    case firstFrameToInteractive = "First Frame → Interactive"
    case custom = "Custom"
}

public struct Milestone: Codable, Sendable {
    public let name: String
    public let time: CFAbsoluteTime
    public let details: String?
    public let threadName: String
    public var duration: TimeInterval?
    
    public init(name: String, time: CFAbsoluteTime, details: String?, threadName: String, duration: TimeInterval? = nil) {
        self.name = name
        self.time = time
        self.details = details
        self.threadName = threadName
        self.duration = duration
    }
}

public enum StartupType: String, Codable, Sendable {
    case cold = "Cold Start"
    case warm = "Warm Start"
}

public enum StartupGrade: String, Codable, Sendable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case critical = "Critical"
    
    public var emoji: String {
        switch self {
        case .excellent: return "🟢"
        case .good: return "🔵"
        case .fair: return "🟡"
        case .poor: return "🟠"
        case .critical: return "🔴"
        }
    }
}

public struct StartupRecommendation: Codable, Sendable {
    public let category: RecommendationCategory
    public let title: String
    public let description: String
    public let impact: ImpactLevel
    public let estimatedSavings: String
}

public enum RecommendationCategory: String, Codable, Sendable {
    case preMain = "Pre-main"
    case launch = "Launch"
    case postLaunch = "Post-launch"
    case general = "General"
}

public enum ImpactLevel: String, Codable, Sendable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

public struct StartupTiming: Codable, Sendable {
    public let processStart: CFAbsoluteTime
    public let mainFunction: CFAbsoluteTime
    public let didFinishLaunching: CFAbsoluteTime
    public let firstFrame: CFAbsoluteTime
    public let interactive: CFAbsoluteTime
    public let current: CFAbsoluteTime
    public let elapsedSinceProcessStart: TimeInterval
}

public struct DyldInfo: Codable, Sendable {
    public let imageCount: Int
    public let frameworks: [String]
    public let systemFrameworks: Int
    public let appFrameworks: Int
}
