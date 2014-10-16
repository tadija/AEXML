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
    
    @IBAction func readXML(sender: UIBarButtonItem) {
        resetTextField()
        
        if let xmlPath = NSBundle.mainBundle().pathForResource("plant_catalog", ofType: "xml") {
            let xmlData = NSData(contentsOfFile: xmlPath)
            var error: NSError?
            if let doc = AEXMLDocument(data: xmlData, error: &error) {
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
                if let doc = AEXMLDocument(data: data, error: &error) {
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

