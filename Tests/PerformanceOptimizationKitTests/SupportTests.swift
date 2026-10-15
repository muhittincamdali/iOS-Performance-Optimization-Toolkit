import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("RingBuffer")
struct RingBufferTests {
    @Test("keeps the newest elements in order after wrapping")
    func wrapsInOrder() {
        var buffer = RingBuffer<Int>(capacity: 3)
        for value in 1...7 { buffer.append(value) }
        #expect(buffer.elements == [5, 6, 7])
        #expect(buffer.count == 3)
        #expect(buffer.last == 7)
    }

    @Test("returns elements in order before it is full")
    func partiallyFilled() {
        var buffer = RingBuffer<Int>(capacity: 4)
        buffer.append(1)
        buffer.append(2)
        #expect(buffer.elements == [1, 2])
        #expect(buffer.last == 2)
    }

    @Test("clamps the capacity", arguments: [(-5, 1), (0, 1), (2_000_000, 1_000_000)])
    func clampsCapacity(requested: Int, expected: Int) {
        #expect(RingBuffer<Int>(capacity: requested).capacity == expected)
    }

    @Test("removeAll empties the buffer and keeps working")
    func removeAll() {
        var buffer = RingBuffer<Int>(capacity: 2)
        [1, 2, 3].forEach { buffer.append($0) }
        buffer.removeAll()
        #expect(buffer.isEmpty)
        #expect(buffer.last == nil)
        buffer.append(9)
        #expect(buffer.elements == [9])
    }

    @Test("compares by contents, not by internal layout")
    func equality() {
        var wrapped = RingBuffer<Int>(capacity: 2)
        [1, 2, 3].forEach { wrapped.append($0) }
        var direct = RingBuffer<Int>(capacity: 2)
        [2, 3].forEach { direct.append($0) }
        #expect(wrapped == direct)
    }
}

@Suite("Numeric conversion")
struct NumericConversionTests {
    @Test("Int conversion never traps", arguments: [
        (Double.nan, nil), (.infinity, nil), (-.infinity, nil),
        (1e300, Int.max), (-1e300, Int.min), (9.223372036854775807e18, Int.max), (42.9, 42), (-42.9, -42),
    ] as [(Double, Int?)])
    func clampedInt(value: Double, expected: Int?) {
        #expect(value.clampedInt == expected)
    }

    @Test("UInt64 conversion never traps", arguments: [
        (Double.nan, nil), (.infinity, nil), (-1, nil), (1e30, UInt64.max), (1_048_576.5, 1_048_576),
    ] as [(Double, UInt64?)])
    func clampedUInt64(value: Double, expected: UInt64?) {
        #expect(value.clampedUInt64 == expected)
    }

    @Test("saturating addition stops at the bounds")
    func saturatingAdd() {
        #expect(Int.max.saturatingAdd(1) == .max)
        #expect(Int.min.saturatingAdd(-1) == .min)
        #expect(2.saturatingAdd(3) == 5)
    }

    @Test("durations from seconds reject invalid values")
    func validSeconds() {
        #expect(Duration.validSeconds(.nan) == nil)
        #expect(Duration.validSeconds(-0.001) == nil)
        #expect(Duration.validSeconds(.infinity) == nil)
        #expect(Duration.validSeconds(1e300) == nil)
        #expect(Duration.validSeconds(0.25) == .milliseconds(250))
    }
}
