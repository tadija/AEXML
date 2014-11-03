# AEXML
**Simple and lightweight XML parser for iOS written in Swift**

**AEXML** is a [minion](http://tadija.net/public/minion.png) which consists of three classes:  

Class | Description
------------ | -------------
AEXMLElement | Base class
AEXMLDocument | Inherited from AEXMLElement
AEXMLParser | Simple wrapper around NSXMLParser

> This is not robust full featured XML parser (at the moment), but rather really simple, 
smart and very easy to use utility for casual XML handling (it just works).


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


# API

## AEXMLElement
`class AEXMLElement`

#### Properties
- `let name: String`
- `var value: String`
- `var attributes: [NSObject : AnyObject]`
- `var parent: AEXMLElement?`
- `var children: [AEXMLElement] = [AEXMLElement]()`

> **name**, **value**, **attributes** by example:  
`<name attributeName="attributeValue">value</name>`  
**parent** - every `AEXMLElement` has it's parent, instead of `AEXMLDocument` :(   
**children** - array of all child elements

#### Initializers
- `init(_ name: String, value: String = String(), attributes: [NSObject : AnyObject] = [NSObject : AnyObject]())`

> **designated** initializer has default values for **value** and **attributes**, but **name** is required

#### Read from XML
- `subscript(key: String) -> AEXMLElement`
- `var last: AEXMLElement`
- `var all: [AEXMLElement]`

> get the **first** element with some name like this: `xmlDoc["someName"]`  
**last** - returns the last element with name as `self.name`  
**all** - returns all of the elements with name as `self.name`  

#### Write to XML
- `func addChild(child: AEXMLElement) -> AEXMLElement`
- `func addChild(name: String, value: String = String(), attributes: [NSObject : AnyObject] = [NSObject : AnyObject]()) -> AEXMLElement`
- `func addAttribute(name: NSObject, value: AnyObject)`
- `var xmlString: String`
- `var xmlStringCompact: String`

> **addChild** - add child to `self.children` (then return that child)  
**addAttribute** - add attribute to `self.attributes`  
**xmlString** - complete hierarchy of `self` and `children` in XML formatted String  
**xmlStringCompact** - same as `xmlString` but without `\n` and `\t` characters


## AEXMLDocument
`class AEXMLDocument: AEXMLElement`

#### Properties
- `let version: Double`
- `let encoding: String`
- `var rootElement: AEXMLElement`

> **version** and **encoding** - used only for the first line in `xmlString` property:  
`<?xml version="1.0" encoding="utf-8"?>`  
**rootElement** - returns the first child element of XML document

#### Initializers
- `init(version: Double = 1.0, encoding: String = "utf-8")`
- `convenience init?(version: Double = 1.0, encoding: String = "utf-8", xmlData: NSData, inout error: NSError?)`

> **designated** initializer has default values for **version** and **encoding** properties  
**convenience** initializer also automatically calls **readXMLData** with given `NSData`

#### Parse XML
- `func readXMLData(data: NSData) -> NSError?`

> **readXMLData** - create instance of `AEXMLParser` and start parsing given XML data, return `NSError` if parsing is not successfull, otherwise `nil`


## Requirements
- Xcode 6+
- iOS 7.0+ / Mac OS X 10.9+
- AEXML doesn't require any additional libraries for it to work.


## Installation
Just drag AEXML.swift into your project and start using it.


## License
AEXML is released under the MIT license. See [LICENSE](LICENSE) for details.