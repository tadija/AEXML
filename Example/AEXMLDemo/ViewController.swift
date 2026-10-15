/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2026
 *  Licensed under the MIT license
 */

import UIKit
import AEXML

final class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        printExampleFromReadme()
    }

    private func printExampleFromReadme() {
        guard
            let xmlPath = Bundle.main.path(forResource: "example", ofType: "xml"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath))
        else {
            print("resource not found!")
            return
        }

        // example of using NSXMLParserOptions
        var options = AEXMLOptions()
        options.parserSettings.shouldProcessNamespaces = false
        options.parserSettings.shouldReportNamespacePrefixes = false
        options.parserSettings.shouldResolveExternalEntities = false

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
    }
    
    @IBAction func readXML(_ sender: UIBarButtonItem) {
        defer {
            resetTextField()
        }
        
        guard let
            xmlPath = Bundle.main.path(forResource: "plant_catalog", ofType: "xml"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath))
        else {
            textView.text = "Sample XML Data error."
            return
        }
        
        do {
            let document = try AEXMLDocument(xml: data)
            var parsedText = String()
            // parse known structure
            for plant in try document["CATALOG"]["PLANT"].all! {
                parsedText += try plant["COMMON"].string + "\n"
            }
            textView.text = parsedText
        } catch {
            textView.text = "\(error)"
        }
    }
    
    @IBAction func writeXML(_ sender: UIBarButtonItem) {
        resetTextField()
        // sample SOAP request
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" : "http://www.w3.org/2001/XMLSchema"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: attributes)
        let header = envelope.addChild(name: "soap:Header")
        let body = envelope.addChild(name: "soap:Body")
        header.addChild(name: "m:Trans", value: "234", attributes: ["xmlns:m" : "http://www.w3schools.com/transaction/", "soap:mustUnderstand" : "1"])
        let getStockPrice = body.addChild(name: "m:GetStockPrice")
        getStockPrice.addChild(name: "m:StockName", value: "AAPL")
        textView.text = soapRequest.xml
    }
    
    func resetTextField() {
        textField.resignFirstResponder()
        textField.text = "http://www.w3schools.com/xml/cd_catalog.xml"
    }
    
    @IBAction func tryRemoteXML(_ sender: UIButton) {
        defer {
            textField.resignFirstResponder()
        }

        guard
            let text = textField.text,
            let url = URL(string: text),
            let data = try? Data(contentsOf: url)
        else {
            textView.text = "Bad URL or XML Data."
            return
        }

        do {
            let document = try AEXMLDocument(xml: data)
            var parsedText = String()
            // parse unknown structure
            for child in try document.root.children {
                parsedText += child.xml + "\n"
            }
            textView.text = parsedText
        } catch {
            textView.text = "\(error)"
        }
    }

}
