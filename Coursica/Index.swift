//
//  Index.swift
//  Coursica
//
//  Created by Regan Bell on 7/14/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import RealmSwift

class Entry {
    var n = 0
    var courses: [Course] = []
    var idf = 0.0
}

class Index: NSObject {
   
    var type: IndexType
    var terms: [String: Entry] = Dictionary<String, Entry>()
    
    init(type: IndexType) {
        self.type = type
    }
    
    func addField(field: String, fromCourse course: Course) {
        let tokens = FastTokenizer.tokensFromString(field.lowercaseString) as! [String]
        for token in tokens {
            if stopWords.contains(token) {
                continue
            } else {
                if token == "10" {
                    
                }
                if let termEntry = terms[token] {
                    termEntry.n++
                    termEntry.courses.append(course)
                    terms[token] = termEntry
                } else {
                    let termEntry = Entry()
                    termEntry.n = 1
                    termEntry.courses = [course]
                    terms[token] = termEntry
                }
            }
        }
    }
    
    func calculateIDFs(totalCourses: Int) {
        for (term, entry) in terms {
            entry.idf = log(Double(totalCourses) / Double(entry.n))
        }
    }
}
