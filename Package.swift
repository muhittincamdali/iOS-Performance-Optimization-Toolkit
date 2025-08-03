// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PerformanceOptimizationKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        // Main performance optimization library
        .library(
            name: "PerformanceOptimizationKit",
            targets: ["PerformanceOptimizationKit"]
        ),
        
        // Core performance components
        .library(
            name: "PerformanceCore",
            targets: ["PerformanceCore"]
        ),
        
        // Memory optimization components
        .library(
            name: "MemoryOptimization",
            targets: ["MemoryOptimization"]
        ),
        
        // Battery optimization components
        .library(
            name: "BatteryOptimization",
            targets: ["BatteryOptimization"]
        ),
        
        // CPU optimization components
        .library(
            name: "CPUOptimization",
            targets: ["CPUOptimization"]
        ),
        
        // UI optimization components
        .library(
            name: "UIOptimization",
            targets: ["UIOptimization"]
        ),
        
        // Performance analytics components
        .library(
            name: "PerformanceAnalytics",
            targets: ["PerformanceAnalytics"]
        )
    ],
    dependencies: [
        // Core dependencies
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.0.0"),
        
        // Testing dependencies
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.1.0")
    ],
    targets: [
        // Main performance optimization target
        .target(
            name: "PerformanceOptimizationKit",
            dependencies: [
                "PerformanceCore",
                "MemoryOptimization",
                "BatteryOptimization",
                "CPUOptimization",
                "UIOptimization",
                "PerformanceAnalytics"
            ],
            path: "Sources/PerformanceOptimizationKit"
        ),
        
        // Core performance components
        .target(
            name: "PerformanceCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics")
            ],
            path: "Sources/Core"
        ),
        
        // Memory optimization components
        .target(
            name: "MemoryOptimization",
            dependencies: [
                "PerformanceCore",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Performance"
        ),
        
        // Battery optimization components
        .target(
            name: "BatteryOptimization",
            dependencies: [
                "PerformanceCore",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Battery"
        ),
        
        // CPU optimization components
        .target(
            name: "CPUOptimization",
            dependencies: [
                "PerformanceCore",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/CPU"
        ),
        
        // UI optimization components
        .target(
            name: "UIOptimization",
            dependencies: [
                "PerformanceCore",
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/UI"
        ),
        
        // Performance analytics components
        .target(
            name: "PerformanceAnalytics",
            dependencies: [
                "PerformanceCore",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics")
            ],
            path: "Sources/Analytics"
        ),
        
        // Unit tests
        .testTarget(
            name: "PerformanceOptimizationKitTests",
            dependencies: [
                "PerformanceOptimizationKit",
                "PerformanceCore",
                "MemoryOptimization",
                "BatteryOptimization",
                "CPUOptimization",
                "UIOptimization",
                "PerformanceAnalytics",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/UnitTests"
        ),
        
        // Performance tests
        .testTarget(
            name: "PerformanceOptimizationKitPerformanceTests",
            dependencies: [
                "PerformanceOptimizationKit",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/PerformanceTests"
        ),
        
        // UI tests
        .testTarget(
            name: "PerformanceOptimizationKitUITests",
            dependencies: [
                "PerformanceOptimizationKit",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/UITests"
        )
    ]
) 