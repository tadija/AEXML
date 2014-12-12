//
// AEXML.swift
//
// Copyright (c) 2014 Marko Tadic - http://markotadic.com
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

public class AEXMLElement {
    
    // MARK: Main Properties
    
    public let name: String
    public var value: String
    public private(set) var attributes: [NSObject : AnyObject]
    
    public private(set) weak var parent: AEXMLElement?
    public private(set) var children: [AEXMLElement] = [AEXMLElement]()
    
    private let indentChar = "\t"
    
    // MARK: Converted Properties
    
    public var boolValue: Bool {
        return value.lowercaseString == "true" || value.toInt() == 1 ? true : false
    }
    public var intValue: Int {
        return value.toInt() ?? 0
    }
    public var doubleValue: Double {
        return (value as NSString).doubleValue
    }
    
    // MARK: Lifecycle
    
    public init(_ name: String, value: String = String(), attributes: [NSObject : AnyObject] = [NSObject : AnyObject]()) {
        self.name = name
        self.value = value
        self.attributes = attributes
    }
    
    // MARK: XML Read
    
    // returns the first element with given name
    public subscript(key: String) -> AEXMLElement {
        if name == "error" {
            return self
        } else {
            let filtered = children.filter { $0.name == key }
            return filtered.count > 0 ? filtered.first! : AEXMLElement("error", value: "element <\(key)> not found")
        }
    }
    
    public var last: AEXMLElement {
        let filtered = parent?.children.filter { $0.name == self.name }
        return filtered?.count > 0 ? filtered!.last! : self
    }
    
    public var all: [AEXMLElement] {
        let filtered = parent?.children.filter { $0.name == self.name }
        return filtered?.count > 0 ? filtered! : [self]
    }
    
    public var count: Int {
        let filtered = parent?.children.filter { $0.name == self.name }
        return filtered?.count ?? 0
    }
    
    public func allWithAttributes <K: NSObject, V: AnyObject where K: Equatable, V: Equatable> (attributes: [K : V]) -> [AEXMLElement]? {
        var found = [AEXMLElement]()
        if let filtered = (parent?.children.filter { $0.name == self.name }) {
            for element in filtered {
                var countAttributes = 0
                for (key, value) in attributes {
                    if element.attributes[key] as? V == value {
                        countAttributes++
                    }
                }
                if countAttributes == attributes.count {
                    found.append(element)
                }
            }
            return found.count > 0 ? found : nil
        } else {
            return nil
        }
    }
    
    public func countWithAttributes <K: NSObject, V: AnyObject where K: Equatable, V: Equatable> (attributes: [K : V]) -> Int {
        return allWithAttributes(attributes)?.count ?? 0
    }
    
    // MARK: XML Write
    
    public func addChild(child: AEXMLElement) -> AEXMLElement {
        child.parent = self
        children.append(child)
        return child
    }
    
    public func addChild(name: String, value: String = String(), attributes: [NSObject : AnyObject] = [NSObject : AnyObject]()) -> AEXMLElement {
        let child = AEXMLElement(name, value: value, attributes: attributes)
        return addChild(child)
    }
    
    public func addAttribute(name: NSObject, value: AnyObject) {
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
    
    public var xmlString: String {
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
    
    public var xmlStringCompact: String {
        let chars = NSCharacterSet(charactersInString: "\n" + indentChar)
        return join("", xmlString.componentsSeparatedByCharactersInSet(chars))
    }
}

// MARK: -

public class AEXMLDocument: AEXMLElement {
    
    // MARK: Properties
    
    public let version: Double
    public let encoding: String
    public let standalone: String
    
    public var rootElement: AEXMLElement {
        return children.count == 1 ? children.first! : AEXMLElement("error", value: "document does not have root element")
    }
    
    // MARK: Lifecycle
    
    public init(version: Double = 1.0, encoding: String = "utf-8", standalone: String = "no") {
        self.version = version
        self.encoding = encoding
        self.standalone = standalone
        super.init("AEXMLDocumentRoot")
        parent = nil
    }
    
    public convenience init?(version: Double = 1.0, encoding: String = "utf-8", standalone: String = "no", xmlData: NSData, inout error: NSError?) {
        self.init(version: version, encoding: encoding, standalone: standalone)
        if let parseError = readXMLData(xmlData) {
            error = parseError
            return nil
        }
    }
    
    // MARK: Read XML
    
    public func readXMLData(data: NSData) -> NSError? {
        children.removeAll(keepCapacity: false)
        let xmlParser = AEXMLParser(xmlDocument: self, xmlData: data)
        return xmlParser.tryParsing() ?? nil
    }
    
    // MARK: Override
    
    public override var xmlString: String {
        var xml =  "<?xml version=\"\(version)\" encoding=\"\(encoding)\" standalone=\"\(standalone)\"?>\n"
        for child in children {
            xml += child.xmlString
        }
        return xml
    }
    
}

// MARK: -

private class AEXMLParser: NSObject, NSXMLParserDelegate {
    
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
    
    // MARK: XML Parse
    
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
        currentValue += string
        currentElement?.value = currentValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        currentParent = currentParent?.parent
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        self.parseError = parseError
    }
    
}