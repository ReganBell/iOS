//
//  Display.swift
//  Coursica
//
//  Created by Regan Bell on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import RealmSwift

class Display: NSObject {
    
    var course: Course?
    var meeting: Meeting?
    var title: String { get {
        if course != nil {
            return "\(course!.shortField) \(course!.number) - \(course!.title)"
        } else {
            return self.standardTime(meeting!.beginTime) + "-" + self.standardTime(meeting!.endTime)
        }
        }}
    var serverTitle: String { get {
            return "\(course!.shortField) \(course!.number): \(course!.title)".encodedAsFirebaseKey()
        }}
    var genEds: String {
        get {
            if course!.genEds.count == 0 {
                return "None"
            } else {
                var string = ""
                for genEd in course!.genEds {
                    string += (string.isEmpty ? "":", ") + genEd.name
                }
                    return string
            }
        }
    }
    var locations: String {
        get {
            if course!.locations.count == 0 {
                return "TBD"
            } else {
                var string = ""
                for location in course!.locations {
                    let locationString = location.building + " " + location.room
                    string += (string.isEmpty ? "":", ") + locationString
                }
                return string
            }
        }
    }
    var faculty: String {
        get {
            if course!.faculty.count == 0 {
                return "TBD"
            } else {
                var string = ""
                for faculty in course!.faculty {
                    if !faculty.last.isEmpty {
                        string += (string.isEmpty ? "":", ") + faculty.first + " " + faculty.last
                    }
                }
                return string
            }
        }
    }
    var meetings: String {
        get {
            if course!.meetings.count == 0 {
                return "TBD"
            } else {
                let meetings = course!.meetings.sorted("day", ascending: true)
                var string = ""
                for meeting in meetings {
                    if !meeting.day.isEmpty {
                        string += (string.isEmpty ? "":", ") + self.abbreviatedString(meeting.day) + "s"
                    }
                }
                let last = meetings.last! as Meeting
                string += (" from " + last.display.title)
                return string
            }
        }
    }
    var enrollmentSource: String {
        get {
            let key = Key(string: course!.enrollmentSource)
            return "(in \(key.term.capitalizedString) \(key.year))"
        }
    }
    
    func abbreviatedString(dayNumber: String) -> String {
        switch dayNumber {
            case "0": return "Sunday"
            case "1": return "Monday"
            case "2": return "Tuesday"
            case "3": return "Wednesday"
            case "4": return "Thursday"
            case "5": return "Friday"
            case "6": return "Saturday"
            default: return ""
    }
    }
    
    func standardTime(militaryTime: String) -> String {
        let components = militaryTime.componentsSeparatedByString(":")
        let rawHours = components[0]
        let rawMinutes = components[1]
        let minutes = (rawMinutes as NSString).integerValue == 0 ? "" : ":" + rawMinutes
        let intHours = (rawHours as NSString).integerValue
        let hours = intHours > 12 ? "\(intHours - 12)" : rawHours
        return "\(hours)\(minutes)"
    }
    
    init(meeting: Meeting) {
        self.meeting = meeting
    }
    
    init(course: Course) {
        self.course = course
    }
}