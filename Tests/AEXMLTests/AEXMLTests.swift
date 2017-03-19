import Foundation
import XCTest
@testable import AEXML

class AEXMLTests: XCTestCase {
    
    // MARK: - Properties
    
    var exampleDocument = AEXMLDocument()
    var plantsDocument = AEXMLDocument()
    
    // MARK: - Helpers
    
    func URLForResource(fileName: String, withExtension: String) -> URL {
        let bundle = Bundle(for: AEXMLTests.self)
        return bundle.url(forResource: fileName, withExtension: withExtension)!
    }
    
    func xmlDocumentFromURL(url: URL) -> AEXMLDocument {
        var xmlDocument = AEXMLDocument()
        
        do {
            let data = try Data.init(contentsOf: url)
            xmlDocument = try AEXMLDocument(xml: data)
        } catch {
            print(error)
        }
        
        return xmlDocument
    }
    
    func readXMLFromFile(filename: String) -> AEXMLDocument {
        let url = URLForResource(fileName: filename, withExtension: "xml")
        return xmlDocumentFromURL(url: url)
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // create some sample xml documents
        exampleDocument = readXMLFromFile(filename: "example")
        plantsDocument = readXMLFromFile(filename: "plant_catalog")
    }
    
    override func tearDown() {
        // reset sample xml document
        exampleDocument = AEXMLDocument()
        plantsDocument = AEXMLDocument()
        
        super.tearDown()
    }
    
    // MARK: - XML Document
    
    func testXMLDocumentManualDataLoading() {
        do {
            let url = URLForResource(fileName: "example", withExtension: "xml")
            let data = try Data.init(contentsOf: url)
            
            let testDocument = AEXMLDocument()
            try testDocument.loadXML(data)
            XCTAssertEqual(testDocument.root.name, "animals", "Should be able to find root element.")
        } catch {
            XCTFail("Should be able to load XML Document with given Data.")
        }
    }
    
    func testXMLDocumentInitFromString() {
        do {
            let testDocument = try AEXMLDocument(xml: exampleDocument.xml)
            XCTAssertEqual(testDocument.xml, exampleDocument.xml)
        } catch {
            XCTFail("Should be able to initialize XML Document from XML String.")
        }
    }
    
    func testXMLOptions() {
        do {
            var options = AEXMLOptions()
            options.documentHeader.version = 2.0
            options.documentHeader.encoding = "utf-16"
            options.documentHeader.standalone = "yes"
            
            let testDocument = try AEXMLDocument(xml: "<foo><bar>hello</bar></foo>", options: options)
            XCTAssertEqual(testDocument.xml, "<?xml version=\"2.0\" encoding=\"utf-16\" standalone=\"yes\"?>\n<foo>\n\t<bar>hello</bar>\n</foo>")
            XCTAssertEqual(testDocument.root["bar"].first?.string, "hello")
        } catch {
            XCTFail("Should be able to initialize XML Document with custom AEXMLOptions.")
        }
    }
    
    func testXMLParser() {
        do {
            let testDocument = AEXMLDocument()
            let url = URLForResource(fileName: "example", withExtension: "xml")
            let data = try Data.init(contentsOf: url)
            
            let parser = AEXMLParser(document: testDocument, data: data)
            try parser.parse()
            
            XCTAssertEqual(testDocument.root.name, "animals", "Should be able to find root element.")
        } catch {
            XCTFail("Should be able to parse XML Data into XML Document without throwing error.")
        }
    }
    
    func testXMLParserError() {
        do {
            let testDocument = AEXMLDocument()
            let testData = Data()
            let parser = AEXMLParser(document: testDocument, data: testData)
            try parser.parse()
        } catch {
            XCTAssertEqual(error.localizedDescription, AEXMLError.parsingFailed.localizedDescription)
        }
    }
    
    // MARK: - XML Read
    
    func testRootElement() {
        XCTAssertEqual(exampleDocument.root.name, "animals", "Should be able to find root element.")
        
        let documentWithoutRootElement = AEXMLDocument()
        let rootElement = documentWithoutRootElement.root
        XCTAssertEqual(rootElement.error, AEXMLError.rootElementMissing, "Should have RootElementMissing error.")
    }
    
    func testParentElement() {
        XCTAssertEqual(exampleDocument.root["cats"].parent!.name, "animals", "Should be able to find parent element.")
    }
    
    func testChildrenElements() {
        var count = 0
        for _ in exampleDocument.root["cats"].children {
            count += 1
        }
        XCTAssertEqual(count, 4, "Should be able to iterate children elements")
    }
    
    func testName() {
        let secondChildElementName = exampleDocument.root.children[1].name
        XCTAssertEqual(secondChildElementName, "dogs", "Should be able to return element name.")
    }
    
    func testAttributes() {
        let firstCatAttributes = exampleDocument.root["cats"]["cat"].attributes
        
        // iterate attributes
        var count = 0
        for _ in firstCatAttributes {
            count += 1
        }
        XCTAssertEqual(count, 2, "Should be able to iterate element attributes.")
        
        // get attribute value
        if let firstCatBreed = firstCatAttributes["breed"] {
            XCTAssertEqual(firstCatBreed, "Siberian", "Should be able to return attribute value.")
        } else {
            XCTFail("The first cat should have breed attribute.")
        }
    }
    
