//
//  CoreDataProfiler.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import Foundation
import CoreData

/// Comprehensive Core Data performance profiling and optimization
public final class CoreDataProfiler {
    
    // MARK: - Singleton
    public static let shared = CoreDataProfiler()
    
    // MARK: - Properties
    private let profilerQueue = DispatchQueue(label: "com.performancekit.coredata", qos: .utility)
    private var isEnabled = false
    private var config = Configuration()
    
    // Tracked operations
    private var fetchOperations: [FetchOperation] = []
    private var saveOperations: [SaveOperation] = []
    private var faultOperations: [FaultOperation] = []
    
    // Statistics
    private var totalFetches: Int = 0
    private var totalSaves: Int = 0
    private var totalFaults: Int = 0
    
    // Notification observers
    private var notificationObservers: [Any] = []
    
    // Callbacks
    public var onSlowFetch: ((FetchOperation) -> Void)?
    public var onSlowSave: ((SaveOperation) -> Void)?
    public var onExcessiveFaulting: ((FaultingReport) -> Void)?
    
    // MARK: - Configuration
    public struct Configuration {
        public var slowFetchThresholdMs: Double = 100.0
        public var slowSaveThresholdMs: Double = 200.0
        public var maxFaultsPerSecond: Int = 100
        public var maxStoredOperations: Int = 1000
        public var enableFetchPlanAnalysis: Bool = true
        public var trackRelationshipFaults: Bool = true
        public var enableQueryOptimization: Bool = true
        
        public init() {}
    }
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// Configure the Core Data profiler
    public func configure(_ configuration: Configuration) {
        self.config = configuration
    }
    
    /// Enable Core Data profiling
    public func enable() {
        guard !isEnabled else { return }
        isEnabled = true
        
        setupNotificationObservers()
    }
    
    /// Disable Core Data profiling
    public func disable() {
        isEnabled = false
        removeNotificationObservers()
    }
    
    /// Profile a fetch request
    @discardableResult
    public func profileFetch<T: NSManagedObject>(
        _ request: NSFetchRequest<T>,
        in context: NSManagedObjectContext,
        label: String? = nil
    ) throws -> [T] {
        let startTime = CFAbsoluteTimeGetCurrent()
        let results = try context.fetch(request)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let duration = (endTime - startTime) * 1000 // ms
        
        let operation = FetchOperation(
            entityName: request.entityName ?? "Unknown",
            predicateDescription: request.predicate?.description,
            sortDescriptors: request.sortDescriptors?.map { $0.description },
            fetchLimit: request.fetchLimit,
            fetchOffset: request.fetchOffset,
            resultCount: results.count,
            duration: duration,
            label: label,
            timestamp: Date(),
            contextType: getContextType(context),
            isSlowFetch: duration > config.slowFetchThresholdMs
        )
        
        profilerQueue.async {
            self.fetchOperations.append(operation)
            self.totalFetches += 1
            
            if self.fetchOperations.count > self.config.maxStoredOperations {
                self.fetchOperations.removeFirst()
            }
        }
        
        if duration > config.slowFetchThresholdMs {
            onSlowFetch?(operation)
        }
        
        return results
    }
    
    /// Profile a save operation
    public func profileSave(
        in context: NSManagedObjectContext,
        label: String? = nil
    ) throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let insertedCount = context.insertedObjects.count
        let updatedCount = context.updatedObjects.count
        let deletedCount = context.deletedObjects.count
        
        try context.save()
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let duration = (endTime - startTime) * 1000 // ms
        
        let operation = SaveOperation(
            insertedCount: insertedCount,
            updatedCount: updatedCount,
            deletedCount: deletedCount,
            duration: duration,
            label: label,
            timestamp: Date(),
            contextType: getContextType(context),
            isSlowSave: duration > config.slowSaveThresholdMs
        )
        
        profilerQueue.async {
            self.saveOperations.append(operation)
            self.totalSaves += 1
            
            if self.saveOperations.count > self.config.maxStoredOperations {
                self.saveOperations.removeFirst()
            }
        }
        
