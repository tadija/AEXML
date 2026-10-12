// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AEXML",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_14),
        .tvOS(.v17),
        .watchOS(.v10)
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
