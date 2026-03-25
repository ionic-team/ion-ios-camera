// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "IONCameraLib",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "IONCameraLib",
            targets: ["IONCameraLib"]),
    ],
    dependencies: [
        .package(url:  "https://github.com/Quick/Nimble.git", from: "13.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "IONCameraLib",
            dependencies: []
        ),
        .testTarget(
            name: "IONCameraLibTests",
            dependencies: ["IONCameraLib", "Nimble", "Quick"]
        ),
    ]
)
