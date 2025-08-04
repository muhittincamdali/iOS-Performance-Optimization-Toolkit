//
//  PerformanceCoreTests.swift
//  iOS Performance Optimization Toolkit Tests
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import PerformanceOptimizationKit

final class PerformanceCoreTests: XCTestCase {
    
    var performanceCore: PerformanceCore!
    
    override func setUpWithError() throws {
        performanceCore = PerformanceCore.shared
    }
    
    override func tearDownWithError() throws {
        performanceCore = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitializationWithValidConfiguration() throws {
        let config = PerformanceCore.PerformanceConfiguration(
            memoryOptimizationEnabled: true,
            cpuOptimizationEnabled: true,
            batteryOptimizationEnabled: true,
            uiOptimizationEnabled: true,
            analyticsEnabled: true,
            autoCleanupEnabled: true,
            monitoringInterval: 1.0,
            maxMemoryUsage: 200 * 1024 * 1024,
            targetFrameRate: 60
        )
        
        XCTAssertNoThrow(try performanceCore.initialize(with: config))
    }
    
    func testInitializationWithMinimalConfiguration() throws {
        let config = PerformanceCore.PerformanceConfiguration(
            memoryOptimizationEnabled: false,
            cpuOptimizationEnabled: false,
            batteryOptimizationEnabled: false,
            uiOptimizationEnabled: false,
            analyticsEnabled: false,
            autoCleanupEnabled: false
        )
        
        XCTAssertNoThrow(try performanceCore.initialize(with: config))
    }
    
    // MARK: - Performance Metrics Tests
    
    func testGetCurrentMetrics() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        let metrics = performanceCore.getCurrentMetrics()
        
        XCTAssertNotNil(metrics)
        XCTAssertGreaterThanOrEqual(metrics.timestamp.timeIntervalSince1970, 0)
        XCTAssertGreaterThanOrEqual(metrics.memoryUsage, 0)
        XCTAssertGreaterThanOrEqual(metrics.cpuUsage, 0.0)
        XCTAssertLessThanOrEqual(metrics.cpuUsage, 100.0)
        XCTAssertGreaterThanOrEqual(metrics.batteryLevel, 0.0)
        XCTAssertLessThanOrEqual(metrics.batteryLevel, 100.0)
        XCTAssertGreaterThanOrEqual(metrics.frameRate, 0.0)
        XCTAssertGreaterThanOrEqual(metrics.responseTime, 0.0)
    }
    
    func testPerformanceLevelCalculation() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        let level = performanceCore.getPerformanceLevel()
        
