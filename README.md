# AEXML
**Simple and lightweight XML parser for iOS in Swift**

AEXML consists of three objects: **AEXMLElement** (base class), **AEXMLDocument** (inherited from previous) and **AEXMLParser** (simple wrapper around NSXMLParser).

It's not full featured advanced robust XML parser (at the moment), but rather really simple, smart and very easy to use utility for casual XML handling (it just works).

## Features
- **Read XML** data
- **Write XML** string
- I believe that's all

## Installation
Just drag AEXML.swift into your project and start using it.

## Usage

### Read XML

```xml
<?xml version="1.0" encoding="utf-8"?>
<example>
  <info>
    <name platform="iOS" language="Swift">AEXML</name>
    <url type="github">https://github.com/tadija/AEXML</url>
  </info>
  <features>
    <feature>Read XML</feature>
    <feature>Write XML</feature>
    <feature>Easy to use</feature>
  </features>
  <installation>Just drag AEXML.swift into your project and start using it.</installation>
</example>
```

Let's say this is some XML data you picked up somewhere and made variable data: NSData of it.
This is how you use AEXML for parsing this data:

```swift
// works only if data is successfully parsed
// otherwise prints information about error with parsing
var error: NSError?
if let xmlDoc = AEXMLDocument(xmlData: data, error: &error) {

  // prints the same XML structure as original
  println(xmlDoc.xmlString)
  
  // prints info, features, installation
  for child in xmlDoc.rootElement.children {
    println(child.name)
  }

  // prints <features><feature>Read XML</feature><feature>Write XML</feature><feature>Easy to use</feature></features>
  println(xmlDoc["example"]["features"].xmlStringCompact)
  
  // prints Read XML (first element)
  println(xmlDoc["example"]["features"]["feature"].value)
  
  // prints Easy to use (last element)
  println(xmlDoc["example"]["features"]["feature"].last.value)
  
  // prints Read XML, Write XML, Easy to use (all "feature" elements)
  for feature in xmlDoc["example"]["features"]["feature"].all {
    println(feature.value)
  }
  
  // prints github
  println(xmlDoc.rootElement["info"]["url"].attributes["type"]!)
  
  // prints element <badexample> not found
  println(xmlDoc["badexample"]["installation"].value)
  
} else {
  println("description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)")
}

```

### Write XML

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

Let's say this is some SOAP XML request you need to generate.
Well, you could just build ordinary string for that?
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

## Requirements
AEXML is tested with iOS SDK 7.0 and higher and it doesn't require any additional libraries for it to work.

## License
AEXML is released under the MIT license. See [LICENSE](LICENSE) for details.
