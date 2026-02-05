//
//  SystemMetrics.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import Foundation
import Darwin
import MachO

// MARK: - System Metrics Provider
/// Real-time system metrics using Mach kernel APIs
public final class SystemMetrics {
    
    // MARK: - Singleton
    public static let shared = SystemMetrics()
    private init() {
        setupProcessInfo()
    }
    
    // MARK: - Properties
    private var hostPort: mach_port_t = 0
    private var selfTask: mach_port_t = 0
    private let metricsQueue = DispatchQueue(label: "com.performancekit.metrics", qos: .utility)
    private var previousCPUInfo: host_cpu_load_info?
    private var previousSampleTime: Date?
    
    // MARK: - Setup
    private func setupProcessInfo() {
        hostPort = mach_host_self()
        selfTask = mach_task_self_
    }
    
    // MARK: - Memory Metrics
    
    /// Get current memory usage in bytes
    public func getMemoryUsage() -> MemoryInfo {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(selfTask, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return MemoryInfo()
        }
        
        // Get VM statistics
        var vmStats = vm_statistics64()
        var vmCount = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        
        let vmResult = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(vmCount)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &vmCount)
            }
        }
        
        let pageSize = UInt64(vm_kernel_page_size)
        
        var totalMemory: UInt64 = 0
        var freeMemory: UInt64 = 0
        var activeMemory: UInt64 = 0
        var inactiveMemory: UInt64 = 0
        var wiredMemory: UInt64 = 0
        var compressedMemory: UInt64 = 0
        
        if vmResult == KERN_SUCCESS {
            totalMemory = UInt64(ProcessInfo.processInfo.physicalMemory)
            freeMemory = UInt64(vmStats.free_count) * pageSize
            activeMemory = UInt64(vmStats.active_count) * pageSize
            inactiveMemory = UInt64(vmStats.inactive_count) * pageSize
            wiredMemory = UInt64(vmStats.wire_count) * pageSize
            compressedMemory = UInt64(vmStats.compressor_page_count) * pageSize
        }
        
        return MemoryInfo(
            residentSize: info.resident_size,
            virtualSize: info.virtual_size,
            residentSizeMax: info.resident_size_max,
            totalPhysicalMemory: totalMemory,
            freeMemory: freeMemory,
            activeMemory: activeMemory,
            inactiveMemory: inactiveMemory,
            wiredMemory: wiredMemory,
            compressedMemory: compressedMemory,
            timestamp: Date()
        )
    }
    
    /// Get memory footprint (actual memory impact)
    public func getMemoryFootprint() -> UInt64 {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(selfTask, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return 0 }
        return info.phys_footprint
    }
    
    /// Get memory pressure level
    public func getMemoryPressure() -> MemoryPressureLevel {
        var status = DispatchSource.MemoryPressureEvent.normal
        
        // Use dispatch source to check memory pressure
        let source = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: nil)
        status = source.data
        source.cancel()
        
        switch status {
        case .normal:
            return .normal
        case .warning:
            return .warning
        case .critical:
            return .critical
        default:
            return .normal
        }
    }
    
    // MARK: - CPU Metrics
    
    /// Get current CPU usage percentage (0-100)
    public func getCPUUsage() -> CPUInfo {
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t()
        
        let result = task_threads(selfTask, &threadList, &threadCount)
        guard result == KERN_SUCCESS, let threads = threadList else {
            return CPUInfo()
        }
        
        defer {
            vm_deallocate(selfTask, vm_address_t(bitPattern: threads), vm_size_t(Int(threadCount) * MemoryLayout<thread_act_t>.stride))
        }
        
        var totalUserTime: Double = 0
        var totalSystemTime: Double = 0
        var threadInfos: [ThreadCPUInfo] = []
        
        for i in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var infoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            
            let infoResult = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &infoCount)
                }
            }
            
            guard infoResult == KERN_SUCCESS else { continue }
            
            if info.flags & TH_FLAGS_IDLE == 0 {
                let userTime = Double(info.user_time.seconds) + Double(info.user_time.microseconds) / 1_000_000
                let systemTime = Double(info.system_time.seconds) + Double(info.system_time.microseconds) / 1_000_000
                
                totalUserTime += userTime
                totalSystemTime += systemTime
                
                threadInfos.append(ThreadCPUInfo(
                    threadId: UInt64(threads[i]),
                    cpuUsage: Double(info.cpu_usage) / Double(TH_USAGE_SCALE) * 100,
                    userTime: userTime,
                    systemTime: systemTime,
                    state: ThreadState(rawValue: Int(info.run_state)) ?? .unknown,
                    priority: Int(info.policy)
                ))
            }
        }
        
        // Calculate total CPU usage
        let totalUsage = threadInfos.reduce(0) { $0 + $1.cpuUsage }
        
        // Get system-wide CPU
        let systemCPU = getSystemCPUUsage()
        
        return CPUInfo(
            processUsage: min(totalUsage, 100 * Double(ProcessInfo.processInfo.activeProcessorCount)),
            userUsage: totalUserTime,
            systemUsage: totalSystemTime,
            systemWideUsage: systemCPU.total,
            systemWideUser: systemCPU.user,
            systemWideSystem: systemCPU.system,
            systemWideIdle: systemCPU.idle,
            threadCount: Int(threadCount),
            activeThreads: threadInfos.filter { $0.state == .running }.count,
            threads: threadInfos,
            timestamp: Date()
        )
    }
    
    /// Get system-wide CPU usage
    private func getSystemCPUUsage() -> (total: Double, user: Double, system: Double, idle: Double) {
        var cpuInfo: host_cpu_load_info?
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride)
        
        var cpuLoadInfo = host_cpu_load_info()
        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(hostPort, HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return (0, 0, 0, 0)
        }
        
        cpuInfo = cpuLoadInfo
        
        guard let current = cpuInfo, let previous = previousCPUInfo else {
            previousCPUInfo = cpuInfo
            previousSampleTime = Date()
            return (0, 0, 0, 0)
        }
        
        let userDiff = Double(current.cpu_ticks.0 - previous.cpu_ticks.0)
        let systemDiff = Double(current.cpu_ticks.1 - previous.cpu_ticks.1)
        let idleDiff = Double(current.cpu_ticks.2 - previous.cpu_ticks.2)
        let niceDiff = Double(current.cpu_ticks.3 - previous.cpu_ticks.3)
        
        let totalDiff = userDiff + systemDiff + idleDiff + niceDiff
        
        guard totalDiff > 0 else {
            return (0, 0, 0, 100)
        }
        
        previousCPUInfo = cpuInfo
        previousSampleTime = Date()
        
        return (
            total: ((userDiff + systemDiff + niceDiff) / totalDiff) * 100,
            user: (userDiff / totalDiff) * 100,
            system: (systemDiff / totalDiff) * 100,
            idle: (idleDiff / totalDiff) * 100
        )
    }
    
    // MARK: - Disk I/O Metrics
    
    /// Get disk usage information
    public func getDiskUsage() -> DiskInfo {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) else {
            return DiskInfo()
        }
        
        let totalSpace = (attributes[.systemSize] as? NSNumber)?.uint64Value ?? 0
        let freeSpace = (attributes[.systemFreeSize] as? NSNumber)?.uint64Value ?? 0
        let usedSpace = totalSpace - freeSpace
        
        return DiskInfo(
            totalSpace: totalSpace,
            freeSpace: freeSpace,
            usedSpace: usedSpace,
            usagePercentage: totalSpace > 0 ? Double(usedSpace) / Double(totalSpace) * 100 : 0,
            timestamp: Date()
        )
    }
    
    // MARK: - Network I/O Metrics
    
    /// Get network interface statistics
    public func getNetworkStats() -> NetworkInfo {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return NetworkInfo()
        }
        
        defer { freeifaddrs(ifaddr) }
        
        var bytesIn: UInt64 = 0
        var bytesOut: UInt64 = 0
        var packetsIn: UInt64 = 0
        var packetsOut: UInt64 = 0
        
        var addr = firstAddr
        while true {
            let name = String(cString: addr.pointee.ifa_name)
            
            // Filter for relevant interfaces (en0 = WiFi, pdp_ip0 = Cellular)
            if name.hasPrefix("en") || name.hasPrefix("pdp_ip") {
                if let data = addr.pointee.ifa_data {
                    let networkData = data.assumingMemoryBound(to: if_data.self).pointee
                    bytesIn += UInt64(networkData.ifi_ibytes)
                    bytesOut += UInt64(networkData.ifi_obytes)
                    packetsIn += UInt64(networkData.ifi_ipackets)
                    packetsOut += UInt64(networkData.ifi_opackets)
                }
            }
            
            guard let next = addr.pointee.ifa_next else { break }
            addr = next
        }
        
        return NetworkInfo(
            bytesReceived: bytesIn,
            bytesSent: bytesOut,
            packetsReceived: packetsIn,
            packetsSent: packetsOut,
            timestamp: Date()
        )
    }
    
    // MARK: - Device Info
    
    /// Get device and system information
    public func getDeviceInfo() -> DeviceInfo {
        var sysinfo = utsname()
        uname(&sysinfo)
        
        let machine = withUnsafePointer(to: &sysinfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        
        let processInfo = ProcessInfo.processInfo
        
        return DeviceInfo(
            model: machine,
            systemVersion: processInfo.operatingSystemVersionString,
            processorCount: processInfo.processorCount,
            activeProcessorCount: processInfo.activeProcessorCount,
            physicalMemory: processInfo.physicalMemory,
            systemUptime: processInfo.systemUptime,
            thermalState: ThermalState(rawValue: processInfo.thermalState.rawValue) ?? .nominal,
            isLowPowerModeEnabled: processInfo.isLowPowerModeEnabled
        )
    }
}

