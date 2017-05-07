// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "pyTanks.SwiftPlayer",
    dependencies: [
        .Package(url: "https://github.com/daltoniam/Starscream.git", majorVersion: 2)
    ]
)
