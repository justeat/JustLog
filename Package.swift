// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "JustLog",
    products: [
        .library(name: "JustLog", targets: ["JustLog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.9.1"),
    ],
    targets: [
        .target(
            name: "JustLog",
            path: "JustLog",
            dependencies: ["SwiftyBeaver"]),
        .target(
            name: "Example",
            path: "Example",
            dependencies: ["JustLog"]),
        .testTarget(
            name: "JustLogTests",
            path: "Example/Tests",
            dependencies: ["Example"]),
    ]
)