    func testValue() {
        let firstPlant = plantsDocument.root["PLANT"]
        
        let firstPlantCommon = firstPlant["COMMON"].value!
        XCTAssertEqual(firstPlantCommon, "Bloodroot", "Should be able to return element value as optional string.")
        
        let firstPlantElementWithoutValue = firstPlant["ELEMENTWITHOUTVALUE"].value
        XCTAssertNil(firstPlantElementWithoutValue, "Should be able to have nil value.")
        
        let firstPlantEmptyElement = firstPlant["EMPTYELEMENT"].value
        XCTAssertNil(firstPlantEmptyElement, "Should be able to have nil value.")
    }
    
    func testStringValue() {
        let firstPlant = plantsDocument.root["PLANT"]
        
        let firstPlantCommon = firstPlant["COMMON"].string
        XCTAssertEqual(firstPlantCommon, "Bloodroot", "Should be able to return element value as string.")
        
        let firstPlantElementWithoutValue = firstPlant["ELEMENTWITHOUTVALUE"].string
        XCTAssertEqual(firstPlantElementWithoutValue, "", "Should be able to return empty string if element has no value.")
        
        let firstPlantEmptyElement = firstPlant["EMPTYELEMENT"].string
        XCTAssertEqual(firstPlantEmptyElement, String(), "Should be able to return empty string if element has no value.")
    }
    
    func testBoolValue() {
        let firstTrueString = plantsDocument.root["PLANT"]["TRUESTRING"].bool
        XCTAssertEqual(firstTrueString, true, "Should be able to cast element value as Bool.")
        
        let firstFalseString = plantsDocument.root["PLANT"]["FALSESTRING"].bool
        XCTAssertEqual(firstFalseString, false, "Should be able to cast element value as Bool.")
        
        let firstElementWithoutValue = plantsDocument.root["ELEMENTWITHOUTVALUE"].bool
        XCTAssertNil(firstElementWithoutValue, "Should be able to return nil if value can't be represented as Bool.")
    }
    
    func testIntValue() {
        let firstPlantZone = plantsDocument.root["PLANT"]["ZONE"].int
        XCTAssertEqual(firstPlantZone, 4, "Should be able to cast element value as Integer.")
        
        let firstPlantPrice = plantsDocument.root["PLANT"]["PRICE"].int
        XCTAssertNil(firstPlantPrice, "Should be able to return nil if value can't be represented as Integer.")
    }
    
    func testDoubleValue() {
        let firstPlantPrice = plantsDocument.root["PLANT"]["PRICE"].double
        XCTAssertEqual(firstPlantPrice, 2.44, "Should be able to cast element value as Double.")
        
        let firstPlantBotanical = plantsDocument.root["PLANT"]["BOTANICAL"].double
        XCTAssertNil(firstPlantBotanical, "Should be able to return nil if value can't be represented as Double.")
    }
    
    func testNotExistingElement() {
        // non-optional
        XCTAssertNotNil(exampleDocument.root["ducks"]["duck"].error, "Should contain error inside element which does not exist.")
        XCTAssertEqual(exampleDocument.root["ducks"]["duck"].error, AEXMLError.elementNotFound, "Should have ElementNotFound error.")
        XCTAssertEqual(exampleDocument.root["ducks"]["duck"].string, String(), "Should have empty value.")
        
        // optional
        if let _ = exampleDocument.root["ducks"]["duck"].first {
            XCTFail("Should not be able to find ducks here.")
        } else {
            XCTAssert(true)
        }
    }
    
    func testAllElements() {
        var count = 0
        if let cats = exampleDocument.root["cats"]["cat"].all {
            for cat in cats {
                XCTAssertNotNil(cat.parent, "Each child element should have its parent element.")
                count += 1
            }
        }
        XCTAssertEqual(count, 4, "Should be able to iterate all elements")
    }
    
    func testFirstElement() {
        let catElement = exampleDocument.root["cats"]["cat"]
        let firstCatExpectedValue = "Tinna"
        
        // non-optional
        XCTAssertEqual(catElement.string, firstCatExpectedValue, "Should be able to find the first element as non-optional.")
        
        // optional
        if let cat = catElement.first {
            XCTAssertEqual(cat.string, firstCatExpectedValue, "Should be able to find the first element as optional.")
        } else {
            XCTFail("Should be able to find the first element.")
        }
    }
    
    func testLastElement() {
        if let dog = exampleDocument.root["dogs"]["dog"].last {
            XCTAssertEqual(dog.string, "Kika", "Should be able to find the last element.")
        } else {
            XCTFail("Should be able to find the last element.")
        }
    }
    
    func testCountElements() {
        let dogsCount = exampleDocument.root["dogs"]["dog"].count
        XCTAssertEqual(dogsCount, 4, "Should be able to count elements.")
    }
    
