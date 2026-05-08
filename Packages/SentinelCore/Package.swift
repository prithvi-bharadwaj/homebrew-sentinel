// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SentinelCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "SentinelCore", targets: ["SentinelCore"])
    ],
    targets: [
        .target(name: "SentinelCore"),
        .testTarget(name: "SentinelCoreTests", dependencies: ["SentinelCore"])
    ],
    swiftLanguageVersions: [.v5]
)
