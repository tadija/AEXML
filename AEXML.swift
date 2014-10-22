//
// AEXML.swift
//
// Copyright (c) 2014 Marko Tadic (http://markotadic.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

class AEXMLElement {
    
    // MARK: Properties
    
    let name: String
    var value: String
    private(set) var attributes: [NSObject : AnyObject]
    
    private(set) var parent: AEXMLElement?
    private(set) var children: [AEXMLElement] = [AEXMLElement]()
    
    private let indentChar = "\t"
    
    // MARK: Lifecycle
    
    init(_ name: String, value: String = String(), attributes: [NSObject : AnyObject] = [NSObject : AnyObject]()) {
        self.name = name
        self.value = value
        self.attributes = attributes
    }
    
    // MARK: XML Read
    
    subscript(key: String) -> AEXMLElement {
        if name == "error" {
            return self
        } else {
            let filtered = children.filter { $0.name == key }
            return filtered.count > 0 ? filtered.first! : AEXMLElement("error", value: "element <\(key)> not found")
        }
    }
    
    var all: [AEXMLElement] {
        let filtered = parent?.children.filter { $0.name == self.name }
        return filtered?.count > 0 ? filtered! : [self]
    }
    
    var last: AEXMLElement {
        let filtered = parent?.children.filter { $0.name == self.name }
        return filtered?.count > 0 ? filtered!.last! : self
    }
    
    // MARK: XML Write
    
    func addChild(child: AEXMLElement) -> AEXMLElement {
        child.parent = self
        children.append(child)
        return child
    }
    
    func addChild(name: String, value: String = String(), attributes: [NSObject : AnyObject] = [NSObject : AnyObject]()) -> AEXMLElement {
        let child = AEXMLElement(name, value: value, attributes: attributes)
        return addChild(child)
    }
    
    func addAttribute(name: NSObject, value: AnyObject) {
        attributes[name] = value
    }
    
    private var parentsCount: Int {
        var count = 0
        var element = self
        while let parent = element.parent? {
            count++
            element = parent
        }
        return count
    }
    
    private func indentation(count: Int) -> String {
        var indent = String()
        if count > 0 {
            for i in 0..<count {
                indent += indentChar
            }
        }
        return indent
    }
    
    var xmlString: String {
        var xml = String()
        
        // open element
        xml += indentation(parentsCount - 1)
        xml += "<\(name)"
        
        if attributes.count > 0 {
            // insert attributes
            for att in attributes {
                xml += " \(att.0.description)=\"\(att.1.description)\""
            }
        }
        
        if value == "" && children.count == 0 {
            // close element
            xml += " />"
        } else {
            if children.count > 0 {
                // add children
                xml += ">\n"
                for child in children {
                    xml += "\(child.xmlString)\n"
                }
                // add indentation
                xml += indentation(parentsCount - 1)
                xml += "</\(name)>"
            } else {
                // insert value and close element
                xml += ">\(value)</\(name)>"
            }
        }
        
        return xml
    }
    
    var xmlStringCompact: String {
        let chars = NSCharacterSet(charactersInString: "\n" + indentChar)
        return join("", xmlString.componentsSeparatedByCharactersInSet(chars))
    }
}

// MARK: -

class AEXMLDocument: AEXMLElement {
    
    // MARK: Properties
    
    let version: Double
    let encoding: String
    
    var rootElement: AEXMLElement {
        return children.count == 1 ? children.first! : AEXMLElement("error", value: "document does not have root element")
    }
    
    // MARK: Lifecycle
    
    init(version: Double = 1.0, encoding: String = "utf-8") {
        self.version = version
        self.encoding = encoding
        super.init("AEXMLDocumentRoot")
        parent = nil
    }
    
    convenience init?(version: Double = 1.0, encoding: String = "utf-8", xmlData: NSData, inout error: NSError?) {
        self.init(version: version, encoding: encoding)
        if let parseError = readXMLData(xmlData) {
            error = parseError
            return nil
        }
    }
    
    // MARK: Read XML
    
    func readXMLData(data: NSData) -> NSError? {
        children.removeAll(keepCapacity: false)
        let xmlParser = AEXMLParser(xmlDocument: self, xmlData: data)
        return xmlParser.tryParsing() ?? nil
    }
    
    // MARK: Override
    
    override var xmlString: String {
        var xml =  "<?xml version=\"\(version)\" encoding=\"\(encoding)\"?>\n"
        for child in children {
            xml += child.xmlString
        }
        return xml
    }
    
}

// MARK: -

class AEXMLParser: NSObject, NSXMLParserDelegate {
    
    // MARK: Properties
    
    let xmlDocument: AEXMLDocument
    let xmlData: NSData
    
    var currentParent: AEXMLElement?
    var currentElement: AEXMLElement?
    var currentValue = String()
    var parseError: NSError?
    
    // MARK: Lifecycle
    
    init(xmlDocument: AEXMLDocument, xmlData: NSData) {
        self.xmlDocument = xmlDocument
        self.xmlData = xmlData
        currentParent = xmlDocument
        super.init()
    }
    
    // returns NSError from NSXMLParser delegate callback "parseErrorOccurred"
    // returns nil if NSXMLParser successfully parsed XML data
    func tryParsing() -> NSError? {
        var success = false
        let parser = NSXMLParser(data: xmlData)
        parser.delegate = self
        success = parser.parse()
        return success ? nil : parseError
    }
    
    // MARK: NSXMLParserDelegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        currentValue = String()
        currentElement = currentParent?.addChild(elementName, attributes: attributeDict)
        currentParent = currentElement
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        currentValue += string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        currentElement?.value = currentValue
    }
    
    // because of the existing bug in NSXMLParser "didEndElement" delegate callback
    // here are used unwrapped optionals for namespaceURI and qualifiedName and that's the only reason why AEXMLParser is not private class
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String!, qualifiedName qName: String!) {
        currentParent = currentParent?.parent
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        self.parseError = parseError
    }
    
}