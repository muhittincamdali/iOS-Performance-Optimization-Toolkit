//
//  FrameRateMonitor.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import QuartzCore

/// Real-time frame rate monitoring using CADisplayLink
@MainActor
public final class FrameRateMonitor {
    
    // MARK: - Singleton
    public static let shared = FrameRateMonitor()
    
    // MARK: - Properties
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    private var frameTimes: [CFTimeInterval] = []
    private let maxSamples = 120
    
    private var isMonitoring = false
    private var config = Configuration()
    
    // Historical data for analytics
    private var frameHistory: [FrameSample] = []
    private let maxHistorySize = 3600 // 1 hour at 1 sample/second
    
    // Callbacks
    public var onFrameRateUpdate: ((FrameRateInfo) -> Void)?
    public var onFrameDrop: ((FrameDropInfo) -> Void)?
    public var onHitchDetected: ((HitchInfo) -> Void)?
    
    // MARK: - Configuration
    public struct Configuration {
        public var targetFrameRate: Int = 60
        public var dropThreshold: Double = 0.5 // 50% of target
        public var hitchThresholdMs: Double = 16.67 // 1 frame at 60fps
        public var sampleInterval: TimeInterval = 1.0
        public var enableHitchDetection: Bool = true
        public var enableDetailedLogging: Bool = false
        
        public init(
            targetFrameRate: Int = 60,
            dropThreshold: Double = 0.5,
            hitchThresholdMs: Double = 16.67,
            sampleInterval: TimeInterval = 1.0,
            enableHitchDetection: Bool = true,
            enableDetailedLogging: Bool = false
        ) {
            self.targetFrameRate = targetFrameRate
            self.dropThreshold = dropThreshold
            self.hitchThresholdMs = hitchThresholdMs
            self.sampleInterval = sampleInterval
            self.enableHitchDetection = enableHitchDetection
            self.enableDetailedLogging = enableDetailedLogging
        }
    }
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Configure the frame rate monitor
    public func configure(_ configuration: Configuration) {
        self.config = configuration
    }
    
    /// Start frame rate monitoring
    public func startMonitoring() {
        guard !isMonitoring else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        displayLink?.add(to: .main, forMode: .common)
        
        if #available(iOS 15.0, *) {
            displayLink?.preferredFrameRateRange = CAFrameRateRange(
                minimum: 30,
                maximum: Float(config.targetFrameRate),
                preferred: Float(config.targetFrameRate)
            )
        }
        
