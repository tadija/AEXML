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
                    for plant in doc["CATALOG"]["PLANT"].all {
                        parsedText += plant["COMMON"].value + "\n"
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
        let envelope = soapRequest.addChild("soap:Envelope", attributes: attributes)
        let header = envelope.addChild("soap:Header")
        let body = envelope.addChild("soap:Body")
        header.addChild("m:Trans", value: "234", attributes: ["xmlns:m" : "http://www.w3schools.com/transaction/", "soap:mustUnderstand" : "1"])
        let getStockPrice = body.addChild("m:GetStockPrice")
        getStockPrice.addChild("m:StockName", value: "AAPL")
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
                    for child in doc.rootElement.children {
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

