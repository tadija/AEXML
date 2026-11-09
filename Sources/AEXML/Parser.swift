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
        let parser = XMLParser(data: data)
        parser.delegate = self

        parser.shouldProcessNamespaces = parserSettings.shouldProcessNamespaces
        parser.shouldReportNamespacePrefixes = parserSettings.shouldReportNamespacePrefixes
        parser.shouldResolveExternalEntities = parserSettings.shouldResolveExternalEntities
        
        let success = parser.parse()
        
        if !success {
            // keep text found before the error in the partial document
            flushCurrentValue()
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
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
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
