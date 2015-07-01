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

@objc class TempCourse {
    var number: String = ""
    var shortField: String = ""
    var title: String = ""
    var displayTitle: String {
        get {
            return "\(self.shortField) \(self.number): \(self.title)"
        }
    }
    
    init(snapshot: FDataSnapshot) {
        for field in snapshot.snapshotChildren() {
            switch field.key {
            case "number":
                number = field.value as! String
            case "shortField":
                shortField = field.value as! String
            case "title":
                title = field.value as! String
            default:
                print("Unexpected course field type")
            }
        }
    }
    
    init(course: Course) {
        self.number = course.number
        self.title = course.title
        self.shortField = course.shortField
    }
}