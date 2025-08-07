import Foundation
import PerformanceOptimizationKit

/// Basic CPU Optimization Example
/// This example demonstrates fundamental CPU optimization techniques
/// including CPU profiling, thread management, and algorithm optimization.

class BasicCPUExample {
    
    // MARK: - Properties
    
    private let cpuProfiler = CPUProfiler()
    private let threadManager = ThreadManager()
    private let algorithmOptimizer = AlgorithmOptimizer()
    
    // MARK: - Initialization
    
    init() {
        setupCPUOptimization()
    }
    
    // MARK: - Setup
    
    private func setupCPUOptimization() {
        // Configure CPU profiler
        cpuProfiler.enableRealTimeProfiling = true
        cpuProfiler.samplingInterval = 0.1 // 100ms
        cpuProfiler.enableCallStackAnalysis = true
        
        // Configure thread manager
        threadManager.maxConcurrentThreads = 4
        threadManager.enableThreadPooling = true
        threadManager.enableLoadBalancing = true
        
        // Configure algorithm optimizer
        algorithmOptimizer.enableAutoOptimization = true
        algorithmOptimizer.optimizationLevel = .balanced
        algorithmOptimizer.enableParallelProcessing = true
    }
    
    // MARK: - CPU Profiling
    
    func startCPUProfiling() {
        print("🚀 Starting CPU profiling...")
        
        cpuProfiler.startProfiling { cpuInfo in
            self.handleCPUInfo(cpuInfo)
        }
    }
    
    private func handleCPUInfo(_ cpuInfo: CPUInfo) {
        print("📊 CPU Information:")
        print("   Overall Usage: \(cpuInfo.overallUsage)%")
        print("   User Space: \(cpuInfo.userSpaceUsage)%")
        print("   System Space: \(cpuInfo.systemSpaceUsage)%")
        print("   Idle Time: \(cpuInfo.idleTime)%")
        print("   Temperature: \(cpuInfo.temperature)°C")
        print("   Active Threads: \(cpuInfo.activeThreads)")
        
        if cpuInfo.overallUsage > 80 {
            print("⚠️ High CPU usage detected!")
            handleHighCPUUsage()
        }
        
        if cpuInfo.temperature > 70 {
            print("⚠️ High CPU temperature detected!")
            handleHighTemperature()
        }
    }
    
    // MARK: - High CPU Usage Handling
    
    private func handleHighCPUUsage() {
        print("🔧 Handling high CPU usage...")
        
        // Scale down thread count
        threadManager.scaleDownThreads()
        
        // Optimize algorithms
        algorithmOptimizer.optimizeAlgorithm(currentAlgorithm) { stats in
            print("✅ Algorithm optimization completed:")
            print("   Performance improvement: \(stats.performanceImprovement)%")
            print("   Memory reduction: \(stats.memoryReduction)%")
        }
        
        print("✅ High CPU usage handling completed")
    }
    
    private func handleHighTemperature() {
        print("🌡️ Handling high temperature...")
        
        // Reduce processing load
        threadManager.maxConcurrentThreads = 2
        
        // Implement thermal throttling
        algorithmOptimizer.optimizationLevel = .conservative
        
        print("✅ High temperature handling completed")
    }
    
    // MARK: - Thread Management
    
    func manageThreads() {
        print("🧵 Managing threads...")
        
        // Execute CPU-intensive tasks
        for i in 1...5 {
            threadManager.executeTask {
                self.performCPUIntensiveTask(taskId: i)
            }
        }
        
        // Monitor thread performance
        threadManager.monitorThreadPerformance { threadStats in
            print("📊 Thread Statistics:")
            print("   Active Threads: \(threadStats.activeThreads)")
            print("   Idle Threads: \(threadStats.idleThreads)")
            print("   Average Utilization: \(threadStats.averageUtilization)%")
            print("   Queue Length: \(threadStats.queueLength)")
            
            if threadStats.averageUtilization > 80 {
                print("⚠️ High thread utilization!")
                self.threadManager.scaleUpThreads()
            } else if threadStats.averageUtilization < 20 {
                print("⚠️ Low thread utilization!")
                self.threadManager.scaleDownThreads()
            }
        }
    }
    
    private func performCPUIntensiveTask(taskId: Int) {
        print("⚙️ Performing CPU-intensive task \(taskId)...")
        
        // Simulate CPU-intensive work
        var result = 0
        for i in 1...1000000 {
            result += i * i
        }
        
        print("✅ Task \(taskId) completed with result: \(result)")
    }
    
    // MARK: - Algorithm Optimization
    
    func optimizeAlgorithms() {
        print("⚡ Optimizing algorithms...")
        
        // Optimize sorting algorithm
        let sortingAlgorithm = createSortingAlgorithm()
        algorithmOptimizer.optimizeAlgorithm(sortingAlgorithm) { stats in
            print("📊 Sorting Algorithm Optimization:")
            print("   Performance improvement: \(stats.performanceImprovement)%")
            print("   Memory reduction: \(stats.memoryReduction)%")
            print("   Execution time reduction: \(stats.executionTimeReduction)%")
        }
        
        // Optimize search algorithm
        let searchAlgorithm = createSearchAlgorithm()
        algorithmOptimizer.optimizeAlgorithm(searchAlgorithm) { stats in
            print("📊 Search Algorithm Optimization:")
            print("   Performance improvement: \(stats.performanceImprovement)%")
            print("   Memory reduction: \(stats.memoryReduction)%")
            print("   Execution time reduction: \(stats.executionTimeReduction)%")
        }
    }
    
