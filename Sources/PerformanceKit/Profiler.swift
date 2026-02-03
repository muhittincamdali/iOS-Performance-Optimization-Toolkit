//
//  Profiler.swift
//  PerformanceKit
//
//  Created by Muhittin Camdali
//  Copyright © 2026 Muhittin Camdali. All rights reserved.
//

import Foundation

/// A scoped profiler that automatically measures execution time
public final class Profiler: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// The profiler name
    public let name: String
    
    /// Start time
    private let startTime: CFAbsoluteTime
    
    /// Parent profiler for nested profiling
    private weak var parent: Profiler?
    
    /// Child profilers
    private var children: [Profiler] = []
    
    /// Whether the profiler has been stopped
    private var isStopped = false
    
    /// Elapsed time (only valid after stop)
    public private(set) var elapsed: TimeInterval = 0
    
    // MARK: - Initialization
    
    /// Creates and starts a new profiler
    /// - Parameter name: The profiler name
    public init(_ name: String) {
        self.name = name
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    // MARK: - Nested Profiling
    
    /// Creates a child profiler for nested measurements
    /// - Parameter name: The child profiler name
    /// - Returns: A new child profiler
    public func child(_ name: String) -> Profiler {
        let child = Profiler(name)
        child.parent = self
        children.append(child)
        return child
    }
    
    // MARK: - Control
    
    /// Stops the profiler and records the elapsed time
    /// - Returns: The elapsed time in seconds
    @discardableResult
    public func stop() -> TimeInterval {
        guard !isStopped else { return elapsed }
        
        elapsed = CFAbsoluteTimeGetCurrent() - startTime
        isStopped = true
        
        // Stop any unstoppedchildren
        for child in children where !child.isStopped {
            child.stop()
        }
        
        return elapsed
    }
    
    /// Generates a report of this profiler and its children
    /// - Parameter indent: The indentation level
    /// - Returns: A formatted report string
    public func report(indent: Int = 0) -> String {
        let prefix = String(repeating: "  ", count: indent)
        var lines: [String] = []
        
        let time = isStopped ? elapsed : CFAbsoluteTimeGetCurrent() - startTime
        lines.append("\(prefix)\(name): \(String(format: "%.4f", time))s")
        
        for child in children {
            lines.append(child.report(indent: indent + 1))
        }
        
        return lines.joined(separator: "\n")
    }
    
    deinit {
        if !isStopped {
            stop()
        }
    }
}

// MARK: - Convenience Extensions

extension Profiler {
    /// Profiles a synchronous closure
    /// - Parameters:
    ///   - name: The profiler name
    ///   - block: The closure to profile
    /// - Returns: The result of the closure
    @discardableResult
    public static func profile<T>(_ name: String, block: () throws -> T) rethrows -> T {
        let profiler = Profiler(name)
        defer { profiler.stop() }
        return try block()
    }
    
    /// Profiles an async closure
    /// - Parameters:
    ///   - name: The profiler name
    ///   - block: The async closure to profile
    /// - Returns: The result of the closure
    @discardableResult
    public static func profileAsync<T>(_ name: String, block: () async throws -> T) async rethrows -> T {
        let profiler = Profiler(name)
        defer { profiler.stop() }
        return try await block()
    }
}

// MARK: - AutoProfiler

/// A property wrapper that automatically profiles property access
@propertyWrapper
public struct AutoProfiled<Value> {
    private var value: Value
    private let name: String
    
    public init(wrappedValue: Value, name: String? = nil) {
        self.value = wrappedValue
        self.name = name ?? "Property"
    }
    
    public var wrappedValue: Value {
        get {
            let profiler = Profiler("\(name).get")
            defer { profiler.stop() }
            return value
        }
        set {
            let profiler = Profiler("\(name).set")
            defer { profiler.stop() }
            value = newValue
        }
    }
}
