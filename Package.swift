// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "DCFrame",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "DCFrame", targets: ["DCFrame"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "DCFrame"),
    ]
)
