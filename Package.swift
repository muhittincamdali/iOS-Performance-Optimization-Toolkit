// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PerformanceToolkit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "PerformanceToolkit", targets: ["PerformanceToolkit"]),
    ],
    targets: [
        .target(
            name: "PerformanceToolkit",
            path: "Sources/PerformanceToolkit",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "PerformanceToolkitTests",
            dependencies: ["PerformanceToolkit"]
        )
    ]
)