        isMonitoring = true
        lastTimestamp = 0
        frameCount = 0
        frameTimes.removeAll()
    }
    
    /// Stop frame rate monitoring
    public func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
        isMonitoring = false
    }
    
    /// Get current frame rate info
    public nonisolated func getCurrentFrameRate() -> FrameRateInfo {
        return FrameRateInfo(
            currentFPS: calculateCurrentFPS(),
            averageFPS: calculateAverageFPS(),
            minFPS: calculateMinFPS(),
            maxFPS: calculateMaxFPS(),
            droppedFrames: calculateDroppedFrames(),
            totalFrames: frameCount,
            jankScore: calculateJankScore(),
            timestamp: Date()
        )
    }
    
    /// Get frame rate analytics
    public nonisolated func getAnalytics() -> FrameRateAnalytics {
        guard !frameHistory.isEmpty else {
            return FrameRateAnalytics()
        }
        
        let fpsList = frameHistory.map { $0.fps }
        let avgFPS = fpsList.reduce(0, +) / Double(fpsList.count)
        let sortedFPS = fpsList.sorted()
        
        return FrameRateAnalytics(
            averageFPS: avgFPS,
            minFPS: sortedFPS.first ?? 0,
            maxFPS: sortedFPS.last ?? 0,
            percentile95: sortedFPS[Int(Double(sortedFPS.count) * 0.95)] ,
            percentile99: sortedFPS[Int(Double(sortedFPS.count) * 0.99)],
            totalDroppedFrames: frameHistory.reduce(0) { $0 + $1.droppedFrames },
            totalHitches: frameHistory.filter { $0.hasHitch }.count,
            jankPercentage: calculateJankPercentage(),
            smoothnessScore: calculateSmoothnessScore(),
            sampleCount: frameHistory.count
        )
    }
    
    /// Get frame time histogram
    public nonisolated func getFrameTimeHistogram() -> [FrameTimeBucket] {
        var buckets: [String: Int] = [
            "0-8ms": 0,
            "8-16ms": 0,
            "16-33ms": 0,
            "33-50ms": 0,
            "50-100ms": 0,
            "100ms+": 0
        ]
        
        for frameTime in frameTimes {
            let ms = frameTime * 1000
            switch ms {
            case 0..<8:
                buckets["0-8ms", default: 0] += 1
            case 8..<16:
                buckets["8-16ms", default: 0] += 1
            case 16..<33:
                buckets["16-33ms", default: 0] += 1
            case 33..<50:
                buckets["33-50ms", default: 0] += 1
            case 50..<100:
                buckets["50-100ms", default: 0] += 1
            default:
                buckets["100ms+", default: 0] += 1
            }
        }
        
        return buckets.map { FrameTimeBucket(range: $0.key, count: $0.value) }
            .sorted { $0.range < $1.range }
    }
    
    /// Reset all collected data
    public func reset() {
        frameCount = 0
        frameTimes.removeAll()
        frameHistory.removeAll()
        lastTimestamp = 0
    }
    
    // MARK: - Private Methods
    
    @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
        let currentTimestamp = displayLink.timestamp
        
        if lastTimestamp > 0 {
            let frameTime = currentTimestamp - lastTimestamp
            frameTimes.append(frameTime)
            
            // Keep only recent samples
            if frameTimes.count > maxSamples {
                frameTimes.removeFirst()
            }
            
            frameCount += 1
            
            // Check for hitches
            if config.enableHitchDetection {
                let frameTimeMs = frameTime * 1000
                if frameTimeMs > config.hitchThresholdMs {
                    let hitchInfo = HitchInfo(
                        duration: frameTimeMs,
                        expectedDuration: 1000.0 / Double(config.targetFrameRate),
                        severity: calculateHitchSeverity(frameTimeMs),
                        timestamp: Date()
                    )
                    onHitchDetected?(hitchInfo)
                }
            }
            
            // Update callback
            if frameCount % Int(config.sampleInterval * Double(config.targetFrameRate)) == 0 {
                let info = getCurrentFrameRate()
                onFrameRateUpdate?(info)
                
                // Record sample
                let sample = FrameSample(
                    fps: info.currentFPS,
                    droppedFrames: info.droppedFrames,
                    hasHitch: frameTime * 1000 > config.hitchThresholdMs,
                    timestamp: Date()
                )
                frameHistory.append(sample)
                
                if frameHistory.count > maxHistorySize {
                    frameHistory.removeFirst()
                }
                
                // Check for frame drops
                if info.currentFPS < Double(config.targetFrameRate) * config.dropThreshold {
                    let dropInfo = FrameDropInfo(
                        currentFPS: info.currentFPS,
                        expectedFPS: Double(config.targetFrameRate),
                        dropPercentage: (1.0 - info.currentFPS / Double(config.targetFrameRate)) * 100,
                        timestamp: Date()
                    )
                    onFrameDrop?(dropInfo)
                }
            }
        }
        
        lastTimestamp = currentTimestamp
    }
    
    private nonisolated func calculateCurrentFPS() -> Double {
        guard frameTimes.count > 0 else { return 0 }
        let recentFrames = Array(frameTimes.suffix(10))
        let avgFrameTime = recentFrames.reduce(0, +) / Double(recentFrames.count)
        return avgFrameTime > 0 ? 1.0 / avgFrameTime : 0
    }
    
    private nonisolated func calculateAverageFPS() -> Double {
        guard frameTimes.count > 0 else { return 0 }
        let avgFrameTime = frameTimes.reduce(0, +) / Double(frameTimes.count)
        return avgFrameTime > 0 ? 1.0 / avgFrameTime : 0
    }
    
    private nonisolated func calculateMinFPS() -> Double {
        guard let maxFrameTime = frameTimes.max(), maxFrameTime > 0 else { return 0 }
        return 1.0 / maxFrameTime
    }
    
    private nonisolated func calculateMaxFPS() -> Double {
        guard let minFrameTime = frameTimes.min(), minFrameTime > 0 else { return 0 }
        return 1.0 / minFrameTime
    }
    
    private nonisolated func calculateDroppedFrames() -> Int {
        let targetFrameTime = 1.0 / Double(config.targetFrameRate)
        return frameTimes.filter { $0 > targetFrameTime * 1.5 }.count
    }
    
    private nonisolated func calculateJankScore() -> Double {
        guard frameTimes.count > 1 else { return 0 }
        
        // Calculate variance in frame times
        let mean = frameTimes.reduce(0, +) / Double(frameTimes.count)
        let variance = frameTimes.map { pow($0 - mean, 2) }.reduce(0, +) / Double(frameTimes.count)
        let stdDev = sqrt(variance)
        
        // Normalize to 0-100 (lower is better)
        let normalizedStdDev = min(stdDev * 1000 / 16.67, 1.0) * 100
        return 100 - normalizedStdDev
    }
    
    private nonisolated func calculateJankPercentage() -> Double {
        guard !frameTimes.isEmpty else { return 0 }
        let jankFrames = frameTimes.filter { $0 * 1000 > 16.67 }.count
        return Double(jankFrames) / Double(frameTimes.count) * 100
    }
    
    private nonisolated func calculateSmoothnessScore() -> Double {
        let analytics = getAnalytics()
        let fpsScore = min(analytics.averageFPS / Double(config.targetFrameRate), 1.0) * 50
        let jankScore = max(0, 50 - analytics.jankPercentage)
        return fpsScore + jankScore
    }
    
    private func calculateHitchSeverity(_ durationMs: Double) -> HitchSeverity {
        switch durationMs {
        case 0..<33:
            return .minor
        case 33..<100:
            return .moderate
        case 100..<250:
            return .major
        default:
            return .severe
        }
    }
}

