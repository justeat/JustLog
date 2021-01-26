// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "JustLog",
    platforms: [
        .iOS(.v10),
        .watchOS(.v3),
        .tvOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "JustLog",
            targets: ["JustLog"]),

    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver", from: "1.9.3")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "JustLog",
            dependencies: ["SwiftyBeaver"],
                path: "JustLog/",
        exclude: ["JustLog/Supporting Files/Info.plist", "JustLog/Supporting Files/JustLog.h"]),
    ]
)
