/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2026
 *  Licensed under the MIT license
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/**
    This is formatting used when serializing an element hierarchy to a String.

    Each nesting level is prefixed with `indent` and each child is followed by `newline`, so for
    `AEXMLFormat(indent: "\t", newline: "\n")` the `<a><b /></a>` XML is written as `<a>\n\t<b />\n</a>`,
    while `AEXMLFormat(indent: "", newline: "")` keeps it as `<a><b /></a>`.
*/
public struct AEXMLFormat {
    
    /// String written once per nesting level in front of an element.
    public let indent: String
    
    /// String written after an opening tag and after each child.
    public let newline: String
    
    /**
        Designated initializer - Creates and returns new serialization format.
     
        - parameter indent: String written once per nesting level in front of an element.
        - parameter newline: String written after an opening tag and after each child.
     
        - returns: An initialized `AEXMLFormat` object.
    */
    public init(indent: String, newline: String) {
        self.indent = indent
        self.newline = newline
    }
    
    /// Format used by `xml` property (`\t` indentation, `\n` line breaks).
    public static let tabs = AEXMLFormat(indent: "\t", newline: "\n")
    
    /// Format used by `xmlCompact` property (no indentation, no line breaks).
    public static let compact = AEXMLFormat(indent: "", newline: "")
    
    /// Format used by `xmlSpaces` property (4 spaces indentation, `\n` line breaks).
    public static let fourSpaces = AEXMLFormat(indent: "    ", newline: "\n")
    
    /// Format used by `xmlDoubleSpace` property (2 spaces indentation, `\n` line breaks).
    public static let doubleSpace = AEXMLFormat(indent: "  ", newline: "\n")

}

/**
    This is base class for holding XML structure.

    You can access its structure by using subscript like this: `element["foo"]["bar"]` which would
    return `<bar></bar>` element from `<element><foo><bar></bar></foo></element>` XML as an `AEXMLElement` object.
*/
open class AEXMLElement {
    
    // MARK: - Properties
    
    /// Every `AEXMLElement` should have its parent element instead of `AEXMLDocument` which parent is `nil`.
    open internal(set) weak var parent: AEXMLElement?
    
    /// Child XML elements.
    open internal(set) var children = [AEXMLElement]()
    
    /// XML Element name.
    open var name: String
    
    /// XML Element value.
    open var value: String?
    
    /// XML Element attributes.
    open var attributes: [String : String]
    
    /// Error value (`nil` if there is no error).
    open var error: AEXMLError?
    
    /// String representation of `value` property (if `value` is `nil` this is empty String).
    open var string: String { return value ?? String() }
    
    /// Boolean representation of `value` property (`nil` if `value` can't be represented as Bool).
    open var bool: Bool? {
        switch string.lowercased() {
        case "true", "1":
            return true
        case "false", "0":
            return false
        default:
            return nil
        }
    }

    /// Integer representation of `value` property (`nil` if `value` can't be represented as Integer).
    open var int: Int? { return Int(string) }
    
    /// Double representation of `value` property (`nil` if `value` can't be represented as Double).
    open var double: Double? { return Double(string) }
    
    // MARK: - Init
    
    /**
        Designated initializer - all parameters are optional.
    
        - parameter name: XML element name.
        - parameter value: XML element value (defaults to `nil`).
        - parameter attributes: XML element attributes (defaults to empty dictionary).
    
        - returns: An initialized `AEXMLElement` object.
    */
    public init(name: String, value: String? = nil, attributes: [String : String] = [:]) {
        self.name = name
        self.value = value
        self.attributes = attributes
    }
    
    // MARK: - XML Read
    
    /// The first element with given name **(Empty element with error if not exists)**.
    open subscript(key: String) -> AEXMLElement {
        guard let
            first = children.first(where: { $0.name == key })
        else {
            let errorElement = AEXMLElement(name: key)
            errorElement.error = AEXMLError.elementNotFound
            return errorElement
        }
        return first
    }
    
    /// Returns all of the elements with equal name as `self` **(nil if not exists)**.
    open var all: [AEXMLElement]? { return parent?.children.filter { $0.name == self.name } }
    
    /// Returns the first element with equal name as `self` **(nil if not exists)**.
    open var first: AEXMLElement? { return all?.first }
    
    /// Returns the last element with equal name as `self` **(nil if not exists)**.
    open var last: AEXMLElement? { return all?.last }
    
