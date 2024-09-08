// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "kindlededrmtools",
  platforms: [.iOS(.v14), .macOS(.v11)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "kindlededrmtools",
      targets: ["kindlededrmtools"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    .package(
      url: "https://github.com/apple/swift-collections.git",
      .upToNextMinor(from: "1.1.0")
    )
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "kindlededrmtools",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Collections", package: "swift-collections")
      ]),
    .testTarget(
      name: "kindlededrmtoolsTests",
      dependencies: ["kindlededrmtools"]),
  ]
)