        if duration > config.slowSaveThresholdMs {
            onSlowSave?(operation)
        }
    }
    
    /// Analyze a fetch request for optimization opportunities
    public func analyzeFetchRequest<T: NSManagedObject>(
        _ request: NSFetchRequest<T>
    ) -> FetchRequestAnalysis {
        var issues: [FetchIssue] = []
        var recommendations: [FetchRecommendation] = []
        
        // Check fetch limit
        if request.fetchLimit == 0 {
            issues.append(FetchIssue(
                type: .noFetchLimit,
                description: "No fetch limit set - may load excessive data",
                severity: .medium
            ))
            recommendations.append(FetchRecommendation(
                title: "Add fetch limit",
                description: "Use setFetchLimit() to limit results when possible",
                code: "request.fetchLimit = 50"
            ))
        }
        
        // Check batch size
        if request.fetchBatchSize == 0 {
            issues.append(FetchIssue(
                type: .noBatchSize,
                description: "No batch size set - all objects loaded immediately",
                severity: .medium
            ))
            recommendations.append(FetchRecommendation(
                title: "Add fetch batch size",
                description: "Use setFetchBatchSize() for better memory management",
                code: "request.fetchBatchSize = 20"
            ))
        }
        
        // Check result type
        if request.resultType == .managedObjectResultType && request.propertiesToFetch == nil {
            issues.append(FetchIssue(
                type: .fullObjectFetch,
                description: "Fetching full objects - consider using propertiesToFetch for better performance",
                severity: .low
            ))
        }
        
        // Check predicate complexity
        if let predicate = request.predicate {
            let predicateString = predicate.description
            if predicateString.contains("SUBQUERY") || predicateString.contains("ANY") || predicateString.contains("ALL") {
                issues.append(FetchIssue(
                    type: .complexPredicate,
                    description: "Complex predicate may be slow",
                    severity: .medium
                ))
            }
            
            if predicateString.contains("LIKE") || predicateString.contains("CONTAINS") {
                issues.append(FetchIssue(
                    type: .stringSearch,
                    description: "String search without index may be slow",
                    severity: .low
                ))
                recommendations.append(FetchRecommendation(
                    title: "Add string index",
                    description: "Add an index on the searched attribute in the Core Data model",
                    code: nil
                ))
            }
        }
        
        // Check includes property values
        if !request.includesPropertyValues && request.resultType == .managedObjectResultType {
            issues.append(FetchIssue(
                type: .noPropertyValues,
                description: "includesPropertyValues is false - will cause faulting on access",
                severity: .low
            ))
        }
        
        // Check relationship prefetching
        if request.relationshipKeyPathsForPrefetching?.isEmpty ?? true {
            recommendations.append(FetchRecommendation(
                title: "Consider prefetching relationships",
                description: "Use relationshipKeyPathsForPrefetching to avoid N+1 queries",
                code: "request.relationshipKeyPathsForPrefetching = [\"relationship\"]"
            ))
        }
        
        // Calculate score
        var score = 100.0
        for issue in issues {
            switch issue.severity {
            case .high: score -= 25
            case .medium: score -= 15
            case .low: score -= 5
            }
        }
        
        return FetchRequestAnalysis(
            score: max(score, 0),
            issues: issues,
            recommendations: recommendations,
            request: FetchRequestInfo(
                entityName: request.entityName ?? "Unknown",
                predicate: request.predicate?.description,
                sortDescriptors: request.sortDescriptors?.count ?? 0,
                fetchLimit: request.fetchLimit,
                fetchBatchSize: request.fetchBatchSize,
                includesPropertyValues: request.includesPropertyValues,
                returnsObjectsAsFaults: request.returnsObjectsAsFaults,
                resultType: String(describing: request.resultType)
            )
        )
    }
    
    /// Get Core Data statistics
    public func getStatistics() -> CoreDataStatistics {
        var stats: CoreDataStatistics!
        
        profilerQueue.sync {
            let fetchDurations = fetchOperations.map { $0.duration }
            let saveDurations = saveOperations.map { $0.duration }
            
            let avgFetchTime = fetchDurations.isEmpty ? 0 : fetchDurations.reduce(0, +) / Double(fetchDurations.count)
            let avgSaveTime = saveDurations.isEmpty ? 0 : saveDurations.reduce(0, +) / Double(saveDurations.count)
            
            let slowFetches = fetchOperations.filter { $0.isSlowFetch }.count
            let slowSaves = saveOperations.filter { $0.isSlowSave }.count
            
            stats = CoreDataStatistics(
                totalFetches: totalFetches,
                totalSaves: totalSaves,
                totalFaults: totalFaults,
                averageFetchTime: avgFetchTime,
                averageSaveTime: avgSaveTime,
                slowFetchCount: slowFetches,
                slowSaveCount: slowSaves,
                recentFetches: Array(fetchOperations.suffix(10)),
                recentSaves: Array(saveOperations.suffix(10))
            )
        }
        
        return stats
    }
    
    /// Get performance report
    public func getPerformanceReport() -> CoreDataPerformanceReport {
        let stats = getStatistics()
        var issues: [CoreDataIssue] = []
        var recommendations: [CoreDataRecommendation] = []
        
        // Analyze fetch performance
        if stats.averageFetchTime > config.slowFetchThresholdMs {
            issues.append(CoreDataIssue(
                type: .slowFetches,
                description: "Average fetch time is \(String(format: "%.0f", stats.averageFetchTime))ms",
                severity: .high
            ))
            recommendations.append(CoreDataRecommendation(
                title: "Optimize fetch requests",
                description: "Add fetch limits, batch sizes, and indexes",
                impact: .high
            ))
        }
        
        // Analyze save performance
        if stats.averageSaveTime > config.slowSaveThresholdMs {
            issues.append(CoreDataIssue(
                type: .slowSaves,
                description: "Average save time is \(String(format: "%.0f", stats.averageSaveTime))ms",
                severity: .high
            ))
            recommendations.append(CoreDataRecommendation(
                title: "Batch save operations",
                description: "Group multiple changes into fewer save operations",
                impact: .high
            ))
        }
        
        // Analyze fault rate
        let faultRatePerFetch = stats.totalFetches > 0 ? Double(stats.totalFaults) / Double(stats.totalFetches) : 0
        if faultRatePerFetch > 10 {
            issues.append(CoreDataIssue(
                type: .excessiveFaulting,
                description: "High fault rate: \(String(format: "%.1f", faultRatePerFetch)) faults per fetch",
                severity: .medium
            ))
            recommendations.append(CoreDataRecommendation(
                title: "Reduce faulting",
                description: "Use prefetching and batch fetching to reduce faults",
                impact: .medium
            ))
        }
        
        // Calculate health score
        var healthScore = 100.0
        healthScore -= min(stats.averageFetchTime / 10, 30)
        healthScore -= min(stats.averageSaveTime / 20, 20)
        healthScore -= min(faultRatePerFetch * 2, 20)
        healthScore = max(healthScore, 0)
        
        return CoreDataPerformanceReport(
            healthScore: healthScore,
            statistics: stats,
            issues: issues,
            recommendations: recommendations,
            timestamp: Date()
        )
    }
    
    /// Clear stored data
    public func clear() {
        profilerQueue.async {
            self.fetchOperations.removeAll()
            self.saveOperations.removeAll()
            self.faultOperations.removeAll()
            self.totalFetches = 0
            self.totalSaves = 0
            self.totalFaults = 0
        }
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationObservers() {
        // Observe context will save
        let willSaveObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextWillSave,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.handleContextWillSave(notification)
        }
        notificationObservers.append(willSaveObserver)
        
        // Observe context did save
        let didSaveObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.handleContextDidSave(notification)
        }
        notificationObservers.append(didSaveObserver)
        
        // Observe objects did change
        let didChangeObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextObjectsDidChange,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.handleObjectsDidChange(notification)
        }
        notificationObservers.append(didChangeObserver)
    }
    
    private func removeNotificationObservers() {
        for observer in notificationObservers {
            NotificationCenter.default.removeObserver(observer)
        }
        notificationObservers.removeAll()
    }
    
    private func handleContextWillSave(_ notification: Notification) {
        // Track save start time
    }
    
    private func handleContextDidSave(_ notification: Notification) {
        // Track save completion
    }
    
    private func handleObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        // Track faults
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject> {
            profilerQueue.async {
                self.totalFaults += refreshedObjects.count
            }
        }
    }
    
    private func getContextType(_ context: NSManagedObjectContext) -> ContextType {
        switch context.concurrencyType {
        case .mainQueueConcurrencyType:
            return .mainQueue
        case .privateQueueConcurrencyType:
            return .privateQueue
        case .confinementConcurrencyType:
            return .confinement
        @unknown default:
            return .unknown
        }
    }
}

