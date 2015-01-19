//
//  AEXMLTests.swift
//
//  Copyright (c) 2014 Michael Hohl - http://michaelhohl.net/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import AEXML
import Nimble
import Quick

class AEXMLSpec: QuickSpec {
    
    override func spec() {
        let xmlToParse = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?><animals><cats><cat breed=\"Siberian\" color=\"lightgray\">Tinna</cat></cats><dogs><dog breed=\"Bull Terrier\" color=\"white\">Villy</dog><dog breed=\"Bull Terrier\" color=\"white\">Spot</dog><dog breed=\"Golden Retriever\" color=\"yellow\">Betty</dog><dog breed=\"Miniature Schnauzer\" color=\"black\">Kika</dog></dogs></animals>"
        
        var xml = AEXMLDocument()
        var error: NSError?
        
        beforeEach {
            xml = AEXMLDocument(xmlData: xmlToParse.dataUsingEncoding(NSUTF8StringEncoding)!, error: &error)!
        }
        
        describe("xml parsing") {
            it("should be able to find the root element") {
                expect(xml.rootElement.name).to(equal("animals"))
            }
            
            it("should be able to parse individual elements") {
                expect(xml.rootElement["cats"]["cat"].value).to(equal("Tinna"))
            }
            
            it("should be able to parse single element of groups") {
                expect(xml.rootElement["dogs"]["dog"].last.value).to(equal("Kika"))
            }
            
            it("should be able to look up elements by name and attribute") {
                expect(xml.rootElement["dogs"]["dog"].countWithAttributes(["breed" : "Bull Terrier"])).to(equal(2))
            }
            
            it("should be able to iterate element groups") {
                expect(", ".join(xml.rootElement["dogs"]["dog"].all.map { element in element.value })).to(equal("Villy, Spot, Betty, Kika"))
            }
            
            it("should be able to iterate element groups even if only one element is found") {
                expect(xml.rootElement["cats"]["cat"].count).to(equal(1))
            }
            
            it("should be able to iterate using for-in") {
                var count = 0
                for elem in xml.rootElement["dogs"]["dog"].all {
                    count++
                }
                
                expect(count).to(equal(4))
            }
        }
        
        describe("xml string") {
            it("should be able to get xml string from element") {
                expect(xml.rootElement["cats"]["cat"].xmlStringCompact).to(equal("<cat breed=\"Siberian\" color=\"lightgray\">Tinna</cat>"))
            }
            
            it("should be able to get full document string") {
                expect(xml.xmlStringCompact).to(equal(xmlToParse))
            }
        }
    }
    
}
