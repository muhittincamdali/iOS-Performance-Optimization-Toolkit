// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PerformanceKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "PerformanceKit",
            targets: ["PerformanceKit"]
        )
    ],
    targets: [
        .target(
            name: "PerformanceKit",
            path: "Sources/PerformanceKit",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "PerformanceKitTests",
            dependencies: ["PerformanceKit"],
            path: "Tests/PerformanceKitTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
