// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AEXML",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v9)
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
