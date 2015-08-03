//
//  Course.swift
//  Coursica
//
//  Created by Regan Bell on 7/12/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//
import RealmSwift

class Course: Object {
    
    dynamic var bracketed = false
    dynamic var graduate = false
    dynamic var catalogNumber = ""
    dynamic var courseDescription = ""
    dynamic var examGroup = ""
    dynamic var term = ""
    dynamic var enrollment = 0
    dynamic var enrollmentSource = ""
    
    dynamic var longField = ""
    dynamic var shortField = ""
    dynamic var notes = ""
    dynamic var number = ""
    dynamic var title = ""
    dynamic var prerequisitesString = ""
    dynamic var integerNumber = -1
    
    dynamic var overall50 = 0.0
    dynamic var overall = 0.0
    dynamic var workload = 0.0
    dynamic var difficulty = 0.0
    dynamic var searchScore = 0.0
    
    let genEds = List<GenEd>()
    let faculty = List<Faculty>()
    let locations = List<Location>()
    let meetings = List<Meeting>()
    let prerequisites = List<Course>()
    
    var display: Display { get { return Display(course: self) }}
}

class GenEd: Object {
    
    dynamic var name = ""
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

class Faculty: Object {
    
    dynamic var first = ""
    dynamic var middle = ""
    dynamic var last = ""
    dynamic var suffix = ""
    let courses = List<Course>()
}

class Location: Object {
    
    dynamic var type = ""
    dynamic var building = ""
    dynamic var room = ""
    dynamic var course: Course? = nil
}

class Meeting: Object {
    
    dynamic var day = ""
    dynamic var type = ""
    dynamic var optional = false
    dynamic var beginTime = ""
    dynamic var endTime = ""
    dynamic var course: Course? = nil
    var display: Display { get { return Display(meeting: self) }}
}

class Report: Object {
    
    dynamic var term = ""
    dynamic var year = ""
    dynamic var enrollment = 0
    dynamic var comments: [String] = []
    let responses = List<Response>()
    let facultyReports = List<FacultyReport>()
}

class FacultyReport: Object {
    
    dynamic var name = ""
    let responses = List<Response>()
}

class Response: Object {
    
    dynamic var question = ""
    dynamic var breakdown = Breakdown()
    dynamic var baselineSingleTerm = Baseline()
    dynamic var baselineThreeYears = Baseline()
    dynamic var mean = 0.0
    dynamic var median = 0
}

class Breakdown: Object {
    dynamic var one = 0
    dynamic var two = 0
    dynamic var three = 0
    dynamic var four = 0
    dynamic var five = 0
}

class Baseline: Object {
    dynamic var department = 0.0
    dynamic var division = 0.0
    dynamic var group = 0.0
    dynamic var size = 0.0
}