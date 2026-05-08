// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SentinelAuth",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "SentinelAuth", targets: ["SentinelAuth"])
    ],
    dependencies: [
        .package(path: "../SentinelCore")
    ],
    targets: [
        .target(
            name: "SentinelAuth",
            dependencies: [
                .product(name: "SentinelCore", package: "SentinelCore")
            ]
        ),
        .testTarget(
            name: "SentinelAuthTests",
            dependencies: ["SentinelAuth", "SentinelCore"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
