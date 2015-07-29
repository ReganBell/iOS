//
//  Object.swift
//  Coursica
//
//  Created by Regan Bell on 7/14/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import RealmSwift

extension Object {
    
    func setFieldsWithList(keys: [String], data: NSDictionary) {
        var map = Dictionary<String, String>()
        for key in keys {
            map[key] = key
        }
        self.setFieldsWithMap(map, data: data)
    }
        
    func setFieldsWithMap(map: [String: String], data: NSDictionary) {
        
        for (dataKey, objectKey) in map {
            if let value = data[dataKey] as? String {
                self.setValue(value.purifiedString(), forKey: objectKey)
            }
        }
    }
}