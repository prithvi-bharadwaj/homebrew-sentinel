// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SentinelPower",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "SentinelPower", targets: ["SentinelPower"])
    ],
    dependencies: [
        .package(path: "../SentinelCore")
    ],
    targets: [
        .target(
            name: "SentinelPower",
            dependencies: [
                .product(name: "SentinelCore", package: "SentinelCore")
            ]
        ),
        .testTarget(
            name: "SentinelPowerTests",
            dependencies: ["SentinelPower", "SentinelCore"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
