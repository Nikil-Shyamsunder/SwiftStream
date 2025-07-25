// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WordCount",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "WordCountMapper", targets: ["WordCountMapperCLI"]),
        .executable(name: "WordCountReducer", targets: ["WordCountReducerCLI"]),
        .library(name: "WordCount", targets: ["WordCount"])
    ],
    dependencies: [
        .package(path: "../../Core")
    ],
    targets: [
        .target(
            name: "WordCount",
            dependencies: [
                .product(name: "SwiftStream", package: "Core")
            ]
        ),
        .executableTarget(
            name: "WordCountMapperCLI",
            dependencies: ["WordCount"]
        ),
        .executableTarget(
            name: "WordCountReducerCLI",
            dependencies: ["WordCount"]
        ),
        .testTarget(
            name: "WordCountTests",
            dependencies: ["WordCount"]
        )
    ]
)