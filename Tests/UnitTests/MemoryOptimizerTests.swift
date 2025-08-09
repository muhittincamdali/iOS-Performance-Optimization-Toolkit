import XCTest
import PerformanceOptimizationKit

final class MemoryOptimizerTests: XCTestCase {
    var memoryOptimizer: MemoryOptimizer!
    
    override func setUp() {
        super.setUp()
        memoryOptimizer = MemoryOptimizer()
    }
    
    override func tearDown() {
        memoryOptimizer = nil
        super.tearDown()
    }
    
    func testMemoryOptimizerInitialization() {
        let optimizer = MemoryOptimizer()
        XCTAssertNotNil(optimizer)
    }
    
    func testGetMemoryUsage() {
        let usage = memoryOptimizer.getMemoryUsage()
        XCTAssertGreaterThanOrEqual(usage, 0)
        XCTAssertLessThanOrEqual(usage, 100)
    }
    
    func testGetMemoryStatistics() {
        let statistics = memoryOptimizer.getMemoryStatistics()
        XCTAssertNotNil(statistics)
        XCTAssertGreaterThan(statistics.totalMemory, 0)
    }
    
    func testDetectLeaks() {
        let leaks = memoryOptimizer.detectLeaks()
        XCTAssertNotNil(leaks)
        XCTAssertGreaterThanOrEqual(leaks.count, 0)
    }
}
