[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat)](https://swift.org)
[![Platforms iOS | watchOS | tvOS | macOS](https://img.shields.io/badge/Platforms-iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20macOS-lightgray.svg?style=flat)](http://www.apple.com)
[![CocoaPods](https://img.shields.io/cocoapods/v/AEXML.svg?style=flat)](https://cocoapods.org/pods/AEXML)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://github.com/tadija/AEXML/blob/master/LICENSE)

# AEXML

**Swift minion for simple and lightweight XML parsing**

> I made this for personal use, but feel free to use it or contribute.
> For more examples check out [Sources](Sources) and [Tests](Tests).

## Index
- [Intro](#intro)
- [Features](#features)
- [Usage](#usage)
    - [Read XML](#read-xml)
    - [Write XML](#write-xml)
- [Installation](#installation)
- [License](#license)

## Intro

This is not a robust full featured XML parser, but rather simple, lightweight and easy to use utility for casual XML handling.

## Features
- **Read XML** data
- **Write XML** string
- Covered with [unit tests](https://github.com/tadija/AEXML/blob/master/Tests/AEXMLTests.swift)
- Covered with inline docs

## Usage

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

This is how you can use **AEXML** for working with this data:  
(for even more examples, look at the unit tests code included in project)

```swift
guard let
    let xmlPath = Bundle.main.path(forResource: "example", ofType: "xml"),
    let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath))
else { return }

let xmlDoc = try AEXMLDocument(xml: data, options: options)

let xmlDoc: AEXMLDocument
let root: AEXMLElement
do {
    xmlDoc = try AEXMLDocument(xml: data, options: options)
    root = try xmlDoc.root
} catch {
    print("Failed to parse doc and root:", error)
    return
}

// prints the same XML structure as original
print(xmlDoc.xml)

// prints cats, dogs
for child in root.children {
    print(child.name)
}

// prints Optional("Tinna") (first element)
do {
    let tinna = try root["cats"]["cat"].value
    print(String(describing: tinna))
} catch {
    print(error)
}

// prints Tinna (first element)
do {
    let tinna = try root["cats"]["cat"].string
    print(tinna)
} catch {
    print(error)
}

// prints Optional("Kika") (last element)
do {
    let kika = try root["dogs"]["dog"].last?.value
    print(String(describing: kika))
} catch {
    print(error)
}

// prints Betty (3rd element)
do {
    let betty = try root["dogs"].children[2].string
    print(betty)
} catch {
    print(error)
}

// prints Tinna, Rose, Caesar
do {
    let cats = try root["cats"]["cat"]
    if let allCats = cats.all {
        for cat in allCats {
            if let name = cat.value {
                print(name)
            }
        }
    }
} catch {
    print(error)
}

// prints Villy, Spot
do {
    let dogs = try root["dogs"]["dog"]
    for dog in dogs.all! {
        if let color = dog.attributes["color"] {
            if color == "white" {
                print(dog.string)
            }
        }
    }
} catch {
    print(error)
}

// prints Tinna
do {
    let cats = try root["cats"]["cat"]
    if let tinna = cats.all(withValue: "Tinna") {
        for cat in tinna {
            print(cat.string)
        }
    }
} catch {
    print(error)
}

// prints Caesar
do {
    let cats = try root["cats"]["cat"]
    if let caesar = cats.all(withAttributes: ["breed" : "Domestic", "color" : "yellow"]) {
        for cat in caesar {
            print(cat.string)
        }
    }
} catch {
    print(error)
}

// prints 4
do {
    print(try root["cats"]["cat"].count)
} catch {
    print(error)
}

// prints Siberian
do {
    print(try root["cats"]["cat"].attributes["breed"]!)
} catch {
    print(error)
}

// prints <cat breed="Siberian" color="lightgray">Tinna</cat>
do {
    print(try root["cats"]["cat"].xmlCompact)
} catch {
    print(error)
}

// prints Optional(AEXML.AEXMLError.elementNotFound)
do {
    let _ = try xmlDoc["NotExistingElement"]
} catch {
    print(error)
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
// create XML Document
let soapRequest = AEXMLDocument()
let attributes = ["xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" : "http://www.w3.org/2001/XMLSchema"]
let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: attributes)
let header = envelope.addChild(name: "soap:Header")
let body = envelope.addChild(name: "soap:Body")
header.addChild(name: "m:Trans", value: "234", attributes: ["xmlns:m" : "http://www.w3schools.com/transaction/", "soap:mustUnderstand" : "1"])
let getStockPrice = body.addChild(name: "m:GetStockPrice")
getStockPrice.addChild(name: "m:StockName", value: "AAPL")

// prints the same XML structure as original
print(soapRequest.xml)
```

Or perhaps like this, using result builders (see [#186](https://github.com/tadija/AEXML/pull/186)):

```swift
@AEXMLDocumentBuilder
private func buildSoapEnvelope(
    for action: String,
    in serviceType: String,
    with parameters: [String: String] = [:]
) -> AEXMLDocument {
    AEXMLElement("s:Envelope", attributes: [
        "xmlns:s": "http://schemas.xmlsoap.org/soap/envelope/",
        "s:encodingStyle": "http://schemas.xmlsoap.org/soap/encoding/"
    ]) {
        AEXMLElement("s:Body") {
            AEXMLElement("s:\(action)", attributes: [
                "xmlns:u": serviceType
            ]) {
                for parameter in parameters {
                    AEXMLElement(
                        name: parameter.key,
                        value: parameter.value
                    )
                }
            }
        }
    }
}
```

## Installation

- [Swift Package Manager](https://swift.org/package-manager/):

	```swift
    .package(url: "https://github.com/tadija/AEXML.git", from: "4.7.3")
	```

- [Carthage](https://github.com/Carthage/Carthage):

	```ogdl
	github "tadija/AEXML"
	```

- [CocoaPods](http://cocoapods.org/):

	```ruby
	pod 'AEXML'
	```

## License
AEXML is released under the MIT license. See [LICENSE](LICENSE) for details.
