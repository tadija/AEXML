# AEXML
**Simple and lightweight XML parser written in Swift**

> This is not robust full featured XML parser (at the moment), but rather simple,  
and very easy to use utility for casual XML handling (it just works).

**AEXML** is a [minion](http://tadija.net/public/minion.png) which consists of these classes:  

Class | Description
------------ | -------------
`AEXMLElement` | Base class
`AEXMLDocument` | Inherited from `AEXMLElement` with a few addons
`AEXMLParser` | Simple (private) wrapper around `XMLParser`


## Features
- **Read XML** data
- **Write XML** string
- Covered with **unit tests**
- Covered with [docs](http://tadija.net/projects/AEXML/docs/)
- **Swift 4.2**


## Index
- [Example](#example)
  - [Read XML](#read-xml)
  - [Write XML](#write-xml)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)


## Example

### Read XML
Let's say this is some XML string you picked up somewhere and made a variable `data: Data` from that.

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
guard let
    xmlPath = Bundle.main.path(forResource: "example", ofType: "xml"),
    let data = Data(contentsOfFile: URL(fileURLWithPath: xmlPath))
else { return }

do {
    let xmlDoc = try AEXMLDocument(xmlData: data)

    // prints the same XML structure as original
    print(xmlDoc.xmlString)

    // prints cats, dogs
    for child in xmlDoc.root.children {
        print(child.name)
    }

    // prints Optional("Tinna") (first element)
    print(xmlDoc.root["cats"]["cat"].value ?? "Unexpected nil value")

    // prints Tinna (first element)
    print(xmlDoc.root["cats"]["cat"].stringValue)

    // prints Optional("Kika") (last element)
    print(xmlDoc.root["dogs"]["dog"].last?.value ?? "Unexpected nil value")

    // prints Betty (3rd element)
    print(xmlDoc.root["dogs"].children[2].stringValue)

    // prints Tinna, Rose, Caesar
    if let cats = xmlDoc.root["cats"]["cat"].all {
        for cat in cats {
            if let name = cat.value {
                print(name)
            }
        }
    }

    // prints Villy, Spot
    for dog in xmlDoc.root["dogs"]["dog"].all! {
        if let color = dog.attributes["color"] {
            if color == "white" {
                print(dog.stringValue)
            }
        }
    }

    // prints Tinna
    if let cats = xmlDoc.root["cats"]["cat"].allWithValue("Tinna") {
        for cat in cats {
            print(cat.stringValue)
        }
    }

    // prints Caesar
    if let cats = xmlDoc.root["cats"]["cat"].allWithAttributes(["breed" : "Domestic", "color" : "yellow"]) {
        for cat in cats {
            print(cat.stringValue)
        }
    }

    // prints 4
    print(xmlDoc.root["cats"]["cat"].count)

    // prints Siberian
    print(xmlDoc.root["cats"]["cat"].attributes["breed"]!)

    // prints element <badexample> not found
    print(xmlDoc["badexample"]["notexisting"].stringValue)
    }
catch {
    print("\(error)")
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


## Requirements
- Xcode 10.1
- iOS 8.0+
- AEXML doesn't require any additional libraries for it to work.


## Installation

- [CocoaPods](http://cocoapods.org/):

	```ruby
	pod 'AEXML'
	```
  
- [Carthage](https://github.com/Carthage/Carthage):

	```ogdl
	github "tadija/AEXML"
	```

- Manually:

  Just drag **AEXML.swift** into your project and start using it.

## License
AEXML is released under the MIT license. See [LICENSE](LICENSE) for details.
