//
//  BreakdownParser.swift
//  Coursica
//
//  Created by Regan Bell on 7/24/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class BreakdownParser: NSObject {
    class func breakdownFromArray(array: NSArray?) -> Breakdown? {
        if array?.count != 5 {
            return nil
        }
        let breakdown = Breakdown()
        for (index, modelKey) in ["one", "two", "three", "four", "five"].enumerate() {
            if let value = array![index] as? Int {
                breakdown.setValue(value, forKey: modelKey)
            }
        }
//        breakdown.one = array![0] as! Int
//        breakdown.two = array![1] as! Int
//        breakdown.three = array![2] as! Int
//        breakdown.four = array![3] as! Int
//        breakdown.five = array![4] as! Int
        return breakdown
    }
}
