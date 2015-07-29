//
//  ResponseParser.swift
//  Coursica
//
//  Created by Regan Bell on 7/24/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class ResponseParser: NSObject {
    class func responseFromDictionary(dictionary: NSDictionary) -> Response {
        let response = Response()
        if let mean = (dictionary["mean"] as? NSNumber) {
            response.mean = mean.doubleValue
        }
        let baselines = dictionary["baselines"] as? NSDictionary
        if let threeYearsDict = baselines?["three_years"] as? NSDictionary {
            if let baseline = BaselineParser.baselineFromDictionary(threeYearsDict) {
                response.baselineThreeYears = baseline
            }
        }
        if let singleTermDict = baselines?["single_term"] as? NSDictionary {
            if let baseline = BaselineParser.baselineFromDictionary(singleTermDict) {
                response.baselineSingleTerm = baseline
            }
        }
        if let breakdown = BreakdownParser.breakdownFromArray((dictionary["breakdown"] as? NSArray)) {
            response.breakdown = breakdown
        }
        if let median = dictionary["median"] as? Int {
            response.median = median
        }
        return response
    }
}
