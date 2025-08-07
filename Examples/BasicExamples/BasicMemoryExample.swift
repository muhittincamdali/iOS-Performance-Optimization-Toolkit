import Foundation
import PerformanceOptimizationKit

/// Basic Memory Optimization Example
/// This example demonstrates fundamental memory optimization techniques
/// including memory leak detection, cleanup, and monitoring.

class BasicMemoryExample {
    
    // MARK: - Properties
    
    private let memoryLeakDetector = MemoryLeakDetector()
    private let memoryCleaner = MemoryCleaner()
    private let cacheOptimizer = CacheOptimizer()
    
    // MARK: - Initialization
    
    init() {
        setupMemoryOptimization()
    }
    
    // MARK: - Setup
    
    private func setupMemoryOptimization() {
        // Configure memory leak detector
        memoryLeakDetector.enableAutomaticDetection = true
        memoryLeakDetector.detectionThreshold = 0.1 // 10% memory growth
        
        // Configure memory cleaner
        memoryCleaner.enableAutomaticCleanup = true
        memoryCleaner.cleanupThreshold = 0.8 // 80% memory usage
        
        // Configure cache optimizer
        cacheOptimizer.maxCacheSize = 50 * 1024 * 1024 // 50MB
        cacheOptimizer.enableLRUStrategy = true
    }
    
    // MARK: - Memory Monitoring
    
    func startMemoryMonitoring() {
        print("🔍 Starting memory monitoring...")
        
        memoryLeakDetector.startMonitoring { memoryInfo in
            self.handleMemoryInfo(memoryInfo)
        }
    }
    
    private func handleMemoryInfo(_ memoryInfo: MemoryInfo) {
        print("📊 Memory Information:")
        print("   Used Memory: \(memoryInfo.usedMemory)MB")
        print("   Available Memory: \(memoryInfo.availableMemory)MB")
        print("   Memory Pressure: \(memoryInfo.pressureLevel)")
        
        if memoryInfo.isLeakDetected {
            print("⚠️ Memory leak detected!")
            handleMemoryLeak()
        }
        
        if memoryInfo.usedMemory > 200 { // 200MB threshold
            print("⚠️ High memory usage detected!")
            performMemoryCleanup()
        }
    }
    
    // MARK: - Memory Leak Handling
    
    private func handleMemoryLeak() {
        print("🔧 Handling memory leak...")
        
        let report = memoryLeakDetector.generateReport()
        print("📋 Memory Leak Report:")
        print("   Suspicious Objects: \(report.suspiciousObjects.count)")
        print("   Retain Cycles: \(report.retainCycles.count)")
        print("   Memory Growth Rate: \(report.growthRate)%/min")
        
        // Generate detailed report
        for leak in report.detectedLeaks {
            print("   ⚠️ Leak: \(leak.objectType) at \(leak.location)")
            print("      Size: \(leak.size) bytes")
            print("      Age: \(leak.age) seconds")
        }
    }
    
    // MARK: - Memory Cleanup
    
    private func performMemoryCleanup() {
        print("🧹 Performing memory cleanup...")
        
        memoryCleaner.performCleanup { result in
            print("✅ Memory Cleanup Completed:")
            print("   Freed Memory: \(result.freedMemory)MB")
            print("   Cleanup Duration: \(result.duration)s")
            print("   Cleanup Efficiency: \(result.efficiency)%")
        }
    }
    
    // MARK: - Cache Optimization
    
    func optimizeCache() {
        print("⚡ Optimizing cache...")
        
        cacheOptimizer.optimizeCache { stats in
            print("📊 Cache Statistics:")
            print("   Hit Rate: \(stats.hitRate)%")
            print("   Miss Rate: \(stats.missRate)%")
            print("   Current Size: \(stats.currentSize)MB")
            print("   Efficiency: \(stats.efficiency)%")
            
            if stats.hitRate < 70 {
                print("⚠️ Low cache hit rate detected!")
                self.improveCachePerformance()
            }
        }
    }
    
    private func improveCachePerformance() {
        print("🔧 Improving cache performance...")
        
        // Clear expired cache entries
        cacheOptimizer.clearExpiredCache()
        
        // Adjust cache settings
        cacheOptimizer.maxCacheSize = 100 * 1024 * 1024 // Increase to 100MB
        
        print("✅ Cache performance improvements applied")
    }
    
    // MARK: - Memory Pressure Handling
    
    func handleMemoryPressure() {
        print("⚠️ Handling memory pressure...")
        
        // Perform aggressive cleanup
        memoryCleaner.performCleanup { result in
            print("🧹 Aggressive cleanup completed:")
            print("   Freed Memory: \(result.freedMemory)MB")
            
            if result.freedMemory < 50 {
                print("⚠️ Insufficient memory freed!")
                self.performEmergencyCleanup()
            }
        }
    }
    
    private func performEmergencyCleanup() {
        print("🚨 Performing emergency cleanup...")
        
        // Clear all caches
        cacheOptimizer.clearExpiredCache()
        
        // Force garbage collection (if available)
        // Note: In iOS, ARC handles memory automatically
        
        print("✅ Emergency cleanup completed")
    }
    
    // MARK: - Memory Usage Analysis
    
    func analyzeMemoryUsage() {
        print("📊 Analyzing memory usage...")
        
        memoryCleaner.monitorMemoryUsage { usage in
            print("📈 Memory Usage Analysis:")
            print("   Current Usage: \(usage.usedMemory)MB")
            print("   Peak Usage: \(usage.peakMemory)MB")
            print("   Available Memory: \(usage.availableMemory)MB")
            print("   Memory Pressure: \(usage.pressureLevel)")
            
            // Calculate memory efficiency
            let efficiency = (usage.availableMemory / (usage.usedMemory + usage.availableMemory)) * 100
            print("   Memory Efficiency: \(efficiency)%")
            
            if efficiency < 20 {
                print("⚠️ Low memory efficiency detected!")
                self.optimizeMemoryUsage()
            }
        }
    }
    
    private func optimizeMemoryUsage() {
        print("🔧 Optimizing memory usage...")
        
        // Perform comprehensive cleanup
        performMemoryCleanup()
        
        // Optimize cache
        optimizeCache()
        
        // Adjust memory thresholds
        memoryCleaner.cleanupThreshold = 0.7 // More aggressive cleanup
        
        print("✅ Memory usage optimization completed")
    }
    
    // MARK: - Example Usage
    
    func runExample() {
        print("🚀 Running Basic Memory Optimization Example")
        print("==========================================")
        
        // Start memory monitoring
        startMemoryMonitoring()
        
        // Analyze current memory usage
        analyzeMemoryUsage()
        
        // Optimize cache
        optimizeCache()
        
        // Simulate memory pressure
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.handleMemoryPressure()
        }
        
        print("✅ Basic memory optimization example completed")
    }
}

// MARK: - Usage Example

/*
// Create and run the example
let example = BasicMemoryExample()
example.runExample()

// Expected output:
// 🚀 Running Basic Memory Optimization Example
// ==========================================
// 🔍 Starting memory monitoring...
// 📊 Memory Information:
//    Used Memory: 150MB
//    Available Memory: 850MB
//    Memory Pressure: Normal
// 📊 Memory Usage Analysis:
//    Current Usage: 150MB
//    Peak Usage: 200MB
//    Available Memory: 850MB
//    Memory Pressure: Normal
//    Memory Efficiency: 85%
// ⚡ Optimizing cache...
// 📊 Cache Statistics:
//    Hit Rate: 85%
//    Miss Rate: 15%
//    Current Size: 25MB
//    Efficiency: 90%
// ✅ Basic memory optimization example completed
*/
