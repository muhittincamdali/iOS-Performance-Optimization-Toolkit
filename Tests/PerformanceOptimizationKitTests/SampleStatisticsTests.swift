import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("SampleStatistics")
struct SampleStatisticsTests {
    @Test("computes the figures of a known set")
    func knownValues() throws {
        let statistics = try #require(SampleStatistics([4, 1, 3, 2]))
        #expect(statistics.count == 4)
        #expect(statistics.minimum == 1)
        #expect(statistics.maximum == 4)
        #expect(statistics.mean == 2.5)
        #expect(abs(statistics.standardDeviation - 1.25.squareRoot()) < 1e-12)
        #expect(statistics.p50 == 2.5)
        #expect(abs(statistics.p90 - 3.7) < 1e-12)
    }

    @Test("returns nil when no value is finite")
    func emptyOrInvalid() {
        #expect(SampleStatistics([]) == nil)
        #expect(SampleStatistics([.nan, .infinity, -.infinity]) == nil)
    }

    @Test("leaves NaN and infinity out instead of returning NaN")
    func ignoresNonFinite() throws {
        let statistics = try #require(SampleStatistics([1, .nan, 3, .infinity]))
        #expect(statistics.count == 2)
        #expect(statistics.mean == 2)
    }

    @Test("a single value is every percentile")
    func singleValue() throws {
        let statistics = try #require(SampleStatistics([0.3]))
        #expect(statistics.p50 == 0.3)
        #expect(statistics.p99 == 0.3)
        #expect(statistics.standardDeviation == 0)
    }

    @Test("stays finite for values near the largest Double")
    func extremeMagnitudes() throws {
        let statistics = try #require(SampleStatistics([.greatestFiniteMagnitude, .greatestFiniteMagnitude, -.greatestFiniteMagnitude]))
        #expect(statistics.mean.isFinite)
        #expect(statistics.p50.isFinite)
        #expect(statistics.p90.isFinite)
    }

    @Test("clamps the percentile fraction and rejects NaN")
    func percentileBounds() {
        #expect(SampleStatistics.percentile(-1, of: [1, 2, 3]) == 1)
        #expect(SampleStatistics.percentile(5, of: [1, 2, 3]) == 3)
        #expect(SampleStatistics.percentile(.nan, of: [1, 2, 3]) == nil)
        #expect(SampleStatistics.percentile(0.5, of: []) == nil)
    }

    @Test("converts durations to seconds")
    func durations() throws {
        let statistics = try #require(SampleStatistics(durations: [.milliseconds(100), .milliseconds(300)]))
        #expect(abs(statistics.mean - 0.2) < 1e-12)
    }
}
