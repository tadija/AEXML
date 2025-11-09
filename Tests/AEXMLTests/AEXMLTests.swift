/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2024
 *  Licensed under the MIT license
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

import Testing
@testable import AEXML

class AEXMLTests {

    // MARK: - Properties
    
    var exampleDocument = AEXMLDocument()
    var plantsDocument = AEXMLDocument()

    // MARK: - Helpers
    
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
    
    // MARK: - Setup & Teardown

    init() throws {
        // create some sample xml documents
        exampleDocument = try readXMLFromFile(filename: "example")
        plantsDocument = try readXMLFromFile(filename: "plant_catalog")
    }

    // MARK: - XML Document

    @Test
    func testXMLDocumentManualDataLoading() throws {
        let url = URLForResource(fileName: "example", withExtension: "xml")
        let data = try Data.init(contentsOf: url)

        let testDocument = AEXMLDocument()
        try testDocument.loadXML(data)

        let root = try testDocument.root
        #expect(root.name == "animals")
    }

    @Test
    func testXMLDocumentInitFromString() throws {
        let testDocument = try AEXMLDocument(xml: exampleDocument.xml)
        #expect(testDocument.xml == exampleDocument.xml)
    }

    @Test
    func testXMLOptions() throws {
        var options = AEXMLOptions()
        options.documentHeader.version = 2.0
        options.documentHeader.encoding = "utf-16"
        options.documentHeader.standalone = "yes"

        let testDocument = try AEXMLDocument(xml: "<foo><bar>hello</bar></foo>", options: options)
        #expect(testDocument.xml == "<?xml version=\"2.0\" encoding=\"utf-16\" standalone=\"yes\"?>\n<foo>\n\t<bar>hello</bar>\n</foo>")

        let firstString = try testDocument.root["bar"].first?.string
        #expect(firstString == "hello")
    }

    @Test
    func testXMLParser() throws {
        let testDocument = AEXMLDocument()
        let url = URLForResource(fileName: "example", withExtension: "xml")
        let data = try Data.init(contentsOf: url)

        let parser = AEXMLParser(document: testDocument, data: data)
        try parser.parse()

        let rootName = try testDocument.root.name
        #expect(rootName == "animals")
    }

    @Test
    func testXMLParserTrimsWhitespace() throws {
        let result = try whitespaceResult(shouldTrimWhitespace: true)
        #expect(result == "Hello,")
    }

    @Test
    func testXMLParserWithoutTrimmingWhitespace() throws {
        let result = try whitespaceResult(shouldTrimWhitespace: false)
        #expect(result == "Hello, ")
    }
    
    private func whitespaceResult(shouldTrimWhitespace: Bool) throws -> String? {
        var options = AEXMLOptions()
        options.parserSettings.shouldTrimWhitespace = shouldTrimWhitespace

        let testDocument = AEXMLDocument(options: options)
        let url = URLForResource(fileName: "whitespace_examples", withExtension: "xml")
        let data = try Data.init(contentsOf: url)

        let parser = AEXMLParser(document: testDocument, data: data)
        try parser.parse()

        return try testDocument.root["text"].first?.string
    }

