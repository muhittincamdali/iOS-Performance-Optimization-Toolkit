import Foundation

/// Analyzes task execution times to prevent concurrency stalls.
public actor ConcurrencyProfiler {
    public static let shared = ConcurrencyProfiler()
    
    private var activeTasks: [UUID: Date] = [:]
    private var metrics: [String: TimeInterval] = [:]
    
    private init() {}
    
    public func startTask(name: String) -> UUID {
        let id = UUID()
        activeTasks[id] = Date()
        return id
    }
    
    public func endTask(id: UUID, name: String) {
        guard let start = activeTasks.removeValue(forKey: id) else { return }
        let duration = Date().timeIntervalSince(start)
        metrics[name, default: 0] += duration
        
        if duration > 0.1 {
            print("⏳ [Performance] Long task detected: \\(name) took \\(String(format: \"%.2f\", duration * 1000))ms")
        }
    }
    
    public func printReport() {
        print("📊 [Performance] Concurrency Report:")
        for (name, duration) in metrics {
            print(" - \\(name): \\(String(format: \"%.2f\", duration * 1000))ms total")
        }
    }
}

/// A wrapper to easily profile async operations
public func profileAsync<T: Sendable>(name: String, operation: @Sendable () async throws -> T) async throws -> T {
    let id = await ConcurrencyProfiler.shared.startTask(name: name)
    defer {
        Task { await ConcurrencyProfiler.shared.endTask(id: id, name: name) }
    }
    return try await operation()
}
