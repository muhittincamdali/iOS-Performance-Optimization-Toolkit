//
//  MemoryLeakDetector.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import Foundation
import ObjectiveC

/// Advanced memory leak detection using object tracking and retain cycle detection
public final class MemoryLeakDetector {
    
    // MARK: - Singleton
    public static let shared = MemoryLeakDetector()
    
    // MARK: - Properties
    private var trackedObjects: [TrackedObject] = []
    private var retainCycleDetector: RetainCycleDetector?
    private let trackingQueue = DispatchQueue(label: "com.performancekit.leakdetector", qos: .utility)
    private var isTracking = false
    private var config = Configuration()
    
    // Callbacks
    public var onLeakDetected: ((LeakInfo) -> Void)?
    public var onRetainCycleDetected: ((RetainCycleInfo) -> Void)?
    
    // MARK: - Configuration
    public struct Configuration {
        public var trackingInterval: TimeInterval = 5.0
        public var leakThresholdSeconds: TimeInterval = 30.0
        public var maxTrackedObjects: Int = 10000
        public var enableRetainCycleDetection: Bool = true
        public var excludedClasses: Set<String> = []
        public var trackViewControllers: Bool = true
        public var trackViews: Bool = true
        public var trackCustomClasses: Bool = true
        
        public init() {}
    }
    
    // MARK: - Initialization
    private init() {
        retainCycleDetector = RetainCycleDetector()
    }
    
    // MARK: - Public Methods
    
    /// Configure the leak detector
    public func configure(_ configuration: Configuration) {
        self.config = configuration
    }
    
    /// Start tracking for memory leaks
    public func startTracking() {
        guard !isTracking else { return }
        isTracking = true
        
        startPeriodicCheck()
        
        #if DEBUG
        setupSwizzling()
        #endif
    }
    
    /// Stop tracking for memory leaks
    public func stopTracking() {
        isTracking = false
    }
    
    /// Track a specific object for leaks
    public func track<T: AnyObject>(_ object: T, identifier: String? = nil) {
        trackingQueue.async { [weak self] in
            guard let self = self else { return }
            
            let id = identifier ?? "\(type(of: object))_\(ObjectIdentifier(object).hashValue)"
            let tracked = TrackedObject(
                object: object,
                identifier: id,
                className: String(describing: type(of: object)),
                creationTime: Date(),
                stackTrace: Thread.callStackSymbols
            )
            
            self.trackedObjects.append(tracked)
            
            // Limit tracked objects
            if self.trackedObjects.count > self.config.maxTrackedObjects {
                self.trackedObjects.removeFirst(self.trackedObjects.count - self.config.maxTrackedObjects)
            }
        }
    }
    
    /// Manually trigger leak check
    public func checkForLeaks() -> [LeakInfo] {
        var leaks: [LeakInfo] = []
        
        trackingQueue.sync {
            let now = Date()
            var objectsToRemove: [Int] = []
            
            for (index, tracked) in trackedObjects.enumerated() {
                // Check if object still exists
                if tracked.object != nil {
                    let age = now.timeIntervalSince(tracked.creationTime)
                    if age > config.leakThresholdSeconds {
                        // Potential leak detected
                        let leak = LeakInfo(
                            identifier: tracked.identifier,
                            className: tracked.className,
                            age: age,
                            severity: calculateSeverity(age: age),
                            stackTrace: tracked.stackTrace,
                            detectionTime: now,
                            memoryAddress: String(format: "%p", tracked.object as AnyObject)
                        )
                        leaks.append(leak)
                    }
                } else {
                    // Object was deallocated - remove from tracking
                    objectsToRemove.append(index)
                }
            }
            
            // Remove deallocated objects (in reverse order to maintain indices)
            for index in objectsToRemove.reversed() {
                trackedObjects.remove(at: index)
            }
        }
        
        // Notify about leaks
        for leak in leaks {
            onLeakDetected?(leak)
        }
        
        return leaks
    }
    