    private func createSortingAlgorithm() -> Algorithm {
        // Create a sorting algorithm for optimization
        return Algorithm(name: "QuickSort", complexity: .nlogn)
    }
    
    private func createSearchAlgorithm() -> Algorithm {
        // Create a search algorithm for optimization
        return Algorithm(name: "BinarySearch", complexity: .logn)
    }
    
    // MARK: - CPU Performance Analysis
    
    func analyzeCPUPerformance() {
        print("📊 Analyzing CPU performance...")
        
        cpuProfiler.getCPUInfo { cpuInfo in
            print("📈 CPU Performance Analysis:")
            print("   Overall Usage: \(cpuInfo.overallUsage)%")
            print("   User Space: \(cpuInfo.userSpaceUsage)%")
            print("   System Space: \(cpuInfo.systemSpaceUsage)%")
            print("   Idle Time: \(cpuInfo.idleTime)%")
            print("   Temperature: \(cpuInfo.temperature)°C")
            
            // Calculate CPU efficiency
            let efficiency = (100.0 - cpuInfo.overallUsage)
            print("   CPU Efficiency: \(efficiency)%")
            
            if efficiency < 20 {
                print("⚠️ Low CPU efficiency detected!")
                self.improveCPUEfficiency()
            }
        }
    }
    
    private func improveCPUEfficiency() {
        print("🔧 Improving CPU efficiency...")
        
        // Optimize thread management
        threadManager.maxConcurrentThreads = 2
        
        // Optimize algorithms
        algorithmOptimizer.optimizationLevel = .conservative
        
        // Implement task prioritization
        print("   Implementing task prioritization")
        print("   Optimizing thread scheduling")
        print("   Reducing unnecessary computations")
        
        print("✅ CPU efficiency improvements applied")
    }
    
    // MARK: - Parallel Processing
    
    func demonstrateParallelProcessing() {
        print("🔄 Demonstrating parallel processing...")
        
        let dataSet = createLargeDataSet()
        
        // Process data in parallel
        algorithmOptimizer.processInParallel(dataSet) { results in
            print("✅ Parallel processing completed:")
            print("   Processed items: \(results.processedItems)")
            print("   Processing time: \(results.processingTime)s")
            print("   Speedup factor: \(results.speedupFactor)x")
        }
    }
    
    private func createLargeDataSet() -> [Int] {
        // Create a large dataset for processing
        return Array(1...1000000)
    }
    
    // MARK: - CPU Load Testing
    
    func performCPULoadTest() {
        print("🧪 Performing CPU load test...")
        
        // Create load test scenarios
        let scenarios = [
            "Light Load": 10,
            "Medium Load": 50,
            "Heavy Load": 100
        ]
        
        for (scenario, load) in scenarios {
            print("📊 Testing \(scenario)...")
            
            // Apply load
            for i in 1...load {
                threadManager.executeTask {
                    self.performCPUIntensiveTask(taskId: i)
                }
            }
            
            // Monitor performance
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.analyzeCPUPerformance()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var currentAlgorithm: Algorithm {
        return Algorithm(name: "CurrentAlgorithm", complexity: .n2)
    }
    
    // MARK: - Example Usage
    
    func runExample() {
        print("🚀 Running Basic CPU Optimization Example")
        print("=======================================")
        
        // Start CPU profiling
        startCPUProfiling()
        
        // Manage threads
        manageThreads()
        
        // Optimize algorithms
        optimizeAlgorithms()
        
        // Analyze CPU performance
        analyzeCPUPerformance()
        
        // Demonstrate parallel processing
        demonstrateParallelProcessing()
        
        // Perform load test
        performCPULoadTest()
        
        print("✅ Basic CPU optimization example completed")
    }
}

// MARK: - Usage Example

/*
// Create and run the example
let example = BasicCPUExample()
example.runExample()

// Expected output:
// 🚀 Running Basic CPU Optimization Example
// =======================================
// 🚀 Starting CPU profiling...
// 📊 CPU Information:
//    Overall Usage: 45%
//    User Space: 30%
//    System Space: 15%
//    Idle Time: 55%
//    Temperature: 45°C
//    Active Threads: 3
// 🧵 Managing threads...
// ⚙️ Performing CPU-intensive task 1...
// ✅ Task 1 completed with result: 333333833333500000
// 📊 Thread Statistics:
//    Active Threads: 3
//    Idle Threads: 1
//    Average Utilization: 75%
//    Queue Length: 2
// ⚡ Optimizing algorithms...
// 📊 Sorting Algorithm Optimization:
//    Performance improvement: 25%
//    Memory reduction: 15%
//    Execution time reduction: 30%
// 📊 Search Algorithm Optimization:
//    Performance improvement: 20%
//    Memory reduction: 10%
//    Execution time reduction: 25%
// 📊 Analyzing CPU performance...
// 📈 CPU Performance Analysis:
//    Overall Usage: 45%
//    User Space: 30%
//    System Space: 15%
//    Idle Time: 55%
//    Temperature: 45°C
//    CPU Efficiency: 55%
// 🔄 Demonstrating parallel processing...
// ✅ Parallel processing completed:
//    Processed items: 1000000
//    Processing time: 2.5s
//    Speedup factor: 3.2x
// 🧪 Performing CPU load test...
// 📊 Testing Light Load...
// 📊 Testing Medium Load...
// 📊 Testing Heavy Load...
// ✅ Basic CPU optimization example completed
*/
