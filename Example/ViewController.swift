//
//  ViewController.swift
//  AEXMLExample
//
//  Created by Marko Tadic on 10/16/14.
//  Copyright (c) 2014-2019 ae. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // example from README.md
        guard let
            xmlPath = Bundle.main.path(forResource: "example", ofType: "xml"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath))
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
            let document = try AEXMLDocument(xmlData: data)
            var parsedText = String()
            // parse known structure
            for plant in document["CATALOG"]["PLANT"].all! {
                parsedText += plant["COMMON"].stringValue + "\n"
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
        _ = header.addChild(name: "m:Trans", value: "234", attributes: ["xmlns:m" : "http://www.w3schools.com/transaction/", "soap:mustUnderstand" : "1"])
        let getStockPrice = body.addChild(name: "m:GetStockPrice")
        _ = getStockPrice.addChild(name: "m:StockName", value: "AAPL")
        textView.text = soapRequest.xmlString
    }
    
    func resetTextField() {
        textField.resignFirstResponder()
        textField.text = "http://www.w3schools.com/xml/cd_catalog.xml"
    }
    
    @IBAction func tryRemoteXML(_ sender: UIButton) {
        defer {
            textField.resignFirstResponder()
        }

        guard let
            text = textField.text,
            let url = URL(string: text),
            let data = try? Data(contentsOf: url)
        else {
            textView.text = "Bad URL or XML Data."
            return
        }

        do {
            let document = try AEXMLDocument(xmlData: data)
            var parsedText = String()
            // parse unknown structure
            for child in document.root.children {
                parsedText += child.xmlString + "\n"
            }
            textView.text = parsedText
        } catch {
            textView.text = "\(error)"
        }
    }
}

