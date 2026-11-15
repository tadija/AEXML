/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2026
 *  Licensed under the MIT license
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

import Testing
@testable import AEXML

class AEXMLTests: SharedTesting {
    // MARK: - Properties

    var exampleDocument = AEXMLDocument()
    var plantsDocument = AEXMLDocument()

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

        let root = testDocument.root
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

        let firstString = testDocument.root["bar"].first?.string
        #expect(firstString == "hello")
    }

    @Test
    func testXMLParser() throws {
        let testDocument = AEXMLDocument()
        let url = URLForResource(fileName: "example", withExtension: "xml")
        let data = try Data.init(contentsOf: url)

        let parser = AEXMLParser(document: testDocument, data: data)
        try parser.parse()

        let rootName = testDocument.root.name
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

    @Test
    func testXMLParserLeavesValueOfEmptyElementNil() throws {
        let testDocument = try AEXMLDocument(xml: "<root><empty></empty><selfClosing /></root>")

        #expect(testDocument.root["empty"].value == nil)
        #expect(testDocument.root["selfClosing"].value == nil)
    }

    @Test
    func testXMLParserTrimsWhitespaceOnlyValueToEmptyString() throws {
        let testDocument = try AEXMLDocument(xml: "<root><blank>  \n  </blank></root>")

        #expect(testDocument.root["blank"].value == "")
    }

    @Test
    func testXMLParserJoinsValueSplitByEntityReferences() throws {
        let testDocument = try AEXMLDocument(xml: "<root><text>a &amp; b &lt; c &gt; d &quot;e&quot; &apos;f&apos;</text></root>")

        #expect(testDocument.root["text"].value == "a & b < c > d \"e\" 'f'")
    }

    @Test
    func testXMLParserKeepsTextBeforeChildAndDropsTextAfterIt() throws {
        let testDocument = try AEXMLDocument(xml: "<root><mixed> before <child>inner</child> after </mixed></root>")

        #expect(testDocument.root["mixed"].value == " before ")
        #expect(testDocument.root["mixed"]["child"].value == "inner")
    }

    @Test
    func testXMLParserKeepsValueOfElementLeftOpenByTruncatedInput() {
        let testDocument = AEXMLDocument()

        // truncated input is a parsing error on Apple platforms, while FoundationXML on Linux reports success
        try? testDocument.loadXML("<root><text>hello wor".data(using: .utf8)!)

        #expect(testDocument.root["text"].value == "hello wor", "Text of an element left open by truncated input should stay in the document.")
    }
    
    private func whitespaceResult(shouldTrimWhitespace: Bool) throws -> String? {
        var options = AEXMLOptions()
        options.parserSettings.shouldTrimWhitespace = shouldTrimWhitespace

        let testDocument = AEXMLDocument(options: options)
        let url = URLForResource(fileName: "whitespace_examples", withExtension: "xml")
        let data = try Data.init(contentsOf: url)

        let parser = AEXMLParser(document: testDocument, data: data)
        try parser.parse()

        return testDocument.root["text"].first?.string
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
        let root = exampleDocument.root
        #expect(root.name == "animals")

        let documentWithoutRootElement = AEXMLDocument()
        #expect(documentWithoutRootElement.root.error == .rootElementMissing)
    }

    @Test
    func testParentElement() throws {
        let root = exampleDocument.root
        let cats = root["cats"]
        let parent = try #require(cats.parent)
        #expect(parent.name == "animals")
    }

    @Test
    func testChildrenElements() throws {
        let cats = exampleDocument.root["cats"]
        var count = 0
        for _ in cats.children {
            count += 1
        }
        #expect(count == 4, "Should be able to iterate children elements")
    }

    @Test
    func testName() throws {
        let secondChildElementName = exampleDocument.root.children[1].name
        #expect(secondChildElementName == "dogs", "Should be able to return element name.")
    }

    @Test
    func testAttributes() throws {
        let firstCatAttributes = exampleDocument.root["cats"]["cat"].attributes

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
        let firstPlant = plantsDocument.root["PLANT"]

        let firstPlantCommon = firstPlant["COMMON"].value
        #expect(firstPlantCommon == "Bloodroot", "Should be able to return element value as optional string.")

        let firstPlantElementWithoutValue = firstPlant["ELEMENTWITHOUTVALUE"].value
        #expect(firstPlantElementWithoutValue == nil, "Should be able to have nil value.")

        let firstPlantEmptyElement = firstPlant["EMPTYELEMENT"].value
        #expect(firstPlantEmptyElement == nil, "Should be able to have nil value.")
    }

    @Test
    func testStringValue() throws {
        let firstPlant = plantsDocument.root["PLANT"]

        let firstPlantCommon = firstPlant["COMMON"].string
        #expect(firstPlantCommon == "Bloodroot", "Should be able to return element value as string.")

        let firstPlantElementWithoutValue = firstPlant["ELEMENTWITHOUTVALUE"].string
        #expect(firstPlantElementWithoutValue == "", "Should be able to return empty string if element has no value.")

        let firstPlantEmptyElement = firstPlant["EMPTYELEMENT"].string
        #expect(firstPlantEmptyElement == String(), "Should be able to return empty string if element has no value.")
    }

    @Test
    func testBoolValue() throws {
        let root = plantsDocument.root

        let firstTrueString = root["PLANT"]["TRUESTRING"].bool
        #expect(firstTrueString == true, "Should be able to cast element value as Bool.")

        let firstFalseString = root["PLANT"]["FALSESTRING"].bool
        #expect(firstFalseString == false, "Should be able to cast element value as Bool.")

        let firstTrueString2 = root["PLANT"]["TRUESTRING2"].bool
        #expect(firstTrueString2 == true, "Should be able to cast element value as Bool.")

        let firstFalseString2 = root["PLANT"]["FALSESTRING2"].bool
        #expect(firstFalseString2 == false, "Should be able to cast element value as Bool.")

        let firstTrueInt = root["PLANT"]["TRUEINT"].bool
        #expect(firstTrueInt == true, "Should be able to cast element value as Bool.")

        let firstFalseInt = root["PLANT"]["FALSEINT"].bool
        #expect(firstFalseInt == false, "Should be able to cast element value as Bool.")

        let firstElementWithoutValue = root["PLANT"]["ELEMENTWITHOUTVALUE"].bool
        #expect(firstElementWithoutValue == nil, "Should be able to return nil if value can't be represented as Bool.")
    }

    @Test
    func testIntValue() throws {
        let firstPlantZone = plantsDocument.root["PLANT"]["ZONE"].int
        #expect(firstPlantZone == 4, "Should be able to cast element value as Integer.")

        let firstPlantPrice = plantsDocument.root["PLANT"]["PRICE"].int
        #expect(firstPlantPrice == nil, "Should be able to return nil if value can't be represented as Integer.")
    }

    @Test
    func testDoubleValue() throws {
        let firstPlantPrice = plantsDocument.root["PLANT"]["PRICE"].double
        #expect(firstPlantPrice == 2.44, "Should be able to cast element value as Double.")

        let firstPlantBotanical = plantsDocument.root["PLANT"]["BOTANICAL"].double
        #expect(firstPlantBotanical == nil, "Should be able to return nil if value can't be represented as Double.")
    }

    @Test
    func testNotExistingElement() {
        // non-optional
        let nonOptional = exampleDocument.root["ducks"]["duck"]
        #expect(nonOptional.error == .elementNotFound)

        // optional
        let optional = exampleDocument.root["ducks"]["duck"].first
        #expect(optional == nil)
    }

    @Test
    func testAllElements() throws {
        var count = 0
        let cats = exampleDocument.root["cats"]["cat"]
        let allCats = try #require(cats.all)
        for cat in allCats {
            #expect(cat.parent != nil, "Each child element should have its parent element.")
            count += 1
        }
        #expect(count == 4, "Should be able to iterate all elements")
    }

    @Test
    func testFirstElement() throws {
        let catElement = exampleDocument.root["cats"]["cat"]
        let firstCatExpectedValue = "Tinna"
        
        // non-optional
        #expect(catElement.string == firstCatExpectedValue, "Should be able to find the first element as non-optional.")

        // optional
        let cat = try #require(catElement.first)
        #expect(cat.string == firstCatExpectedValue, "Should be able to find the first element as optional.")
    }

    @Test
    func testLastElement() throws {
        let dogs = exampleDocument.root["dogs"]["dog"]
        #expect(dogs.last?.string == "Kika", "Should be able to find the last element.")
    }

    @Test
    func testCountElements() throws {
        let dogsCount = exampleDocument.root["dogs"]["dog"].count
        #expect(dogsCount == 4, "Should be able to count elements.")
    }

    @Test
    func testAllWithValue() throws {
        let cats = exampleDocument.root["cats"]
        cats.addChild(name: "cat", value: "Tinna")

        let catsElement = cats["cat"]
        let tinnas = try #require(catsElement.all(withValue: "Tinna"))
        #expect(tinnas.count == 2, "Should be able to return elements with given value.")
    }

    @Test
    func testAllWithAttributes() throws {
        let dogElements = exampleDocument.root["dogs"]["dog"]
        let bulls = try #require(dogElements.all(withAttributes: ["color" : "white"]))
        #expect(bulls.count == 2, "Should be able to return elements with given attributes.")
    }

    @Test
    func testAllContainingAttributes() throws {
        let dogElements = exampleDocument.root["dogs"]["dog"]
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
        let descendant = plantsDocument.root.firstDescendant { $0.hasDescendant { $0.name == "LIGHT" && $0.value == "Sunny" } }
        let plantName = descendant?["COMMON"].value

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
        let ducks = exampleDocument.root.addChild(name: "ducks")
        ducks.addChild(name: "duck", value: "Donald")
        ducks.addChild(name: "duck", value: "Daisy")
        ducks.addChild(name: "duck", value: "Scrooge")
        
        let animalsCount = exampleDocument.root.children.count
        #expect(animalsCount == 3, "Should be able to add child elements to an element.")

        let resultDucks = exampleDocument.root["ducks"]["duck"]
        #expect(resultDucks.last?.string == "Scrooge", "Should be able to iterate ducks now.")
    }

    @Test
    func testAddChildWithAttributes() throws {
        let cats = exampleDocument.root["cats"]
        let dogs = exampleDocument.root["dogs"]

        cats.addChild(name: "cat", value: "Garfield", attributes: ["breed" : "tabby", "color" : "orange"])
        dogs.addChild(name: "dog", value: "Snoopy", attributes: ["breed" : "beagle", "color" : "white"])
        
        let catsCount = cats["cat"].count
        let dogsCount = dogs["dog"].count

        let lastCat = cats["cat"].last!
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
        exampleDocument.root.addChildren(animals)

        let animalsCount = exampleDocument.root.children.count
        #expect(animalsCount == 5, "Should be able to add children elements to an element.")
    }

    @Test
    func testAddAttributes() throws {
        let firstCat = exampleDocument.root["cats"]["cat"]

        firstCat.attributes["funny"] = "true"
        firstCat.attributes["speed"] = "fast"
        firstCat.attributes["years"] = "7"
        
        #expect(firstCat.attributes.count == 5, "Should be able to add attributes to an element.")

        let firstCatYear = try #require(firstCat.attributes["years"])
        #expect(Int(firstCatYear) == 7, "Should be able to get any attribute value now.")
    }

    @Test
    func testRemoveChild() throws {
        let cats = exampleDocument.root["cats"]
        let lastCat = cats["cat"].last!
        let duplicateCat = cats.addChild(name: "cat", value: "Tinna", attributes: ["breed" : "Siberian", "color" : "lightgray"])
        
        lastCat.removeFromParent()
        duplicateCat.removeFromParent()
        
        let catsCount = cats["cat"].count
        let firstCat = cats["cat"]
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
    func testXMLEscapedStringEscapesWhitespaceControlCharacters() {
        #expect("a\nb\rc\td".xmlEscaped == "a&#10;b&#13;c&#9;d")
    }

    @Test
    func testXMLEscapedStringKeepsStringWithoutSpecialCharacters() {
        let string = "Plain text with unicode: Žđšćč, 日本語, 👨‍👩‍👧 and spaces"
        #expect(string.xmlEscaped == string)
    }

    @Test
    func testXMLEscapedStringEscapesSpecialCharactersAmongUnicode() {
        #expect("Žđ<šćč>&日本語'👨‍👩‍👧\"".xmlEscaped == "Žđ&lt;šćč&gt;&amp;日本語&apos;👨‍👩‍👧&quot;")
    }

    @Test
    func testXMLEscapedStringEscapesAlreadyEscapedEntities() {
        #expect("&amp;&lt;".xmlEscaped == "&amp;amp;&amp;lt;")
    }

    @Test
    func testXMLEscapedStringOnEmptyString() {
        #expect("".xmlEscaped == "")
    }

    @Test
    func testXMLEscapedStringOfLongString() {
        let chunk = "Lorem ipsum <dolor> sit & amet, \"consectetur\" 'adipiscing' elit.\n"
        let string = String(repeating: chunk, count: 20_000)

        let escaped = string.xmlEscaped

        #expect(escaped.hasPrefix("Lorem ipsum &lt;dolor&gt; sit &amp; amet, &quot;consectetur&quot; &apos;adipiscing&apos; elit.&#10;"))
        #expect(escaped.utf8.count == string.utf8.count + 20_000 * (3 + 3 + 4 + 10 + 10 + 4))
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

    @Test
    func testXMLStringKeepsTabsAndCarriageReturns() throws {
        let testDocument = AEXMLDocument()
        testDocument.addChild(name: "child", value: "a\tb\r\nc", attributes: ["attribute" : "x\ty\rz"])

        for xml in [testDocument.xml, testDocument.xmlCompact, testDocument.xmlSpaces, testDocument.xmlDoubleSpace] {
            let parsedDocument = try AEXMLDocument(xml: xml)
            #expect(parsedDocument.root.value == "a\tb\r\nc", "Should keep tabs and carriage returns in values.")
            #expect(parsedDocument.root.attributes["attribute"] == "x\ty\rz", "Should keep tabs and carriage returns in attributes.")
        }
    }

    @Test
    func testXMLStringOfNestedDocument() {
        let testDocument = AEXMLDocument()
        let root = testDocument.addChild(name: "root")
        let level1 = root.addChild(name: "level1", attributes: ["b" : "2", "a" : "1"])
        let level2 = level1.addChild(name: "level2")
        level2.addChild(name: "leaf", value: "value")
        level2.addChild(name: "empty")
        root.addChild(name: "sibling", value: "")

        #expect(testDocument.xml == "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<root>\n\t<level1 a=\"1\" b=\"2\">\n\t\t<level2>\n\t\t\t<leaf>value</leaf>\n\t\t\t<empty />\n\t\t</level2>\n\t</level1>\n\t<sibling></sibling>\n</root>")
    }

    @Test
    func testXMLStringVariantsOfNestedDocument() {
        let testDocument = AEXMLDocument()
        let root = testDocument.addChild(name: "root")
        let level1 = root.addChild(name: "level1", attributes: ["a" : "1"])
        level1.addChild(name: "leaf", value: "value")
        level1.addChild(name: "empty")

        let header = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>"
        #expect(testDocument.xmlCompact == header + "<root><level1 a=\"1\"><leaf>value</leaf><empty /></level1></root>")
        #expect(testDocument.xmlSpaces == header + "\n<root>\n    <level1 a=\"1\">\n        <leaf>value</leaf>\n        <empty />\n    </level1>\n</root>")
        #expect(testDocument.xmlDoubleSpace == header + "\n<root>\n  <level1 a=\"1\">\n    <leaf>value</leaf>\n    <empty />\n  </level1>\n</root>")

        #expect(level1.xmlCompact == "<level1 a=\"1\"><leaf>value</leaf><empty /></level1>")
        #expect(level1.xmlSpaces == "    <level1 a=\"1\">\n        <leaf>value</leaf>\n        <empty />\n    </level1>")
        #expect(level1.xmlDoubleSpace == "  <level1 a=\"1\">\n    <leaf>value</leaf>\n    <empty />\n  </level1>")
    }

    private class CommentedElement: AEXMLElement {
        override func appendXML(to xml: inout String, depth: Int, format: AEXMLFormat) {
            xml += "<!-- \(name) -->\(format.newline)"
            super.appendXML(to: &xml, depth: depth, format: format)
        }
    }

    @Test
    func testSubclassSerializationIsUsedInsideParentAndAllVariants() {
        let testDocument = AEXMLDocument()
        let root = testDocument.addChild(name: "root")
        root.addChild(CommentedElement(name: "custom", value: "value"))
        root.addChild(name: "plain")

        let header = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>"
        #expect(testDocument.xml == header + "\n<root>\n<!-- custom -->\n\t<custom>value</custom>\n\t<plain />\n</root>")
        #expect(testDocument.xmlCompact == header + "<root><!-- custom --><custom>value</custom><plain /></root>")
        #expect(testDocument.xmlSpaces == header + "\n<root>\n<!-- custom -->\n    <custom>value</custom>\n    <plain />\n</root>")
        #expect(root["custom"].xml == "<!-- custom -->\n\t<custom>value</custom>")
    }

    @Test
    func testXMLStringOfNestedElementIsIndentedByItsDepth() {
        let testDocument = AEXMLDocument()
        let root = testDocument.addChild(name: "root")
        let level1 = root.addChild(name: "level1")
        level1.addChild(name: "leaf", value: "value")

        #expect(root.xml == "<root>\n\t<level1>\n\t\t<leaf>value</leaf>\n\t</level1>\n</root>")
        #expect(level1.xml == "\t<level1>\n\t\t<leaf>value</leaf>\n\t</level1>")
        #expect(level1["leaf"].xml == "\t\t<leaf>value</leaf>")
    }

    @Test
    func testXMLStringOfDetachedElementIndentsRelativeToDocument() {
        let element = AEXMLElement(name: "parent", attributes: ["key" : "value"])
        element.addChild(name: "child", value: "text")
        element.addChild(name: "child")

        #expect(element.xml == "<parent key=\"value\">\n<child>text</child>\n<child />\n</parent>")
        #expect(element.xmlCompact == "<parent key=\"value\"><child>text</child><child /></parent>")
        #expect(element.xmlSpaces == "<parent key=\"value\">\n<child>text</child>\n<child />\n</parent>")
        #expect(element.xmlDoubleSpace == "<parent key=\"value\">\n<child>text</child>\n<child />\n</parent>")
    }

    @Test
    func testXMLStringOfElementWithChildrenIgnoresValue() {
        let element = AEXMLElement(name: "parent", value: "ignored")
        element.addChild(name: "child")

        #expect(element.xml == "<parent>\n<child />\n</parent>")
    }
}