// MARK: - Data Types

public struct FrameRateInfo: Codable, Sendable {
    public let currentFPS: Double
    public let averageFPS: Double
    public let minFPS: Double
    public let maxFPS: Double
    public let droppedFrames: Int
    public let totalFrames: Int
    public let jankScore: Double
    public let timestamp: Date
    
    public init(
        currentFPS: Double = 0,
        averageFPS: Double = 0,
        minFPS: Double = 0,
        maxFPS: Double = 0,
        droppedFrames: Int = 0,
        totalFrames: Int = 0,
        jankScore: Double = 0,
        timestamp: Date = Date()
    ) {
        self.currentFPS = currentFPS
        self.averageFPS = averageFPS
        self.minFPS = minFPS
        self.maxFPS = maxFPS
        self.droppedFrames = droppedFrames
        self.totalFrames = totalFrames
        self.jankScore = jankScore
        self.timestamp = timestamp
    }
    
    /// Performance grade based on FPS
    public var grade: PerformanceGrade {
        switch currentFPS {
        case 55...: return .excellent
        case 45..<55: return .good
        case 30..<45: return .fair
        case 20..<30: return .poor
        default: return .critical
        }
    }
}

public struct FrameRateAnalytics: Codable, Sendable {
    public let averageFPS: Double
    public let minFPS: Double
    public let maxFPS: Double
    public let percentile95: Double
    public let percentile99: Double
    public let totalDroppedFrames: Int
    public let totalHitches: Int
    public let jankPercentage: Double
    public let smoothnessScore: Double
    public let sampleCount: Int
    
    public init(
        averageFPS: Double = 0,
        minFPS: Double = 0,
        maxFPS: Double = 0,
        percentile95: Double = 0,
        percentile99: Double = 0,
        totalDroppedFrames: Int = 0,
        totalHitches: Int = 0,
        jankPercentage: Double = 0,
        smoothnessScore: Double = 0,
        sampleCount: Int = 0
    ) {
        self.averageFPS = averageFPS
        self.minFPS = minFPS
        self.maxFPS = maxFPS
        self.percentile95 = percentile95
        self.percentile99 = percentile99
        self.totalDroppedFrames = totalDroppedFrames
        self.totalHitches = totalHitches
        self.jankPercentage = jankPercentage
        self.smoothnessScore = smoothnessScore
        self.sampleCount = sampleCount
    }
}

public struct FrameDropInfo: Codable, Sendable {
    public let currentFPS: Double
    public let expectedFPS: Double
    public let dropPercentage: Double
    public let timestamp: Date
}

public struct HitchInfo: Codable, Sendable {
    public let duration: Double // milliseconds
    public let expectedDuration: Double
    public let severity: HitchSeverity
    public let timestamp: Date
}

public enum HitchSeverity: String, Codable, Sendable {
    case minor = "Minor"
    case moderate = "Moderate"
    case major = "Major"
    case severe = "Severe"
}

public struct FrameSample: Codable, Sendable {
    public let fps: Double
    public let droppedFrames: Int
    public let hasHitch: Bool
    public let timestamp: Date
}

public struct FrameTimeBucket: Codable, Sendable {
    public let range: String
    public let count: Int
}

public enum PerformanceGrade: String, Codable, Sendable {
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
#endif
