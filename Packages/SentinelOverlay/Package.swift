// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SentinelOverlay",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "SentinelOverlay", targets: ["SentinelOverlay"])
    ],
    dependencies: [
        .package(path: "../SentinelCore")
    ],
    targets: [
        .target(
            name: "SentinelOverlay",
            dependencies: [
                .product(name: "SentinelCore", package: "SentinelCore")
            ]
        ),
        .testTarget(
            name: "SentinelOverlayTests",
            dependencies: ["SentinelOverlay", "SentinelCore"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
