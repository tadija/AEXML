//
// AEXML.swift
//
// Copyright (c) 2014 Marko Tadić <tadija@me.com> http://tadija.net
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

/**
    This class is inherited from `AEXMLElement` and has a few addons to represent **XML Document**.

    XML Parsing is also done with this object.
*/
open class AEXMLDocument: AEXMLElement {
    
    fileprivate struct Defaults {
        static let version = 1.0
        static let encoding = "utf-8"
        static let standalone = "no"
        static let documentName = "AEXMLDocument"
    }
    
    /// Default options used by XMLParser
    public struct Options {
        public var shouldProcessNamespaces = false
        public var shouldReportNamespacePrefixes = false
        public var shouldResolveExternalEntities = false
        
        public init() {}
    }
    
    // MARK: Properties
    
    /// This is only used for XML Document header (default value is 1.0).
    open let version: Double
    
    /// This is only used for XML Document header (default value is "utf-8").
    open let encoding: String
    
    /// This is only used for XML Document header (default value is "no").
    open let standalone: String
    
    /// Options for XMLParser (default values are all `false`)
    open let options: Options
    
    /// Root (the first child element) element of XML Document **(Empty element with error if not exists)**.
    open var root: AEXMLElement {
        guard let rootElement = children.first else {
            let errorElement = AEXMLElement(name: Defaults.documentName)
            errorElement.error = AEXMLError.rootElementMissing
            return errorElement
        }
        return rootElement
    }
    
    // MARK: Lifecycle
    
    /**
        Designated initializer - Creates and returns XML Document object.
    
        - parameter version: Version value for XML Document header (defaults to 1.0).
        - parameter encoding: Encoding value for XML Document header (defaults to "utf-8").
        - parameter standalone: Standalone value for XML Document header (defaults to "no").
        - parameter root: Root XML element for XML Document (defaults to `nil`).
        - parameter options: Options for XMLParser (defaults to `false` for all).
    
        - returns: An initialized XML Document object.
    */
    public init(version: Double = Defaults.version,
                encoding: String = Defaults.encoding,
                standalone: String = Defaults.standalone,
                root: AEXMLElement? = nil,
                options: Options = Options())
    {
        // set document properties
        self.version = version
        self.encoding = encoding
        self.standalone = standalone
        self.options = options
        
        // init super with default name
        super.init(name: Defaults.documentName)
        
        // document has no parent element
        parent = nil
        
        // add root element to document (if any)
        if let rootElement = root {
            _ = addChild(rootElement)
        }
    }
    
    /**
        Convenience initializer - used for parsing XML data (by calling `loadXMLData:` internally).
    
        - parameter version: Version value for XML Document header (defaults to 1.0).
        - parameter encoding: Encoding value for XML Document header (defaults to "utf-8").
        - parameter standalone: Standalone value for XML Document header (defaults to "no").
        - parameter xmlData: XML data to parse.
        - parameter xmlParserOptions: Options for XMLParser (defaults to `false` for all).
    
        - returns: An initialized XML Document object containing parsed data. Throws error if data could not be parsed.
    */
    public convenience init(version: Double = Defaults.version,
                            encoding: String = Defaults.encoding,
                            standalone: String = Defaults.standalone,
                            xmlData: Data,
                            options: Options = Options()) throws
    {
        self.init(version: version, encoding: encoding, standalone: standalone, options: options)
        try loadXMLData(xmlData)
    }
    
    // MARK: Read XML
    
    /**
        Creates instance of `AEXMLParser` (private class which is simple wrapper around `XMLParser`)
        and starts parsing the given XML data. Throws error if data could not be parsed.
    
        - parameter data: XML which should be parsed.
    */
    open func loadXMLData(_ data: Data) throws {
        children.removeAll(keepingCapacity: false)
        let xmlParser = AEXMLParser(xmlDocument: self, xmlData: data)
        try xmlParser.parse()
    }
    
    // MARK: Override
    
    /// Override of `xmlString` property of `AEXMLElement` - it just inserts XML Document header at the beginning.
    open override var xmlString: String {
        var xml =  "<?xml version=\"\(version)\" encoding=\"\(encoding)\" standalone=\"\(standalone)\"?>\n"
        for child in children {
            xml += child.xmlString
        }
        return xml
    }
    
}
