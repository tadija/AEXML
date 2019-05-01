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
    
    func encode(into element: AEXMLElement?) -> AEXMLElement
}

public protocol SoapDecodable {
    
    init(from data: Data) throws
}

public protocol CodingTag: CodingKey {
    
    func createElement(withValue value: String?) -> AEXMLElement
    func findElement(in xmlDoc: AEXMLDocument) throws -> AEXMLElement
    func value(in xmlDoc: AEXMLDocument) throws -> String
}

// MARK: - Default Implementation
public extension CodingTag {
    
    func createElement(withValue value: String?) -> AEXMLElement {
        return AEXMLElement(name: stringValue, value: value)
    }
    
    func findElement(in xmlDoc: AEXMLDocument) throws -> AEXMLElement {
        let element = try xmlDoc.getElement(for: self)
        return element
    }
    
    func value(in xmlDoc: AEXMLDocument) throws -> String {
        let value = try xmlDoc.getValue(for: self)
        return value
    }
}
