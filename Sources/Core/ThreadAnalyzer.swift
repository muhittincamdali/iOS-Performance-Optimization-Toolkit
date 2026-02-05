//
//  ThreadAnalyzer.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import Foundation
import Darwin

/// Advanced thread analysis and deadlock detection
public final class ThreadAnalyzer {
    
    // MARK: - Singleton
    public static let shared = ThreadAnalyzer()
    
    // MARK: - Properties
    private let analyzerQueue = DispatchQueue(label: "com.performancekit.threadanalyzer", qos: .utility)
    private var isMonitoring = false
    private var config = Configuration()
    private var threadSnapshots: [ThreadSnapshot] = []
    private var mainThreadBlockEvents: [MainThreadBlockEvent] = []
    
    // Callbacks
    public var onMainThreadBlocked: ((MainThreadBlockEvent) -> Void)?
    public var onDeadlockDetected: ((DeadlockInfo) -> Void)?
    public var onThreadOverload: ((ThreadOverloadInfo) -> Void)?
    
    // MARK: - Configuration
    public struct Configuration {
        public var mainThreadBlockThresholdMs: Double = 16.67 // 1 frame at 60fps
        public var monitoringInterval: TimeInterval = 0.5
        public var maxThreadCount: Int = 64
        public var enableDeadlockDetection: Bool = true
        public var maxStoredSnapshots: Int = 1000
        public var mainThreadWatchdogEnabled: Bool = true
        
        public init() {}
    }
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Configure the thread analyzer
    public func configure(_ configuration: Configuration) {
        self.config = configuration
    }
    
    /// Start monitoring threads
    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        startPeriodicMonitoring()
        
