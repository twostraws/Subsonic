// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "Subsonic",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "Subsonic",
            targets: ["Subsonic"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Subsonic",
            dependencies: [])
    ]
)
