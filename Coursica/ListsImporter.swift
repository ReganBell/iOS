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
    var xmlString: String?
    var urlString: String?
    var password: String?
    var completionBlock: ((Bool, String?) -> (Void))?
    
    func parametersForXMLString(xmlString: String) ->  [String: String] {
        let htmlData = xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let document = TFHpple(HTMLData: htmlData)
        var parameters: [String: String] = Dictionary<String, String>()
        for node in document.searchWithXPathQuery("//input") {
            if let element = node as? TFHppleElement {
                if let name = element.attributes["name"] as? String {
                    if let value = element.attributes["value"] as? String {
                        parameters[name] = value
                        print("\(name): \(value)")
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
        return parameters
    }
    
    func listIDsForXMLString(xmlString: String) -> [String] {
        
        NSLog(xmlString)
        let htmlData = xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let document = TFHpple(HTMLData: htmlData)
        var counts: [NSString] = []
        var ids: [NSString] = []
        for node in document.searchWithXPathQuery("//a[@class=\"list-link\"]/@data-list-id") {
            if let element = node as? TFHppleElement {
                if let id = element.content {
                    ids.append(id)
                }
            }
        }
        for node in document.searchWithXPathQuery("//a[@class=\"list-link\"]/@data-list-count") {
            if let element = node as? TFHppleElement {
                if let count = element.content {
                    counts.append(count)
                }
            }
        }
        return []
    }
    
    func canMakeLoginRequest() -> Bool {
        for stringOption in [urlString, password, xmlString] {
            if let string = stringOption {
                if string.isEmpty {
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }
    
    func tryLists() {
        if !canMakeLoginRequest() {
           return
        }
        Alamofire.request(.POST, urlString!, parameters: parametersForXMLString(xmlString!), encoding: .URL, headers: nil).responseString { request, response, result in
            switch result {
            case .Success:
                let URLString = response?.URL?.absoluteString ?? ""
                if let _ = URLString.rangeOfString("https://courses.cs50.net/", options: NSStringCompareOptions(), range: nil, locale: nil) {
//                    let ids = self.listIDsForXMLString(string)
                    self.completionBlock!(true, nil)
                    return
                } else {
                    self.completionBlock!(false, "Invalid password, try again.")
                }
            case .Failure(_, let error):
                self.completionBlock!(false, "Network error: \(error)")
            }
        }.resume()
    }
    
    func getLogIn(completionBlock: (Bool, String?) -> (Void)) {
        self.completionBlock = completionBlock
        let urlString = "https://courses.cs50.net/classes/login"
        Alamofire.request(.GET, urlString, parameters: nil, encoding: .URL, headers: nil).responseString {request, response, result in
            switch result {
            case .Success(let xmlString):
                self.urlString = response?.URL?.absoluteString ?? ""
                self.xmlString = xmlString
                self.tryLists()
            case .Failure(_, let error):
                self.completionBlock!(false, "Network error: \(error)")
            }
        }.resume()
    }
    
    func getListsWithPassword(password: String) {
        self.password = password
        self.tryLists()
    }
}
