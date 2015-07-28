//
//  CS50Downloader.swift
//  Coursica
//
//  Created by Regan Bell on 7/12/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

extension String {
    
    func purifiedString() -> String {
        let b = self.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
        return b.stringByReplacingOccurrencesOfString("\\'", withString:"'")
    }
}

@objc class CS50Downloader: NSObject {
    
    class func integerNumberFromNumberString(string: String) -> Int {
        let scanner = NSScanner(string: string)
        var integerNumber: Int = -1
        scanner.scanInteger(&integerNumber)
        return integerNumber
    }
    
    class func getCourses(completion: Void -> Void) {
        
        let path = NSBundle.mainBundle().pathForResource("final_results copy", ofType: "json")
        let data = NSData(contentsOfFile: path!)!
        let qData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: nil) as! NSDictionary
        
        let parser = CS50Parser()
        
        let request = Alamofire.request(.GET, "http://api.cs50.net/courses/3/courses?key=bb344e1e4724ebdcfe53cc61f0cb2649&output=json", parameters: nil).responseJSON { (request, response, data, error) in
            
        let realm = Realm()
        var courses: [Course] = []
        if let serverCourses = data as? [NSDictionary] {
            
            let longFields = Search.shared.commonAbbreviations
            
            for serverCourse in serverCourses {
                let course = Course()
                let basicKeyMapping =       ["title":         "title",
                                             "description":   "courseDescription",
                                             "cat_num":       "catalogNumber",
                                             "term":          "term",
                                             "number":        "number",
                                             "notes":         "notes",
                                             "prerequisites": "prerequisitesString"]
                if let shortField = serverCourse["field"] as? String {
                    course.shortField = shortField
                    if let longField = longFields[shortField] {
                        course.longField = longField
                    }
                }
                course.setFieldsWithMap(basicKeyMapping, data: serverCourse)
                course.integerNumber = parser.integerNumberFromNumberString(course.number)
                for genEdName in parser.genEdsForShortField(course.shortField, notes: course.notes) {
                    course.genEds.append(GenEd(name: genEdName))
                }
                course.graduate = parser.graduateFromCourseNumber(course.number)
                if let facultyArray = serverCourse["faculty"] as? NSArray {
                    for instructorDict in facultyArray {
                        let faculty = Faculty()
                        faculty.setFieldsWithList(["first", "middle", "last", "suffix"], data: instructorDict as! NSDictionary)
                        course.faculty.append(faculty)
                    }
                }
                if let meetingArray = serverCourse["schedule"] as? NSArray {
                    for meetingDict in meetingArray {
                        let meeting = Meeting()
                        meeting.setFieldsWithList(["day", "type", "optional"], data: meetingDict as! NSDictionary)
                        let map = ["begin_time": "beginTime", "end_time": "endTime"]
                        meeting.setFieldsWithMap(map, data: meetingDict as! NSDictionary)
                        course.meetings.append(meeting)
                    }
                }
                if let locationArray = serverCourse["locations"] as? NSArray {
                    for locationDict in locationArray {
                        let location = Location()
                        location.setFieldsWithList(["type", "building", "room"], data: locationDict as! NSDictionary)
                        course.locations.append(location)
                    }
                }
                courses.append(course)
            }
            realm.write({
                for course in courses {
                    realm.add(course)
                }
            })
            completion()
        }
    }
        request.resume()
    }
}