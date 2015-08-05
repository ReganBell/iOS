//
//  Login.swift
//  Coursica
//
//  Created by Regan Bell on 8/2/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import Alamofire

class Login: NSObject {
    
    class func attemptLoginWithCredentials(username: String, password: String, completionBlock: (Bool, String?) -> (Void)) {
        
        let sessionID = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "")
        
        // 22B73CF4A780B532491C7F324A10E338
        let urlString = "https://www.pin1.harvard.edu/cas/login;jsessionid=\(sessionID)?service=https%3A%2F%2Fwww.pin1.harvard.edu%2Fpin%2Fauthenticate%3F__authen_application%3DFAS_CS_COURSE_EVAL_REPORTS%26original_request%3D%252Fcourse_evaluation_reports%252Ffas%252Flist%253F"
        
        var parameters: [String: String] = Dictionary<String, String>()
        
        Alamofire.request(.POST, urlString, parameters: nil, encoding: ParameterEncoding.URL, headers: nil).responseString { _, _, string, _ in

            if let xmlString = string {
                let htmlData = xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
                let document = TFHpple(HTMLData: htmlData)
                for node in document.searchWithXPathQuery("//input") {
                    if let element = node as? TFHppleElement {
                        if let name = element.attributes["name"] {
                            if let value = element.attributes["value"] {
                                parameters[name as! String] = value as! String
                                println("\(name): \(value)")
                            }
                        }
                    }
                }

                let additional = [
                    "username": username,
                    "password": password,
                    "compositeAuthenticationSourceType": "PIN"]

                for (key, value) in additional {
                    parameters.updateValue(value, forKey: key)
                }

                Alamofire.request(.POST, urlString, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil).responseString { _, response, string, error in
                    if let error = error {
                        completionBlock(false, "Network error.")
                        return
                    }
                    if let response = response {
                        let URLString = "\(response.URL!)"
                        if let range = URLString.rangeOfString("https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list", options: NSStringCompareOptions.allZeros, range: nil, locale: nil) {
                            completionBlock(true, nil)
                            return
                        }
                    }
                    completionBlock(false, "Invalid HUID or password, try again.")
                }.resume()
            } else {
                completionBlock(false, "Network error.")
            }
        }.resume()
    }
}