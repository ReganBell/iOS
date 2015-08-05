//
//  ListsImporter.swift
//  Coursica
//
//  Created by Regan Bell on 8/3/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import Alamofire

class ListsImporter: NSObject {
    
    static let shared = ListsImporter()
    var parameters: [String: String]?
    var urlString: String?
    var password: String?
    var completionBlock: ((Bool, String?) -> (Void))?
    
    func setParametersForXMLString(xmlString: String) {
        let htmlData = xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let document = TFHpple(HTMLData: htmlData)
        var parameters: [String: String] = Dictionary<String, String>()
        for node in document.searchWithXPathQuery("//input") {
            if let element = node as? TFHppleElement {
                if let name = element.attributes["name"] as? String {
                    if let value = element.attributes["value"] as? String {
                        parameters[name] = value
                        println("\(name): \(value)")
                    }
                }
            }
        }
        
        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
        let additional = [
            "username": HUID,
            "password": password,
            "compositeAuthenticationSourceType": "PIN"]
        
        for (key, value) in additional {
            parameters.updateValue(value!, forKey: key)
        }
        self.parameters = parameters
    }
    
    func listIDsForXMLString(xmlString: String) -> [String] {
        
        return []
    }
    
    func tryLists() {
        if self.urlString == nil || self.password == nil {
            return
        }
        Alamofire.request(.POST, urlString!, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil).responseString { _, response, string, error in
            if let error = error {
                self.completionBlock!(false, "Network error.")
                return
            }
            if let response = response {
                let URLString = "\(response.URL!)"
                if let range = URLString.rangeOfString("https://courses.cs50.net/", options: NSStringCompareOptions.allZeros, range: nil, locale: nil) {
                    let ids = self.listIDsForXMLString(string!)
                    self.completionBlock!(true, nil)
                    return
                }
            }
            self.completionBlock!(false, "Invalid password, try again.")
        }.resume()
    }
    
    func getLogIn(completionBlock: (Bool, String?) -> (Void)) {
        self.completionBlock = completionBlock
        let urlString = "https://courses.cs50.net/classes/login"
        Alamofire.request(.GET, urlString, parameters: nil, encoding: ParameterEncoding.URL, headers: nil).responseString { _, response, string, error in
            if let xmlString = string {
                self.urlString = response!.URL!.absoluteString
                self.setParametersForXMLString(xmlString)
                self.tryLists()
            } else {
                completionBlock(false, "Network error.")
            }
        }.resume()
    }
    
    func getListsWithPassword(password: String) {
        self.password = password
        self.tryLists()
    }
}
