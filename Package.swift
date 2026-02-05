// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PerformanceOptimizationKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v1)
    ],
    products: [
        // Main performance optimization library - includes everything
        .library(
            name: "PerformanceOptimizationKit",
            targets: ["PerformanceOptimizationKit"]
        ),
        
        // Core performance components - lightweight, no UI dependencies
        .library(
            name: "PerformanceCore",
            targets: ["PerformanceCore"]
        )
    ],
    dependencies: [
        // Apple's official logging framework
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        
        // Apple's official metrics framework
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.4.0")
    ],
    targets: [
        // Core performance components - the foundation
        .target(
            name: "PerformanceCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics")
            ],
            path: "Sources/Core",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // Main umbrella target
        .target(
            name: "PerformanceOptimizationKit",
            dependencies: [
                "PerformanceCore"
            ],
            path: "Sources/PerformanceOptimizationKit",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // Unit tests
        .testTarget(
            name: "PerformanceOptimizationKitTests",
            dependencies: [
                "PerformanceOptimizationKit",
                "PerformanceCore"
            ],
            path: "Tests/UnitTests"
        ),
        
        // Performance tests
        .testTarget(
            name: "PerformanceTests",
            dependencies: [
                "PerformanceOptimizationKit"
            ],
            path: "Tests/PerformanceTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
