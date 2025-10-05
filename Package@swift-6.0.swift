// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "KindleDeDRMTools",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "KindleDeDRMTools",
            targets: ["KindleDeDRMTools"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/themuzzleflare/kfxtablesswift.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", branch: "feature/swift6"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", branch: "main"),
        .package(url: "https://github.com/themuzzleflare/OSInfo.git", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        .target(
            name: "KindleDeDRMTools",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "KFXTables", package: "kfxtablesswift"),
                "ZIPFoundation",
                "CryptoSwift",
                "OSInfo"
            ]
        ),
        .testTarget(
            name: "KindleDeDRMToolsTests",
            dependencies: ["KindleDeDRMTools"],
            resources: [.copy("testdata")]
        )
    ],
    swiftLanguageModes: [.v6]
)
