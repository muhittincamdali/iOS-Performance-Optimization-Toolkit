// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PerformanceOptimizationKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "PerformanceOptimizationKit", targets: ["PerformanceOptimizationKit"])
    ],
    targets: [
        .target(
            name: "PerformanceOptimizationKit",
            path: "Sources/PerformanceOptimizationKit"
        ),
        .testTarget(
            name: "PerformanceOptimizationKitTests",
            dependencies: ["PerformanceOptimizationKit"],
            path: "Tests/PerformanceOptimizationKitTests"
        )
    ]
)
