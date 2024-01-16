/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2024
 *  Licensed under the MIT license
 */

// MARK: AEXMLDocumentBuilder

@resultBuilder
public enum AEXMLDocumentBuilder {

    public static func buildBlock(_ component: AEXMLElement) -> AEXMLDocument {
        AEXMLDocument(root: component)
    }

    public static func buildOptional(_ component: AEXMLElement?) -> AEXMLDocument {
        AEXMLDocument(root: component)
    }

    public static func buildEither(first component: AEXMLElement) -> AEXMLDocument {
        AEXMLDocument(root: component)
    }

    public static func buildEither(second component: AEXMLElement) -> AEXMLDocument {
        AEXMLDocument(root: component)
    }

}

// MARK: AEXMLDocument+AEXMLDocumentBuilder

public extension AEXMLDocument {

    /**
     Convenience initializer - Creates and returns new XML Document object.

     - parameter options: Options for XML Document header and parser settings (defaults to `AEXMLOptions()`).
     - parameter rootBuilder: Builder for root XML element for XML Document.

     - returns: Initialized XML Document object.
     */
    convenience init(options: AEXMLOptions = AEXMLOptions(),
                     @AEXMLDocumentBuilder rootBuilder: () -> AEXMLElement) {
        self.init(root: rootBuilder(),
                  options: options)
    }

}

// MARK: - AEXMLElementBuilder

@resultBuilder
public enum AEXMLElementBuilder {

    public static func buildBlock(_ components: AEXMLElement...) -> [AEXMLElement] {
        components
    }

    // MARK: If & switch support

    public static func buildOptional(_ component: [AEXMLElement]?) -> [AEXMLElement] {
        component ?? []
    }

    public static func buildEither(first component: [AEXMLElement]) -> [AEXMLElement] {
        component
    }

    public static func buildEither(second component: [AEXMLElement]) -> [AEXMLElement] {
        component
    }

    // MARK: For...in support

    public static func buildArray(_ components: [[AEXMLElement]]) -> [AEXMLElement] {
        components.flatMap { $0 }
    }

    // MARK: Limited availabiliy

    public static func buildLimitedAvailability(_ component: [AEXMLElement]) -> [AEXMLElement] {
        component
    }

    // MARK: Partial results

    public static func buildExpression(_ expression: AEXMLElement) -> [AEXMLElement] {
        [expression]
    }

    public static func buildExpression(_ expression: [AEXMLElement]) -> [AEXMLElement] {
        expression
    }

    public static func buildExpression(_ expression: [[AEXMLElement]]) -> [AEXMLElement] {
        expression.flatMap { $0 }
    }

    public static func buildPartialBlock(first: [AEXMLElement]) -> [AEXMLElement] {
        first
    }

    public static func buildPartialBlock(accumulated: [AEXMLElement], next: [AEXMLElement]) -> [AEXMLElement] {
        accumulated + next
    }

}

// MARK: AEXMLElement+AEXMLElementBuilder

public extension AEXMLElement {

    /**
     Convenience initializer - Creates a new XML element.

     - parameter name: XML element name.
     - parameter attributes: XML element attributes (defaults to empty dictionary).
     - parameter childrenBuilder: Builder for the child XML elements.

     - returns: An initialized `AEXMLElement` object.
     */
    convenience init(_ name: String,
                     attributes: [String: String] = [:],
                     @AEXMLElementBuilder childrenBuilder: () -> [AEXMLElement]) {
        self.init(name: name,
                  attributes: attributes)

        addChildren(childrenBuilder())
    }

}
