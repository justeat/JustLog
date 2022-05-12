// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "JustLog",
    platforms: [
        .iOS(.v13.4),
        .tvOS(.v13.4)
    ],
    products: [
        .library(
            name: "JustLog",
            targets: ["JustLog"]),
    ],
    dependencies: [
        .package(
		url: "https://github.com/SwiftyBeaver/SwiftyBeaver",
		.exact("1.9.6")
	)
    ],
    targets: [
        .target(
            name: "JustLog",
            dependencies: ["SwiftyBeaver"],
                path: "JustLog/",
            exclude: ["Supporting Files/Info.plist", "Supporting Files/JustLog.h"]),
    ]
)