        if config.mainThreadWatchdogEnabled {
            startMainThreadWatchdog()
        }
    }
    
    /// Stop monitoring threads
    public func stopMonitoring() {
        isMonitoring = false
    }
    
    /// Get current thread information
    public func getCurrentThreadInfo() -> [ThreadInfo] {
        var threads: [ThreadInfo] = []
        
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t()
        
        let result = task_threads(mach_task_self_, &threadList, &threadCount)
        guard result == KERN_SUCCESS, let threadArray = threadList else {
            return threads
        }
        
        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threadArray), vm_size_t(Int(threadCount) * MemoryLayout<thread_act_t>.stride))
        }
        
        for i in 0..<Int(threadCount) {
            let thread = threadArray[i]
            
            // Get basic info
            var basicInfo = thread_basic_info()
            var basicInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            
            let basicResult = withUnsafeMutablePointer(to: &basicInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(thread, thread_flavor_t(THREAD_BASIC_INFO), $0, &basicInfoCount)
                }
            }
            
            guard basicResult == KERN_SUCCESS else { continue }
            
            // Get identifier info
            var identifierInfo = thread_identifier_info()
            var identifierInfoCount = mach_msg_type_number_t(THREAD_IDENTIFIER_INFO_COUNT)
            
            let identifierResult = withUnsafeMutablePointer(to: &identifierInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(thread, thread_flavor_t(THREAD_IDENTIFIER_INFO), $0, &identifierInfoCount)
                }
            }
            
            let threadId: UInt64
            let dispatchQueueAddress: UInt64
            
            if identifierResult == KERN_SUCCESS {
                threadId = identifierInfo.thread_id
                dispatchQueueAddress = identifierInfo.dispatch_qaddr
            } else {
                threadId = UInt64(thread)
                dispatchQueueAddress = 0
            }
            
            // Calculate CPU usage
            let cpuUsage = Double(basicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100
            
            // Get user and system time
            let userTime = Double(basicInfo.user_time.seconds) + Double(basicInfo.user_time.microseconds) / 1_000_000
            let systemTime = Double(basicInfo.system_time.seconds) + Double(basicInfo.system_time.microseconds) / 1_000_000
            
            // Determine state
            let state = ThreadRunState(rawValue: Int(basicInfo.run_state)) ?? .unknown
            
            // Check if main thread
            let isMainThread = pthread_main_np() != 0 && i == 0
            
            let info = ThreadInfo(
                threadId: threadId,
                port: thread,
                cpuUsage: cpuUsage,
                userTime: userTime,
                systemTime: systemTime,
                state: state,
                flags: Int(basicInfo.flags),
                priority: Int(basicInfo.policy),
                isMainThread: isMainThread,
                dispatchQueueAddress: dispatchQueueAddress,
                stackTrace: getStackTrace(for: thread)
            )
            
            threads.append(info)
        }
        
        return threads
    }
    
    /// Analyze thread health
    public func analyzeThreadHealth() -> ThreadHealthReport {
        let threads = getCurrentThreadInfo()
        var issues: [ThreadIssue] = []
        var recommendations: [ThreadRecommendation] = []
        
        // Check thread count
        if threads.count > config.maxThreadCount {
            issues.append(ThreadIssue(
                type: .tooManyThreads,
                description: "Thread count (\(threads.count)) exceeds recommended limit (\(config.maxThreadCount))",
                severity: .high,
                affectedThreads: []
            ))
            recommendations.append(ThreadRecommendation(
                title: "Reduce thread count",
                description: "Use GCD or OperationQueue with limited concurrency instead of creating many threads",
                impact: .high
            ))
        }
        
        // Check for high CPU threads
        let highCPUThreads = threads.filter { $0.cpuUsage > 80 }
        if !highCPUThreads.isEmpty {
            issues.append(ThreadIssue(
                type: .highCPUUsage,
                description: "\(highCPUThreads.count) thread(s) with CPU usage > 80%",
                severity: highCPUThreads.count > 2 ? .high : .medium,
                affectedThreads: highCPUThreads.map { $0.threadId }
            ))
        }
        
        // Check main thread
        if let mainThread = threads.first(where: { $0.isMainThread }) {
            if mainThread.cpuUsage > 50 {
                issues.append(ThreadIssue(
                    type: .mainThreadOverloaded,
                    description: "Main thread CPU usage is \(String(format: "%.1f", mainThread.cpuUsage))%",
                    severity: .high,
                    affectedThreads: [mainThread.threadId]
                ))
                recommendations.append(ThreadRecommendation(
                    title: "Offload work from main thread",
                    description: "Move heavy computations to background queues",
                    impact: .high
                ))
            }
        }
        
        // Check for blocked threads
        let blockedThreads = threads.filter { $0.state == .waiting || $0.state == .uninterruptible }
        if blockedThreads.count > threads.count / 2 {
            issues.append(ThreadIssue(
                type: .manyBlockedThreads,
                description: "\(blockedThreads.count) threads are blocked/waiting",
                severity: .medium,
                affectedThreads: blockedThreads.map { $0.threadId }
            ))
        }
        
        // Calculate health score
        var healthScore = 100.0
        for issue in issues {
            switch issue.severity {
            case .high: healthScore -= 20
            case .medium: healthScore -= 10
            case .low: healthScore -= 5
            }
        }
        healthScore = max(healthScore, 0)
        
        return ThreadHealthReport(
            healthScore: healthScore,
            threadCount: threads.count,
            activeThreadCount: threads.filter { $0.state == .running }.count,
            totalCPUUsage: threads.reduce(0) { $0 + $1.cpuUsage },
            mainThreadCPUUsage: threads.first(where: { $0.isMainThread })?.cpuUsage ?? 0,
            issues: issues,
            recommendations: recommendations,
            threads: threads,
            timestamp: Date()
        )
    }
    
    /// Check for potential deadlocks
    public func checkForDeadlocks() -> [DeadlockInfo] {
        var deadlocks: [DeadlockInfo] = []
        let threads = getCurrentThreadInfo()
        
        // Simple deadlock detection: look for cycles in thread dependencies
        // This is a simplified version - real deadlock detection is more complex
        
        let waitingThreads = threads.filter { $0.state == .waiting || $0.state == .uninterruptible }
        
        // If many threads are waiting and have been for a while, flag as potential deadlock
        if waitingThreads.count > 2 {
            // Check if threads are making progress
            // Compare with previous snapshot
            if let lastSnapshot = threadSnapshots.last {
                let previousWaiting = lastSnapshot.threads.filter { $0.state == .waiting || $0.state == .uninterruptible }
                
                // Check if same threads are still waiting
                let stillWaiting = waitingThreads.filter { current in
                    previousWaiting.contains { $0.threadId == current.threadId }
                }
                
                if stillWaiting.count >= 2 {
                    let deadlock = DeadlockInfo(
                        involvedThreads: stillWaiting.map { $0.threadId },
                        detectionTime: Date(),
                        description: "Potential deadlock: \(stillWaiting.count) threads have been waiting across multiple samples",
                        stackTraces: stillWaiting.compactMap { $0.stackTrace }
                    )
                    deadlocks.append(deadlock)
                    onDeadlockDetected?(deadlock)
                }
            }
        }
        
        return deadlocks
    }
    
    /// Get main thread block events
    public func getMainThreadBlockEvents() -> [MainThreadBlockEvent] {
        return mainThreadBlockEvents
    }
    
    /// Clear stored data
    public func clear() {
        analyzerQueue.async {
            self.threadSnapshots.removeAll()
            self.mainThreadBlockEvents.removeAll()
        }
    }
    
    // MARK: - Private Methods
    
    private func startPeriodicMonitoring() {
        analyzerQueue.asyncAfter(deadline: .now() + config.monitoringInterval) { [weak self] in
            guard let self = self, self.isMonitoring else { return }
            
            // Take snapshot
            let threads = self.getCurrentThreadInfo()
            let snapshot = ThreadSnapshot(threads: threads, timestamp: Date())
            
            self.threadSnapshots.append(snapshot)
            if self.threadSnapshots.count > self.config.maxStoredSnapshots {
                self.threadSnapshots.removeFirst()
            }
            
            // Check for thread overload
            if threads.count > self.config.maxThreadCount {
                let overload = ThreadOverloadInfo(
                    currentCount: threads.count,
                    maxRecommended: self.config.maxThreadCount,
                    timestamp: Date()
                )
                self.onThreadOverload?(overload)
            }
            
            // Check for deadlocks
            if self.config.enableDeadlockDetection {
                _ = self.checkForDeadlocks()
            }
            
            self.startPeriodicMonitoring()
        }
    }
    
    private func startMainThreadWatchdog() {
        // Watchdog runs on background thread and checks if main thread responds
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            while self.isMonitoring {
                let startTime = CFAbsoluteTimeGetCurrent()
                let semaphore = DispatchSemaphore(value: 0)
                
                DispatchQueue.main.async {
                    semaphore.signal()
                }
                
                // Wait for main thread response
                let timeout = DispatchTime.now() + .milliseconds(Int(self.config.mainThreadBlockThresholdMs * 2))
                let result = semaphore.wait(timeout: timeout)
                
                let endTime = CFAbsoluteTimeGetCurrent()
                let blockDuration = (endTime - startTime) * 1000 // ms
                
                if result == .timedOut || blockDuration > self.config.mainThreadBlockThresholdMs {
                    let event = MainThreadBlockEvent(
                        duration: blockDuration,
                        threshold: self.config.mainThreadBlockThresholdMs,
                        timestamp: Date(),
                        stackTrace: self.getMainThreadStackTrace()
                    )
                    
                    self.analyzerQueue.async {
                        self.mainThreadBlockEvents.append(event)
                    }
                    
                    DispatchQueue.main.async {
                        self.onMainThreadBlocked?(event)
                    }
                }
                
                Thread.sleep(forTimeInterval: self.config.monitoringInterval)
            }
        }
    }
    
    private func getStackTrace(for thread: thread_act_t) -> [String]? {
        // Getting stack trace requires more complex implementation
        // This is a placeholder - full implementation would use backtrace APIs
        return nil
    }
    
    private func getMainThreadStackTrace() -> [String] {
        // Capture main thread stack trace
        // This needs to be called from the main thread for accurate results
        var result: [String] = []
        
        DispatchQueue.main.sync {
            result = Thread.callStackSymbols
        }
        
        return result
    }
}

