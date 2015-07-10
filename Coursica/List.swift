//
//  List.swift
//  Coursica
//
//  Created by Regan Bell on 6/24/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

extension String {
    
    func encodedAsFirebaseKey() -> String {
        var string = self
        for (i, forbidden) in enumerate([".", "#", "$", "/", "[", "]"]) {
            string = string.stringByReplacingOccurrencesOfString(forbidden, withString: "&\(i)&")
        }
        return string
    }
}

@objc class List {
    
    var name: String = ""
    var courses: [TempCourse] = []
    var id: String = ""
    
    init(name: String, courses: [TempCourse]) {
        self.name = name
        self.courses = courses
    }
    
    func setCoursesFromJSON(JSON: NSDictionary) {
        
        if let courseDictionaries = JSON["list"] as? [NSDictionary] {
            var tempCourses: [TempCourse] = []
            for courseDict in courseDictionaries {
                let tempCourse = TempCourse(CS50Dictionary: courseDict)
                tempCourses.append(tempCourse)
            }
            self.courses = tempCourses
            
        }
    }
    
    class func listNames() -> [String] {
        return ["Courses I've Taken",
                "Courses I'm Taking",
                "Courses I'm Shopping",
                "Courses I've Liked",
                "Courses I've Disliked"]
    }
    
    class func emptyListsDictionary() -> [List] {
        return [List(name: "Courses I've Taken", courses: []),
                List(name: "Courses I'm Taking", courses: []),
                List(name: "Courses I'm Shopping", courses: []),
                List(name: "Courses I've Liked", courses: []),
                List(name: "Courses I've Disliked", courses: [])]
    }
    
    func removeTempCourse(tempCourse: TempCourse) -> Bool {
        
        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
        let firebaseRoot: Firebase = Firebase(url: "glaring-heat-9505.firebaseIO.com/\(HUID)/lists/\(name)")
        if courses.count == 1 {
            firebaseRoot.removeValue()
            return true //should delete List
        } else {
            self.courses = self.courses.filter({ course in course.title != tempCourse.title })
            let courseRef = firebaseRoot.childByAppendingPath(tempCourse.displayTitle.encodedAsFirebaseKey())
            courseRef.removeValue()
            return false //should not delete List
        }
    }
    
    class func moveCourseFromList(fromList: List, toList: List, tempCourse: TempCourse) {
    
        fromList.removeTempCourse(tempCourse)
        toList.courses.append(tempCourse)
        self.addTempCourseToListWithName(toList.name, tempCourse: tempCourse)
    }

    class func fetchListsForCurrentUserWithCompletion(completionBlock: [List]? -> Void) {
        
        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
        let firebaseRoot: Firebase = Firebase(url: "glaring-heat-9505.firebaseIO.com/\(HUID)/lists")
        let snapshot: FDataSnapshot
        firebaseRoot.observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
            if let null = (snapshot.value as? NSNull) {
                completionBlock(nil)
                return
            }
            var lists: [List] = []
            for list in snapshot.snapshotChildren() {
                let name = list.key
                var courses: [TempCourse] = []
                for course in list.snapshotChildren() {
                    courses.append(TempCourse(snapshot: course))
                }
                lists.append(List(name: name, courses: courses))
            }
            completionBlock(lists)
        })
    }
    
    class func addTempCourseToListWithName(name: String, tempCourse: TempCourse, completionBlock: (NSError?) -> Void) {
        
        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
        let firebaseRoot: Firebase = Firebase(url: "glaring-heat-9505.firebaseIO.com/\(HUID)/lists/\(name)")
        let courseRef = firebaseRoot.childByAppendingPath(tempCourse.displayTitle.encodedAsFirebaseKey())
        let courseDict = ["title": tempCourse.title, "number": tempCourse.number, "shortField": tempCourse.shortField]
        courseRef.setValue(courseDict, withCompletionBlock: {error, firebase in completionBlock(error) })
    }
    
    class func addTempCourseToListWithName(name: String, tempCourse: TempCourse) {
        self.addTempCourseToListWithName(name, tempCourse: tempCourse, completionBlock: {error in })
    }
    
    class func addCourseToListWithName(name: String, course: Course) {
        self.addTempCourseToListWithName(name, tempCourse: TempCourse(course: course))
    }
}