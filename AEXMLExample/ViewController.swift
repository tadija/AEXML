//
//  ViewController.swift
//  AEXMLExample
//
//  Created by Marko Tadic on 10/16/14.
//  Copyright (c) 2014 ae. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // example from README.md
        if let xmlPath = NSBundle.mainBundle().pathForResource("example", ofType: "xml") {
            if let data = NSData(contentsOfFile: xmlPath) {
                
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
                
            }
        }
    }
    
    @IBAction func readXML(sender: UIBarButtonItem) {
        resetTextField()
        
        if let xmlPath = NSBundle.mainBundle().pathForResource("plant_catalog", ofType: "xml") {
            if let data = NSData(contentsOfFile: xmlPath) {
                var error: NSError?
                if let doc = AEXMLDocument(xmlData: data, error: &error) {
                    var parsedText = String()
                    // parse known structure
                    for plant in doc["CATALOG"]["PLANT"].all! {
                        parsedText += plant["COMMON"].stringValue + "\n"
                    }
                    textView.text = parsedText
                } else {
                    let err = "description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)"
                    textView.text = err
                }
            }
        }
    }
    
    @IBAction func writeXML(sender: UIBarButtonItem) {
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
        textView.text = soapRequest.xmlString
    }
    
    func resetTextField() {
        textField.resignFirstResponder()
        textField.text = "http://www.w3schools.com/xml/cd_catalog.xml"
    }
    
    @IBAction func tryRemoteXML(sender: UIButton) {
        if let url = NSURL(string: textField.text) {
            if let data = NSData(contentsOfURL: url) {
                var error: NSError?
                if let doc = AEXMLDocument(xmlData: data, error: &error) {
                    var parsedText = String()
                    // parse unknown structure
                    for child in doc.root.children {
                        parsedText += child.xmlString + "\n"
                    }
                    textView.text = parsedText
                } else {
                    let err = "description: \(error?.localizedDescription)\ninfo: \(error?.userInfo)"
                    textView.text = err
                }
            }
        }
        textField.resignFirstResponder()
    }

}

