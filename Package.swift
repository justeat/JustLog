// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "JustLog",
    platforms: [
       .iOS("10.0"),
       .tvOS("10.0")
    ],
    products: [
        .library(name: "JustLog", targets: ["JustLog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.9.1"),
    ],
    targets: [
        .target(
            name: "JustLog",
            dependencies: ["SwiftyBeaver"],
            path: "JustLog"),
        .testTarget(
            name: "JustLogTests",
            dependencies: ["Example"],
            path: "Example/Tests"),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
