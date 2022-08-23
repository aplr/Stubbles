// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Stubbles",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "Stubbles",
            targets: ["Stubbles"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Stubbles"
        ),
        .testTarget(
            name: "StubblesTests",
            dependencies: ["Stubbles"]
        ),
    ]
)
