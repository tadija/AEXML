/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2026
 *  Licensed under the MIT license
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

@testable import AEXML

protocol SharedTesting {}

extension SharedTesting {
    func URLForResource(fileName: String, withExtension ext: String) -> URL {
        if let url = Bundle(for: AEXMLTests.self)
            .url(forResource: fileName, withExtension: ext) {
            return url
        } else {
            guard let url = Bundle.module
                .url(forResource: "Resources/\(fileName)", withExtension: ext) else {
                fatalError("can't find resource named: '\(fileName)'")
            }
            return url
        }
    }

    func xmlDocumentFromURL(url: URL) throws -> AEXMLDocument {
        var xmlDocument = AEXMLDocument()

        let data = try Data.init(contentsOf: url)
        xmlDocument = try AEXMLDocument(xml: data)

        return xmlDocument
    }

    func readXMLFromFile(filename: String) throws -> AEXMLDocument {
        let url = URLForResource(fileName: filename, withExtension: "xml")
        return try xmlDocumentFromURL(url: url)
    }
}

// MARK: - Bundle

#if XCODE
/// - Note: copied this extension from private "resource_bundle_accessor.swift"
/// - SeeAlso: https://stackoverflow.com/a/61263653/2165585
extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var module: Bundle = {
        let bundleName = "AEXML_AEXMLTests"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: AEXMLTests.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named AEXML_AEXMLTests")
    }()
}
#endif
