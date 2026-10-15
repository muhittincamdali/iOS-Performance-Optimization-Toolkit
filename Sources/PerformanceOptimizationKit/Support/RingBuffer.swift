/// A first-in, first-out buffer that keeps at most `capacity` elements.
///
/// Appending to a full buffer drops the oldest element, so memory stays bounded however long a
/// monitor runs. The toolkit uses it for frame intervals, trace durations and hang events.
public struct RingBuffer<Element> {
    /// The largest capacity a buffer accepts. Larger requests are clamped to it.
    public static var maximumCapacity: Int { 1_000_000 }

    /// The number of elements the buffer keeps before it drops the oldest one.
    public let capacity: Int

    private var storage: [Element] = []
    private var head = 0

    /// Creates an empty buffer.
    ///
    /// - Parameter capacity: The number of elements to keep. Values below 1 become 1 and values
    ///   above ``maximumCapacity`` become ``maximumCapacity``.
    public init(capacity: Int) {
        self.capacity = min(max(capacity, 1), Self.maximumCapacity)
    }

    /// The number of elements in the buffer.
    public var count: Int { storage.count }

    /// A Boolean value that indicates whether the buffer is empty.
    public var isEmpty: Bool { storage.isEmpty }

    /// The elements from the oldest to the newest.
    public var elements: [Element] {
        guard storage.count == capacity, head > 0 else { return storage }
        return Array(storage[head...] + storage[..<head])
    }

    /// The most recently appended element.
    public var last: Element? {
        guard !storage.isEmpty else { return nil }
        guard storage.count == capacity else { return storage.last }
        return storage[(head + capacity - 1) % capacity]
    }

    /// Appends an element, dropping the oldest one when the buffer is full.
    public mutating func append(_ element: Element) {
        if storage.count < capacity {
            storage.append(element)
            return
        }
        storage[head] = element
        head = (head + 1) % capacity
    }

    /// Removes every element and keeps the capacity.
    public mutating func removeAll() {
        storage.removeAll(keepingCapacity: true)
        head = 0
    }
}

extension RingBuffer: Sendable where Element: Sendable {}
extension RingBuffer: Equatable where Element: Equatable {
    public static func == (lhs: RingBuffer, rhs: RingBuffer) -> Bool {
        lhs.capacity == rhs.capacity && lhs.elements == rhs.elements
    }
}
