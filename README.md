# AEXML
**Simple and lightweight XML parser for iOS written in Swift**

> This is not robust full featured XML parser (at the moment), but rather really simple, 
smart and very easy to use utility for casual XML handling (it just works).

**AEXML** is a [minion](http://tadija.net/public/minion.png) which consists of these classes:  

Class | Description
------------ | -------------
`AEXMLElement` | Base class
`AEXMLDocument` | Inherited from `AEXMLElement`
`AEXMLParser` | Simple wrapper around `NSXMLParser`


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
Let's say this is some XML data you picked up somewhere and made data: NSData of it.

```xml
<?xml version="1.0" encoding="utf-8"?>
<animals>
    <cats>
        <cat breed="Siberian" color="lightgray">Tinna</cat>
        <cat breed="Domestic" color="darkgray">Rose</cat>
        <cat breed="Domestic" color="yellow">Caesar</cat>
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

```swift
// works only if data is successfully parsed
// otherwise prints information about error with parsing
var error: NSError?
if let xmlDoc = AEXMLDocument(xmlData: data, error: &error) {
    
    // prints the same XML structure as original
    println(xmlDoc.xmlString)
    
    // prints cats, dogs
    for child in xmlDoc.rootElement.children {
        println(child.name)
    }
    
    // prints Tinna (first element)
    println(xmlDoc.rootElement["cats"]["cat"].value)
    
    // prints Kika (last element)
    println(xmlDoc.rootElement["dogs"]["dog"].last.value)
    
    // prints Betty (3rd element)
    println(xmlDoc.rootElement["dogs"].children[2].value)
    
    // prints Tinna, Rose, Caesar
    for cat in xmlDoc.rootElement["cats"]["cat"].all {
        println(cat.value)
    }
    
    // prints Villy, Spot
    for dog in xmlDoc.rootElement["dogs"]["dog"].all {
        if let color = dog.attributes["color"] as? NSString {
            if color == "white" {
                println(dog.value)
            }
        }
    }

    // prints Caesar
    if let cats = xmlDoc.rootElement["cats"]["cat"].allWithAttributes(["breed" : "Domestic", "color" : "yellow"]) {
        for cat in cats {
            println(cat.value)
        }
    }

    // prints 3
    println(xmlDoc.rootElement["cats"]["cat"].count)

    // prints 2
    println(xmlDoc.rootElement["dogs"]["dog"].countWithAttributes(["breed" : "Bull Terrier"]))

    // prints 1
    println(xmlDoc.rootElement["cats"]["cat"].countWithAttributes(["breed" : "Domestic", "color" : "darkgray"]))
    
    // prints Siberian
    println(xmlDoc.rootElement["cats"]["cat"].attributes["breed"]!)
    
    // prints <cat breed="Siberian" color="lightgray">Tinna</cat>
    println(xmlDoc.rootElement["cats"]["cat"].xmlStringCompact)
    
    // prints element <badexample> not found
    println(xmlDoc["badexample"]["notexisting"].value)
    
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
let envelope = soapRequest.addChild("soap:Envelope", attributes: attributes)
let header = envelope.addChild("soap:Header")
let body = envelope.addChild("soap:Body")
header.addChild("m:Trans", value: "234", attributes: ["xmlns:m" : "http://www.w3schools.com/transaction/", "soap:mustUnderstand" : "1"])
let getStockPrice = body.addChild("m:GetStockPrice")
getStockPrice.addChild("m:StockName", value: "AAPL")
println(soapRequest.xmlString)
```


## API

### AEXMLElement
`class AEXMLElement`

Property | Description
------------ | -------------
`let name: String` | XML element name
`var value: String` | XML element value
`var attributes: [NSObject : AnyObject]` | `readonly` XML element attributes
`var parent: AEXMLElement?` | `readonly` parent XML element - every `AEXMLElement` has it's parent, instead of `AEXMLDocument` :(
`var children: [AEXMLElement] = [AEXMLElement]()` | `readonly` child XML elements

Initializer | Description
------------ | -------------
`init(_ name: String, value: String = String(), attributes: [NSObject : AnyObject] = [NSObject : AnyObject]())` | designated initializer has default values for **value** and **attributes**, but **name** is required

Read XML | Description
------------ | -------------
`subscript(key: String) -> AEXMLElement` | get the **first** element with some name like this: `xmlDoc["someName"]`
`var last: AEXMLElement` | last element with name as `self.name`
`var all: [AEXMLElement]` | all of the elements with name as `self.name`
`var count: Int` | count of elements with name as `self.name`
`func allWithAttributes <K: NSObject, V: AnyObject where K: Equatable, V: Equatable> (attributes: [K : V]) -> [AEXMLElement]?` | child elements which contain given `attributes`
`func countWithAttributes<K: NSObject, V: AnyObject where K: Equatable, V: Equatable>(attributes: [K : V]) -> Int` | count of child elements which contain given `attributes`

Write XML | Description
------------ | -------------
`func addChild(child: AEXMLElement) -> AEXMLElement` | add child to `self.children` (then return that child)
`func addChild(name: String, value: String = String(), attributes: [NSObject : AnyObject] = [NSObject : AnyObject]()) -> AEXMLElement` | add child to `self.children` (then return that child)
`func addAttribute(name: NSObject, value: AnyObject)` | add attribute to `self.attributes`
`var xmlString: String` | complete hierarchy of `self` and `children` in XML formatted String
`var xmlStringCompact: String` | same as `xmlString` but without `\n` and `\t` characters


### AEXMLDocument
`class AEXMLDocument: AEXMLElement`

Property | Description
------------ | -------------
`let version: Double` | used only for the first line in `xmlString`
`let encoding: String` | used only for the first line in `xmlString`
`let standalone: String` | used only for the first line in `xmlString`
`var rootElement: AEXMLElement` | the first child element of XML document

Initializer | Description
------------ | -------------
`init(version: Double = 1.0, encoding: String = "utf-8", standalone: String = "no")` | designated initializer has default values for **version**, **encoding** and **standalone** properties
`convenience init?(version: Double = 1.0, encoding: String = "utf-8", standalone: String = "no", xmlData: NSData, inout error: NSError?)` | convenience initializer also automatically calls **readXMLData** with given `NSData`

Parse XML | Description
------------ | -------------
`func readXMLData(data: NSData) -> NSError?` | create instance of `AEXMLParser` and start parsing given XML data, return `NSError` if parsing is not successfull, otherwise `nil`


## Requirements
- Xcode 6.1+
- iOS 7.0+
- AEXML doesn't require any additional libraries for it to work.


## Installation
Just drag AEXML.swift into your project and start using it.


## License
AEXML is released under the MIT license. See [LICENSE](LICENSE) for details.
