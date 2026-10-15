import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("FieldHistogram")
struct FieldHistogramTests {
    // 10 launches of 0.1 to 0.2 s, 30 of 0.2 to 0.3 s, 10 of 0.3 to 0.4 s, unsorted.
    private let launches = FieldHistogram(buckets: [
        .init(lowerBound: 0.2, upperBound: 0.3, count: 30),
        .init(lowerBound: 0.1, upperBound: 0.2, count: 10),
        .init(lowerBound: 0.3, upperBound: 0.4, count: 10),
    ])

    @Test("sorts buckets and estimates percentiles inside them")
    func percentiles() throws {
        #expect(launches.buckets.map(\.lowerBound) == [0.1, 0.2, 0.3])
        #expect(launches.totalCount == 50)
        #expect(abs(try #require(launches.percentile(0.5)) - 0.25) < 1e-9)
        #expect(abs(try #require(launches.percentile(0.1)) - 0.15) < 1e-9)
        #expect(launches.percentile(0) == 0.1)
        #expect(launches.percentile(1) == 0.4)
        #expect(launches.percentile(.nan) == nil)
        #expect(launches.percentile(7) == 0.4)
    }

    @Test("estimates the mean from bucket middles")
    func mean() throws {
        #expect(abs(try #require(launches.mean) - 0.25) < 1e-9)
    }

    @Test("estimates the share at or above a value")
    func fractionAbove() throws {
        #expect(abs(try #require(launches.fraction(atOrAbove: 0.3)) - 0.2) < 1e-9)
        #expect(abs(try #require(launches.fraction(atOrAbove: 0.35)) - 0.1) < 1e-9)
        #expect(launches.fraction(atOrAbove: 0) == 1)
        #expect(launches.fraction(atOrAbove: .nan) == nil)
    }

    @Test("leaves out damaged buckets")
    func dropsInvalidBuckets() {
        let histogram = FieldHistogram(buckets: [
            .init(lowerBound: .nan, upperBound: 1, count: 5),
            .init(lowerBound: 0, upperBound: .infinity, count: 5),
            .init(lowerBound: 2, upperBound: 1, count: 5),
            .init(lowerBound: 0, upperBound: 1, count: 0),
            .init(lowerBound: 0, upperBound: 1, count: -9),
            .init(lowerBound: -1e308, upperBound: 1e308, count: 5),
            .init(lowerBound: 1, upperBound: 2, count: 3),
        ])
        #expect(histogram.buckets == [.init(lowerBound: 1, upperBound: 2, count: 3)])
    }

    @Test("an empty histogram has no estimates")
    func empty() {
        let histogram = FieldHistogram(buckets: [])
        #expect(histogram.isEmpty)
        #expect(histogram.percentile(0.5) == nil)
        #expect(histogram.mean == nil)
        #expect(histogram.fraction(atOrAbove: 1) == nil)
    }

    @Test("counts that add up past Int.max stop there")
    func saturatingTotal() throws {
        let histogram = FieldHistogram(buckets: [
            .init(lowerBound: 0, upperBound: 1, count: .max),
            .init(lowerBound: 1, upperBound: 2, count: .max),
        ])
        #expect(histogram.totalCount == .max)
        #expect(try #require(histogram.percentile(0.5)).isFinite)
    }

    @Test("keeps at most maximumBucketCount buckets")
    func bucketLimit() {
        let many = (0..<20_000).map { FieldHistogram.Bucket(lowerBound: Double($0), upperBound: Double($0) + 1, count: 1) }
        #expect(FieldHistogram(buckets: many).buckets.count == FieldHistogram.maximumBucketCount)
    }

    @Test("checks buckets when decoding")
    func decodingValidates() throws {
        let json = Data(#"{"buckets":[{"lowerBound":0,"upperBound":1,"count":-4},{"lowerBound":3,"upperBound":1,"count":2},{"lowerBound":0.5,"upperBound":0.75,"count":2}]}"#.utf8)
        let histogram = try JSONDecoder().decode(FieldHistogram.self, from: json)
        #expect(histogram.buckets == [.init(lowerBound: 0.5, upperBound: 0.75, count: 2)])
    }
}

@Suite("FieldMetrics")
struct FieldMetricsTests {
    @Test("round-trips through JSON")
    func roundTrip() throws {
        let metrics = FieldMetrics(
            periodStart: Date(timeIntervalSince1970: 1_700_000_000),
            periodEnd: Date(timeIntervalSince1970: 1_700_086_400),
            appBuild: "42",
            timeToFirstDraw: FieldHistogram(buckets: [.init(lowerBound: 0.2, upperBound: 0.3, count: 12)]),
            hitchTimeRatio: 3.5,
            peakMemoryBytes: 210_000_000,
            cpuTime: 81,
            foregroundTerminations: .init(normal: 30, memoryLimit: 2, watchdog: 1)
        )
        let decoded = try JSONDecoder().decode(FieldMetrics.self, from: JSONEncoder().encode(metrics))
        #expect(decoded == metrics)
    }

    @Test("decoding drops negative figures")
    func decodingValidates() throws {
        let json = Data(#"{"hitchTimeRatio":-3,"cpuTime":-1,"foregroundTerminations":{"memoryLimit":-5,"watchdog":2}}"#.utf8)
        let metrics = try JSONDecoder().decode(FieldMetrics.self, from: json)
        #expect(metrics.hitchTimeRatio == nil)
        #expect(metrics.cpuTime == nil)
        #expect(metrics.foregroundTerminations == .init(watchdog: 2))
    }

    @Test("unexpected terminations add up without overflowing")
    func unexpectedTerminations() {
        #expect(FieldMetrics.Terminations(normal: 9, memoryLimit: 2, watchdog: 1, badAccess: 1).unexpected == 4)
        #expect(FieldMetrics.Terminations(memoryLimit: .max, watchdog: .max).unexpected == .max)
    }
}