        XCTAssertNotNil(level)
        XCTAssertTrue([.excellent, .good, .average, .poor, .critical].contains(level))
    }
    
    func testPerformanceLevelDescriptions() throws {
        let levels: [PerformanceCore.PerformanceLevel] = [
            .excellent, .good, .average, .poor, .critical
        ]
        
        for level in levels {
            XCTAssertFalse(level.description.isEmpty)
            XCTAssertNotNil(level.color)
        }
    }
    
    // MARK: - Performance Issues Tests
    
    func testDetectPerformanceIssues() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        let issues = performanceCore.detectPerformanceIssues()
        
        XCTAssertNotNil(issues)
        // Issues may or may not be detected depending on current system state
    }
    
    func testPerformanceIssueDescriptions() throws {
        let issues: [PerformanceCore.PerformanceIssue] = [
            .memoryLeak,
            .highCPUUsage,
            .lowBattery,
            .lowFrameRate,
            .slowResponse,
            .excessiveNetworkCalls,
            .inefficientAlgorithms,
            .poorImageOptimization
        ]
        
        for issue in issues {
            XCTAssertFalse(issue.description.isEmpty)
            XCTAssertNotNil(issue.severity)
        }
    }
    
    func testPerformanceIssueSeverity() throws {
        let criticalIssues: [PerformanceCore.PerformanceIssue] = [
            .memoryLeak, .highCPUUsage
        ]
        
        let poorIssues: [PerformanceCore.PerformanceIssue] = [
            .lowFrameRate, .slowResponse
        ]
        
        let averageIssues: [PerformanceCore.PerformanceIssue] = [
            .lowBattery, .excessiveNetworkCalls
        ]
        
        let goodIssues: [PerformanceCore.PerformanceIssue] = [
            .inefficientAlgorithms, .poorImageOptimization
        ]
        
        for issue in criticalIssues {
            XCTAssertEqual(issue.severity, .critical)
        }
        
        for issue in poorIssues {
            XCTAssertEqual(issue.severity, .poor)
        }
        
        for issue in averageIssues {
            XCTAssertEqual(issue.severity, .average)
        }
        
        for issue in goodIssues {
            XCTAssertEqual(issue.severity, .good)
        }
    }
    
    // MARK: - Optimization Tests
    
    func testOptimizePerformance() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        let issues: [PerformanceCore.PerformanceIssue] = [
            .memoryLeak, .highCPUUsage
        ]
        
        XCTAssertNoThrow(try performanceCore.optimizePerformance(for: issues))
    }
    
    func testOptimizeAppLaunch() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        XCTAssertNoThrow(try performanceCore.optimizeAppLaunch())
    }
    
    func testOptimizeImageLoading() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        XCTAssertNoThrow(try performanceCore.optimizeImageLoading())
    }
    
    func testOptimizeNetworkRequests() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        XCTAssertNoThrow(try performanceCore.optimizeNetworkRequests())
    }
    
    // MARK: - Monitoring Tests
    
    func testStartStopMonitoring() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        XCTAssertNoThrow(performanceCore.startMonitoring())
        XCTAssertNoThrow(performanceCore.stopMonitoring())
    }
    
    // MARK: - Analytics Tests
    
    func testGetAnalytics() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        let analytics = performanceCore.getAnalytics()
        
        XCTAssertNotNil(analytics)
    }
    
    // MARK: - Configuration Tests
    
    func testConfigurationWithDifferentMemoryLimits() throws {
        let memoryLimits: [UInt64] = [
            100 * 1024 * 1024, // 100MB
            200 * 1024 * 1024, // 200MB
            500 * 1024 * 1024  // 500MB
        ]
        
        for limit in memoryLimits {
            let config = PerformanceCore.PerformanceConfiguration(maxMemoryUsage: limit)
            XCTAssertNoThrow(try performanceCore.initialize(with: config))
        }
    }
    
    func testConfigurationWithDifferentFrameRates() throws {
        let frameRates: [Int] = [30, 60, 120]
        
        for frameRate in frameRates {
            let config = PerformanceCore.PerformanceConfiguration(targetFrameRate: frameRate)
            XCTAssertNoThrow(try performanceCore.initialize(with: config))
        }
    }
    
    func testConfigurationWithDifferentMonitoringIntervals() throws {
        let intervals: [TimeInterval] = [0.5, 1.0, 2.0, 5.0]
        
        for interval in intervals {
            let config = PerformanceCore.PerformanceConfiguration(monitoringInterval: interval)
            XCTAssertNoThrow(try performanceCore.initialize(with: config))
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testPerformanceErrorDescriptions() throws {
        let errors: [PerformanceCore.PerformanceError] = [
            .initializationFailed,
            .monitoringFailed,
            .optimizationFailed,
            .invalidConfiguration,
            .resourceUnavailable,
            .permissionDenied
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription?.isEmpty ?? true)
        }
    }
    
    // MARK: - Thread Safety Tests
    
    func testThreadSafety() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        let expectation = XCTestExpectation(description: "Thread safety test")
        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        
        for i in 0..<10 {
            queue.async {
                let metrics = self.performanceCore.getCurrentMetrics()
                XCTAssertNotNil(metrics)
                
                let level = self.performanceCore.getPerformanceLevel()
                XCTAssertNotNil(level)
                
                if i == 9 {
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Performance Tests
    
    func testInitializationPerformance() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        
        measure {
            try? performanceCore.initialize(with: config)
        }
    }
    
    func testMetricsCollectionPerformance() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        measure {
            _ = performanceCore.getCurrentMetrics()
        }
    }
    
    func testIssueDetectionPerformance() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        measure {
            _ = performanceCore.detectPerformanceIssues()
        }
    }
    
    // MARK: - Edge Cases
    
    func testMultipleInitializations() throws {
        let config1 = PerformanceCore.PerformanceConfiguration(maxMemoryUsage: 100 * 1024 * 1024)
        let config2 = PerformanceCore.PerformanceConfiguration(maxMemoryUsage: 200 * 1024 * 1024)
        
        XCTAssertNoThrow(try performanceCore.initialize(with: config1))
        XCTAssertNoThrow(try performanceCore.initialize(with: config2))
    }
    
    func testEmptyIssuesArray() throws {
        let config = PerformanceCore.PerformanceConfiguration()
        try performanceCore.initialize(with: config)
        
        let emptyIssues: [PerformanceCore.PerformanceIssue] = []
        XCTAssertNoThrow(try performanceCore.optimizePerformance(for: emptyIssues))
    }
    
    func testAllFeaturesDisabled() throws {
        let config = PerformanceCore.PerformanceConfiguration(
            memoryOptimizationEnabled: false,
            cpuOptimizationEnabled: false,
            batteryOptimizationEnabled: false,
            uiOptimizationEnabled: false,
            analyticsEnabled: false,
            autoCleanupEnabled: false
        )
        
        XCTAssertNoThrow(try performanceCore.initialize(with: config))
        
        let metrics = performanceCore.getCurrentMetrics()
        XCTAssertNotNil(metrics)
    }
} 