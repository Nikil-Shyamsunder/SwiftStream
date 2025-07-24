// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotoDupes",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PhotoDupes",
            targets: ["PhotoDupes"]
        ),
        .executable(
            name: "photodupes",
            targets: ["PhotoDupesCLI"]
        )
    ],
    dependencies: [
        .package(path: "../../Core")
    ],
    targets: [
        .target(
            name: "PhotoDupes",
            dependencies: [
                .product(name: "SwiftStream", package: "Core")
            ]
        ),
        .executableTarget(
            name: "PhotoDupesCLI",
            dependencies: [
                "PhotoDupes",
                .product(name: "SwiftStream", package: "Core")
            ]
        ),
        .testTarget(
            name: "PhotoDupesTests",
            dependencies: ["PhotoDupes"]
        )
    ]
)