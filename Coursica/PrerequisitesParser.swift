//
//  PrerequisitesParser.swift
//  Coursica
//
//  Created by Regan Bell on 9/5/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Foundation
import RealmSwift

struct PrerequisiteMatch {
    let range: NSRange
    let course: Course
}

private struct Match: CustomStringConvertible, Hashable {
    let number: Bool
    let range: NSRange
    let match: String
    let field: String
    var description: String {
        return "number: \(number) range: \(range) match: \(match)\n"
    }
    var hashValue: Int {
        return (range.location + 2) * (range.length + 2)
    }
    func intersects(match: Match) -> Bool {
        return NSIntersectionRange(self.range, match.range).length != 0
    }
}

private func ==(lhs: Match, rhs: Match) -> Bool {
    return lhs.range.location == rhs.range.location && lhs.range.length == rhs.range.length
}

struct PrerequisitesParser {
    
    let courseNumberRegEx = NSRegularExpression(pattern: "\\d(\\w?)+")
    
    func processPrerequisiteString(masterCourse: Course) -> [PrerequisiteMatch] {
        
        let source = masterCourse.prerequisitesString.stringByReplacingOccurrencesOfString("/", withString: "") as NSString
        
        let courseNumberMatches = courseNumberRegEx?.matchesInString(source as String, options: NSMatchingOptions(), range: NSMakeRange(0, (source as String).characters.count))
        if courseNumberMatches == nil {
            return []
        }
        
        var unsortedMatches = fieldMatchesInString(source)
        for match in courseNumberMatches! {
            unsortedMatches.append(Match(number: true, range: match.range, match: source.substringWithRange(match.range), field:""))
        }
        
        let sortedByLengthMatches = Array(unsortedMatches).sort({lhs, rhs in lhs.range.length > rhs.range.length})
        var filteredMatches: [Match] = []
        // Sort by length, then de-duplicate intersecting matches
        // If we have intersecting matches on the string "Science of Living Systems" as both "Science of Living Systems" and "Systems"
        // We prefer "Science of Living Systems", the longer match
        for match in sortedByLengthMatches {
            var intersects = false
            for filtered in filteredMatches {
                if filtered.intersects(match) {
                    intersects = true
                    break
                }
            }
            if !intersects {
                filteredMatches.append(match)
            }
        }
        
        // Sort matches by order in the string. Then combine field names with every number that is between them and another field. This way we can match things like "Ec 10a and 10b"
        let sortedMatches = filteredMatches.sort({lhs, rhs in lhs.range.location < rhs.range.location})
        var finalMatches: [PrerequisiteMatch] = []
        for var index = 0; index < sortedMatches.count; index++ {
            let current = sortedMatches[index]
            if current.number == false {
                var nextIndex = index + 1
                while nextIndex < sortedMatches.count {
                    let next = sortedMatches[nextIndex]
                    if next.number == true {
                        let number = next.match
                        var matchCourse: Course? = nil
                        if let matchCourse = try? Realm().objects(Course).filter("longField = %@ && number = %@", current.field, number).first {}
                        else {
                            matchCourse = (try? Realm().objects(Course).filter("shortField = %@ && number = %@", current.match.uppercaseString, number))?.first
                        }
                        var range = next.range
                        if nextIndex - index == 1 {
                            range = NSMakeRange(current.range.location, next.range.location + next.range.length - current.range.location)
                        }
                        if let course = matchCourse where course != masterCourse {
                            finalMatches.append(PrerequisiteMatch(range: range, course: course))
                        }
                    } else {
                        break
                    }
                    nextIndex++
                }
            }
        }
        return finalMatches
    }
    
    private func fieldMatchesInString(source: NSString) -> [Match] {
        var unsortedMatches: [Match] = []
        for (short, long) in Search.shared.commonAbbreviations {
            for field in ["\(short.capitalizedString) ", "\(short.uppercaseString) ", long] {
                let options: NSStringCompareOptions = (field == long) ? .CaseInsensitiveSearch : []
                var range = source.rangeOfString(field, options: options)
                while range.location != NSNotFound {
                    unsortedMatches.append(Match(number: false, range: range, match: source.substringWithRange(range), field: long))
                    let endIndex = range.location + range.length
                    let newRange = NSMakeRange(endIndex, source.length - endIndex)
                    let newString = source.substringWithRange(newRange)
                    range = source.rangeOfString(field, options: options, range: newRange)
                }
            }
        }
        return unsortedMatches
    }
}

