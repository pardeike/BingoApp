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
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI.git", from: "0.2.4")
    ],
    targets: [
        .target(
            name: "BingoCore",
            dependencies: [
                .product(name: "OpenAI", package: "OpenAI")
            ]
        ),
        .testTarget(
            name: "BingoCoreTests",
            dependencies: ["BingoCore"]
        )
    ]
)