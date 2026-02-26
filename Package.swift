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
    dependencies: [],
    targets: [
        .target(
            name: "IONCameraLib",
            dependencies: []
        ),
        .testTarget(
            name: "IONCameraLibTests",
            dependencies: ["IONCameraLib"]
        ),
    ]
)