    /// Check for retain cycles on a specific object
    public func checkRetainCycles(for object: AnyObject) -> [RetainCycleInfo] {
        guard config.enableRetainCycleDetection else { return [] }
        
        var cycles: [RetainCycleInfo] = []
        
        if let detector = retainCycleDetector {
            let detected = detector.findRetainCycles(from: object)
            for cycle in detected {
                onRetainCycleDetected?(cycle)
            }
            cycles.append(contentsOf: detected)
        }
        
        return cycles
    }
    
    /// Get current tracking statistics
    public func getStatistics() -> LeakDetectorStatistics {
        var stats: LeakDetectorStatistics!
        
        trackingQueue.sync {
            let aliveObjects = trackedObjects.filter { $0.object != nil }
            let classCounts = Dictionary(grouping: aliveObjects, by: { $0.className })
                .mapValues { $0.count }
            
            stats = LeakDetectorStatistics(
                totalTrackedObjects: trackedObjects.count,
                aliveObjects: aliveObjects.count,
                deallocatedObjects: trackedObjects.count - aliveObjects.count,
                potentialLeaks: aliveObjects.filter {
                    Date().timeIntervalSince($0.creationTime) > config.leakThresholdSeconds
                }.count,
                classCounts: classCounts,
                trackingDuration: aliveObjects.first.map {
                    Date().timeIntervalSince($0.creationTime)
                } ?? 0
            )
        }
        
        return stats
    }
    
    /// Clear all tracked objects
    public func clearTracking() {
        trackingQueue.async {
            self.trackedObjects.removeAll()
        }
    }
    
    /// Get memory graph for analysis
    public func getMemoryGraph() -> MemoryGraph {
        var nodes: [MemoryGraphNode] = []
        var edges: [MemoryGraphEdge] = []
        
        trackingQueue.sync {
            for tracked in trackedObjects where tracked.object != nil {
                let node = MemoryGraphNode(
                    identifier: tracked.identifier,
                    className: tracked.className,
                    memoryAddress: String(format: "%p", tracked.object as AnyObject),
                    size: estimateObjectSize(tracked.object)
                )
                nodes.append(node)
            }
        }
        
        return MemoryGraph(nodes: nodes, edges: edges)
    }
    
    // MARK: - Private Methods
    
    private func startPeriodicCheck() {
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + config.trackingInterval) { [weak self] in
            guard let self = self, self.isTracking else { return }
            
            _ = self.checkForLeaks()
            self.startPeriodicCheck()
        }
    }
    
    private func calculateSeverity(age: TimeInterval) -> LeakSeverity {
        switch age {
        case 0..<60:
            return .low
        case 60..<300:
            return .medium
        case 300..<900:
            return .high
        default:
            return .critical
        }
    }
    
    private func estimateObjectSize(_ object: AnyObject?) -> Int {
        guard let obj = object else { return 0 }
        return class_getInstanceSize(type(of: obj))
    }
    
    #if DEBUG
    private func setupSwizzling() {
        // Method swizzling for automatic tracking - DEBUG only
        // This is a simplified version; production would need more robust implementation
    }
    #endif
}

// MARK: - Retain Cycle Detector

private final class RetainCycleDetector {
    
    func findRetainCycles(from object: AnyObject) -> [RetainCycleInfo] {
        var cycles: [RetainCycleInfo] = []
        var visited: Set<ObjectIdentifier> = []
        var path: [ObjectReference] = []
        
        findCyclesDFS(object: object, visited: &visited, path: &path, cycles: &cycles)
        
        return cycles
    }
    
