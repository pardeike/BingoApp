// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BingoApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "BingoCore",
            targets: ["BingoCore"]
        )
    ],
    targets: [
        .target(
            name: "BingoCore",
            dependencies: []
        ),
        .testTarget(
            name: "BingoCoreTests",
            dependencies: ["BingoCore"]
        )
    ]
)