// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "kindlededrmtools",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "kindlededrmtools",
            targets: ["kindlededrmtools"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.4")),
        .package(url: "https://github.com/themuzzleflare/kfxtablesswift.git", from: "2.0.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.19")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.8.3"))
    ],
    targets: [
        .target(
            name: "kindlededrmtools",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "kfxtables", package: "kfxtablesswift"),
                "ZIPFoundation",
                "CryptoSwift"
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-testing"], .when(configuration: .release))
            ]
        ),
        .testTarget(
            name: "kindlededrmtoolsTests",
            dependencies: ["kindlededrmtools"],
            resources: [
                .copy("testdata")])
    ],
    swiftLanguageModes: [.v6]
)
