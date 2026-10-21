import Foundation
import Testing
@testable import PerformanceOptimizationKit

@Suite("LeakTracker")
struct LeakTrackerTests {
    final class ViewModel {
        var onUpdate: (() -> Void)?
    }

    @Test("an object that is released is not reported")
    func releasedObject() async {
        let tracker = LeakTracker(gracePeriod: .milliseconds(100))
        var model: ViewModel? = ViewModel()
        let task = tracker.expectRelease(of: model!, name: "Released")
        model = nil
        #expect(await task.value == nil)
        #expect(tracker.pendingCount == 0)
    }

    @Test("an object kept alive by a retain cycle is reported")
    func retainCycle() async throws {
        let tracker = LeakTracker(gracePeriod: .milliseconds(100))
        let reports = tracker.reports()
        var model: ViewModel? = ViewModel()
        model!.onUpdate = { [model] in _ = model }
        let task = tracker.expectRelease(of: model!, name: "Profile")
        weak let weakModel = model
        model = nil
        let report = try #require(await task.value)
        #expect(report.name == "Profile")
        #expect(report.typeName.hasSuffix("ViewModel"))
        #expect(report.gracePeriod == .milliseconds(100))
        var iterator = reports.makeAsyncIterator()
        #expect(await iterator.next() == report)
        weakModel?.onUpdate = nil
    }

    @Test("cancelling the task stops tracking without a report")
    func cancellation() async {
        let tracker = LeakTracker(gracePeriod: .seconds(5))
        let model = ViewModel()
        let task = tracker.expectRelease(of: model, name: "Cancelled")
        task.cancel()
        #expect(await task.value == nil)
        withExtendedLifetime(model) {}
    }

    @Test("skips objects beyond the pending limit or with a name that is too long")
    func pendingLimit() async {
        let tracker = LeakTracker(gracePeriod: .milliseconds(100), maximumPending: 2)
        let models = (0..<4).map { _ in ViewModel() }
        let tasks = models.map { tracker.expectRelease(of: $0, name: "Model") }
        #expect(tracker.skippedCount == 2)
        #expect(await tasks[3].value == nil)
        for task in tasks { _ = await task.value }
        #expect(tracker.pendingCount == 0)
        withExtendedLifetime(models) {}

        let named = LeakTracker(gracePeriod: .milliseconds(100))
        let longest = String(repeating: "a", count: LeakTracker.maximumNameLength)
        let kept = named.expectRelease(of: models[0], name: longest)
        let tooLong = named.expectRelease(of: models[1], name: longest + "a")
        // 129 two-byte characters are 258 bytes.
        let tooLongInBytes = named.expectRelease(of: models[2], name: String(repeating: "é", count: 129))
        #expect(named.skippedCount == 2)
        #expect(await tooLong.value == nil)
        #expect(await tooLongInBytes.value == nil)
        #expect(await kept.value?.name == longest)
        withExtendedLifetime(models) {}
    }

    @Test("clamps grace period and limit")
    func clamps() {
        let tracker = LeakTracker(gracePeriod: .zero, maximumPending: 0)
        #expect(tracker.gracePeriod == .milliseconds(100))
        #expect(tracker.maximumPending == 1)
        #expect(LeakTracker(gracePeriod: .seconds(10_000)).gracePeriod == .seconds(600))
    }
}
