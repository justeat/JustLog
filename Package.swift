// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "JustLog",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "JustLog",
            targets: ["JustLog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver", from: "1.9.3")
    ],
    targets: [
        .target(
            name: "JustLog",
            dependencies: ["SwiftyBeaver"],
                path: "JustLog/",
            exclude: ["Supporting Files/Info.plist", "Supporting Files/JustLog.h"]),
    ]
)