    /// Returns number of all elements with equal name as `self`.
    open var count: Int { return all?.count ?? 0 }
    
    /**
        Returns all elements with given value.
        
        - parameter value: XML element value.
        
        - returns: Optional Array of found XML elements.
    */
    open func all(withValue value: String) -> [AEXMLElement]? {
        let found = all?.compactMap {
            $0.value == value ? $0 : nil
        }
        return found
    }
    
    /**
        Returns all elements containing given attributes.

        - parameter attributes: Array of attribute names.

        - returns: Optional Array of found XML elements.
    */
    open func all(containingAttributeKeys keys: [String]) -> [AEXMLElement]? {
        return all?.filter { element in
            keys.allSatisfy { element.attributes[$0] != nil }
        }
    }
    
    /**
        Returns all elements with given attributes.
    
        - parameter attributes: Dictionary of Keys and Values of attributes.
    
        - returns: Optional Array of found XML elements.
    */
    open func all(withAttributes attributes: [String : String]) -> [AEXMLElement]? {
        return all?.filter { element in
            attributes.allSatisfy { element.attributes[$0.key] == $0.value }
        }
    }
    
    /**
        Returns all descendant elements which satisfy the given predicate.
     
        Searching is done vertically; children are tested before siblings. Elements appear in the list
        in the order in which they are found.
     
        - parameter predicate: Function which returns `true` for a desired element and `false` otherwise.
     
        - returns: Array of found XML elements.
    */
    open func allDescendants(where predicate: (AEXMLElement) -> Bool) -> [AEXMLElement] {
        var result: [AEXMLElement] = []
        
        for child in children {
            if predicate(child) {
                result.append(child)
            }
            result.append(contentsOf: child.allDescendants(where: predicate))
        }
        
        return result
    }
    
    /**
        Returns the first descendant element which satisfies the given predicate, or nil if no such element is found.
     
        Searching is done vertically; children are tested before siblings.
     
        - parameter predicate: Function which returns `true` for the desired element and `false` otherwise.
     
        - returns: Optional AEXMLElement.
    */
    open func firstDescendant(where predicate: (AEXMLElement) -> Bool) -> AEXMLElement? {
        for child in children {
            if predicate(child) {
                return child
            } else if let descendant = child.firstDescendant(where: predicate) {
                return descendant
            }
        }
        return nil
    }
    
    /**
        Indicates whether the element has a descendant satisfying the given predicate.
     
        - parameter predicate: Function which returns `true` for the desired element and `false` otherwise.
     
        - returns: Bool.
    */
    open func hasDescendant(where predicate: (AEXMLElement) -> Bool) -> Bool {
        return firstDescendant(where: predicate) != nil
    }
    
    // MARK: - XML Write
    
    /**
        Adds child XML element to `self`.
    
        - parameter child: Child XML element to add.
    
        - returns: Child XML element with `self` as `parent`.
    */
    @discardableResult
    open func addChild(_ child: AEXMLElement) -> AEXMLElement {
        child.parent = self
        children.append(child)
        return child
    }
    
    /**
        Adds child XML element to `self`.
        
        - parameter name: Child XML element name.
        - parameter value: Child XML element value (defaults to `nil`).
        - parameter attributes: Child XML element attributes (defaults to empty dictionary).
        
        - returns: Child XML element with `self` as `parent`.
    */
    @discardableResult
    open func addChild(name: String,
                       value: String? = nil,
                       attributes: [String : String] = [:]) -> AEXMLElement {
        let child = AEXMLElement(name: name, value: value, attributes: attributes)
        return addChild(child)
    }
    
    /**
        Adds an array of XML elements to `self`.
    
        - parameter children: Child XML element array to add.
    
        - returns: Child XML elements with `self` as `parent`.
    */
    @discardableResult
    open func addChildren(_ children: [AEXMLElement]) -> [AEXMLElement] {
        children.forEach{ addChild($0) }
        return children
    }
    
    /// Removes `self` from `parent` XML element.
    open func removeFromParent() {
        if let index = parent?.children.firstIndex(where: { $0 === self }) {
            parent?.children.remove(at: index)
        }
    }
    
    /// Complete hierarchy of `self` and `children` in **XML** escaped and formatted String
    open var xml: String {
        return xmlString(format: .tabs)
    }
    
