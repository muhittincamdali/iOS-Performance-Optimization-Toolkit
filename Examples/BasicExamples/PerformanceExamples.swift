import SwiftUI
import PerformanceOptimizationKit

/**
 * Performance Examples
 * 
 * Comprehensive examples showing how to use PerformanceManager component
 * with different optimization features and configurations.
 */
struct PerformanceExamples: View {
    @StateObject private var performanceManager = PerformanceManager()
    @State private var performanceMetrics: PerformanceMetrics?
    @State private var memoryStatistics: MemoryStatistics?
    @State private var batteryStatistics: BatteryStatistics?
    @State private var cpuStatistics: CPUStatistics?
    @State private var uiStatistics: UIPerformanceStatistics?
    @State private var performanceReport: PerformanceReport?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Performance Optimization
                performanceOptimizationSection
                
                // Memory Management
                memoryManagementSection
                
                // Battery Optimization
                batteryOptimizationSection
                
                // CPU Optimization
                cpuOptimizationSection
                
                // UI Optimization
                uiOptimizationSection
                
                // Performance Monitoring
                performanceMonitoringSection
            }
            .padding()
        }
        .navigationTitle("Performance Examples")
        .onAppear {
            loadPerformanceData()
        }
    }
    
    // MARK: - Performance Optimization
    private var performanceOptimizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Optimization")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Optimize App Performance
                Button("Optimize App Performance") {
                    optimizeAppPerformance()
                }
                .buttonStyle(.borderedProminent)
                
                // Set Performance Level
                VStack(alignment: .leading, spacing: 8) {
                    Text("Performance Level:")
                        .font(.headline)
                    
                    HStack {
                        Button("Power Saving") {
                            setPerformanceLevel(.powerSaving)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Balanced") {
                            setPerformanceLevel(.balanced)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Performance") {
                            setPerformanceLevel(.performance)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Ultra Performance") {
                            setPerformanceLevel(.ultraPerformance)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Current Performance Level
                HStack {
                    Text("Current Level:")
                    Spacer()
                    Text(performanceManager.currentPerformanceLevel.rawValue)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Memory Management
    private var memoryManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Memory Management")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Optimize Memory
                Button("Optimize Memory") {
                    optimizeMemory()
                }
                .buttonStyle(.borderedProminent)
                
                // Detect Memory Leaks
                Button("Detect Memory Leaks") {
                    detectMemoryLeaks()
                }
                .buttonStyle(.borderedProminent)
                
                // Memory Statistics Display
                if let memoryStats = memoryStatistics {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Memory Statistics:")
                            .font(.headline)
                        
                        Text("• Usage: \(String(format: "%.1f", memoryStats.memoryUsagePercentage))%")
                        Text("• Available: \(formatBytes(memoryStats.availableMemory))")
                        Text("• Pressure: \(memoryStats.memoryPressure)")
                        Text("• Leaks: \(memoryStats.leakCount)")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Battery Optimization
    private var batteryOptimizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Battery Optimization")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Optimize Battery
                Button("Optimize Battery") {
                    optimizeBattery()
                }
                .buttonStyle(.borderedProminent)
                
                // Battery Statistics Display
                if let batteryStats = batteryStatistics {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Battery Statistics:")
                            .font(.headline)
                        
                        Text("• Level: \(String(format: "%.1f", batteryStats.batteryLevel))%")
                        Text("• Charging: \(batteryStats.isCharging ? "Yes" : "No")")
                        Text("• Temperature: \(String(format: "%.1f", batteryStats.batteryTemperature))°C")
                        Text("• Health: \(String(format: "%.1f", batteryStats.batteryHealth))%")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - CPU Optimization
    private var cpuOptimizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CPU Optimization")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Optimize CPU
                Button("Optimize CPU") {
                    optimizeCPU()
                }
                .buttonStyle(.borderedProminent)
                
                // CPU Statistics Display
                if let cpuStats = cpuStatistics {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CPU Statistics:")
                            .font(.headline)
                        
                        Text("• Usage: \(String(format: "%.1f", cpuStats.cpuUsage))%")
                        Text("• Threads: \(cpuStats.threadCount)")
                        Text("• Active: \(cpuStats.activeThreads)")
                        Text("• Temperature: \(String(format: "%.1f", cpuStats.cpuTemperature))°C")
                        Text("• Performance: \(String(format: "%.1f", cpuStats.performanceScore))%")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - UI Optimization
    private var uiOptimizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("UI Optimization")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Optimize UI
                Button("Optimize UI") {
                    optimizeUI()
                }
                .buttonStyle(.borderedProminent)
                
                // UI Statistics Display
                if let uiStats = uiStatistics {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("UI Performance:")
                            .font(.headline)
                        
                        Text("• Current FPS: \(String(format: "%.1f", uiStats.currentFPS))")
                        Text("• Average FPS: \(String(format: "%.1f", uiStats.averageFPS))")
                        Text("• Frame Drops: \(uiStats.frameDropCount)")
                        Text("• Rendering Time: \(String(format: "%.2f", uiStats.renderingTime))ms")
                        Text("• Animations: \(uiStats.animationCount)")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Performance Monitoring
    private var performanceMonitoringSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Monitoring")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Get Performance Metrics
                Button("Get Performance Metrics") {
                    getPerformanceMetrics()
                }
                .buttonStyle(.borderedProminent)
                
                // Get Performance Report
                Button("Get Performance Report") {
                    getPerformanceReport()
                }
                .buttonStyle(.borderedProminent)
                
                // Performance Metrics Display
                if let metrics = performanceMetrics {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Performance Metrics:")
                            .font(.headline)
                        
                        Text("• Memory: \(String(format: "%.1f", metrics.memoryUsage))%")
                        Text("• Battery: \(String(format: "%.1f", metrics.batteryImpact))%")
                        Text("• CPU: \(String(format: "%.1f", metrics.cpuUsage))%")
                        Text("• FPS: \(String(format: "%.1f", metrics.fps))")
                        Text("• Temperature: \(String(format: "%.1f", metrics.temperature))°C")
                        Text("• Network: \(String(format: "%.1f", metrics.networkLatency))ms")
                        
                        HStack {
                            Text("Status:")
                            Spacer()
                            Text(metrics.isOptimal ? "✅ Optimal" : "⚠️ Needs Optimization")
                                .foregroundColor(metrics.isOptimal ? .green : .orange)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func optimizeAppPerformance() {
        performanceManager.optimizeAppPerformance()
        print("App performance optimization enabled")
    }
    
    private func setPerformanceLevel(_ level: PerformanceManager.PerformanceLevel) {
        performanceManager.setPerformanceLevel(level)
        print("Performance level set to: \(level)")
    }
    
    private func optimizeMemory() {
        performanceManager.optimizeMemory()
        memoryStatistics = performanceManager.getMemoryStatistics()
        print("Memory optimization completed")
    }
    
    private func detectMemoryLeaks() {
        let leaks = performanceManager.detectMemoryLeaks()
        print("Detected \(leaks.count) memory leaks")
        
        for leak in leaks {
            print("Leak: \(leak.objectType), Size: \(formatBytes(leak.memorySize)), Severity: \(leak.severity)")
        }
    }
    
    private func optimizeBattery() {
        performanceManager.optimizeBattery()
        batteryStatistics = performanceManager.getBatteryStatistics()
        print("Battery optimization completed")
    }
    
    private func optimizeCPU() {
        performanceManager.optimizeCPU()
        cpuStatistics = performanceManager.getCPUStatistics()
        print("CPU optimization completed")
    }
    
    private func optimizeUI() {
        performanceManager.optimizeUI()
        uiStatistics = performanceManager.getUIPerformanceStatistics()
        print("UI optimization completed")
    }
    
    private func getPerformanceMetrics() {
        performanceMetrics = performanceManager.getPerformanceMetrics()
        print("Performance metrics retrieved")
    }
    
    private func getPerformanceReport() {
        performanceReport = performanceManager.getPerformanceReport()
        print("Performance report generated")
        
        if let report = performanceReport {
            print("Report contains \(report.recommendations.count) recommendations")
            for recommendation in report.recommendations {
                print("Recommendation: \(recommendation)")
            }
        }
    }
    
    private func loadPerformanceData() {
        performanceMetrics = performanceManager.getPerformanceMetrics()
        memoryStatistics = performanceManager.getMemoryStatistics()
        batteryStatistics = performanceManager.getBatteryStatistics()
        cpuStatistics = performanceManager.getCPUStatistics()
        uiStatistics = performanceManager.getUIPerformanceStatistics()
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Performance Level Extension
extension PerformanceManager.PerformanceLevel: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        switch rawValue {
        case "powerSaving": self = .powerSaving
        case "balanced": self = .balanced
        case "performance": self = .performance
        case "ultraPerformance": self = .ultraPerformance
        default: return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .powerSaving: return "Power Saving"
        case .balanced: return "Balanced"
        case .performance: return "Performance"
        case .ultraPerformance: return "Ultra Performance"
        }
    }
}

// MARK: - Previews
struct PerformanceExamples_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PerformanceExamples()
        }
    }
} 