/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2026
 *  Licensed under the MIT license
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif


/// Options for parsing XML and writing declarations before the document's root element.
public protocol AEXMLOptionsProtocol: Sendable {
    var documentHeader: AEXMLOptions.DocumentHeader { get }
    var parserSettings: AEXMLOptions.ParserSettings { get }

    /// Appends the document prolog, including any separator before the root element.
    /// Use `format.newline` for separators so compact output stays compact.
    func appendDocumentProlog(to xml: inout String, format: AEXMLFormat)
}

public extension AEXMLOptionsProtocol {
    /// Default XML declaration for custom options that do not supply one.
    var documentHeader: AEXMLOptions.DocumentHeader { AEXMLOptions().documentHeader }

    /// Default parser settings for custom options that do not supply them.
    var parserSettings: AEXMLOptions.ParserSettings { AEXMLOptions().parserSettings }

    /// Writes the XML declaration followed by the format's newline.
    func appendDocumentProlog(to xml: inout String, format: AEXMLFormat) {
        xml += documentHeader.xmlString
        xml += format.newline
    }
}

/// Default options used in `AEXMLDocument`.
public struct AEXMLOptions: AEXMLOptionsProtocol {
    
    /// Values used in XML Document header
    public struct DocumentHeader: Sendable {
        /// Version value for XML Document header (defaults to 1.0).
        public var version = 1.0
        
        /// Encoding value for XML Document header (defaults to "utf-8").
        public var encoding = "utf-8"
        
        /// Standalone value for XML Document header (defaults to "no"); omitted when `nil`.
        public var standalone: String? = "no"
        
        /// XML Document header
        public var xmlString: String {
            var xml = "<?xml version=\"\(version)\" encoding=\"\(encoding)\""
            if let standalone {
                xml += " standalone=\"\(standalone)\""
            }
            return xml + "?>"
        }
    }
    
    /// Settings used by `Foundation.XMLParser`
    public struct ParserSettings: Sendable {
        /// Parser reports the namespaces and qualified names of elements. (defaults to `false`)
        public var shouldProcessNamespaces = false
        
        /// Parser reports the prefixes indicating the scope of namespace declarations. (defaults to `false`)
        public var shouldReportNamespacePrefixes = false
        
        /// Parser reports declarations of external entities. (defaults to `false`)
        public var shouldResolveExternalEntities = false
        
        /// Parser should trim whitespace from text nodes. (defaults to `true`)
        public var shouldTrimWhitespace = true
    }
    
    /// Values used in XML Document header (defaults to `DocumentHeader()`)
    public var documentHeader = DocumentHeader()
    
    /// Settings used by `Foundation.XMLParser` (defaults to `ParserSettings()`)
    public var parserSettings = ParserSettings()
    
    /// Designated initializer - Creates and returns default `AEXMLOptions`.
    public init() {}
    
}
