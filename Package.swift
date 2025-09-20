// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BingoApp",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI.git", from: "0.2.4")
    ]
)