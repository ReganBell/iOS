//
//  File.swift
//  Coursica
//
//  Created by Regan Bell on 7/14/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import RealmSwift

let stopWords: Set<String> =  ["I","a","about","an","are","as","at","be","by","com","for","from","how","in","is","it","of","on","or","that","the","this","to","was","what","when","where","who","will","with","the","www"]

enum IndexType {
    case Title, Field, Number
}

struct SearchHit {
    var term = ""
    var course: Course?
    var scoreAdd = 0.0
}

extension NSRegularExpression {
    
    convenience init?(pattern: String) {
        self.init(pattern: pattern, options: NSRegularExpressionOptions.allZeros, error: NSErrorPointer())
    }
    
    func firstMatchInWholeString(string: String) -> String? {
        let matches = self.matchesInString(string, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(string)))
        if let first = matches.first as? NSTextCheckingResult {
            return (string as NSString).substringWithRange(first.range)
        }
        return nil
    }
}

class Search: NSObject {
    
    static let shared = Search()
    var courseCount = 0.0
    var titleIndex = Index(type: .Title)
    var fieldIndex = Index(type: .Field)
    var numberIndex = Index(type: .Number)
    var _commonAbbreviations: [String: String]? = nil
    var commonAbbreviations: [String: String] {
        get {
            if self._commonAbbreviations == nil {
                var abbreviations: [String: String] = Dictionary<String, String>()
                let rawShortFields = NSString(contentsOfFile: "ShortFields", encoding: NSUTF8StringEncoding, error: NSErrorPointer())
                let rawLongFields = NSString(contentsOfFile: "LongFields", encoding: NSUTF8StringEncoding, error: NSErrorPointer())
                let shortFields = rawShortFields!.componentsSeparatedByString(",\n")
                let longFields = rawLongFields!.componentsSeparatedByString(",\n")
                for (index, longField) in enumerate(longFields) {
                    let shortField = shortFields[index] as! String
                    abbreviations[shortField.lowercaseString] = longField.lowercaseString;
                }
                let common =   ["cs":    "computer science",
                                "ec":    "economics",
                                "cb":    "culture and belief",
                                "ai":    "aesthetic and interpretive understanding",
                                "aiu":   "aesthetic and interpretive understanding",
                                "astro": "astronomy",
                                "bio":   "biology",
                                "lit":   "literature",
                                "comp":  "computer comparative",
                                "sci":   "science",
                                "em":    "empirical and mathematical reasoning",
                                "eps":   "earth and planetary sciences",
                                "es":    "engineering sciences",
                                "er":    "ethical reasoning",
                                "pol":   "policy politics",
                                "hum":   "humanities",
                                "hist":  "history",
                                "kor":   "korean",
                                "lat":   "latin",
                                "med":   "medical",
                                "sls":   "science of living systems",
                                "spu":   "science of the physical universe",
                                "syst":  "systems",
                                "usw":   "united states in the world",
                                "ls":    "life sciences"]
                for (key, value) in common {
                    abbreviations[key] = value
                }
                self._commonAbbreviations = abbreviations
            }
            return _commonAbbreviations!
        }
    }
    
    func buildIndex(courses: [Course]) {
        
        for course in courses {
            
            titleIndex.addField(course.title, fromCourse: course)
            fieldIndex.addField(course.longField, fromCourse: course)
            if course.integerNumber > 0 {
                numberIndex.addField("\(course.integerNumber)", fromCourse: course)
            }
            numberIndex.addField(course.number, fromCourse: course)
        }
        [titleIndex, fieldIndex, numberIndex].map({ index in index.calculateIDFs(courses.count) })
    }
    
    func assignScoresForSearch(search: String) {
        self.clearSearchScores()
        let searchTerms = self.explodeSearch(search)
        //TODO: do a weaker match for word stems using NSLinguisticTagger
        var results: [SearchHit] = []
        var weights: [(Index, Double)]
        if let numbers = NSRegularExpression(pattern: "[0-9]+")?.firstMatchInWholeString(search) {
            weights = [(titleIndex, 0.3), (fieldIndex, 0.6), (numberIndex, 0.6)]
        } else {
            weights = [(titleIndex, 0.3), (fieldIndex, 0.3), (numberIndex, 0.3)]
        }
        weights.map({ (index, weight) in self.searchIndex(index, terms: searchTerms, zoneWeight: weight, results: results) })
        //Debug search with: print("\(results)")
    }
    
    func searchIndex(index: Index, terms: [String], zoneWeight: Double, var results: [SearchHit]) {
        for term in terms {
            if let entry = index.terms[term] {
                let maxIDF = log(self.courseCount / 1.0)
                let normalizeFactor = 1.0 / maxIDF
                let normalizedScore = entry.idf * normalizeFactor
                let zonedScore = zoneWeight * normalizedScore
                for course in entry.courses {
                    course.searchScore += zonedScore
                    results.append(SearchHit(term: term, course: course, scoreAdd: zonedScore))
                }
            }
        }
    }
    
    func explodeSearch(search: String) -> [String] {
        var searchTerms = search.componentsSeparatedByString(" ")
        var count = searchTerms.count;
        var index: Int
        for index = 0; index < count; index++ {
            let term = searchTerms[index]
            if let squish = NSRegularExpression(pattern: "[a-zA-Z]+[0-9]+")?.firstMatchInWholeString(term) {
                let word = NSRegularExpression(pattern: "[a-zA-Z]+")!.firstMatchInWholeString(squish)
                let rest = term.stringByReplacingOccurrencesOfString(word!, withString: "")
                searchTerms.extend([word!, rest])
                count++
                index--
            }
            if let expansion = self.commonAbbreviations[term.lowercaseString] {
                let newTerms = expansion.componentsSeparatedByString(" ")
                searchTerms.removeAtIndex(index)
                count--
                for newTerm in newTerms {
                    searchTerms .insert(newTerm, atIndex: index)
                    index++
                    count++
                }
            }
        }
        return searchTerms
    }
    
    func clearSearchScores() {
        let courses = Realm().objects(Course)
        for course in courses {
            course.searchScore = 0
        }
    }
}
