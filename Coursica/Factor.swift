//
//  Factor.swift
//  CoursicaMac
//
//  Created by Regan Bell on 12/1/15.
//  Copyright © 2015 Prestige Worldwide. All rights reserved.
//

import Foundation
import RealmSwift

class Factor {
    let name: String
    let allPossible: Set<Int>
    let rankedPossible: [Int]
    let count: Int
    var validTerm: String -> Bool = { _ in return true }
    init(name: String, count: Int, validTerm: (String -> Bool)?, coursesStringKey: Dictionary<String, Int>, block: Course -> Bool) {
        self.name = name
        let config = Realm.Configuration(
            // Get the path to the bundled file
            path: NSBundle.mainBundle().pathForResource("seed", ofType:"realm"),
            // Open the file in read-only mode as application bundles are not writeable
            readOnly: true)
        
        // Open the Realm with the configuration
        let realm = try! Realm(configuration: config)
        self.count = count
        if let validTerm = validTerm {
            self.validTerm = validTerm
        }
        var possibleCourses = Set<Int>()
        var ranked = [Int]()
        for course in realm.objects(Course).filter(NSPredicate(format: "graduate = false AND enrollment > 10", false, 10)).sorted("percentileSize", ascending: false) {
            if block(course) {
                possibleCourses.insert(coursesStringKey[course.displayTitle]!)
                ranked.append(coursesStringKey[course.displayTitle]!)
            }
        }
        self.allPossible = possibleCourses
        self.rankedPossible = ranked
    }
}