    private func findCyclesDFS(
        object: AnyObject,
        visited: inout Set<ObjectIdentifier>,
        path: inout [ObjectReference],
        cycles: inout [RetainCycleInfo]
    ) {
        let objectId = ObjectIdentifier(object)
        
        // Check for cycle
        if visited.contains(objectId) {
            if let cycleStart = path.firstIndex(where: { $0.identifier == objectId }) {
                let cycleObjects = Array(path[cycleStart...])
                let cycle = RetainCycleInfo(
                    objects: cycleObjects,
                    cycleLength: cycleObjects.count,
                    detectionTime: Date()
                )
                cycles.append(cycle)
            }
            return
        }
        
        visited.insert(objectId)
        let ref = ObjectReference(
            identifier: objectId,
            className: String(describing: type(of: object)),
            memoryAddress: String(format: "%p", object)
        )
        path.append(ref)
        
        // Get strong references using Mirror
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            if let childObject = child.value as? AnyObject {
                findCyclesDFS(object: childObject, visited: &visited, path: &path, cycles: &cycles)
            }
        }
        
        path.removeLast()
    }
}

// MARK: - Tracked Object

private class TrackedObject {
    weak var object: AnyObject?
    let identifier: String
    let className: String
    let creationTime: Date
    let stackTrace: [String]
    
    init(object: AnyObject, identifier: String, className: String, creationTime: Date, stackTrace: [String]) {
        self.object = object
        self.identifier = identifier
        self.className = className
        self.creationTime = creationTime
        self.stackTrace = stackTrace
    }
}

// MARK: - Data Types

public struct LeakInfo: Codable, Sendable {
    public let identifier: String
    public let className: String
    public let age: TimeInterval
    public let severity: LeakSeverity
    public let stackTrace: [String]
    public let detectionTime: Date
    public let memoryAddress: String
    
    public var formattedAge: String {
        let minutes = Int(age) / 60
        let seconds = Int(age) % 60
        return "\(minutes)m \(seconds)s"
    }
}

public enum LeakSeverity: String, Codable, Sendable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    public var emoji: String {
        switch self {
        case .low: return "🟢"
        case .medium: return "🟡"
        case .high: return "🟠"
        case .critical: return "🔴"
        }
    }
}

public struct RetainCycleInfo: Codable, Sendable {
    public let objects: [ObjectReference]
    public let cycleLength: Int
    public let detectionTime: Date
    
    public var description: String {
        objects.map { $0.className }.joined(separator: " → ")
    }
}

public struct ObjectReference: Codable, Sendable {
    public let identifier: ObjectIdentifier
    public let className: String
    public let memoryAddress: String
    
    public init(identifier: ObjectIdentifier, className: String, memoryAddress: String) {
        self.identifier = identifier
        self.className = className
        self.memoryAddress = memoryAddress
    }
}

extension ObjectIdentifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hashValue = try container.decode(Int.self)
        // Note: This is a simplified implementation for serialization
        self = ObjectIdentifier(NSObject())
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hashValue)
    }
}

public struct LeakDetectorStatistics: Codable, Sendable {
    public let totalTrackedObjects: Int
    public let aliveObjects: Int
    public let deallocatedObjects: Int
    public let potentialLeaks: Int
    public let classCounts: [String: Int]
    public let trackingDuration: TimeInterval
    
    public var leakPercentage: Double {
        guard aliveObjects > 0 else { return 0 }
        return Double(potentialLeaks) / Double(aliveObjects) * 100
    }
}

public struct MemoryGraph: Codable, Sendable {
    public let nodes: [MemoryGraphNode]
    public let edges: [MemoryGraphEdge]
    
    public var totalSize: Int {
        nodes.reduce(0) { $0 + $1.size }
    }
}

public struct MemoryGraphNode: Codable, Sendable {
    public let identifier: String
    public let className: String
    public let memoryAddress: String
    public let size: Int
}

public struct MemoryGraphEdge: Codable, Sendable {
    public let fromIdentifier: String
    public let toIdentifier: String
    public let referenceType: ReferenceType
}

public enum ReferenceType: String, Codable, Sendable {
    case strong = "Strong"
    case weak = "Weak"
    case unowned = "Unowned"
}