// MARK: - Data Types

public struct MemoryInfo: Codable, Sendable {
    public let residentSize: UInt64
    public let virtualSize: UInt64
    public let residentSizeMax: UInt64
    public let totalPhysicalMemory: UInt64
    public let freeMemory: UInt64
    public let activeMemory: UInt64
    public let inactiveMemory: UInt64
    public let wiredMemory: UInt64
    public let compressedMemory: UInt64
    public let timestamp: Date
    
    public init(
        residentSize: UInt64 = 0,
        virtualSize: UInt64 = 0,
        residentSizeMax: UInt64 = 0,
        totalPhysicalMemory: UInt64 = 0,
        freeMemory: UInt64 = 0,
        activeMemory: UInt64 = 0,
        inactiveMemory: UInt64 = 0,
        wiredMemory: UInt64 = 0,
        compressedMemory: UInt64 = 0,
        timestamp: Date = Date()
    ) {
        self.residentSize = residentSize
        self.virtualSize = virtualSize
        self.residentSizeMax = residentSizeMax
        self.totalPhysicalMemory = totalPhysicalMemory
        self.freeMemory = freeMemory
        self.activeMemory = activeMemory
        self.inactiveMemory = inactiveMemory
        self.wiredMemory = wiredMemory
        self.compressedMemory = compressedMemory
        self.timestamp = timestamp
    }
    
