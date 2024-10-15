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
		.package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.4")),
		.package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.2.0")),
		.package(url: "https://github.com/themuzzleflare/kfxtablesswift.git", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.19")),
		.package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.8.3")),
		.package(url: "https://github.com/themuzzleflare/OSInfo.git", .upToNextMajor(from: "2.0.0"))
	],
	targets: [
		.target(
			name: "KindleDeDRMTools",
			dependencies: [
				.product(name: "OrderedCollections", package: "swift-collections"),
				.product(name: "Algorithms", package: "swift-algorithms"),
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