    func testAllWithValue() {
        let cats = exampleDocument.root["cats"]
        cats.addChild(name: "cat", value: "Tinna")
        
        var count = 0
        if let tinnas = cats["cat"].all(withValue: "Tinna") {
            for _ in tinnas {
                count += 1
            }
        }
        XCTAssertEqual(count, 2, "Should be able to return elements with given value.")
    }
    
    func testAllWithAttributes() {
        var count = 0
        if let bulls = exampleDocument.root["dogs"]["dog"].all(withAttributes: ["color" : "white"]) {
            for _ in bulls {
                count += 1
            }
        }
        XCTAssertEqual(count, 2, "Should be able to return elements with given attributes.")
    }
    
    func testAllContainingAttributes() {
        var count = 0
        if let bulls = exampleDocument.root["dogs"]["dog"].all(containingAttributeKeys: ["gender"]) {
            for _ in bulls {
                count += 1
            }
        }
        XCTAssertEqual(count, 2, "Should be able to return elements with given attribute keys.")
    }
    
    // MARK: - XML Write
    
    func testAddChild() {
        let ducks = exampleDocument.root.addChild(name: "ducks")
        ducks.addChild(name: "duck", value: "Donald")
        ducks.addChild(name: "duck", value: "Daisy")
        ducks.addChild(name: "duck", value: "Scrooge")
        
        let animalsCount = exampleDocument.root.children.count
        XCTAssertEqual(animalsCount, 3, "Should be able to add child elements to an element.")
        XCTAssertEqual(exampleDocument.root["ducks"]["duck"].last!.string, "Scrooge", "Should be able to iterate ducks now.")
    }
    
    func testAddChildWithAttributes() {
        let cats = exampleDocument.root["cats"]
        let dogs = exampleDocument.root["dogs"]
        
        cats.addChild(name: "cat", value: "Garfield", attributes: ["breed" : "tabby", "color" : "orange"])
        dogs.addChild(name: "dog", value: "Snoopy", attributes: ["breed" : "beagle", "color" : "white"])
        
        let catsCount = cats["cat"].count
        let dogsCount = dogs["dog"].count
        
        let lastCat = cats["cat"].last!
        let penultDog = dogs.children[3]
        
        XCTAssertEqual(catsCount, 5, "Should be able to add child element with attributes to an element.")
        XCTAssertEqual(dogsCount, 5, "Should be able to add child element with attributes to an element.")
        
        XCTAssertEqual(lastCat.attributes["color"], "orange", "Should be able to get attribute value from added element.")
        XCTAssertEqual(penultDog.string, "Kika", "Should be able to add child with attributes without overwrites existing elements. (Github Issue #28)")
    }
    
    func testAddAttributes() {
        let firstCat = exampleDocument.root["cats"]["cat"]

        firstCat.attributes["funny"] = "true"
        firstCat.attributes["speed"] = "fast"
        firstCat.attributes["years"] = "7"
        
        XCTAssertEqual(firstCat.attributes.count, 5, "Should be able to add attributes to an element.")
        XCTAssertEqual(Int(firstCat.attributes["years"]!), 7, "Should be able to get any attribute value now.")
    }
    
    func testRemoveChild() {
        let cats = exampleDocument.root["cats"]
        let lastCat = cats["cat"].last!
        let duplicateCat = cats.addChild(name: "cat", value: "Tinna", attributes: ["breed" : "Siberian", "color" : "lightgray"])
        
        lastCat.removeFromParent()
        duplicateCat.removeFromParent()
        
        let catsCount = cats["cat"].count
        let firstCat = cats["cat"]
        XCTAssertEqual(catsCount, 3, "Should be able to remove element from parent.")
        XCTAssertEqual(firstCat.string, "Tinna", "Should be able to remove the exact element from parent.")
    }
    
    func testXMLEscapedString() {
        let string = "&<>'\""
        let escapedString = string.xmlEscaped
        XCTAssertEqual(escapedString, "&amp;&lt;&gt;&apos;&quot;")
    }
    
    func testXMLString() {
        let testDocument = AEXMLDocument()
        let children = testDocument.addChild(name: "children")
        children.addChild(name: "child", value: "value", attributes: ["attribute" : "attributeValue<&>"])
        children.addChild(name: "child")
        children.addChild(name: "child", value: "&<>'\"")
        
        XCTAssertEqual(testDocument.xml, "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<children>\n\t<child attribute=\"attributeValue&lt;&amp;&gt;\">value</child>\n\t<child />\n\t<child>&amp;&lt;&gt;&apos;&quot;</child>\n</children>", "Should be able to print XML formatted string.")
        
        XCTAssertEqual(testDocument.xmlCompact, "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?><children><child attribute=\"attributeValue&lt;&amp;&gt;\">value</child><child /><child>&amp;&lt;&gt;&apos;&quot;</child></children>", "Should be able to print compact XML string.")
    }
    
    // MARK: - XML Parse Performance
    
    func testReadXMLPerformance() {
        self.measure() {
            _ = self.readXMLFromFile(filename: "plant_catalog")
        }
    }
    
    func testWriteXMLPerformance() {
        self.measure() {
            _ = self.plantsDocument.xml
        }
    }
    
}