// MARK: - Data Types

public struct ThreadInfo: Codable, Sendable {
    public let threadId: UInt64
    public let port: UInt32
    public let cpuUsage: Double
    public let userTime: Double
    public let systemTime: Double
    public let state: ThreadRunState
    public let flags: Int
    public let priority: Int
    public let isMainThread: Bool
    public let dispatchQueueAddress: UInt64
    public let stackTrace: [String]?
    
    public var formattedCPUUsage: String {
        String(format: "%.1f%%", cpuUsage)
    }
}

public enum ThreadRunState: Int, Codable, Sendable {
    case running = 1
    case stopped = 2
    case waiting = 3
    case uninterruptible = 4
    case halted = 5
    case unknown = 0
    
    public var description: String {
        switch self {
        case .running: return "Running"
        case .stopped: return "Stopped"
        case .waiting: return "Waiting"
        case .uninterruptible: return "Uninterruptible"
        case .halted: return "Halted"
        case .unknown: return "Unknown"
        }
    }
    
    public var emoji: String {
        switch self {
        case .running: return "🟢"
        case .stopped: return "🔴"
        case .waiting: return "🟡"
        case .uninterruptible: return "🟠"
        case .halted: return "⚫"
        case .unknown: return "⚪"
        }
    }
}

public struct ThreadSnapshot: Codable, Sendable {
    public let threads: [ThreadInfo]
    public let timestamp: Date
}

