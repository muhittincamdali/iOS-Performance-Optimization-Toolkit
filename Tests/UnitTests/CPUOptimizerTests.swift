import XCTest
import PerformanceOptimizationKit

final class CPUOptimizerTests: XCTestCase {
    var cpuOptimizer: CPUOptimizer!
    
    override func setUp() {
        super.setUp()
        cpuOptimizer = CPUOptimizer()
    }
    
    override func tearDown() {
        cpuOptimizer = nil
        super.tearDown()
    }
    
    func testCPUOptimizerInitialization() {
        let optimizer = CPUOptimizer()
        XCTAssertNotNil(optimizer)
    }
    
    func testGetCPUUsage() {
        let usage = cpuOptimizer.getCPUUsage()
        XCTAssertNotNil(usage)
        XCTAssertGreaterOrEqual(usage.current, 0)
        XCTAssertLessThanOrEqual(usage.current, 100)
    }
    
    func testGetCPUStatistics() {
        let statistics = cpuOptimizer.getCPUStatistics()
        XCTAssertNotNil(statistics)
        XCTAssertGreaterOrEqual(statistics.cpuUsage, 0)
        XCTAssertLessThanOrEqual(statistics.cpuUsage, 100)
    }
    
    func testGetPerformanceScore() {
        let score = cpuOptimizer.getPerformanceScore()
        XCTAssertGreaterOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
    }
}
