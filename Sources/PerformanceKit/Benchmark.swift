//
//  Benchmark.swift
//  PerformanceKit
//
//  Created by Muhittin Camdali
//  Copyright © 2026 Muhittin Camdali. All rights reserved.
//

import Foundation

/// A benchmark utility for running performance tests
public struct Benchmark: Sendable {
    
    // MARK: - Properties
    
    /// The benchmark name
    public let name: String
    
    /// Number of iterations
    public let iterations: Int
    
    /// Number of warmup iterations
    public let warmupIterations: Int
    
    // MARK: - Initialization
    
    /// Creates a new benchmark
    /// - Parameters:
    ///   - name: The benchmark name
    ///   - iterations: Number of iterations (default: 100)
    ///   - warmupIterations: Number of warmup iterations (default: 10)
    public init(
        name: String,
        iterations: Int = 100,
        warmupIterations: Int = 10
    ) {
        self.name = name
        self.iterations = iterations
        self.warmupIterations = warmupIterations
    }
    
    // MARK: - Running
    
    /// Runs the benchmark
    /// - Parameter block: The code to benchmark
    /// - Returns: The benchmark result
    @discardableResult
    public func run(block: () -> Void) -> BenchmarkResult {
        // Warmup
        for _ in 0..<warmupIterations {
            block()
        }
        
        // Actual benchmark
        var times: [TimeInterval] = []
        times.reserveCapacity(iterations)
        
        for _ in 0..<iterations {
            let start = CFAbsoluteTimeGetCurrent()
            block()
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            times.append(elapsed)
        }
        
        return BenchmarkResult(name: name, times: times)
    }
    
    /// Runs the benchmark asynchronously
    /// - Parameter block: The async code to benchmark
    /// - Returns: The benchmark result
    @discardableResult
    public func runAsync(block: () async -> Void) async -> BenchmarkResult {
        // Warmup
        for _ in 0..<warmupIterations {
            await block()
        }
        
        // Actual benchmark
        var times: [TimeInterval] = []
        times.reserveCapacity(iterations)
        
        for _ in 0..<iterations {
            let start = CFAbsoluteTimeGetCurrent()
            await block()
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            times.append(elapsed)
        }
        
        return BenchmarkResult(name: name, times: times)
    }
    
    // MARK: - Comparison
    
    /// Compares two implementations
    /// - Parameters:
    ///   - baseline: The baseline implementation
    ///   - candidate: The candidate implementation
    /// - Returns: A comparison result
    public func compare(
        baseline: () -> Void,
        candidate: () -> Void
    ) -> BenchmarkComparison {
        let baselineResult = run(block: baseline)
        let candidateResult = Benchmark(
            name: "\(name) (candidate)",
            iterations: iterations,
            warmupIterations: warmupIterations
        ).run(block: candidate)
        
        return BenchmarkComparison(
            baseline: baselineResult,
            candidate: candidateResult
        )
    }
}

// MARK: - BenchmarkResult

/// Result of a benchmark run
public struct BenchmarkResult: Sendable {
    /// The benchmark name
    public let name: String
    
    /// Individual run times
    public let times: [TimeInterval]
    
    /// Number of iterations
    public var count: Int { times.count }
    
    /// Total time
    public var total: TimeInterval { times.reduce(0, +) }
    
    /// Mean time per iteration
    public var mean: TimeInterval { total / Double(count) }
    
    /// Minimum time
    public var min: TimeInterval { times.min() ?? 0 }
    
    /// Maximum time
    public var max: TimeInterval { times.max() ?? 0 }
    
    /// Median time
    public var median: TimeInterval {
        let sorted = times.sorted()
        return sorted[count / 2]
    }
    
    /// Standard deviation
    public var standardDeviation: TimeInterval {
        let meanValue = mean
        let variance = times.map { pow($0 - meanValue, 2) }.reduce(0, +) / Double(count)
        return sqrt(variance)
    }
    
    /// Percentile value
    /// - Parameter percentile: The percentile (0-100)
    /// - Returns: The percentile value
    public func percentile(_ percentile: Double) -> TimeInterval {
        let sorted = times.sorted()
        let index = Int(Double(count) * percentile / 100)
        return sorted[Swift.min(index, count - 1)]
    }
    
    /// Formatted summary
    public var summary: String {
        """
        \(name):
          Iterations: \(count)
          Mean: \(String(format: "%.6f", mean))s
          Min: \(String(format: "%.6f", min))s
          Max: \(String(format: "%.6f", max))s
          Median: \(String(format: "%.6f", median))s
          StdDev: \(String(format: "%.6f", standardDeviation))s
          P95: \(String(format: "%.6f", percentile(95)))s
          P99: \(String(format: "%.6f", percentile(99)))s
        """
    }
}

// MARK: - BenchmarkComparison

/// Comparison between two benchmark results
public struct BenchmarkComparison: Sendable {
    /// Baseline result
    public let baseline: BenchmarkResult
    
    /// Candidate result
    public let candidate: BenchmarkResult
    
    /// Speedup factor (> 1 means candidate is faster)
    public var speedup: Double {
        baseline.mean / candidate.mean
    }
    
    /// Whether candidate is faster than baseline
    public var isFaster: Bool {
        speedup > 1
    }
    
    /// Percentage improvement (positive = faster)
    public var percentageImprovement: Double {
        (1 - (candidate.mean / baseline.mean)) * 100
    }
    
    /// Formatted summary
    public var summary: String {
        let direction = isFaster ? "faster" : "slower"
        return """
        Comparison:
          Baseline: \(String(format: "%.6f", baseline.mean))s
          Candidate: \(String(format: "%.6f", candidate.mean))s
          Speedup: \(String(format: "%.2fx", speedup))
          Candidate is \(String(format: "%.1f%%", abs(percentageImprovement))) \(direction)
        """
    }
}

// MARK: - Suite

/// A collection of benchmarks
public struct BenchmarkSuite {
    /// The suite name
    public let name: String
    
    /// Benchmarks in the suite
    private var benchmarks: [(String, () -> Void)] = []
    
    /// Creates a new benchmark suite
    /// - Parameter name: The suite name
    public init(name: String) {
        self.name = name
    }
    
    /// Adds a benchmark to the suite
    /// - Parameters:
    ///   - name: The benchmark name
    ///   - block: The code to benchmark
    public mutating func add(_ name: String, block: @escaping () -> Void) {
        benchmarks.append((name, block))
    }
    
    /// Runs all benchmarks in the suite
    /// - Parameters:
    ///   - iterations: Number of iterations per benchmark
    /// - Returns: Array of benchmark results
    public func run(iterations: Int = 100) -> [BenchmarkResult] {
        var results: [BenchmarkResult] = []
        
        print("=== \(name) ===")
        
        for (benchmarkName, block) in benchmarks {
            let benchmark = Benchmark(
                name: benchmarkName,
                iterations: iterations
            )
            let result = benchmark.run(block: block)
            results.append(result)
            print(result.summary)
            print("")
        }
        
        return results
    }
}
