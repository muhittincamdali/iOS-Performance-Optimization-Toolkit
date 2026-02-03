//
//  PerformanceKitTests.swift
//  PerformanceKitTests
//
//  Created by Muhittin Camdali
//  Copyright © 2026 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import PerformanceKit

final class PerformanceKitTests: XCTestCase {
    
    // MARK: - Memory Tests
    
    func testMemoryUsage() async {
        let memory = await PerformanceKit.shared.memoryUsage
        
        XCTAssertGreaterThan(memory.resident, 0)
        XCTAssertGreaterThan(memory.virtual, 0)
        XCTAssertGreaterThan(memory.residentMB, 0)
    }
    
    func testMemoryFootprint() async {
        let footprint = await PerformanceKit.shared.memoryFootprint
        XCTAssertGreaterThan(footprint, 0)
    }
    
    // MARK: - CPU Tests
    
    func testCPUUsage() async {
        let cpu = await PerformanceKit.shared.cpuUsage
        XCTAssertGreaterThanOrEqual(cpu, 0)
    }
    
    // MARK: - Timing Tests
    
    @MainActor
    func testMeasure() {
        var executed = false
        
        PerformanceKit.measure("test-measure") {
            executed = true
            Thread.sleep(forTimeInterval: 0.01)
        }
        
        XCTAssertTrue(executed)
    }
    
    @MainActor
    func testMeasureReturnsValue() {
        let result = PerformanceKit.measure("test-return") {
            return 42
        }
        
        XCTAssertEqual(result, 42)
    }
    
    @MainActor
    func testMeasureAsync() async {
        var executed = false
        
        await PerformanceKit.measureAsync("test-async") {
            executed = true
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        
        XCTAssertTrue(executed)
    }
    
    // MARK: - Statistics Tests
    
    @MainActor
    func testStatistics() async {
        await PerformanceKit.shared.reset()
        
        // Record some measurements
        for _ in 0..<5 {
            PerformanceKit.measure("stats-test") {
                Thread.sleep(forTimeInterval: 0.001)
            }
        }
        
        // Wait for measurements to be recorded
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        let stats = PerformanceKit.shared.statistics(for: "stats-test")
        
        XCTAssertNotNil(stats)
        XCTAssertEqual(stats?.count, 5)
        XCTAssertGreaterThan(stats?.mean ?? 0, 0)
        XCTAssertGreaterThan(stats?.min ?? 0, 0)
        XCTAssertGreaterThan(stats?.max ?? 0, 0)
    }
    
    // MARK: - Report Tests
    
    @MainActor
    func testGenerateReport() async {
        let report = PerformanceKit.shared.generateReport()
        
        XCTAssertNotNil(report.timestamp)
        XCTAssertGreaterThan(report.memoryUsage.resident, 0)
        XCTAssertFalse(report.summary.isEmpty)
    }
    
    // MARK: - Profiler Tests
    
    func testProfiler() {
        let profiler = Profiler("test-profiler")
        Thread.sleep(forTimeInterval: 0.01)
        let elapsed = profiler.stop()
        
        XCTAssertGreaterThanOrEqual(elapsed, 0.01)
    }
    
    func testNestedProfiler() {
        let parent = Profiler("parent")
        
        let child1 = parent.child("child1")
        Thread.sleep(forTimeInterval: 0.005)
        child1.stop()
        
        let child2 = parent.child("child2")
        Thread.sleep(forTimeInterval: 0.005)
        child2.stop()
        
        parent.stop()
        
        XCTAssertGreaterThanOrEqual(child1.elapsed, 0.005)
        XCTAssertGreaterThanOrEqual(child2.elapsed, 0.005)
        XCTAssertGreaterThanOrEqual(parent.elapsed, 0.01)
    }
    
    func testProfilerReport() {
        let profiler = Profiler("report-test")
        _ = profiler.child("child")
        profiler.stop()
        
        let report = profiler.report()
        
        XCTAssertTrue(report.contains("report-test"))
        XCTAssertTrue(report.contains("child"))
    }
    
    func testProfileClosure() {
        var executed = false
        
        Profiler.profile("closure-test") {
            executed = true
        }
        
        XCTAssertTrue(executed)
    }
    
    // MARK: - Benchmark Tests
    
    func testBenchmark() {
        let benchmark = Benchmark(name: "test-benchmark", iterations: 10, warmupIterations: 2)
        
        var counter = 0
        let result = benchmark.run {
            counter += 1
        }
        
        XCTAssertEqual(result.count, 10)
        XCTAssertGreaterThan(result.mean, 0)
        XCTAssertGreaterThanOrEqual(result.max, result.min)
    }
    
    func testBenchmarkResult() {
        let times: [TimeInterval] = [0.1, 0.2, 0.3, 0.4, 0.5]
        let result = BenchmarkResult(name: "test", times: times)
        
        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result.total, 1.5)
        XCTAssertEqual(result.mean, 0.3)
        XCTAssertEqual(result.min, 0.1)
        XCTAssertEqual(result.max, 0.5)
        XCTAssertEqual(result.median, 0.3)
    }
    
    func testBenchmarkComparison() {
        let baseline = BenchmarkResult(name: "baseline", times: [0.2, 0.2, 0.2])
        let candidate = BenchmarkResult(name: "candidate", times: [0.1, 0.1, 0.1])
        
        let comparison = BenchmarkComparison(baseline: baseline, candidate: candidate)
        
        XCTAssertEqual(comparison.speedup, 2.0)
        XCTAssertTrue(comparison.isFaster)
        XCTAssertEqual(comparison.percentageImprovement, 50.0)
    }
    
    func testBenchmarkSuite() {
        var suite = BenchmarkSuite(name: "Test Suite")
        
        var count1 = 0
        var count2 = 0
        
        suite.add("bench1") { count1 += 1 }
        suite.add("bench2") { count2 += 1 }
        
        let results = suite.run(iterations: 5)
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(count1, 5 + 10) // iterations + warmup
        XCTAssertEqual(count2, 5 + 10)
    }
    
    // MARK: - Memory Usage Model Tests
    
    func testMemoryUsageFormatted() {
        let usage = MemoryUsage(resident: 104_857_600, virtual: 209_715_200) // 100MB, 200MB
        
        XCTAssertEqual(usage.residentMB, 100.0)
        XCTAssertEqual(usage.virtualMB, 200.0)
        XCTAssertTrue(usage.formatted.contains("100.00 MB"))
    }
    
    // MARK: - Percentile Tests
    
    func testPercentile() {
        let times: [TimeInterval] = Array(1...100).map { Double($0) / 1000 }
        let result = BenchmarkResult(name: "percentile-test", times: times)
        
        XCTAssertEqual(result.percentile(50), 0.051, accuracy: 0.001)
        XCTAssertEqual(result.percentile(95), 0.096, accuracy: 0.001)
        XCTAssertEqual(result.percentile(99), 0.100, accuracy: 0.001)
    }
}
