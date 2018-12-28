// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "pyTanks.SwiftPlayer",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "pyTanks",
            targets: ["pyTanks"]),
        .library(
            name: "PyPlayer",
            targets: ["PlayerSupport"]),
        .library(
            name: "PyClient",
            targets: ["ClientControl"]),
        ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "pyTanks",
            dependencies: ["ClientControl", "SimplePlayer"]),
        .target(
            name: "ClientControl",
            dependencies: ["Client", "PlayerSupport"]),
        .target(
            name: "SimplePlayer",
            dependencies: ["PlayerSupport"]),
        .target(
            name: "Client",
            dependencies: ["PlayerSupport", "Starscream", "Utils"]),
        .target(
            name: "PlayerSupport",
            dependencies: []),
        .target(
            name: "Utils",
            dependencies: []),
        ]
)
