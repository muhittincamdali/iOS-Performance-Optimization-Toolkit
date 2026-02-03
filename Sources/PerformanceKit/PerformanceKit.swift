//
//  PerformanceKit.swift
//  PerformanceKit
//
//  Created by Muhittin Camdali
//  Copyright © 2026 Muhittin Camdali. All rights reserved.
//

import Foundation
import os.signpost
#if canImport(UIKit)
import UIKit
#endif

/// PerformanceKit - A comprehensive iOS performance optimization toolkit
///
/// PerformanceKit provides tools for measuring, profiling, and optimizing
/// iOS application performance with zero-configuration setup.
///
/// ## Features
/// - 📊 Real-time performance monitoring
/// - ⏱️ Precise timing measurements
/// - 🧵 Thread profiling
/// - 💾 Memory tracking
/// - 🔥 CPU usage monitoring
/// - 📈 Performance reports
///
/// ## Quick Start
/// ```swift
/// import PerformanceKit
///
/// // Measure execution time
/// let result = PerformanceKit.measure("heavy-operation") {
///     performHeavyTask()
/// }
///
/// // Track memory usage
/// let memory = PerformanceKit.shared.memoryUsage
/// print("Memory: \(memory.used) / \(memory.total)")
/// ```
@MainActor
public final class PerformanceKit: Sendable {
    
    // MARK: - Singleton
    
    /// Shared instance for convenient access
    public static let shared = PerformanceKit()
    
    // MARK: - Properties
    
    /// Whether detailed logging is enabled
    public var isLoggingEnabled: Bool = false
    
    /// The signpost log for performance measurements
    private let signpostLog: OSLog
    
    /// Stored measurements
    private var measurements: [String: [TimeInterval]] = [:]
    
    // MARK: - Initialization
    
    /// Creates a new PerformanceKit instance
    public init() {
        self.signpostLog = OSLog(
            subsystem: Bundle.main.bundleIdentifier ?? "PerformanceKit",
            category: "Performance"
        )
    }
    
    // MARK: - Memory Tracking
    
    /// Current memory usage information
    public var memoryUsage: MemoryUsage {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return MemoryUsage(resident: 0, virtual: 0)
        }
        
        return MemoryUsage(
            resident: UInt64(info.resident_size),
            virtual: UInt64(info.virtual_size)
        )
    }
    
    /// Current memory footprint in bytes
    public var memoryFootprint: UInt64 {
        memoryUsage.resident
    }
    
    // MARK: - CPU Tracking
    
    /// Current CPU usage percentage
    public var cpuUsage: Double {
        var threads: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0
        
        guard task_threads(mach_task_self_, &threads, &threadCount) == KERN_SUCCESS,
              let threads = threads else {
            return 0
        }
        
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: threads),
                vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.stride)
            )
        }
        
        var totalUsage: Double = 0
        
        for i in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var infoCount = mach_msg_type_number_t(THREAD_BASIC_INFO_COUNT)
            
            let result = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(infoCount)) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &infoCount)
                }
            }
            
            if result == KERN_SUCCESS && info.flags & TH_FLAGS_IDLE == 0 {
                totalUsage += Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100
            }
        }
        
        return totalUsage
    }
    
    // MARK: - Timing
    
    /// Measures the execution time of a closure
    /// - Parameters:
    ///   - name: A name for the measurement
    ///   - block: The closure to measure
    /// - Returns: The result of the closure
    @discardableResult
    public static func measure<T>(_ name: String, block: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        
        if shared.isLoggingEnabled {
            print("[\(name)] Elapsed: \(String(format: "%.4f", elapsed))s")
        }
        
        Task { @MainActor in
            shared.recordMeasurement(name: name, duration: elapsed)
        }
        
        return result
    }
    
    /// Measures the execution time of an async closure
    /// - Parameters:
    ///   - name: A name for the measurement
    ///   - block: The async closure to measure
    /// - Returns: The result of the closure
    @discardableResult
    public static func measureAsync<T>(_ name: String, block: () async throws -> T) async rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        
        if shared.isLoggingEnabled {
            print("[\(name)] Elapsed: \(String(format: "%.4f", elapsed))s")
        }
        
        await shared.recordMeasurement(name: name, duration: elapsed)
        
        return result
    }
    
    /// Records a measurement
    private func recordMeasurement(name: String, duration: TimeInterval) {
        if measurements[name] == nil {
            measurements[name] = []
        }
        measurements[name]?.append(duration)
    }
    
    // MARK: - Signpost Integration
    
    /// Begins a signpost interval
    /// - Parameter name: The signpost name
    /// - Returns: A signpost ID for ending the interval
    public func beginSignpost(_ name: StaticString) -> OSSignpostID {
        let id = OSSignpostID(log: signpostLog)
        os_signpost(.begin, log: signpostLog, name: name, signpostID: id)
        return id
    }
    
    /// Ends a signpost interval
    /// - Parameters:
    ///   - name: The signpost name
    ///   - id: The signpost ID from beginSignpost
    public func endSignpost(_ name: StaticString, id: OSSignpostID) {
        os_signpost(.end, log: signpostLog, name: name, signpostID: id)
    }
    
    /// Marks an event in Instruments
    /// - Parameter name: The event name
    public func event(_ name: StaticString) {
        os_signpost(.event, log: signpostLog, name: name)
    }
    
    // MARK: - Statistics
    
    /// Gets statistics for a named measurement
    /// - Parameter name: The measurement name
    /// - Returns: Statistics for the measurement
    public func statistics(for name: String) -> MeasurementStatistics? {
        guard let values = measurements[name], !values.isEmpty else {
            return nil
        }
        
        let sorted = values.sorted()
        let sum = values.reduce(0, +)
        let mean = sum / Double(values.count)
        
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        let stdDev = sqrt(variance)
        
        return MeasurementStatistics(
            count: values.count,
            min: sorted.first ?? 0,
            max: sorted.last ?? 0,
            mean: mean,
            median: sorted[values.count / 2],
            standardDeviation: stdDev,
            total: sum
        )
    }
    
    /// Gets statistics for all measurements
    public var allStatistics: [String: MeasurementStatistics] {
        var result: [String: MeasurementStatistics] = [:]
        for name in measurements.keys {
            if let stats = statistics(for: name) {
                result[name] = stats
            }
        }
        return result
    }
    
    /// Clears all recorded measurements
    public func reset() {
        measurements.removeAll()
    }
    
    // MARK: - Reports
    
    /// Generates a performance report
    public func generateReport() -> PerformanceReport {
        PerformanceReport(
            timestamp: Date(),
            memoryUsage: memoryUsage,
            cpuUsage: cpuUsage,
            measurements: allStatistics
        )
    }
}

