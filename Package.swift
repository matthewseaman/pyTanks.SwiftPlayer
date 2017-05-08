// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "pyTanks.SwiftPlayer",
    targets: [
        Target(name: "pyTanks", dependencies: ["Client", "Utils"]),
        Target(name: "Client"),
        Target(name: "Utils")
    ],
    dependencies: [
        .Package(url: "https://github.com/daltoniam/Starscream.git", majorVersion: 2)
    ]
)
