//
//  SystemMetricsTests.swift
//  iOS Performance Optimization Toolkit
//
//  Created by Muhittin Camdali
//  Copyright © 2024 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import PerformanceCore

final class SystemMetricsTests: XCTestCase {
    
    // MARK: - Memory Tests
    
    func testMemoryUsage() {
        let metrics = SystemMetrics.shared
        let memoryInfo = metrics.getMemoryUsage()
        
        // Verify memory values are reasonable
        XCTAssertGreaterThan(memoryInfo.residentSize, 0, "Resident size should be positive")
        XCTAssertGreaterThan(memoryInfo.totalPhysicalMemory, 0, "Total memory should be positive")
        XCTAssertLessThanOrEqual(memoryInfo.residentSize, memoryInfo.totalPhysicalMemory, "Resident size should not exceed total memory")
    }
    
    func testMemoryFootprint() {
        let metrics = SystemMetrics.shared
        let footprint = metrics.getMemoryFootprint()
        
        XCTAssertGreaterThan(footprint, 0, "Memory footprint should be positive")
    }
    
    func testMemoryPressure() {
        let metrics = SystemMetrics.shared
        let pressure = metrics.getMemoryPressure()
        
        // Just verify it returns a valid value
        XCTAssertNotNil(pressure)
    }
    
    func testMemoryInfoUsagePercentage() {
        let metrics = SystemMetrics.shared
        let memoryInfo = metrics.getMemoryUsage()
        
        XCTAssertGreaterThanOrEqual(memoryInfo.usagePercentage, 0, "Usage percentage should be non-negative")
        XCTAssertLessThanOrEqual(memoryInfo.usagePercentage, 100, "Usage percentage should not exceed 100")
    }
    
    // MARK: - CPU Tests
    
    func testCPUUsage() {
        let metrics = SystemMetrics.shared
        let cpuInfo = metrics.getCPUUsage()
        
        XCTAssertGreaterThanOrEqual(cpuInfo.threadCount, 1, "Should have at least 1 thread")
        XCTAssertGreaterThanOrEqual(cpuInfo.processUsage, 0, "CPU usage should be non-negative")
    }
    
    func testCPUThreadInfo() {
        let metrics = SystemMetrics.shared
        let cpuInfo = metrics.getCPUUsage()
        
        // Should have thread information
        XCTAssertFalse(cpuInfo.threads.isEmpty, "Should have thread information")
        
        for thread in cpuInfo.threads {
            XCTAssertGreaterThanOrEqual(thread.cpuUsage, 0, "Thread CPU usage should be non-negative")
        }
    }
    
    // MARK: - Disk Tests
    
    func testDiskUsage() {
        let metrics = SystemMetrics.shared
        let diskInfo = metrics.getDiskUsage()
        
        XCTAssertGreaterThan(diskInfo.totalSpace, 0, "Total disk space should be positive")
        XCTAssertGreaterThan(diskInfo.freeSpace, 0, "Free disk space should be positive")
        XCTAssertLessThanOrEqual(diskInfo.freeSpace, diskInfo.totalSpace, "Free space should not exceed total")
    }
    
    // MARK: - Network Tests
    
    func testNetworkStats() {
        let metrics = SystemMetrics.shared
        let networkInfo = metrics.getNetworkStats()
        
        // Just verify it doesn't crash - values can be 0 if no network activity
        XCTAssertNotNil(networkInfo.timestamp)
    }
    
    // MARK: - Device Tests
    
    func testDeviceInfo() {
        let metrics = SystemMetrics.shared
        let deviceInfo = metrics.getDeviceInfo()
        
        XCTAssertFalse(deviceInfo.model.isEmpty, "Device model should not be empty")
        XCTAssertFalse(deviceInfo.systemVersion.isEmpty, "System version should not be empty")
        XCTAssertGreaterThan(deviceInfo.processorCount, 0, "Processor count should be positive")
        XCTAssertGreaterThan(deviceInfo.physicalMemory, 0, "Physical memory should be positive")
    }
    
    // MARK: - Performance Tests
    
    func testMetricsPerformance() {
        let metrics = SystemMetrics.shared
        
        measure {
            for _ in 0..<100 {
                _ = metrics.getMemoryUsage()
                _ = metrics.getCPUUsage()
            }
        }
    }
}