    /// Memory usage percentage (0-100)
    public var usagePercentage: Double {
        guard totalPhysicalMemory > 0 else { return 0 }
        return Double(residentSize) / Double(totalPhysicalMemory) * 100
    }
    
    /// Formatted resident size string
    public var formattedResidentSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(residentSize), countStyle: .memory)
    }
}

public enum MemoryPressureLevel: String, Codable, Sendable {
    case normal = "Normal"
    case warning = "Warning"
    case critical = "Critical"
}

public struct CPUInfo: Codable, Sendable {
    public let processUsage: Double
    public let userUsage: Double
    public let systemUsage: Double
    public let systemWideUsage: Double
    public let systemWideUser: Double
    public let systemWideSystem: Double
    public let systemWideIdle: Double
    public let threadCount: Int
    public let activeThreads: Int
    public let threads: [ThreadCPUInfo]
    public let timestamp: Date
    
    public init(
        processUsage: Double = 0,
        userUsage: Double = 0,
        systemUsage: Double = 0,
        systemWideUsage: Double = 0,
        systemWideUser: Double = 0,
        systemWideSystem: Double = 0,
        systemWideIdle: Double = 0,
        threadCount: Int = 0,
        activeThreads: Int = 0,
        threads: [ThreadCPUInfo] = [],
        timestamp: Date = Date()
    ) {
        self.processUsage = processUsage
        self.userUsage = userUsage
        self.systemUsage = systemUsage
        self.systemWideUsage = systemWideUsage
        self.systemWideUser = systemWideUser
        self.systemWideSystem = systemWideSystem
        self.systemWideIdle = systemWideIdle
        self.threadCount = threadCount
        self.activeThreads = activeThreads
        self.threads = threads
        self.timestamp = timestamp
    }
}

