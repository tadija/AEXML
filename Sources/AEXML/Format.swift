/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2026
 *  Licensed under the MIT license
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif


/// Format used when serializing `AEXMLElement` hierarchy to a `String`
///
/// Each nesting level is prefixed with `indent` and each child is followed by `newline`, so for
/// `AEXMLFormat(indent: "\t", newline: "\n")` the `<a><b /></a>` XML is written as `<a>\n\t<b />\n</a>`,
/// while `AEXMLFormat(indent: "", newline: "")` keeps it as `<a><b /></a>`.
public struct AEXMLFormat: Sendable {
    
    /// String written once per nesting level in front of an element.
    public let indent: String
    
    /// String written after an opening tag and after each child.
    public let newline: String
    
    /// Format used by `xml` property (`\t` indentation, `\n` line breaks).
    public static let tabs = AEXMLFormat(indent: "\t", newline: "\n")
    
    /// Format used by `xmlCompact` property (no indentation, no line breaks).
    public static let compact = AEXMLFormat(indent: "", newline: "")
    
    /// Format used by `xmlSpaces` property (4 spaces indentation, `\n` line breaks).
    public static let fourSpaces = AEXMLFormat(indent: "    ", newline: "\n")
    
    /// Format used by `xmlDoubleSpace` property (2 spaces indentation, `\n` line breaks).
    public static let doubleSpace = AEXMLFormat(indent: "  ", newline: "\n")
    
    /// Designated initializer - Creates and returns `AEXMLFormat` with given `indent` and `newline`.
    public init(indent: String, newline: String) {
        self.indent = indent
        self.newline = newline
    }
    
}
