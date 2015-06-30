//
//  List.swift
//  Coursica
//
//  Created by Regan Bell on 6/24/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

@objc class List {
    
    var name: String = ""
    var courses: Array<Course> = []
    
    init(name: String, courses: Array<Course>) {
        self.name = name
        self.courses = courses
    }
    
    class func emptyListsDictionary() -> [List] {
        return [List(name: "Courses I've Taken", courses: []),
                List(name: "Courses I'm Taking", courses: []),
                List(name: "Courses I'm Shopping", courses: []),
                List(name: "Courses I've Liked", courses: []),
                List(name: "Courses I've Disliked", courses: [])]
    }
    
    class func testDictionary() -> [List] {
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let entity = NSEntityDescription.entityForName("Course", inManagedObjectContext: delegate.managedObjectContext)
        
        var testCourse = Course(entity: entity!, insertIntoManagedObjectContext: delegate.managedObjectContext)
        testCourse.title = "Introduction to Computer Science I"
        testCourse.number = "50"
        testCourse.shortField = "COMP-SCI"
        
        return [List(name: "Courses I've Taken", courses: [testCourse]),
            List(name: "Courses I'm Taking", courses: [testCourse]),
            List(name: "Courses I'm Shopping", courses: [testCourse]),
            List(name: "Courses I've Liked", courses: [testCourse]),
            List(name: "Courses I've Disliked", courses: [testCourse])]
    }
    
    class func addCourseToListWithName(listName: String, course: Course) {
        
    }
}