public struct ThreadCPUInfo: Codable, Sendable {
    public let threadId: UInt64
    public let cpuUsage: Double
    public let userTime: Double
    public let systemTime: Double
    public let state: ThreadState
    public let priority: Int
    
    public init(
        threadId: UInt64 = 0,
        cpuUsage: Double = 0,
        userTime: Double = 0,
        systemTime: Double = 0,
        state: ThreadState = .unknown,
        priority: Int = 0
    ) {
        self.threadId = threadId
        self.cpuUsage = cpuUsage
        self.userTime = userTime
        self.systemTime = systemTime
        self.state = state
        self.priority = priority
    }
}

public enum ThreadState: Int, Codable, Sendable {
    case running = 1
    case stopped = 2
    case waiting = 3
    case uninterruptible = 4
    case halted = 5
    case unknown = 0
    
    public var description: String {
        switch self {
        case .running: return "Running"
        case .stopped: return "Stopped"
        case .waiting: return "Waiting"
        case .uninterruptible: return "Uninterruptible"
        case .halted: return "Halted"
        case .unknown: return "Unknown"
        }
    }
}

public struct DiskInfo: Codable, Sendable {
    public let totalSpace: UInt64
    public let freeSpace: UInt64
    public let usedSpace: UInt64
    public let usagePercentage: Double
    public let timestamp: Date
    
    public init(
        totalSpace: UInt64 = 0,
        freeSpace: UInt64 = 0,
        usedSpace: UInt64 = 0,
        usagePercentage: Double = 0,
        timestamp: Date = Date()
    ) {
        self.totalSpace = totalSpace
        self.freeSpace = freeSpace
        self.usedSpace = usedSpace
        self.usagePercentage = usagePercentage
        self.timestamp = timestamp
    }
    
    public var formattedTotalSpace: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalSpace), countStyle: .file)
    }
    
    public var formattedFreeSpace: String {
        ByteCountFormatter.string(fromByteCount: Int64(freeSpace), countStyle: .file)
    }
}

public struct NetworkInfo: Codable, Sendable {
    public let bytesReceived: UInt64
    public let bytesSent: UInt64
    public let packetsReceived: UInt64
    public let packetsSent: UInt64
    public let timestamp: Date
    
    public init(
        bytesReceived: UInt64 = 0,
        bytesSent: UInt64 = 0,
        packetsReceived: UInt64 = 0,
        packetsSent: UInt64 = 0,
        timestamp: Date = Date()
    ) {
        self.bytesReceived = bytesReceived
        self.bytesSent = bytesSent
        self.packetsReceived = packetsReceived
        self.packetsSent = packetsSent
        self.timestamp = timestamp
    }
    
    public var formattedBytesReceived: String {
        ByteCountFormatter.string(fromByteCount: Int64(bytesReceived), countStyle: .memory)
    }
    
    public var formattedBytesSent: String {
        ByteCountFormatter.string(fromByteCount: Int64(bytesSent), countStyle: .memory)
    }
}

public struct DeviceInfo: Codable, Sendable {
    public let model: String
    public let systemVersion: String
    public let processorCount: Int
    public let activeProcessorCount: Int
    public let physicalMemory: UInt64
    public let systemUptime: TimeInterval
    public let thermalState: ThermalState
    public let isLowPowerModeEnabled: Bool
    
    public init(
        model: String = "",
        systemVersion: String = "",
        processorCount: Int = 0,
        activeProcessorCount: Int = 0,
        physicalMemory: UInt64 = 0,
        systemUptime: TimeInterval = 0,
        thermalState: ThermalState = .nominal,
        isLowPowerModeEnabled: Bool = false
    ) {
        self.model = model
        self.systemVersion = systemVersion
        self.processorCount = processorCount
        self.activeProcessorCount = activeProcessorCount
        self.physicalMemory = physicalMemory
        self.systemUptime = systemUptime
        self.thermalState = thermalState
        self.isLowPowerModeEnabled = isLowPowerModeEnabled
    }
}

public enum ThermalState: Int, Codable, Sendable {
    case nominal = 0
    case fair = 1
    case serious = 2
    case critical = 3
    
    public var description: String {
        switch self {
        case .nominal: return "Nominal"
        case .fair: return "Fair"
        case .serious: return "Serious"
        case .critical: return "Critical"
        }
    }
}