// MARK: - Models

/// Memory usage information
public struct MemoryUsage: Sendable {
    /// Resident memory in bytes
    public let resident: UInt64
    
    /// Virtual memory in bytes
    public let virtual: UInt64
    
    /// Resident memory in megabytes
    public var residentMB: Double {
        Double(resident) / 1_048_576
    }
    
    /// Virtual memory in megabytes
    public var virtualMB: Double {
        Double(virtual) / 1_048_576
    }
    
    /// Formatted description
    public var formatted: String {
        String(format: "Resident: %.2f MB, Virtual: %.2f MB", residentMB, virtualMB)
    }
}

/// Statistics for a measurement
public struct MeasurementStatistics: Sendable {
    /// Number of measurements
    public let count: Int
    
    /// Minimum value
    public let min: TimeInterval
    
    /// Maximum value
    public let max: TimeInterval
    
    /// Mean value
    public let mean: TimeInterval
    
    /// Median value
    public let median: TimeInterval
    
    /// Standard deviation
    public let standardDeviation: TimeInterval
    
    /// Total time
    public let total: TimeInterval
}

/// A performance report
public struct PerformanceReport: Sendable {
    /// Report timestamp
    public let timestamp: Date
    
    /// Memory usage at report time
    public let memoryUsage: MemoryUsage
    
    /// CPU usage at report time
    public let cpuUsage: Double
    
    /// All measurement statistics
    public let measurements: [String: MeasurementStatistics]
    
    /// Generates a text summary
    public var summary: String {
        var lines: [String] = []
        lines.append("=== Performance Report ===")
        lines.append("Time: \(timestamp)")
        lines.append("Memory: \(memoryUsage.formatted)")
        lines.append("CPU: \(String(format: "%.1f%%", cpuUsage))")
        lines.append("")
        lines.append("Measurements:")
        for (name, stats) in measurements.sorted(by: { $0.key < $1.key }) {
            lines.append("  \(name):")
            lines.append("    Count: \(stats.count)")
            lines.append("    Mean: \(String(format: "%.4f", stats.mean))s")
            lines.append("    Min: \(String(format: "%.4f", stats.min))s")
            lines.append("    Max: \(String(format: "%.4f", stats.max))s")
        }
        return lines.joined(separator: "\n")
    }
}
