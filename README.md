# AEXML
**Simple and lightweight XML parser for iOS written in Swift**

> This is not robust full featured XML parser (at the moment), but rather simple,  
and very easy to use utility for casual XML handling (it just works).

**AEXML** is a [minion](http://tadija.net/public/minion.png) which consists of these classes:  

Class | Description
------------ | -------------
`AEXMLElement` | Base class
`AEXMLDocument` | Inherited from `AEXMLElement` with a few addons
`AEXMLParser` | Simple (private) wrapper around `NSXMLParser`


## Features
- **Read XML** data
- **Write XML** string
- I believe that's all


## Index
- [Example](#example)
  - [Read XML](#read-xml)
  - [Write XML](#write-xml)
- [API](#api)
  - [AEXMLElement](#aexmlelement)
  - [AEXMLDocument](#aexmldocument)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)


## Example

### Read XML
Let's say this is some XML string you picked up somewhere and made a variable `data: NSData` from that.

```xml
<?xml version="1.0" encoding="utf-8"?>
<animals>
    <cats>
        <cat breed="Siberian" color="lightgray">Tinna</cat>
        <cat breed="Domestic" color="darkgray">Rose</cat>
        <cat breed="Domestic" color="yellow">Caesar</cat>
        <cat></cat>
    </cats>
    <dogs>
        <dog breed="Bull Terrier" color="white">Villy</dog>
        <dog breed="Bull Terrier" color="white">Spot</dog>
        <dog breed="Golden Retriever" color="yellow">Betty</dog>
        <dog breed="Miniature Schnauzer" color="black">Kika</dog>
    </dogs>
</animals>
```

This is how you can use AEXML for working with this data:  
(for even more examples, look at the unit tests code included in project)

```swift
// works only if data is successfully parsed
// otherwise prints information about error with parsing
var error: NSError?
if let xmlDoc = AEXMLDocument(xmlData: data, error: &error) {
    
    // prints the same XML structure as original
    println(xmlDoc.xmlString)
    
    // prints cats, dogs
    for child in xmlDoc.root.children {
        println(child.name)
    }
    
    // prints Optional("Tinna") (first element)
    println(xmlDoc.root["cats"]["cat"].value)

    // prints Tinna (first element)
    println(xmlDoc.root["cats"]["cat"].stringValue)

    // prints Optional("Kika") (last element)
    println(xmlDoc.root["dogs"]["dog"].last?.value)

    // prints Betty (3rd element)
    println(xmlDoc.root["dogs"].children[2].stringValue)

    // prints Tinna, Rose, Caesar
    if let cats = xmlDoc.root["cats"]["cat"].all {
        for cat in cats {
            if let name = cat.value {
                println(name)
            }
        }
    }
    
    // prints Villy, Spot
    for dog in xmlDoc.root["dogs"]["dog"].all! {
        if let color = dog.attributes["color"] as? String {
            if color == "white" {
                println(dog.stringValue)
            }
        }
    }
    
    // prints Caesar
    if let cats = xmlDoc.root["cats"]["cat"].allWithAttributes(["breed" : "Domestic", "color" : "yellow"]) {
        for cat in cats {
            println(cat.stringValue)
        }
    }
    
    // prints 4
    println(xmlDoc.root["cats"]["cat"].count)
    
    // prints 2
    println(xmlDoc.root["dogs"]["dog"].countWithAttributes(["breed" : "Bull Terrier"]))
    
    // prints 1
    println(xmlDoc.root["cats"]["cat"].countWithAttributes(["breed" : "Domestic", "color" : "darkgray"]))
    
    // prints Siberian
    println(xmlDoc.root["cats"]["cat"].attributes["breed"]!)
    
    // prints <cat breed="Siberian" color="lightgray">Tinna</cat>
    println(xmlDoc.root["cats"]["cat"].xmlStringCompact)
    
    // prints element <badexample> not found
    println(xmlDoc["badexample"]["notexisting"].stringValue)
    
} else {
    println("description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)")
}
```

### Write XML
Let's say this is some SOAP XML request you need to generate.  
Well, you could just build ordinary string for that?

```xml
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soap:Header>
    <m:Trans xmlns:m="http://www.w3schools.com/transaction/" soap:mustUnderstand="1">234</m:Trans>
  </soap:Header>
  <soap:Body>
    <m:GetStockPrice>
      <m:StockName>AAPL</m:StockName>
    </m:GetStockPrice>
  </soap:Body>
</soap:Envelope>
```

Yes, but, you can also do it in a more structured and elegant way with AEXML:

```swift
// prints the same XML structure as original
let soapRequest = AEXMLDocument()
let attributes = ["xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" : "http://www.w3.org/2001/XMLSchema"]
let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: attributes)
let header = envelope.addChild(name: "soap:Header")
let body = envelope.addChild(name: "soap:Body")
header.addChild(name: "m:Trans", value: "234", attributes: ["xmlns:m" : "http://www.w3schools.com/transaction/", "soap:mustUnderstand" : "1"])
let getStockPrice = body.addChild(name: "m:GetStockPrice")
getStockPrice.addChild(name: "m:StockName", value: "AAPL")
println(soapRequest.xmlString)
```


## API

### AEXMLElement
`class AEXMLElement`

Property | Description
------------ | -------------
`var parent: AEXMLElement?` | `readonly` parent XML element - every `AEXMLElement` has it's parent, instead of `AEXMLDocument` :(
`var children: [AEXMLElement] = [AEXMLElement]()` | `readonly` child XML elements
`let name: String` | XML element name
`var attributes: [NSObject : AnyObject]` | `readonly` XML element attributes
`var value: String?` | XML element value (stored value property, others are computed)
`var stringValue: String` | if `value` is nil, this is empty string, otherwise `value`
`var boolValue: Bool` | `stringValue` converted to `Bool` (if stringValue is "true" (case insensitive) or "1" then it's true, otherwise false)
`var intValue: Int` | `stringValue` converted to `Int` (if stringValue can't be converted it's 0)
`var doubleValue: Double` | `stringValue` converted to `Double` (if stringValue can't be converted it's 0.0)
`public class var errorElementName: String` | this element name is used when unable to find element

Initializer | Description
------------ | -------------
`init(_ name: String, value: String? = nil, attributes: [NSObject : AnyObject] = [NSObject : AnyObject]())` | designated initializer has default values for **value** and **attributes**, but **name** is required

Read XML | Description
------------ | -------------
`subscript(key: String) -> AEXMLElement` | get the **first** element with given name (`xmlDoc["someName"]`), it's non-optional so it returns dummy element if element with given name is not found
`var all: [AEXMLElement]?` | all of the elements with name as `self.name`
`var first: AEXMLElement?` | the first element with name as `self.name` (same as subscript but optional)
`var last: AEXMLElement?` | last element with name as `self.name`
`var count: Int` | count of elements with name as `self.name`
`func allWithAttributes <K: NSObject, V: AnyObject where K: Equatable, V: Equatable> (attributes: [K : V]) -> [AEXMLElement]?` | child elements which contain given `attributes`
`func countWithAttributes<K: NSObject, V: AnyObject where K: Equatable, V: Equatable>(attributes: [K : V]) -> Int` | count of child elements which contain given `attributes`

Write XML | Description
------------ | -------------
`func addChild(child: AEXMLElement) -> AEXMLElement` | add child to `self.children` (then return that child)
`func addChild(#name: String, value: String? = nil, attributes: [NSObject : AnyObject] = [NSObject : AnyObject]()) -> AEXMLElement` | add child to `self.children` (then return that child)
`func addAttribute(name: NSObject, value: AnyObject)` | add attribute to `self.attributes`
`func addAttributes(attributes: [NSObject : AnyObject])` | add attributes to `self.attributes`
`var xmlString: String` | complete hierarchy of `self` and `children` in XML formatted String
`var xmlStringCompact: String` | same as `xmlString` but without `\n` and `\t` characters


### AEXMLDocument
`class AEXMLDocument: AEXMLElement`

Property | Description
------------ | -------------
`let version: Double` | used only for the first line in `xmlString`
`let encoding: String` | used only for the first line in `xmlString`
`let standalone: String` | used only for the first line in `xmlString`
`var root: AEXMLElement` | the first child element of XML document

Initializer | Description
------------ | -------------
`init(version: Double = 1.0, encoding: String = "utf-8", standalone: String = "no", root: AEXMLElement? = nil)` | designated initializer with default values for all of the properties
`convenience init?(version: Double = 1.0, encoding: String = "utf-8", standalone: String = "no", xmlData: NSData, inout error: NSError?)` | convenience initializer also automatically calls **readXMLData** with given `NSData`

Parse XML | Description
------------ | -------------
`func readXMLData(data: NSData) -> NSError?` | create instance of `AEXMLParser` and start parsing given XML data, return `NSError` if parsing is not successfull, otherwise `nil`


## Requirements
- Xcode 6.1.1
- iOS 7.0+
- AEXML doesn't require any additional libraries for it to work.


## Installation

- Using [CocoaPods](http://cocoapods.org/):

  ```ruby
  use_frameworks!
  pod 'AEXML'
  ```

- Manually:

  Just drag AEXML.swift into your project and start using it.

## License
AEXML is released under the MIT license. See [LICENSE](LICENSE) for details.
