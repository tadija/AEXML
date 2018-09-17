// swift-tools-version:4.2

/**
 *  https://github.com/tadija/AEXML
 *  Copyright (c) Marko Tadić 2014-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "AEXML",
    dependencies: [],
    targets: [
        .target(
            name: "AEXML",
            dependencies: []),
        .testTarget(
            name: "AEXMLTests",
            dependencies: ["AEXML"])
    ]
)