    @Test
    func testXMLParserError() {
        let testDocument = AEXMLDocument()
        let testData = Data()
        let parser = AEXMLParser(document: testDocument, data: testData)
        #expect(throws: AEXMLError.parsingFailed) {
            try parser.parse()
        }
    }
    
    // MARK: - XML Read

    @Test
    func testRootElement() throws {
        let root = try exampleDocument.root
        #expect(root.name == "animals")

        let documentWithoutRootElement = AEXMLDocument()
        #expect(throws: AEXMLError.rootElementMissing) {
            try documentWithoutRootElement.root
        }
    }

    @Test
    func testParentElement() throws {
        let root = try exampleDocument.root
        let cats = try root["cats"]
        let parent = try #require(cats.parent)
        #expect(parent.name == "animals")
    }

    @Test
    func testChildrenElements() throws {
        let cats = try exampleDocument.root["cats"]
        var count = 0
        for _ in cats.children {
            count += 1
        }
        #expect(count == 4, "Should be able to iterate children elements")
    }

    @Test
    func testName() throws {
        let secondChildElementName = try exampleDocument.root.children[1].name
        #expect(secondChildElementName == "dogs", "Should be able to return element name.")
    }

    @Test
    func testAttributes() throws {
        let firstCatAttributes = try exampleDocument.root["cats"]["cat"].attributes

        // iterate attributes
        var count = 0
        for _ in firstCatAttributes {
            count += 1
        }
        #expect(count == 2, "Should be able to iterate element attributes.")

        // get attribute value
        let firstCatBreed = firstCatAttributes["breed"]
        #expect(firstCatBreed == "Siberian", "Should be able to return attribute value.")
    }

    @Test
    func testValue() throws {
        let firstPlant = try plantsDocument.root["PLANT"]

        let firstPlantCommon = try firstPlant["COMMON"].value
        #expect(firstPlantCommon == "Bloodroot", "Should be able to return element value as optional string.")

        let firstPlantElementWithoutValue = try firstPlant["ELEMENTWITHOUTVALUE"].value
        #expect(firstPlantElementWithoutValue == nil, "Should be able to have nil value.")

        let firstPlantEmptyElement = try firstPlant["EMPTYELEMENT"].value
        #expect(firstPlantEmptyElement == nil, "Should be able to have nil value.")
    }

    @Test
    func testStringValue() throws {
        let firstPlant = try plantsDocument.root["PLANT"]

        let firstPlantCommon = try firstPlant["COMMON"].string
        #expect(firstPlantCommon == "Bloodroot", "Should be able to return element value as string.")

        let firstPlantElementWithoutValue = try firstPlant["ELEMENTWITHOUTVALUE"].string
        #expect(firstPlantElementWithoutValue == "", "Should be able to return empty string if element has no value.")

        let firstPlantEmptyElement = try firstPlant["EMPTYELEMENT"].string
        #expect(firstPlantEmptyElement == String(), "Should be able to return empty string if element has no value.")
    }

    @Test
    func testBoolValue() throws {
        let root = try plantsDocument.root

        let firstTrueString = try root["PLANT"]["TRUESTRING"].bool
        #expect(firstTrueString == true, "Should be able to cast element value as Bool.")

        let firstFalseString = try root["PLANT"]["FALSESTRING"].bool
        #expect(firstFalseString == false, "Should be able to cast element value as Bool.")

        let firstTrueString2 = try root["PLANT"]["TRUESTRING2"].bool
        #expect(firstTrueString2 == true, "Should be able to cast element value as Bool.")

        let firstFalseString2 = try root["PLANT"]["FALSESTRING2"].bool
        #expect(firstFalseString2 == false, "Should be able to cast element value as Bool.")

        let firstTrueInt = try root["PLANT"]["TRUEINT"].bool
        #expect(firstTrueInt == true, "Should be able to cast element value as Bool.")

        let firstFalseInt = try root["PLANT"]["FALSEINT"].bool
        #expect(firstFalseInt == false, "Should be able to cast element value as Bool.")

        let firstElementWithoutValue = try root["PLANT"]["ELEMENTWITHOUTVALUE"].bool
        #expect(firstElementWithoutValue == nil, "Should be able to return nil if value can't be represented as Bool.")
    }

    @Test
    func testIntValue() throws {
        let firstPlantZone = try plantsDocument.root["PLANT"]["ZONE"].int
        #expect(firstPlantZone == 4, "Should be able to cast element value as Integer.")

        let firstPlantPrice = try plantsDocument.root["PLANT"]["PRICE"].int
        #expect(firstPlantPrice == nil, "Should be able to return nil if value can't be represented as Integer.")
    }

    @Test
    func testDoubleValue() throws {
        let firstPlantPrice = try plantsDocument.root["PLANT"]["PRICE"].double
        #expect(firstPlantPrice == 2.44, "Should be able to cast element value as Double.")

        let firstPlantBotanical = try plantsDocument.root["PLANT"]["BOTANICAL"].double
        #expect(firstPlantBotanical == nil, "Should be able to return nil if value can't be represented as Double.")
    }

    @Test
    func testNotExistingElement() {
        // non-optional
        #expect(throws: AEXMLError.elementNotFound) {
            try exampleDocument.root["ducks"]["duck"]
        }

        // optional
        let optional = try? exampleDocument.root["ducks"]["duck"].first
        #expect(optional == nil)
    }

    @Test
    func testAllElements() throws {
        var count = 0
        let cats = try exampleDocument.root["cats"]["cat"]
        let allCats = try #require(cats.all)
        for cat in allCats {
            #expect(cat.parent != nil, "Each child element should have its parent element.")
            count += 1
        }
        #expect(count == 4, "Should be able to iterate all elements")
    }

    @Test
    func testFirstElement() throws {
        let catElement = try exampleDocument.root["cats"]["cat"]
        let firstCatExpectedValue = "Tinna"
        
        // non-optional
        #expect(catElement.string == firstCatExpectedValue, "Should be able to find the first element as non-optional.")

        // optional
        let cat = try #require(catElement.first)
        #expect(cat.string == firstCatExpectedValue, "Should be able to find the first element as optional.")
    }

    @Test
    func testLastElement() throws {
        let dogs = try exampleDocument.root["dogs"]["dog"]
        #expect(dogs.last?.string == "Kika", "Should be able to find the last element.")
    }

    @Test
    func testCountElements() throws {
        let dogsCount = try exampleDocument.root["dogs"]["dog"].count
        #expect(dogsCount == 4, "Should be able to count elements.")
    }

    @Test
    func testAllWithValue() throws {
        let cats = try exampleDocument.root["cats"]
        cats.addChild(name: "cat", value: "Tinna")

        let catsElement = try cats["cat"]
        let tinnas = try #require(catsElement.all(withValue: "Tinna"))
        #expect(tinnas.count == 2, "Should be able to return elements with given value.")
    }

    @Test
    func testAllWithAttributes() throws {
        let dogElements = try exampleDocument.root["dogs"]["dog"]
        let bulls = try #require(dogElements.all(withAttributes: ["color" : "white"]))
        #expect(bulls.count == 2, "Should be able to return elements with given attributes.")
    }

    @Test
    func testAllContainingAttributes() throws {
        let dogElements = try exampleDocument.root["dogs"]["dog"]
        let bulls = try #require(dogElements.all(containingAttributeKeys: ["gender"]))
        #expect(bulls.count == 2, "Should be able to return elements with given attribute keys.")
    }

    @Test
    func testAllDescendantsWherePredicate() {
        let children = exampleDocument.allDescendants { $0.attributes["color"] == "yellow" }

        #expect(children.count == 2, "Should be able to return elements matching predicate.")
    }

    @Test
    func testFirstDescendantWherePredicate() throws {
        let descendant = try plantsDocument.root.firstDescendant { $0.hasDescendant { $0.name == "LIGHT" && $0.value == "Sunny" } }
        let plantName = try descendant?["COMMON"].value

        #expect(plantName == "Black-Eyed Susan", "Should be able to find first child satisfying predicate.")
    }

    @Test
    func testHasDescendantWherePredicate() {
        let hasDescendant = plantsDocument.hasDescendant { $0.name == "AVAILABILITY" && $0.int == 030699 }

        #expect(hasDescendant, "Should be able to determine that document has a child satisfying predicate.")
    }

    @Test
    func testSpecialCharacterTrimRead() throws {
        let expected = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<elements>\n\t<string name=\"this_and_that\">This &amp; that</string>\n</elements>"
        
        let readerDocument = try AEXMLDocument(xml: expected)
        let readerXml = readerDocument.xml
        #expect(readerXml == expected, "Should be able to print XML formatted string.")
    }
    
    // MARK: - XML Write

    @Test
    func testAddChild() throws {
        let ducks = try exampleDocument.root.addChild(name: "ducks")
        ducks.addChild(name: "duck", value: "Donald")
        ducks.addChild(name: "duck", value: "Daisy")
        ducks.addChild(name: "duck", value: "Scrooge")
        
        let animalsCount = try exampleDocument.root.children.count
        #expect(animalsCount == 3, "Should be able to add child elements to an element.")

        let resultDucks = try exampleDocument.root["ducks"]["duck"]
        #expect(resultDucks.last?.string == "Scrooge", "Should be able to iterate ducks now.")
    }

    @Test
    func testAddChildWithAttributes() throws {
        let cats = try exampleDocument.root["cats"]
        let dogs = try exampleDocument.root["dogs"]

        cats.addChild(name: "cat", value: "Garfield", attributes: ["breed" : "tabby", "color" : "orange"])
        dogs.addChild(name: "dog", value: "Snoopy", attributes: ["breed" : "beagle", "color" : "white"])
        
        let catsCount = try cats["cat"].count
        let dogsCount = try dogs["dog"].count

        let lastCat = try cats["cat"].last!
        let penultDog = dogs.children[3]
        
        #expect(catsCount == 5, "Should be able to add child element with attributes to an element.")
        #expect(dogsCount == 5, "Should be able to add child element with attributes to an element.")

        #expect(lastCat.attributes["color"] == "orange", "Should be able to get attribute value from added element.")
        #expect(penultDog.string == "Kika", "Should be able to add child with attributes without overwrites existing elements. (Github Issue #28)")
    }

    @Test
    func testAddChildren() throws {
        let animals: [AEXMLElement] = [
            AEXMLElement(name: "dinosaurs"),
            AEXMLElement(name: "birds"),
            AEXMLElement(name: "bugs"),
        ]
        try exampleDocument.root.addChildren(animals)

        let animalsCount = try exampleDocument.root.children.count
        #expect(animalsCount == 5, "Should be able to add children elements to an element.")
    }

    @Test
    func testAddAttributes() throws {
        let firstCat = try exampleDocument.root["cats"]["cat"]

        firstCat.attributes["funny"] = "true"
        firstCat.attributes["speed"] = "fast"
        firstCat.attributes["years"] = "7"
        
        #expect(firstCat.attributes.count == 5, "Should be able to add attributes to an element.")

        let firstCatYear = try #require(firstCat.attributes["years"])
        #expect(Int(firstCatYear) == 7, "Should be able to get any attribute value now.")
    }

    @Test
    func testRemoveChild() throws {
        let cats = try exampleDocument.root["cats"]
        let lastCat = try cats["cat"].last!
        let duplicateCat = cats.addChild(name: "cat", value: "Tinna", attributes: ["breed" : "Siberian", "color" : "lightgray"])
        
        lastCat.removeFromParent()
        duplicateCat.removeFromParent()
        
        let catsCount = try cats["cat"].count
        let firstCat = try cats["cat"]
        #expect(catsCount == 3, "Should be able to remove element from parent.")
        #expect(firstCat.string == "Tinna", "Should be able to remove the exact element from parent.")
    }

    @Test
    func testXMLEscapedString() {
        let string = "&<>'\""
        let escapedString = string.xmlEscaped
        #expect(escapedString == "&amp;&lt;&gt;&apos;&quot;")
    }

    @Test
    func testXMLString() {
        let testDocument = AEXMLDocument()
        let children = testDocument.addChild(name: "children")
        children.addChild(name: "child", value: "value", attributes: ["attribute" : "attributeValue<&>"])
        children.addChild(name: "child")
        children.addChild(name: "child", value: "&<>'\"\n")
        
        #expect(testDocument.xml == "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<children>\n\t<child attribute=\"attributeValue&lt;&amp;&gt;\">value</child>\n\t<child />\n\t<child>&amp;&lt;&gt;&apos;&quot;&#10;</child>\n</children>", "Should be able to print XML formatted string.")

        #expect(testDocument.xmlCompact == "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?><children><child attribute=\"attributeValue&lt;&amp;&gt;\">value</child><child /><child>&amp;&lt;&gt;&apos;&quot;&#10;</child></children>", "Should be able to print compact XML string.")

        #expect(testDocument.xmlSpaces == "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<children>\n    <child attribute=\"attributeValue&lt;&amp;&gt;\">value</child>\n    <child />\n    <child>&amp;&lt;&gt;&apos;&quot;&#10;</child>\n</children>", "Should be able to print XML formatted string.")

        #expect(testDocument.xmlDoubleSpace == "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<children>\n  <child attribute=\"attributeValue&lt;&amp;&gt;\">value</child>\n  <child />\n  <child>&amp;&lt;&gt;&apos;&quot;&#10;</child>\n</children>", "Should be able to print XML formatted string.")
    }
    
    // MARK: - XML Parse Performance

    // TODO: SwiftTesting does not yet support benchmark testing

    /*
    @Test
    func testReadXMLPerformance() {
        self.measure() {
            _ = self.readXMLFromFile(filename: "plant_catalog")
        }
    }

    @Test
    func testWriteXMLPerformance() {
        self.measure() {
            _ = self.plantsDocument.xml
        }
    }
    */
}

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
