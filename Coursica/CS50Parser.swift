//
//  CS50Parser.swift
//  Coursica
//
//  Created by Regan Bell on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Foundation

class CS50Parser {
    
    func integerNumberFromNumberString(string: String) -> Int {
        let scanner = NSScanner(string: string)
        var integerNumber: Int = -1
        scanner.scanInteger(&integerNumber)
        return integerNumber
    }
    
    func genEdsForShortField(field: String, notes: String) -> Set<String> {
        var genEds = Set<String>()
        let allGenEds: [String: String] = ["AESTH&INTP":  "Aesthetic and Interpretive Understanding",
                      "CULTR&BLF":  "Culture and Belief",
                      "E&M-REASON": "Empirical and Mathematical Reasoning",
                      "ETH-REASON": "Ethical Reasoning",
                      "SCI-LIVSYS": "Science of Living Systems",
                      "SCI-PHYUNV": "Science of the Physical Universe",
                      "SOC-WORLD":  "Societies of the World",
                      "US-WORLD":   "United States in the World",
                      "SOP": "Study of the Past"]
        // Get first gen ed from course's field name
        for (key, value) in allGenEds {
            if key == field {
                genEds.insert(value)
                break
            }
        }
        // Get gen eds specified in a course's notes
        for genEd in allGenEds.values {
            let range = notes.rangeOfString(genEd)
            if let start = range?.startIndex {
                genEds.insert(genEd)
            }
        }
        return genEds
    }
    
    func graduateFromCourseNumber(number: String) -> Bool {
        
        let regex = NSRegularExpression(pattern: "[0-9]+", options: NSRegularExpressionOptions.allZeros, error: NSErrorPointer())
        let range = regex!.rangeOfFirstMatchInString(number, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(number)))
        if range.location != NSNotFound {
            let match = (number as NSString).substringWithRange(range)
            if let numberDouble = NSNumberFormatter().numberFromString(match)?.doubleValue {
                // Course numbering scheme explained: http://www.registrar.fas.harvard.edu/courses-exams/courses-instruction/introductory-notes
                if ((numberDouble >= 200 && numberDouble < 1000) || (numberDouble >= 2000)) {
                    return true
                }
            }
        }
        return false
    }
}