// MARK: - Data Types

public struct FetchOperation: Codable, Sendable {
    public let entityName: String
    public let predicateDescription: String?
    public let sortDescriptors: [String]?
    public let fetchLimit: Int
    public let fetchOffset: Int
    public let resultCount: Int
    public let duration: Double // ms
    public let label: String?
    public let timestamp: Date
    public let contextType: ContextType
    public let isSlowFetch: Bool
    
    public var formattedDuration: String {
        String(format: "%.1f ms", duration)
    }
}

public struct SaveOperation: Codable, Sendable {
    public let insertedCount: Int
    public let updatedCount: Int
    public let deletedCount: Int
    public let duration: Double // ms
    public let label: String?
    public let timestamp: Date
    public let contextType: ContextType
    public let isSlowSave: Bool
    
    public var totalChanges: Int {
        insertedCount + updatedCount + deletedCount
    }
    
    public var formattedDuration: String {
        String(format: "%.1f ms", duration)
    }
}

public struct FaultOperation: Codable, Sendable {
    public let entityName: String
    public let objectID: String
    public let timestamp: Date
}

public enum ContextType: String, Codable, Sendable {
    case mainQueue = "Main Queue"
    case privateQueue = "Private Queue"
    case confinement = "Confinement"
    case unknown = "Unknown"
}

