// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TaskManagementSDK",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TaskManagementSDK",
            targets: ["TaskManagementSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.10.0"),
        .package(url: "https://github.com/scade-platform/SQLite.swift.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        
        .target(
            name: "TaskManagementSDK",
            dependencies: [
                .product(name: "OpenCombine", package: "OpenCombine"),
                .product(name: "SQLite", package: "SQLite.swift")
            ]),
        .testTarget(
            name: "TaskManagementSDKTests",
            dependencies: ["TaskManagementSDK"]),
    ]
)
