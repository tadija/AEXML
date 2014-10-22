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

