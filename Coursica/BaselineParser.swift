//
//  BaselineParser.swift
//  Coursica
//
//  Created by Regan Bell on 7/24/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class BaselineParser: NSObject {
    class func baselineFromDictionary(dictionary: NSDictionary?) -> Baseline? {
        if dictionary == nil {
            return nil
        }
        let baseline = Baseline()
        for (serverKey, modelKey) in [("dept", "department"), ("size", "size"), ("group", "group")] {
            if let value = dictionary![serverKey] as? NSNumber {
                baseline.setValue(value.doubleValue, forKey: modelKey)
            }
        }
        return baseline
    }
}
