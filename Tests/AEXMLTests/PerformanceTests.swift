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
    func testReadXMLPerformance() {
        self.measure {
            do {
                _ = try self.readXMLFromFile(filename: "plant_catalog")
            } catch {
                XCTFail()
            }
        }
    }

    func testWriteXMLPerformance() throws {
        let plantsDocument = try readXMLFromFile(filename: "plant_catalog")
        self.measure {
            _ = plantsDocument.xml
        }
    }
}