public struct FetchRequestAnalysis: Codable, Sendable {
    public let score: Double
    public let issues: [FetchIssue]
    public let recommendations: [FetchRecommendation]
    public let request: FetchRequestInfo
    
    public var grade: String {
        switch score {
        case 90...: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
}

public struct FetchIssue: Codable, Sendable {
    public let type: FetchIssueType
    public let description: String
    public let severity: FetchIssueSeverity
}

public enum FetchIssueType: String, Codable, Sendable {
    case noFetchLimit = "No Fetch Limit"
    case noBatchSize = "No Batch Size"
    case fullObjectFetch = "Full Object Fetch"
    case complexPredicate = "Complex Predicate"
    case stringSearch = "String Search"
    case noPropertyValues = "No Property Values"
}

public enum FetchIssueSeverity: String, Codable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

public struct FetchRecommendation: Codable, Sendable {
    public let title: String
    public let description: String
    public let code: String?
}

public struct FetchRequestInfo: Codable, Sendable {
    public let entityName: String
    public let predicate: String?
    public let sortDescriptors: Int
    public let fetchLimit: Int
    public let fetchBatchSize: Int
    public let includesPropertyValues: Bool
    public let returnsObjectsAsFaults: Bool
    public let resultType: String
}

public struct CoreDataStatistics: Codable, Sendable {
    public let totalFetches: Int
    public let totalSaves: Int
    public let totalFaults: Int
    public let averageFetchTime: Double
    public let averageSaveTime: Double
    public let slowFetchCount: Int
    public let slowSaveCount: Int
    public let recentFetches: [FetchOperation]
    public let recentSaves: [SaveOperation]
}

public struct CoreDataPerformanceReport: Codable, Sendable {
    public let healthScore: Double
    public let statistics: CoreDataStatistics
    public let issues: [CoreDataIssue]
    public let recommendations: [CoreDataRecommendation]
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

public struct CoreDataIssue: Codable, Sendable {
    public let type: CoreDataIssueType
    public let description: String
    public let severity: CoreDataIssueSeverity
}

public enum CoreDataIssueType: String, Codable, Sendable {
    case slowFetches = "Slow Fetches"
    case slowSaves = "Slow Saves"
    case excessiveFaulting = "Excessive Faulting"
    case contextMisuse = "Context Misuse"
}

public enum CoreDataIssueSeverity: String, Codable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

public struct CoreDataRecommendation: Codable, Sendable {
    public let title: String
    public let description: String
    public let impact: ImpactLevel
}

public struct FaultingReport: Codable, Sendable {
    public let faultCount: Int
    public let timeWindow: TimeInterval
    public let threshold: Int
    public let timestamp: Date
}
