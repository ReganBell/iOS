//
//  ReportParser.swift
//  Coursica
//
//  Created by Regan Bell on 7/24/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class ReportParser: NSObject {
    class func reportFromSnapshot(snapshot: FDataSnapshot) -> Report? {
        
        if snapshot.value is NSNull {
            return nil
        } else {
            let reportDictionary = snapshot.value.allValues.first! as! NSDictionary
            let report = Report()
            report.setFieldsWithList(["term", "year", "comments", "responses"], data: reportDictionary)
            if let enrollment = reportDictionary["enrollment"] as? Int {
                report.enrollment = enrollment
            }
            if let responses = reportDictionary["responses"] as? NSDictionary {
                for (key, value) in responses {
                    if let responseDict = (value as? NSDictionary) {
                        if let question = key as? String {
                            let response = ResponseParser.responseFromDictionary(responseDict)
                            response.question = question
                            report.responses.append(response)
                        }
                    }
                }
            }
            return report
        }
    }
}
