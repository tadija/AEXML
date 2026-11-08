// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AEXML",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "AEXML",
            targets: ["AEXML"])
    ],
    targets: [
        .target(
            name: "AEXML"
        ),
        .testTarget(
            name: "AEXMLTests",
            dependencies: ["AEXML"],
            resources: [
                .copy("Resources"),
            ]
        ),
    ]
)
