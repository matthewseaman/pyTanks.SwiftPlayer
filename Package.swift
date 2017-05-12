// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "pyTanks.SwiftPlayer",
    targets: [
        Target(name: "pyTanks", dependencies: ["Players", "Client", "Utils"]),
        Target(name: "Players", dependencies: ["Client"]),
        Target(name: "Client"),
        Target(name: "Utils")
    ],
    dependencies: [
        .Package(url: "https://github.com/daltoniam/Starscream.git", majorVersion: 2)
    ]
)
