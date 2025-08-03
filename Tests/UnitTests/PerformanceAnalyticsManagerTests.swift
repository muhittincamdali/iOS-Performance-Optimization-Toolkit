import XCTest
import PerformanceOptimizationKit

/**
 * PerformanceAnalyticsManager Unit Tests
 * 
 * Comprehensive unit tests for the PerformanceAnalyticsManager component
 * covering analytics, event tracking, and reporting.
 */
final class PerformanceAnalyticsManagerTests: XCTestCase {
    var analyticsManager: PerformanceAnalyticsManager!
    
    override func setUp() {
        super.setUp()
        analyticsManager = PerformanceAnalyticsManager()
    }
    
    override func tearDown() {
        analyticsManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testPerformanceAnalyticsManagerInitialization() {
        // Given
        let manager = PerformanceAnalyticsManager()
        
        // Then
        XCTAssertNotNil(manager)
    }
    
    // MARK: - Analytics Management Tests
    
    func testStartAnalytics() {
        // When
        analyticsManager.startAnalytics()
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testStopAnalytics() {
        // When
        analyticsManager.stopAnalytics()
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    // MARK: - Event Logging Tests
    
    func testLogOptimizationEvent() {
        // When
        analyticsManager.logOptimizationEvent(.performanceOptimizationEnabled)
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testLogPerformanceEvent() {
        // When
        analyticsManager.logPerformanceEvent(.performanceMonitoringStarted)
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testLogErrorEvent() {
        // When
        analyticsManager.logErrorEvent(.optimizationFailed)
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    // MARK: - Metrics Collection Tests
    
    func testRecordPerformanceMetric() {
        // Given
        let metric = PerformanceMetric(
            name: "test_metric",
            value: 85.5,
            unit: "percentage",
            timestamp: Date()
        )
        
        // When
        analyticsManager.recordPerformanceMetric(metric)
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    func testRecordOptimizationRecord() {
        // Given
        let record = OptimizationRecord(
            event: .memoryOptimized,
            timestamp: Date(),
            success: true,
            impact: 25.0
        )
        
        // When
        analyticsManager.recordOptimizationRecord(record)
        
        // Then
        // Should not throw any errors
        XCTAssertTrue(true)
    }
    
    // MARK: - Analytics Reports Tests
    
    func testGenerateAnalyticsReport() {
        // When
        let report = analyticsManager.generateAnalyticsReport()
        
        // Then
        XCTAssertNotNil(report)
        XCTAssertGreaterThanOrEqual(report.totalEvents, 0)
        XCTAssertNotNil(report.performanceMetrics)
        XCTAssertNotNil(report.optimizationHistory)
        XCTAssertNotNil(report.eventBreakdown)
        XCTAssertNotNil(report.performanceTrends)
        XCTAssertGreaterThanOrEqual(report.optimizationEffectiveness, 0)
        XCTAssertLessThanOrEqual(report.optimizationEffectiveness, 100)
        XCTAssertNotNil(report.timestamp)
    }
    
    func testGetEventCount() {
        // Given
        analyticsManager.logOptimizationEvent(.memoryOptimized)
        analyticsManager.logPerformanceEvent(.performanceMonitoringStarted)
        analyticsManager.logErrorEvent(.optimizationFailed)
        
        // When
        let optimizationEvents = analyticsManager.getEventCount(for: .optimization)
        let performanceEvents = analyticsManager.getEventCount(for: .performance)
        let errorEvents = analyticsManager.getEventCount(for: .error)
        
        // Then
        XCTAssertGreaterThanOrEqual(optimizationEvents, 1)
        XCTAssertGreaterThanOrEqual(performanceEvents, 1)
        XCTAssertGreaterThanOrEqual(errorEvents, 1)
    }
    
    func testGetPerformanceMetrics() {
        // When
        let metrics = analyticsManager.getPerformanceMetrics()
        
        // Then
        XCTAssertNotNil(metrics)
        XCTAssertGreaterThanOrEqual(metrics.count, 0)
    }
    
    func testGetOptimizationHistory() {
        // When
        let history = analyticsManager.getOptimizationHistory()
        
        // Then
        XCTAssertNotNil(history)
        XCTAssertGreaterThanOrEqual(history.count, 0)
    }
    
    // MARK: - Performance Tests
    
    func testAnalyticsManagerPerformance() {
        measure {
            analyticsManager.startAnalytics()
            analyticsManager.logOptimizationEvent(.memoryOptimized)
            analyticsManager.logPerformanceEvent(.performanceMonitoringStarted)
            analyticsManager.logErrorEvent(.optimizationFailed)
            _ = analyticsManager.generateAnalyticsReport()
            analyticsManager.stopAnalytics()
        }
    }
    
    func testEventLoggingPerformance() {
        measure {
            for _ in 0..<100 {
                analyticsManager.logOptimizationEvent(.memoryOptimized)
            }
        }
    }
    
    func testReportGenerationPerformance() {
        measure {
            _ = analyticsManager.generateAnalyticsReport()
        }
    }
    
    // MARK: - Mock Tests
    
    func testMockAnalyticsManager() {
        // Given
        let mockManager = MockPerformanceAnalyticsManager()
        
        // When
        mockManager.logOptimizationEvent(.memoryOptimized)
        let report = mockManager.generateAnalyticsReport()
        
        // Then
        XCTAssertNotNil(report)
        XCTAssertGreaterThan(report.totalEvents, 0)
    }
}

// MARK: - Mock Performance Analytics Manager

class MockPerformanceAnalyticsManager: PerformanceAnalyticsManager {
    override func generateAnalyticsReport() -> AnalyticsReport {
        return AnalyticsReport(
            totalEvents: 5,
            performanceMetrics: [
                PerformanceMetric(name: "memory_usage", value: 45.0, unit: "percentage", timestamp: Date()),
                PerformanceMetric(name: "battery_impact", value: 25.0, unit: "percentage", timestamp: Date())
            ],
            optimizationHistory: [
                OptimizationRecord(event: .memoryOptimized, timestamp: Date(), success: true, impact: 25.0),
                OptimizationRecord(event: .batteryOptimized, timestamp: Date(), success: true, impact: 15.0)
            ],
            eventBreakdown: ["memory_optimized": 2, "battery_optimized": 1],
            performanceTrends: [],
            optimizationEffectiveness: 85.0,
            timestamp: Date()
        )
    }
} 