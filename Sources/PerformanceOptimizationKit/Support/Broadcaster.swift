import Foundation
import os

/// Hands each value to every open `AsyncStream` made by ``stream()``.
///
/// Each stream buffers at most `bufferSize` values and drops the oldest when its reader falls
/// behind, so a reader that stops reading cannot make memory grow.
final class Broadcaster<Element: Sendable>: Sendable {
    private let continuations = OSAllocatedUnfairLock(initialState: [UUID: AsyncStream<Element>.Continuation]())
    private let bufferSize: Int

    init(bufferSize: Int = 64) {
        self.bufferSize = max(bufferSize, 1)
    }

    func stream() -> AsyncStream<Element> {
        let (stream, continuation) = AsyncStream<Element>.makeStream(bufferingPolicy: .bufferingNewest(bufferSize))
        let id = UUID()
        continuations.withLock { $0[id] = continuation }
        continuation.onTermination = { [weak self] _ in
            self?.continuations.withLock { _ = $0.removeValue(forKey: id) }
        }
        return stream
    }

    func yield(_ value: Element) {
        for continuation in continuations.withLock({ Array($0.values) }) {
            continuation.yield(value)
        }
    }

    func finish() {
        let finished = continuations.withLock { state in
            defer { state.removeAll() }
            return Array(state.values)
        }
        finished.forEach { $0.finish() }
    }

    deinit {
        finish()
    }
}
