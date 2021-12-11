// swift-tools-version:5.5

import PackageDescription


let package = Package(
    name: "swift-nio-lifx",
    products: [
        .executable(name: "lifx", targets: ["lifx"]),
        .library(name: "NIOLIFX", targets: ["NIOLIFX"])
    ],
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", from: "0.3.2"),
        .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(name: "swift-nio", url: "https://github.com/apple/swift-nio.git", from: "2.31.0"),
        .package(name: "swift-nio-ip", url: "https://github.com/PSchmiedmayer/Swift-NIO-IP.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "lifx",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .target(name: "NIOLIFX")
            ]
        ),
        .target(
            name: "NIOLIFX",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOIP", package: "swift-nio-ip")
            ]
        ),
        .testTarget(
            name: "NIOLIFXTests",
            dependencies: [
                .target(name: "NIOLIFX")
            ]
        )
    ]
)
