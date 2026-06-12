// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "IntlEvents",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "IntlEvents", targets: ["IntlEvents"]),
    ],
    dependencies: [
        .package(url: "https://github.com/avgx/IntlWireFormat", from: "1.0.1"),
        .package(url: "https://github.com/avgx/RequestResponse", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "IntlEvents",
            dependencies: [
                .product(name: "IntlWireFormat", package: "IntlWireFormat"),
                .product(name: "RequestResponse", package: "RequestResponse"),
            ]
        ),
        .testTarget(
            name: "IntlEventsTests",
            dependencies: ["IntlEvents"],
            resources: [.process("Resources")]
        ),
    ]
)