    /// Same as `xml` but without `\n` and `\t` characters (`xmlString(format: .compact)`)
    open var xmlCompact: String {
        return xmlString(format: .compact)
    }
    
    /// Same as `xml` but with 4 spaces instead of '\t' character (`xmlString(format: .fourSpaces)`)
    open var xmlSpaces: String {
        return xmlString(format: .fourSpaces)
    }
    
    /// Same as `xml` but with 2 spaces instead of '\t' character (`xmlString(format: .doubleSpace)`)
    open var xmlDoubleSpace: String {
        return xmlString(format: .doubleSpace)
    }
    
    /**
        Complete hierarchy of `self` and `children` in **XML** escaped String with the given formatting.
     
        To customize serialization, override `appendXML(to:depth:format:)` instead. Overriding `xml`
        or one of its variants affects only direct calls on that element, not its output inside a parent.
     
        - parameter format: Indentation and line breaks to use.
     
        - returns: XML String.
    */
    public func xmlString(format: AEXMLFormat) -> String {
        // depth of self relative to the document (root element is at depth 0)
        var depth = -1
        var element = self
        while let parent = element.parent {
            depth += 1
            element = parent
        }
        
        var xml = String()
        appendXML(to: &xml, depth: depth, format: format)
        return xml
    }
    
    /**
        Writes `self` and its `children` into the given buffer in a single pass.
     
        This is the single customization point for serialization: `xml`, `xmlCompact`, `xmlSpaces`,
        `xmlDoubleSpace` and `xmlString(format:)` all end up here, and parents serialize their children
        through it, so overriding it in a subclass takes effect wherever the element appears in a tree.
        Call `super` to write the standard representation.
     
        - parameter xml: Buffer to append to.
        - parameter depth: Nesting level used for indentation (0 for the root element, -1 for the document
          that contains it, so its root is written at depth 0).
        - parameter format: Indentation and line breaks to use.
    */
    open func appendXML(to xml: inout String, depth: Int, format: AEXMLFormat) {
        // open element
        appendIndent(to: &xml, depth: depth, format: format)
        xml += "<\(name)"
        
        if !attributes.isEmpty {
            // insert attributes
            for (key, value) in attributes.sorted(by: { $0.key < $1.key }) {
                xml += " \(key)=\"\(value.xmlEscaped)\""
            }
        }
        
        if value == nil && children.isEmpty {
            // close element
            xml += " />"
        } else {
            if !children.isEmpty {
                // add children
                xml += ">\(format.newline)"
                for child in children {
                    child.appendXML(to: &xml, depth: depth + 1, format: format)
                    xml += format.newline
                }
                // add indentation and close element
                appendIndent(to: &xml, depth: depth, format: format)
                xml += "</\(name)>"
            } else {
                // insert string value and close element
                xml += ">\(string.xmlEscaped)</\(name)>"
            }
        }
    }

    // MARK: - Helpers

    private func appendIndent(to xml: inout String, depth: Int, format: AEXMLFormat) {
        guard depth > 0, !format.indent.isEmpty else { return }
        xml += String(repeating: format.indent, count: depth)
    }

}

public extension String {
    
    /// String representation of self with XML special characters escaped.
    var xmlEscaped: String {
        let scalars = unicodeScalars
        
        // fast path: most values and attributes have nothing to escape
        guard let firstIndex = scalars.firstIndex(where: { $0.xmlEscaped != nil }) else {
            return self
        }
        
        // single pass: copy the clean prefix, then escape the rest scalar by scalar
        var escaped = String(scalars[..<firstIndex])
        escaped.reserveCapacity(utf8.count + 16)
        for scalar in scalars[firstIndex...] {
            if let replacement = scalar.xmlEscaped {
                escaped += replacement
            } else {
                escaped.unicodeScalars.append(scalar)
            }
        }
        
        return escaped
    }
    
}

private extension Unicode.Scalar {
    
    /// XML entity for special characters and the whitespace that XML parsers would normalize
    /// (`nil` if the scalar doesn't need escaping).
    var xmlEscaped: String? {
        switch self {
        case "&": return "&amp;"
        case "<": return "&lt;"
        case ">": return "&gt;"
        case "'": return "&apos;"
        case "\"": return "&quot;"
        case "\n": return "&#10;"
        case "\r": return "&#13;"
        case "\t": return "&#9;"
        default: return nil
        }
    }
    
}
