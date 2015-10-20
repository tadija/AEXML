//
//  AEXMLTests.swift
//  AEXMLTests
//
//  Created by Marko Tadic on 10/16/14.
//  Copyright (c) 2014 ae. All rights reserved.
//

import UIKit
import XCTest
import AEXMLExample

class AEXMLTests: XCTestCase {
    
    // MARK: - Properties
    
    var exampleXML = AEXMLDocument()
    var plantsXML = AEXMLDocument()
    
    // MARK: - Helper
    
    func readXMLFromFile(filename: String, shouldIncludeNamespaces: Bool = true) -> AEXMLDocument {
        var xmlDocument = AEXMLDocument()
        
        // parse xml file
        if let
            xmlPath = NSBundle.mainBundle().pathForResource(filename, ofType: "xml"),
            data = NSData(contentsOfFile: xmlPath)
        {
            do {
                xmlDocument = AEXMLDocument()
                try xmlDocument.loadXMLData(data, shouldIncludeNamespaces: shouldIncludeNamespaces)
            } catch {
                print("\(error)")
            }
        }
        
        return xmlDocument
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // create some sample xml documents
        exampleXML = readXMLFromFile("example")
        plantsXML = readXMLFromFile("plant_catalog")
    }
    
    override func tearDown() {
        // reset sample xml document
        exampleXML = AEXMLDocument()
        plantsXML = AEXMLDocument()
        
        super.tearDown()
    }
    
    // MARK: - XML Read
    
    func testRootElement() {
        XCTAssertEqual(exampleXML.root.name, "animals", "Should be able to find root element.")
    }
    
    func testParentElement() {
        XCTAssertEqual(exampleXML.root["cats"].parent!.name, "animals", "Should be able to find parent element.")
    }
    
    func testChildrenElements() {
        var count = 0
        for _ in exampleXML.root["cats"].children {
            count++
        }
        XCTAssertEqual(count, 4, "Should be able to iterate children elements")
    }
    
    func testName() {
        let secondChildElementName = exampleXML.root.children[1].name
        XCTAssertEqual(secondChildElementName, "dogs", "Should be able to return element name.")
    }
    
