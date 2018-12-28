// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "pyTanks.SwiftPlayer",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .executable(
            name: "pyTanks",
            targets: ["pyTanks"]),
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
            dependencies: ["Players", "Client", "Utils"]),
        .target(
            name: "Players",
            dependencies: ["Client"]),
        .target(
            name: "Client",
            dependencies: ["Starscream"]),
        .target(
            name: "Utils",
            dependencies: []),
        ]
)
