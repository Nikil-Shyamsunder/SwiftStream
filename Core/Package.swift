// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftStream",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftStream",
            targets: ["SwiftStream"]
        ),
        .executable(
            name: "swiftstream-run",
            targets: ["SwiftStreamCLI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftStream",
            dependencies: []
        ),
        .executableTarget(
            name: "SwiftStreamCLI",
            dependencies: ["SwiftStream"]
        ),
        .testTarget(
            name: "SwiftStreamTests",
            dependencies: ["SwiftStream"]
        )
    ]
)