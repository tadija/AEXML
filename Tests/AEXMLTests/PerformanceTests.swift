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
import XCTest

class PerformanceTests: XCTestCase, SharedTesting {
    // MARK: - Helpers

    // Measures wall clock time of `block` (10 iterations on Apple platforms).
    private func measurePerformance(_ block: () -> Void) {
        #if canImport(ObjectiveC)
        let options = XCTMeasureOptions()
        options.iterationCount = 10
        measure(metrics: [XCTClockMetric()], options: options, block: block)
        #else
        measure(block: block)
        #endif
    }

    // Catalog with `count` plants, each with three attributes and four child elements.
    private func makeCatalog(plants count: Int) -> AEXMLDocument {
        let document = AEXMLDocument()
        let catalog = document.addChild(name: "catalog")
        for i in 0..<count {
            let attributes = ["id" : "\(i)", "zone" : "\(i % 11)", "light" : i % 2 == 0 ? "Sun" : "Shade"]
            let plant = catalog.addChild(name: "plant", attributes: attributes)
            plant.addChild(name: "common", value: "Bloodroot \(i)")
            plant.addChild(name: "botanical", value: "Sanguinaria canadensis")
            plant.addChild(name: "availability", value: "03/15/2026")
            plant.addChild(name: "price", value: "$2.44")
        }
        return document
    }

    // Document with a single chain of `depth` nested elements.
    private func makeDeeplyNestedDocument(depth: Int) -> AEXMLDocument {
        let document = AEXMLDocument()
        var current: AEXMLElement = document
        for _ in 0..<depth {
            current = current.addChild(name: "e")
        }
        current.value = "leaf"
        return document
    }

    // MARK: - Parsing

    func testParsePlantCatalogFile() {
        measurePerformance {
            do {
                _ = try readXMLFromFile(filename: "plant_catalog")
            } catch {
                XCTFail()
            }
        }
    }

    func testParseLargeCatalog() {
        let data = makeCatalog(plants: 20_000).xml.data(using: .utf8)!

        measurePerformance {
            XCTAssertNotNil(try? AEXMLDocument(xml: data))
        }
    }

    func testParseValueSplitByEntityReferences() {
        let data = ("<root><text>" + String(repeating: "x &amp; ", count: 100_000) + "</text></root>").data(using: .utf8)!

        measurePerformance {
            XCTAssertNotNil(try? AEXMLDocument(xml: data))
        }
    }

    // MARK: - Serialization

    func testSerializePlantCatalogFile() throws {
        let document = try readXMLFromFile(filename: "plant_catalog")

        measurePerformance {
            _ = document.xml
        }
    }

    func testSerializeLargeCatalog() {
        let document = makeCatalog(plants: 20_000)

        measurePerformance {
            _ = document.xml
        }
    }

    func testSerializeLargeCatalogCompact() {
        let document = makeCatalog(plants: 20_000)

        measurePerformance {
            _ = document.xmlCompact
        }
    }

    func testSerializeLargeCatalogWithSpaces() {
        let document = makeCatalog(plants: 20_000)

        measurePerformance {
            _ = document.xmlSpaces
        }
    }

    func testSerializeDeeplyNestedDocument() {
        let document = makeDeeplyNestedDocument(depth: 4_000)

        measurePerformance {
            _ = document.xml
        }
    }

    // MARK: - Escaping

    func testEscapeShortStringsWithoutSpecialCharacters() {
        let strings = (0..<100_000).map { "Plant number \($0) in zone" }

        measurePerformance {
            for string in strings {
                _ = string.xmlEscaped
            }
        }
    }

    func testEscapeShortStringsWithSpecialCharacters() {
        let strings = (0..<100_000).map { "Plant <\($0)> & \"zone\"" }

        measurePerformance {
            for string in strings {
                _ = string.xmlEscaped
            }
        }
    }

    func testEscapeLongString() {
        let chunk = "Lorem ipsum <dolor> sit & amet, \"consectetur\" 'adipiscing' elit.\n"
        let string = String(repeating: chunk, count: 20_000)

        measurePerformance {
            _ = string.xmlEscaped
        }
    }

    // MARK: - Attribute lookup

    func testFindElementsContainingAttributeKeys() {
        let document = makeCatalog(plants: 100_000)
        let plant = document.root["plant"]
        let keys = [["id"], ["id", "zone"], ["id", "zone", "light"], ["id", "zone", "light", "price"]]

        measurePerformance {
            for keys in keys {
                _ = plant.all(containingAttributeKeys: keys)
            }
        }
        withExtendedLifetime(document) {}
    }

    func testFindElementsWithAttributes() {
        let document = makeCatalog(plants: 100_000)
        let plant = document.root["plant"]

        measurePerformance {
            for zone in 0..<4 {
                _ = plant.all(withAttributes: ["zone" : "\(zone)", "light" : "Sun"])
            }
        }
        withExtendedLifetime(document) {}
    }
}
