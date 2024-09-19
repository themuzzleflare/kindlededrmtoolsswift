// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "kindlededrmtools",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "kindlededrmtools",
            targets: ["kindlededrmtools"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.3")),
        .package(url: "https://github.com/themuzzleflare/kfxtablesswift.git", from: "2.0.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.19"))
    ],
    targets: [
        .target(
            name: "kindlededrmtools",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "kfxtables", package: "kfxtablesswift"),
                "ZIPFoundation"
            ]),
        .testTarget(
            name: "kindlededrmtoolsTests",
            dependencies: ["kindlededrmtools"],
            resources: [
                .copy("testdata")])
    ],
    swiftLanguageModes: [.v6]
)
