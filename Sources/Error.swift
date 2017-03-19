import Foundation

/// A type representing error value that can be thrown or inside `error` property of `AEXMLElement`.
@objc public enum AEXMLError: Int, Error {
    /// This will be inside `error` property of `AEXMLElement` when subscript is used for not-existing element.
    case elementNotFound = 1
    
    /// This will be inside `error` property of `AEXMLDocument` when there is no root element.
    case rootElementMissing
    
    /// `AEXMLDocument` can throw this error on `init` or `loadXMLData` if parsing with `XMLParser` was not successful.
    case parsingFailed
}
