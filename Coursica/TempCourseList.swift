//
//  CourseList.swift
//  Coursica
//
//  Created by Regan Bell on 6/24/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class CourseList {
    
    var name: String = ""
    var courses: [ListableCourse] = []
    var id: String = ""
    
    init(name: String, courses: [ListableCourse]) {
        self.name = name
        self.courses = courses
    }
    
    func setCoursesFromJSON(JSON: NSDictionary) {
        if let courseDictionaries = JSON["list"] as? [NSDictionary] {
            var listCourses: [ListableCourse] = []
            for courseDict in courseDictionaries {
                let tempCourse = TempCourse(CS50Dictionary: courseDict)
                listCourses.append(tempCourse.course ?? tempCourse)
            }
            self.courses = listCourses
        }
    }
    
    class func listNames() -> [String] {
        return ["Courses I've Taken",
                "Courses I'm Taking",
                "Courses I'm Shopping",
                "Courses I've Liked",
                "Courses I've Disliked"]
    }
    
    func removeTempCourse(listableCourse: ListableCourse) -> Bool {
        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
        let firebaseRoot: Firebase = Firebase(url: "glaring-heat-9505.firebaseIO.com/lists/\(HUID)/\(name)")
        if courses.count == 1 {
            firebaseRoot.removeValue()
            return true //should delete List
        } else {
            courses = courses.filter({ course in course.title != listableCourse.title })
            let courseRef = firebaseRoot.childByAppendingPath(listableCourse.displayTitle.asFirebaseKey)
            courseRef.removeValue()
            return false //should not delete List
        }
    }
    
    class func moveCourseFromList(fromList: CourseList, toList: CourseList, listableCourse: ListableCourse) {
        fromList.removeTempCourse(listableCourse)
        toList.courses.append(listableCourse)
        addCourseToListWithName(toList.name, listableCourse: listableCourse, completionBlock: nil)
    }

    class func fetchListsForCurrentUserWithCompletion(completionBlock: [CourseList]? -> Void) {
        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
        let firebaseRoot: Firebase = Firebase(url: "glaring-heat-9505.firebaseIO.com/lists/\(HUID)")
        firebaseRoot.observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
            if let _ = (snapshot.value as? NSNull) {
                completionBlock(nil)
                return
            }
            var lists: [CourseList] = []
            for list in snapshot.snapshotChildren() {
                let name = list.key
                var courses: [ListableCourse] = []
                for course in list.snapshotChildren() {
                    let tempCourse = TempCourse(snapshot: course)
                    courses.append(tempCourse.course ?? tempCourse)
                }
                lists.append(CourseList(name: name, courses: courses))
            }
            completionBlock(lists)
        })
    }
    
    class func addCourseToListWithName(name: String, listableCourse: ListableCourse, completionBlock: (NSError? -> Void)?) {
        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
        let firebaseRoot: Firebase = Firebase(url: "glaring-heat-9505.firebaseIO.com/lists/\(HUID)/\(name)")
        let courseRef = firebaseRoot.childByAppendingPath(listableCourse.displayTitle.asFirebaseKey)
        let courseDict = ["title": listableCourse.title, "number": listableCourse.number, "shortField": listableCourse.shortField]
        courseRef.setValue(courseDict, withCompletionBlock: {error, _ in completionBlock?(error)})
    }
}