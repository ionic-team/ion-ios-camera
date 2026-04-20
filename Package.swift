// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IONCameraLib",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "IONCameraLib",
            targets: ["IONCameraLib"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
    ],
    targets: [
        // Internal target with all the source code, no linker settings.
        // Tests depend on this directly to avoid inheriting the SwiftUICore fix.
        .target(
            name: "IONCameraLibCore",
            dependencies: [],
            path: "Sources/IONCameraLib"
        ),
        // Public-facing shim that re-exports IONCameraLibCore and carries the
        // linker fix. Consumers get the fix automatically; test targets do not
        // inherit it because they depend on IONCameraLibCore directly.
        .target(
            name: "IONCameraLib",
            dependencies: ["IONCameraLibCore"],
            path: "Sources/IONCameraLibShim",
            linkerSettings: [
                // SwiftUICore is a private sub-framework split from SwiftUI in iOS 17.
                // Building with the iOS 17+ SDK creates a hard load command for it,
                // crashing on iOS 15/16 where it doesn't exist. Weak-linking makes it
                // optional at load time without affecting behaviour on iOS 17+.
                .unsafeFlags(["-Xlinker", "-weak_framework", "-Xlinker", "SwiftUICore"])
            ]
        ),
        .testTarget(
            name: "IONCameraLibTests",
            dependencies: ["IONCameraLibCore", "Nimble", "Quick"],
            resources: [.process("Media.xcassets")]
        ),
    ]
)
