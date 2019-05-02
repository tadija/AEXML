//
//  Codable.swift
//  AEXML iOS
//
//  Created by Danny Gilbert on 4/30/19.
//  Copyright © 2019 AE. All rights reserved.
//

import Foundation

public typealias SoapCodable = SoapDecodable & SoapEncodable

public protocol SoapEncodable {
    
    /// Create XML Element from Object.
    ///
    /// - Parameter element: rootElement
    /// - Returns: XML Element representation of Object
    func encode(into element: AEXMLElement?) -> AEXMLElement
}

public protocol SoapDecodable {
    
//    /// Initialize object from XML Data.
//    ///
//    /// - Parameter data: XML Data
//    /// - Throws: AEXMLError
//    init(from data: Data) throws
    
    /// Initialize object from XML Object.
    ///
    /// - Parameter element: XML Object
    /// - Throws: AEXMLError
    init(from element: AEXMLElement) throws
}

public extension CodingKey {
    
    func createElement(withValue value: String?) -> AEXMLElement {
        return AEXMLElement(name: stringValue, value: value)
    }
}
