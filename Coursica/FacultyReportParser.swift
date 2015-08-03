//
//  FacultyReportParser.swift
//  Coursica
//
//  Created by Regan Bell on 8/2/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class FacultyReportParser: NSObject {
    class func facultyReportFromDictionary(dictionary: NSDictionary) -> FacultyReport {
        let facultyReport = FacultyReport()
        for (key, value) in dictionary {
            if let responseDict = (value as? NSDictionary) {
                if let question = key as? String {
                    let response = ResponseParser.responseFromDictionary(responseDict)
                    response.question = question
                    facultyReport.responses.append(response)
                }
            }
        }
        return facultyReport
    }
}