    func testAttributes() {
        let firstCatAttributes = exampleXML.root["cats"]["cat"].attributes
        
        // iterate attributes
        var count = 0
        for _ in firstCatAttributes {
            count++
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
        let firstPlant = plantsXML.root["PLANT"]
        
        let firstPlantCommon = firstPlant["COMMON"].value!
        XCTAssertEqual(firstPlantCommon, "Bloodroot", "Should be able to return element value as optional string.")
        
        let firstPlantElementWithoutValue = firstPlant["ELEMENTWITHOUTVALUE"].value
        XCTAssertNil(firstPlantElementWithoutValue, "Should be able to have nil value.")
        
        let firstPlantEmptyElement = firstPlant["EMPTYELEMENT"].value
        XCTAssertNil(firstPlantEmptyElement, "Should be able to have nil value.")
    }
    
    func testStringValue() {
        let firstPlant = plantsXML.root["PLANT"]
        
        let firstPlantCommon = firstPlant["COMMON"].stringValue
        XCTAssertEqual(firstPlantCommon, "Bloodroot", "Should be able to return element value as string.")
        
        let firstPlantElementWithoutValue = firstPlant["ELEMENTWITHOUTVALUE"].stringValue
        XCTAssertEqual(firstPlantElementWithoutValue, "", "Should be able to return empty string if element has no value.")
        
        let firstPlantEmptyElement = firstPlant["EMPTYELEMENT"].stringValue
        XCTAssertEqual(firstPlantEmptyElement, String(), "Should be able to return empty string if element has no value.")
    }
    
    func testBoolValue() {
        XCTAssertEqual(plantsXML.root["PLANT"]["TRUESTRING"].boolValue, true, "Should be able to cast element value as Bool.")
        XCTAssertEqual(plantsXML.root["PLANT"]["TRUENUMBER"].boolValue, true, "Should be able to cast element value as Bool.")
        XCTAssertEqual(plantsXML.root["PLANT"]["FALSEANYTHINGELSE"].boolValue, false, "Should be able to cast element value as Bool.")
    }
    
    func testIntValue() {
        let firstPlantZone = plantsXML.root["PLANT"]["ZONE"].intValue
        XCTAssertEqual(firstPlantZone, 4, "Should be able to cast element value as Integer.")
    }
    
    func testDoubleValue() {
        let firstPlantPrice = plantsXML.root["PLANT"]["PRICE"].doubleValue
        XCTAssertEqual(firstPlantPrice, 2.44, "Should be able to cast element value as Double.")
    }
    
    func testNotExistingElement() {
        // non-optional
        XCTAssertEqual(exampleXML.root["ducks"]["duck"].name, AEXMLElement.errorElementName, "Should be able to tell you if element does not exist.")
        XCTAssertEqual(exampleXML.root["ducks"]["duck"].stringValue, "element <ducks> not found", "Should be able to tell you which element does not exist.")
        
        // optional
        if let _ = exampleXML.root["ducks"]["duck"].first {
            XCTFail("Should not be able to find ducks here.")
        } else {
            XCTAssert(true)
        }
    }
    
    func testAllElements() {
        var count = 0
        if let cats = exampleXML.root["cats"]["cat"].all {
            for cat in cats {
                XCTAssertNotNil(cat.parent, "Each child element should have its parent element.")
                count++
            }
        }
        XCTAssertEqual(count, 4, "Should be able to iterate all elements")
    }
    
    func testFirstElement() {
        let catElement = exampleXML.root["cats"]["cat"]
        let firstCatExpectedValue = "Tinna"
        
        // non-optional
        XCTAssertEqual(catElement.stringValue, firstCatExpectedValue, "Should be able to find the first element as non-optional.")
        
        // optional
        if let cat = catElement.first {
            XCTAssertEqual(cat.stringValue, firstCatExpectedValue, "Should be able to find the first element as optional.")
        } else {
            XCTFail("Should be able to find the first element.")
        }
    }
    
    func testLastElement() {
        if let dog = exampleXML.root["dogs"]["dog"].last {
            XCTAssertEqual(dog.stringValue, "Kika", "Should be able to find the last element.")
        } else {
            XCTFail("Should be able to find the last element.")
        }
    }
    
    func testCountElements() {
        let dogsCount = exampleXML.root["dogs"]["dog"].count
        XCTAssertEqual(dogsCount, 4, "Should be able to count elements.")
    }
    
    func testAllWithValue() {
        let cats = exampleXML.root["cats"]
        cats.addChild(name: "cat", value: "Tinna")
        
        var count = 0
        if let tinnas = cats["cat"].allWithValue("Tinna") {
            for _ in tinnas {
                count++
            }
        }
        XCTAssertEqual(count, 2, "Should be able to return elements with given value.")
    }
    
    func testAllWithAttributes() {
        var count = 0
        if let bulls = exampleXML.root["dogs"]["dog"].allWithAttributes(["color" : "white"]) {
            for _ in bulls {
                count++
            }
        }
        XCTAssertEqual(count, 2, "Should be able to return elements with given attributes.")
    }
    
    // MARK: - XML Write
    
    func testAddChild() {
        let ducks = exampleXML.root.addChild(name: "ducks")
        ducks.addChild(name: "duck", value: "Donald")
        ducks.addChild(name: "duck", value: "Daisy")
        ducks.addChild(name: "duck", value: "Scrooge")
        
        let animalsCount = exampleXML.root.children.count
        XCTAssertEqual(animalsCount, 3, "Should be able to add child elements to an element.")
        XCTAssertEqual(exampleXML.root["ducks"]["duck"].last!.stringValue, "Scrooge", "Should be able to iterate ducks now.")
    }
    
    func testAddChildWithAttributes() {
        let cats = exampleXML.root["cats"]
        let dogs = exampleXML.root["dogs"]
        
        cats.addChild(name: "cat", value: "Garfield", attributes: ["breed" : "tabby", "color" : "orange"])
        dogs.addChild(name: "dog", value: "Snoopy", attributes: ["breed" : "beagle", "color" : "white"])
        
        let catsCount = cats["cat"].count
        let dogsCount = dogs["dog"].count
        
        let lastCat = cats["cat"].last!
        let penultDog = dogs.children[3]
        
        XCTAssertEqual(catsCount, 5, "Should be able to add child element with attributes to an element.")
        XCTAssertEqual(dogsCount, 5, "Should be able to add child element with attributes to an element.")
        
        XCTAssertEqual(lastCat.attributes["color"], "orange", "Should be able to get attribute value from added element.")
        XCTAssertEqual(penultDog.stringValue, "Kika", "Should be able to add child with attributes without overwrites existing elements. (Github Issue #28)")
    }
    
    func testAddAttributes() {
        let firstCat = exampleXML.root["cats"]["cat"]

        firstCat.attributes["funny"] = "true"
        firstCat.attributes["speed"] = "fast"
        firstCat.attributes["years"] = "7"
        
        XCTAssertEqual(firstCat.attributes.count, 5, "Should be able to add attributes to an element.")
        XCTAssertEqual(Int(firstCat.attributes["years"]!), 7, "Should be able to get any attribute value now.")
    }
    
    func testRemoveChild() {
        let cats = exampleXML.root["cats"]
        let lastCat = cats["cat"].last!
        let duplicateCat = cats.addChild(name: "cat", value: "Tinna", attributes: ["breed" : "Siberian", "color" : "lightgray"])
        
        lastCat.removeFromParent()
        duplicateCat.removeFromParent()
        
        let catsCount = cats["cat"].count
        let firstCat = cats["cat"]
        XCTAssertEqual(catsCount, 3, "Should be able to remove element from parent.")
        XCTAssertEqual(firstCat.stringValue, "Tinna", "Should be able to remove the exact element from parent.")
    }
    
    func testXMLString() {
        let newXMLDocument = AEXMLDocument()
        let children = newXMLDocument.addChild(name: "children")
        let _ = children.addChild(name: "child", value: "value", attributes: ["attribute" : "attributeValue"])
        let _ = children.addChild(name: "child")
        let _ = children.addChild(name: "child", value: "&<>'\"")
        
        XCTAssertEqual(newXMLDocument.xmlString, "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<children>\n\t<child attribute=\"attributeValue\">value</child>\n\t<child />\n\t<child>&amp;&lt;&gt;&apos;&quot;</child>\n</children>", "Should be able to print XML formatted string.")
    }
    
    // MARK: - XML Parse Performance
    
    func testReadXMLPerformance() {
        self.measureBlock() {
            _ = self.readXMLFromFile("plant_catalog")
        }
    }
    
    func testWriteXMLPerformance() {
        self.measureBlock() {
            _ = self.plantsXML.xmlString
        }
    }
    
    func testSoapWithNamespaces() {
        let soapXML = readXMLFromFile("soap")
        let item = soapXML.root["soap:Body"]["m:GetPrice"]["m:Item"].stringValue
        XCTAssertEqual(item, "Apples")
    }
    
    func testSoapWithoutNamespaces() {
        let soapXML = readXMLFromFile("soap", shouldIncludeNamespaces: false)
        let item = soapXML.root["Body"]["GetPrice"]["Item"].stringValue
        XCTAssertEqual(item, "Apples")
    }
    
}
