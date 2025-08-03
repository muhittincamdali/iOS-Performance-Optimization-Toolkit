import XCTest
import PerformanceOptimizationKit

final class BatteryOptimizerTests: XCTestCase {
    var batteryOptimizer: BatteryOptimizer!
    
    override func setUp() {
        super.setUp()
        batteryOptimizer = BatteryOptimizer()
    }
    
    override func tearDown() {
        batteryOptimizer = nil
        super.tearDown()
    }
    
    func testBatteryOptimizerInitialization() {
        let optimizer = BatteryOptimizer()
        XCTAssertNotNil(optimizer)
    }
    
    func testGetBatteryImpactScore() {
        let score = batteryOptimizer.getBatteryImpactScore()
        XCTAssertGreaterThanOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
    }
    
    func testGetBatteryStatistics() {
        let statistics = batteryOptimizer.getBatteryStatistics()
        XCTAssertNotNil(statistics)
        XCTAssertGreaterThanOrEqual(statistics.batteryLevel, 0)
        XCTAssertLessThanOrEqual(statistics.batteryLevel, 100)
    }
}
