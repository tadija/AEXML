// swift-tools-version:4.2

/**
 *  https://github.com/tadija/AEXML
 *  Copyright (c) Marko Tadić 2014-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "AEXML",
    products: [
        .library(name: "AEXML", targets: ["AEXML"])
    ],
    targets: [
        .target(
            name: "AEXML"
        ),
        .testTarget(
            name: "AEXMLTests",
            dependencies: ["AEXML"]
        )
    ]
)
