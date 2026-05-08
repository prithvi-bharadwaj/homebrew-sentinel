// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SentinelInput",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "SentinelInput", targets: ["SentinelInput"])
    ],
    dependencies: [
        .package(path: "../SentinelCore")
    ],
    targets: [
        .target(
            name: "SentinelInput",
            dependencies: [
                .product(name: "SentinelCore", package: "SentinelCore")
            ]
        ),
        .testTarget(
            name: "SentinelInputTests",
            dependencies: ["SentinelInput", "SentinelCore"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
