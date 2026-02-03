//
//  BasicExample.swift
//  PerformanceKit Examples
//
//  Created by Muhittin Camdali
//

import PerformanceKit

// MARK: - Basic Measurement

/// Measure a synchronous operation
func measureSyncOperation() {
    PerformanceKit.shared.isLoggingEnabled = true
    
    PerformanceKit.measure("json-parsing") {
        // Simulate parsing
        Thread.sleep(forTimeInterval: 0.01)
    }
}

/// Measure an async operation
func measureAsyncOperation() async {
    await PerformanceKit.measureAsync("network-request") {
        // Simulate network request
        try? await Task.sleep(nanoseconds: 10_000_000)
    }
}

// MARK: - Memory Monitoring

/// Monitor memory usage
func monitorMemory() async {
    let memory = await PerformanceKit.shared.memoryUsage
    
    print("=== Memory Usage ===")
    print("Resident: \(String(format: "%.2f", memory.residentMB)) MB")
    print("Virtual: \(String(format: "%.2f", memory.virtualMB)) MB")
}

// MARK: - CPU Monitoring

/// Monitor CPU usage
func monitorCPU() async {
    let cpu = await PerformanceKit.shared.cpuUsage
    print("CPU Usage: \(String(format: "%.1f%%", cpu))")
}

// MARK: - Profiling

/// Example of nested profiling
func profileNestedOperations() {
    let profiler = Profiler("data-processing")
    
    let loadProfiler = profiler.child("load")
    // Simulate loading
    Thread.sleep(forTimeInterval: 0.005)
    loadProfiler.stop()
    
    let parseProfiler = profiler.child("parse")
    // Simulate parsing
    Thread.sleep(forTimeInterval: 0.01)
    parseProfiler.stop()
    
    let saveProfiler = profiler.child("save")
    // Simulate saving
    Thread.sleep(forTimeInterval: 0.003)
    saveProfiler.stop()
    
    profiler.stop()
    
    print(profiler.report())
}

// MARK: - Benchmarking

/// Compare two sorting implementations
func benchmarkSorting() {
    let array = (0..<1000).map { _ in Int.random(in: 0..<10000) }
    
    let benchmark = Benchmark(
        name: "sorting-comparison",
        iterations: 100,
        warmupIterations: 10
    )
    
    let comparison = benchmark.compare(
        baseline: {
            var copy = array
            copy.sort()
        },
        candidate: {
            var copy = array
            copy.sort(by: <)
        }
    )
    
    print(comparison.summary)
}

/// Run a benchmark suite
func runBenchmarkSuite() {
    var suite = BenchmarkSuite(name: "Collection Performance")
    
    suite.add("Array.append") {
        var arr = [Int]()
        for i in 0..<100 { arr.append(i) }
    }
    
    suite.add("Array.reserveCapacity") {
        var arr = [Int]()
        arr.reserveCapacity(100)
        for i in 0..<100 { arr.append(i) }
    }
    
    suite.add("Set.insert") {
        var set = Set<Int>()
        for i in 0..<100 { set.insert(i) }
    }
    
    _ = suite.run(iterations: 100)
}

// MARK: - Reports

/// Generate and print a performance report
func generateReport() async {
    let report = await PerformanceKit.shared.generateReport()
    print(report.summary)
}
