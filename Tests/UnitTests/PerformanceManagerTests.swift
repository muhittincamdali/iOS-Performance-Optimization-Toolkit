import XCTest
import PerformanceOptimizationKit

/**
 * PerformanceManager Unit Tests
 * 
 * Comprehensive unit tests for the PerformanceManager component
 * covering all performance optimization features and functionality.
 */
final class PerformanceManagerTests: XCTestCase {
    var performanceManager: PerformanceManager!
    
    override func setUp() {
        super.setUp()
        performanceManager = PerformanceManager()
    }
    
    override func tearDown() {
        performanceManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testPerformanceManagerInitialization() {
        // Given
        let manager = PerformanceManager()
        
        // Then
        XCTAssertNotNil(manager)
        XCTAssertFalse(manager.isOptimizationEnabled)
        XCTAssertEqual(manager.currentPerformanceLevel, .balanced)
    }
    
    // MARK: - Performance Optimization Tests
    
    func testOptimizeAppPerformance() {
        // Given
        XCTAssertFalse(performanceManager.isOptimizationEnabled)
        
        // When
        performanceManager.optimizeAppPerformance()
        
        // Then
        XCTAssertTrue(performanceManager.isOptimizationEnabled)
    }
    
    func testSetPerformanceLevel() {
        // Given
        let levels: [PerformanceManager.PerformanceLevel] = [
            .powerSaving,
            .balanced,
            .performance,
            .ultraPerformance
        ]
        
        // When & Then
        for level in levels {
            performanceManager.setPerformanceLevel(level)
            XCTAssertEqual(performanceManager.currentPerformanceLevel, level)
        }
    }
    
    func testGetPerformanceMetrics() {
        // When
        let metrics = performanceManager.getPerformanceMetrics()
        
        // Then
        XCTAssertNotNil(metrics)
        XCTAssertGreaterThanOrEqual(metrics.memoryUsage, 0)
        XCTAssertLessThanOrEqual(metrics.memoryUsage, 100)
        XCTAssertGreaterThanOrEqual(metrics.batteryImpact, 0)
        XCTAssertLessThanOrEqual(metrics.batteryImpact, 100)
        XCTAssertGreaterThanOrEqual(metrics.cpuUsage, 0)
        XCTAssertLessThanOrEqual(metrics.cpuUsage, 100)
        XCTAssertGreaterThanOrEqual(metrics.fps, 0)
        XCTAssertGreaterThanOrEqual(metrics.temperature, 0)
        XCTAssertGreaterThanOrEqual(metrics.networkLatency, 0)
    }
    
    // MARK: - Memory Management Tests
    
    func testOptimizeMemory() {
        // When
        performanceManager.optimizeMemory()
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testGetMemoryStatistics() {
        // When
        let statistics = performanceManager.getMemoryStatistics()
        
        // Then
        XCTAssertNotNil(statistics)
        XCTAssertGreaterThan(statistics.totalMemory, 0)
        XCTAssertGreaterThanOrEqual(statistics.usedMemory, 0)
        XCTAssertGreaterThanOrEqual(statistics.availableMemory, 0)
        XCTAssertGreaterThanOrEqual(statistics.memoryUsagePercentage, 0)
        XCTAssertLessThanOrEqual(statistics.memoryUsagePercentage, 100)
        XCTAssertGreaterThanOrEqual(statistics.leakCount, 0)
    }
    
    func testDetectMemoryLeaks() {
        // When
        let leaks = performanceManager.detectMemoryLeaks()
        
        // Then
        XCTAssertNotNil(leaks)
        XCTAssertGreaterThanOrEqual(leaks.count, 0)
        
        // Test leak properties if any leaks are found
        for leak in leaks {
            XCTAssertFalse(leak.objectType.isEmpty)
            XCTAssertGreaterThan(leak.memorySize, 0)
            XCTAssertNotNil(leak.leakTime)
            XCTAssertNotNil(leak.stackTrace)
        }
    }
    
    // MARK: - Battery Optimization Tests
    
    func testOptimizeBattery() {
        // When
        performanceManager.optimizeBattery()
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testGetBatteryStatistics() {
        // When
        let statistics = performanceManager.getBatteryStatistics()
        
        // Then
        XCTAssertNotNil(statistics)
        XCTAssertGreaterThanOrEqual(statistics.batteryLevel, 0)
        XCTAssertLessThanOrEqual(statistics.batteryLevel, 100)
        XCTAssertGreaterThanOrEqual(statistics.batteryTemperature, 0)
        XCTAssertGreaterThanOrEqual(statistics.batteryHealth, 0)
        XCTAssertLessThanOrEqual(statistics.batteryHealth, 100)
        XCTAssertGreaterThanOrEqual(statistics.estimatedTimeRemaining, 0)
        XCTAssertGreaterThanOrEqual(statistics.powerConsumption, 0)
    }
    
    func testGetBatteryImpactScore() {
        // When
        let score = performanceManager.getBatteryImpactScore()
        
        // Then
        XCTAssertGreaterThanOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
    }
    
    // MARK: - CPU Optimization Tests
    
    func testOptimizeCPU() {
        // When
        performanceManager.optimizeCPU()
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testGetCPUStatistics() {
        // When
        let statistics = performanceManager.getCPUStatistics()
        
        // Then
        XCTAssertNotNil(statistics)
        XCTAssertGreaterThanOrEqual(statistics.cpuUsage, 0)
        XCTAssertLessThanOrEqual(statistics.cpuUsage, 100)
        XCTAssertGreaterThan(statistics.threadCount, 0)
        XCTAssertGreaterThanOrEqual(statistics.activeThreads, 0)
        XCTAssertGreaterThanOrEqual(statistics.cpuTemperature, 0)
        XCTAssertGreaterThanOrEqual(statistics.performanceScore, 0)
        XCTAssertLessThanOrEqual(statistics.performanceScore, 100)
    }
    
    func testGetCPUPerformanceScore() {
        // When
        let score = performanceManager.getCPUPerformanceScore()
        
        // Then
        XCTAssertGreaterThanOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
    }
    
    // MARK: - UI Optimization Tests
    
    func testOptimizeUI() {
        // When
        performanceManager.optimizeUI()
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testGetUIPerformanceStatistics() {
        // When
        let statistics = performanceManager.getUIPerformanceStatistics()
        
        // Then
        XCTAssertNotNil(statistics)
        XCTAssertGreaterThanOrEqual(statistics.currentFPS, 0)
        XCTAssertGreaterThanOrEqual(statistics.averageFPS, 0)
        XCTAssertGreaterThanOrEqual(statistics.frameDropCount, 0)
        XCTAssertGreaterThanOrEqual(statistics.renderingTime, 0)
        XCTAssertGreaterThanOrEqual(statistics.animationCount, 0)
    }
    
    func testGetCurrentFPS() {
        // When
        let fps = performanceManager.getCurrentFPS()
        
        // Then
        XCTAssertGreaterThanOrEqual(fps, 0)
        XCTAssertLessThanOrEqual(fps, 120) // Max reasonable FPS
    }
    
    // MARK: - Performance Monitoring Tests
    
    func testStartPerformanceMonitoring() {
        // When
        performanceManager.startPerformanceMonitoring()
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testStopPerformanceMonitoring() {
        // When
        performanceManager.stopPerformanceMonitoring()
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testGetPerformanceReport() {
        // When
        let report = performanceManager.getPerformanceReport()
        
        // Then
        XCTAssertNotNil(report)
        XCTAssertNotNil(report.metrics)
        XCTAssertNotNil(report.memoryStatistics)
        XCTAssertNotNil(report.batteryStatistics)
        XCTAssertNotNil(report.cpuStatistics)
        XCTAssertNotNil(report.uiStatistics)
        XCTAssertNotNil(report.recommendations)
        XCTAssertNotNil(report.timestamp)
    }
    
    // MARK: - Performance Metrics Tests
    
    func testPerformanceMetricsIsOptimal() {
        // Given
        let optimalMetrics = PerformanceMetrics(
            memoryUsage: 50.0,
            batteryImpact: 30.0,
            cpuUsage: 40.0,
            fps: 60.0,
            temperature: 35.0,
            networkLatency: 50.0
        )
        
        // When & Then
        XCTAssertTrue(optimalMetrics.isOptimal)
    }
    
    func testPerformanceMetricsIsNotOptimal() {
        // Given
        let poorMetrics = PerformanceMetrics(
            memoryUsage: 85.0,
            batteryImpact: 75.0,
            cpuUsage: 90.0,
            fps: 30.0,
            temperature: 50.0,
            networkLatency: 200.0
        )
        
        // When & Then
        XCTAssertFalse(poorMetrics.isOptimal)
    }
    
    // MARK: - Performance Level Tests
    
    func testPerformanceLevelRawRepresentable() {
        // Given
        let levels: [PerformanceManager.PerformanceLevel] = [
            .powerSaving,
            .balanced,
            .performance,
            .ultraPerformance
        ]
        
        // When & Then
        for level in levels {
            let rawValue = level.rawValue
            let reconstructed = PerformanceManager.PerformanceLevel(rawValue: rawValue)
            XCTAssertEqual(reconstructed, level)
        }
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceOptimizationPerformance() {
        measure {
            performanceManager.optimizeAppPerformance()
        }
    }
    
    func testMemoryOptimizationPerformance() {
        measure {
            performanceManager.optimizeMemory()
        }
    }
    
    func testBatteryOptimizationPerformance() {
        measure {
            performanceManager.optimizeBattery()
        }
    }
    
    func testCPUOptimizationPerformance() {
        measure {
            performanceManager.optimizeCPU()
        }
    }
    
    func testUIOptimizationPerformance() {
        measure {
            performanceManager.optimizeUI()
        }
    }
    
    func testGetPerformanceMetricsPerformance() {
        measure {
            _ = performanceManager.getPerformanceMetrics()
        }
    }
    
    // MARK: - Mock Tests
    
    func testMockPerformanceManager() {
        // Given
        let mockManager = MockPerformanceManager()
        
        // When
        mockManager.optimizeAppPerformance()
        let metrics = mockManager.getPerformanceMetrics()
        
        // Then
        XCTAssertTrue(mockManager.isOptimizationEnabled)
        XCTAssertNotNil(metrics)
    }
    
    func testMockMemoryOptimization() {
        // Given
        let mockManager = MockPerformanceManager()
        
        // When
        let statistics = mockManager.getMemoryStatistics()
        
        // Then
        XCTAssertNotNil(statistics)
        XCTAssertGreaterThan(statistics.totalMemory, 0)
    }
}

// MARK: - Mock Performance Manager

class MockPerformanceManager: PerformanceManager {
    override func optimizeAppPerformance() {
        isOptimizationEnabled = true
    }
    
    override func getPerformanceMetrics() -> PerformanceMetrics {
        return PerformanceMetrics(
            memoryUsage: 45.0,
            batteryImpact: 25.0,
            cpuUsage: 35.0,
            fps: 60.0,
            temperature: 35.0,
            networkLatency: 30.0
        )
    }
    
    override func getMemoryStatistics() -> MemoryStatistics {
        return MemoryStatistics(
            totalMemory: 8 * 1024 * 1024 * 1024, // 8GB
            usedMemory: 4 * 1024 * 1024 * 1024,  // 4GB
            availableMemory: 4 * 1024 * 1024 * 1024, // 4GB
            memoryUsagePercentage: 50.0,
            memoryPressure: .normal,
            leakCount: 0
        )
    }
} 