public struct ThreadHealthReport: Codable, Sendable {
    public let healthScore: Double
    public let threadCount: Int
    public let activeThreadCount: Int
    public let totalCPUUsage: Double
    public let mainThreadCPUUsage: Double
    public let issues: [ThreadIssue]
    public let recommendations: [ThreadRecommendation]
    public let threads: [ThreadInfo]
    public let timestamp: Date
    
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

public struct ThreadIssue: Codable, Sendable {
    public let type: ThreadIssueType
    public let description: String
    public let severity: ThreadIssueSeverity
    public let affectedThreads: [UInt64]
}

public enum ThreadIssueType: String, Codable, Sendable {
    case tooManyThreads = "Too Many Threads"
    case highCPUUsage = "High CPU Usage"
    case mainThreadOverloaded = "Main Thread Overloaded"
    case manyBlockedThreads = "Many Blocked Threads"
    case potentialDeadlock = "Potential Deadlock"
}

public enum ThreadIssueSeverity: String, Codable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

public struct ThreadRecommendation: Codable, Sendable {
    public let title: String
    public let description: String
    public let impact: ImpactLevel
}

public struct DeadlockInfo: Codable, Sendable {
    public let involvedThreads: [UInt64]
    public let detectionTime: Date
    public let description: String
    public let stackTraces: [[String]]
}

public struct MainThreadBlockEvent: Codable, Sendable {
    public let duration: Double // milliseconds
    public let threshold: Double
    public let timestamp: Date
    public let stackTrace: [String]
    
    public var formattedDuration: String {
        String(format: "%.1f ms", duration)
    }
    
    public var severity: MainThreadBlockSeverity {
        switch duration {
        case 0..<50: return .minor
        case 50..<100: return .moderate
        case 100..<250: return .major
        default: return .severe
        }
    }
}

public enum MainThreadBlockSeverity: String, Codable, Sendable {
    case minor = "Minor"
    case moderate = "Moderate"
    case major = "Major"
    case severe = "Severe"
}

public struct ThreadOverloadInfo: Codable, Sendable {
    public let currentCount: Int
    public let maxRecommended: Int
    public let timestamp: Date
}
