// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftHadoopStreaming",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftHadoopStreaming",
            targets: ["SwiftHadoopStreaming"]),
        .executable(
            name: "HadoopExecutor",
            targets: ["HadoopExecutor"])
    ],
    targets: [
        .target(
            name: "SwiftHadoopStreaming",
            dependencies: []),
        .executableTarget(
            name: "HadoopExecutor",
            dependencies: ["SwiftHadoopStreaming"]),
        .testTarget(
            name: "SwiftHadoopStreamingTests",
            dependencies: ["SwiftHadoopStreaming"]),
    ]
)
