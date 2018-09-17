// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

/**
 *  https://github.com/tadija/AEXML
 *  Copyright (c) Marko Tadić 2014-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "AEXML",
    dependencies: [ ],
    targets: [
        .target(
            name: "AEXML",
            dependencies: []),
        .testTarget(
            name: "AEXMLTests",
            dependencies: ["AEXML"])
    ]
)
