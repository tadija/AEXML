/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2026
 *  Licensed under the MIT license
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Simple wrapper around `Foundation.XMLParser`.
internal class AEXMLParser: NSObject, XMLParserDelegate {
    
    // MARK: - Properties
    
    let document: AEXMLDocument
    let data: Data
    
    var currentParent: AEXMLElement?
    var currentElement: AEXMLElement?
    var currentValue = String()
    
    var parseError: Error?

    private lazy var parserSettings: AEXMLOptions.ParserSettings = {
        return document.options.parserSettings
    }()
    
    // MARK: - Lifecycle
    
    init(document: AEXMLDocument, data: Data) {
        self.document = document
        self.data = data
        currentParent = document
        
        super.init()
    }
    
    // MARK: - API
    
    func parse() throws {
        // FoundationXML on Linux can report success for empty input.
        guard !data.isEmpty else { throw AEXMLError.parsingFailed }

        let parser = XMLParser(data: data)
        parser.delegate = self

        parser.shouldProcessNamespaces = parserSettings.shouldProcessNamespaces
        parser.shouldReportNamespacePrefixes = parserSettings.shouldReportNamespacePrefixes
        parser.shouldResolveExternalEntities = parserSettings.shouldResolveExternalEntities
        
        let success = parser.parse()
        
        // keep text of an element left open by truncated input in the document
        // (FoundationXML on Linux reports success for such input)
        flushCurrentValue()
        
        if !success {
            guard let error = parseError else { throw AEXMLError.parsingFailed }
            throw error
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String]) {
        // text found before a child element belongs to the parent
        flushCurrentValue()
        
        currentElement = currentParent?.addChild(name: elementName, attributes: attributeDict)
        currentParent = currentElement
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // only accumulate value here
        currentValue.append(string)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        // XMLParser supplies CDATA as UTF-8, regardless of the source encoding.
        // Preserve an explicitly empty section as an empty value rather than nil.
        if currentElement?.value == nil {
            currentElement?.value = ""
        }
        currentValue.append(String(decoding: CDATABlock, as: UTF8.self))
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        // assign text accumulated for the element that just ended
        // (text found after a child element has no element to go to and is dropped)
        flushCurrentValue()
        
        if parserSettings.shouldTrimWhitespace {
            currentElement?.value = currentElement?.value?
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        currentParent = currentParent?.parent
        currentElement = nil
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
    
    // MARK: - Helpers
    
    private func flushCurrentValue() {
        if !currentValue.isEmpty {
            currentElement?.value = currentValue
        }
        currentValue = String()
    }
    
}
