//
//  TempCourse.swift
//  Coursica
//
//  Created by Regan Bell on 6/30/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Foundation

extension FDataSnapshot {
    
    func snapshotChildren() -> [FDataSnapshot] {
        
        var snapshotChildren: [FDataSnapshot] = []
        for child in self.children {
            let snapshotChild = (child as! FDataSnapshot)
            snapshotChildren.append(snapshotChild)
        }
        return snapshotChildren
    }
}

class TempCourse {
    var number: String = ""
    var shortField: String = ""
    var title: String = ""
    var displayTitle: String {
        get {
            return "\(self.shortField) \(self.number): \(self.title)"
        }
    }
    
    init(CS50Dictionary: NSDictionary) {
        
        if let combined = CS50Dictionary["number"] as? String {
            let halves = combined.componentsSeparatedByString(" ")
            self.shortField = halves.first!
            self.number = halves[1]
        }
        if let title = CS50Dictionary["title"] as? String {
            self.title = title
        }
    }
        
    init(snapshot: FDataSnapshot) {
        for field in snapshot.snapshotChildren() {
            switch field.key {
            case "number":
                self.number = field.value as! String
            case "shortField":
                self.shortField = field.value as! String
            case "title":
                self.title = field.value as! String
            default:
                print("Unexpected course field type", appendNewline: false)
            }
        }
    }
    
    init(course: Course) {
        self.number = course.number
        self.title = course.title
        self.shortField = course.shortField
    }
}