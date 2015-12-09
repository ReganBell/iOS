//
//  FactorChecker.swift
//  CoursicaMac
//
//  Created by Regan Bell on 12/1/15.
//  Copyright © 2015 Prestige Worldwide. All rights reserved.
//

import Foundation
import RealmSwift
import GameKit

enum MoveType {
    case DuplicateCourse, FactorMissing, SwapPrereq, MovePrereq, MovePostReq, PrereqMissing
}

struct Move {
    let type: MoveType
    let index: VariableIndex?
    let swapIndex: VariableIndex?
    let courses: [String]?
}

private extension Course {
    func between(lower: Int, upper: Int) -> Bool {
        return integerNumber >= lower && integerNumber <= upper
    }
    func numberedIn(numbers: [Int]) -> Bool {
        return numbers.indexOf(integerNumber) != nil
    }
    func namedIn(titles: [String]) -> Bool {
        for title in titles {
            let splitTitle = title.componentsSeparatedByString("~")
            if shortField == splitTitle.first! && number == splitTitle.last! {
                return true
            }
        }
        return false
    }
}

let allGenEds: [String: String] = ["AESTH&INTP":  "Aesthetic and Interpretive Understanding",
    "CULTR&BLF":  "Culture and Belief",
    "E&M-REASON": "Empirical and Mathematical Reasoning",
    "ETH-REASON": "Ethical Reasoning",
    "SCI-LIVSYS": "Science of Living Systems",
    "SCI-PHYUNV": "Science of the Physical Universe",
    "SOC-WORLD":  "Societies of the World",
    "US-WORLD":   "United States in the World",
    "SOP": "Study of the Past"]

func genEdFactor(genEd: String) -> Factor {
    return Factor(name: genEd, count: 1, validTerm: nil) { return $0.shortField == genEd || $0.genEds.indexOf(GenEd(name: allGenEds[genEd]!)) != nil }
}

struct VariableIndex {
    let termKey: TermKey
    let index: Int
}

struct CheckerResult {
    var conflicts: Int
    var unusedVariables: [VariableIndex]
    var suggestedMoves: [Move]
}

@available(iOS 9.0, *)
class FactorChecker {
    
    var freshmanFallCourses: Set<String> = []
    var freshmanSpringCourses: Set<String> = []
    var upperClassmanFallCourses: Set<String> = []
    var upperClassmanSpringCourses: Set<String> = []
    
    let basicPrep: Factor
    let multivariable: Factor
    let linearAlgebra: Factor
    let basicSoftware: Factor
    let cs121: Factor
    let theory: Factor
    let electives: Factor
    let concentrationFactors: [Factor]
    let aiu: Factor
    let cb: Factor
    let er: Factor
    let em: Factor
    let spu: Factor
    let sls: Factor
    let sow: Factor
    let usw: Factor
    let sop: Factor
    let expos: Factor
    let genEdFactors: [Factor]
    let factors: [Factor]
    let reverseFactors: [Factor]
    let realm: Realm
    var flipFactorOrder = false
    var prerequisites = Dictionary<String, Set<String>>()
    var prerequisiteStrings = Dictionary<String, String>()
    
    // Per run globals
    var coursesSeen: Set<String> = []
    var unusedVariables: [VariableIndex] = []
    var suggestedMoves = [Move]()
    var conflicts = 0
    var shouldPrint = false
    var termPrecedingCourses = Dictionary<TermKey, Dictionary<String, VariableIndex>>()
    var factorCourseTitles = [[String]]()
    
    init(realm: Realm) {
        
        let allCourses = realm.objects(Course).filter(NSPredicate(format: "graduate = false AND enrollment > 10", false, 10)).sorted("percentileSize", ascending: false)//.map() { return $0.title }
        for course in allCourses.filter(NSPredicate(format: "term != %@", "SPRING")).sorted("percentileSize", ascending: false) {
            freshmanFallCourses.insert(course.displayTitle)
            if course.shortField != "EXPOS" && course.shortField != "FRSEMR" {
                upperClassmanFallCourses.insert(course.displayTitle)
            }
        }
        for course in allCourses.filter(NSPredicate(format: "term != %@", "FALL")).sorted("percentileSize", ascending: false) {
            freshmanSpringCourses.insert(course.displayTitle)
            if course.shortField != "EXPOS" && course.shortField != "FRSEMR" {
                upperClassmanSpringCourses.insert(course.displayTitle)
            }
        }
        
        self.expos = Factor(name: "Expos", count: 1, validTerm: { return $0.containsString("Freshman") }) { return $0.shortField == "EXPOS" }
        
        self.basicPrep = Factor(name: "Basic Math", count: 2, validTerm: nil) { return $0.namedIn([("MATH~1a"), ("MATH~1b")]) }
        self.multivariable = Factor(name: "Math 21a", count: 1, validTerm: nil) { return $0.namedIn(["MATH~21a",]) }
        self.linearAlgebra = Factor(name: "Math 21b", count: 1, validTerm: nil) { return $0.namedIn(["MATH~21b"]) }
        self.basicSoftware = Factor(name: "Basic Software", count: 2, validTerm: nil) { return $0.namedIn(["COMPSCI~50", "COMPSCI~51", "COMPSCI~61"]) }
        self.cs121 = Factor(name: "CS 121", count: 1, validTerm: nil) { return $0.namedIn(["COMPSCI~121"]) }
        self.theory = Factor(name: "Theory", count: 1, validTerm: nil) { return $0.shortField == "COMPSCI" && ($0.between(120, upper: 129) || $0.between(220, upper: 229)) && $0.number != "121" }
        self.electives = Factor(name: "Electives", count: 4, validTerm: nil) { return $0.shortField == "COMPSCI" || $0.namedIn(["STAT~110", "MATH~154", "APMTH~106", "APMTH~107", "APMTH~120", "APMTH~121", "ENG-SCI 50"]) }
        self.concentrationFactors = [basicPrep, multivariable, linearAlgebra, basicSoftware, cs121, theory, electives]
        
        self.realm = realm
        
        self.aiu = genEdFactor("AESTH&INTP")
        self.cb = genEdFactor("CULTR&BLF")
        self.er = genEdFactor("E&M-REASON")
        self.em = genEdFactor("ETH-REASON")
        self.spu = genEdFactor("SCI-PHYUNV")
        self.sls = genEdFactor("SCI-LIVSYS")
        self.sow = genEdFactor("SOC-WORLD")
        self.usw = genEdFactor("US-WORLD")
        self.sop = genEdFactor("SOP")
        self.genEdFactors = [aiu, cb, er, em, spu, sls, usw, sow]
        self.factors = [expos] + concentrationFactors + genEdFactors
        self.reverseFactors = [expos] + concentrationFactors + genEdFactors.reverse()
        for course in realm.objects(Course) {
            var prereqs: Set<String> = []
            let displayTitle = course.displayTitle
            for prereq in course.prerequisites {
                prereqs.insert(prereq.displayTitle)
            }
            if displayTitle == "COMPSCI 61 - Systems Programming and Machine Organization" {
                prereqs.insert("COMPSCI 50 - Introduction to Computer Science I")
            }
            self.prerequisites[displayTitle] = prereqs
            self.prerequisiteStrings[displayTitle] = course.prerequisitesString
        }
    }
    
    func requirementsEliminationList(schedule: Schedule) -> [(String, VariableIndex)] {
        var list: [(String, VariableIndex)] = []
        for termKey in orderedVariableKeys {
            for (i, courseTitle) in schedule.variable(termKey).assignment.enumerate() {
                list.append((courseTitle, VariableIndex(termKey: termKey, index: i)))
            }
        }
        return list
    }
    
    func termPrecedingCourses(schedule: Schedule) -> Dictionary<TermKey, Dictionary<String, VariableIndex>> {
        let orderedTermKeys = orderedVariableKeys + [.All]
        var termPrecedingCourses = Dictionary<TermKey, Dictionary<String, VariableIndex>>()
        for (j, termKey) in orderedTermKeys.enumerate() {
            var i = 0
            var termDictionary = Dictionary<String, VariableIndex>()
            while i < j {
                let termKey = orderedTermKeys[i]
                for (index, courseTitle) in schedule.variable(termKey).assignment.enumerate() {
                    termDictionary[courseTitle] = VariableIndex(termKey: termKey, index: index)
                }
                i++
            }
            termPrecedingCourses[termKey] = termDictionary
        }
        return termPrecedingCourses
    }
    
    func domain(termKey: TermKey) -> Set<String> {
        switch termKey {
        case .FreshmanFall: return freshmanFallCourses
        case .FreshmanSpring: return freshmanSpringCourses
        default: return termKey.rawValue.containsString("Spring") ? upperClassmanSpringCourses : upperClassmanFallCourses
        }
    }
    
    func initialAssignment(delegate: AppDelegate) -> Schedule {
        let unfixedVariables = orderedVariableKeys
        var scrambledGenEds = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(self.genEdFactors) as! [Factor]
        let schedule = Schedule(copy: nil, assignment: nil, realm: realm)
        for (i, termKey) in unfixedVariables.enumerate() {
            let domain = self.domain(termKey)
            let variable = schedule.variable(termKey)
            if let genEd = scrambledGenEds.popLast() {
                var i = 0
                var genEdCourse = genEd.rankedPossible[i]
                while self.domain(termKey).contains(genEdCourse) {
                    i++
                    genEdCourse = genEd.rankedPossible[i]
                }
                variable.assignment.append(genEdCourse)
            }
            var j = 0; var k = 0
            var concentrationCourse = concentrationFactors[(i + k) % concentrationFactors.count].rankedPossible[j]
            while !self.domain(termKey).contains(concentrationCourse) {
                j++
                if j == concentrationFactors[(i + k) % concentrationFactors.count].rankedPossible.count {
                    j = 0
                    k++
                }
                concentrationCourse = concentrationFactors[(i + k) % concentrationFactors.count].rankedPossible[j]
            }
            variable.assignment.append(concentrationCourse)
            while variable.assignment.count < 4 {
                variable.assignment.append(domain.randomElement())
            }
        }
        return schedule
    }
    
    func checkIfSeen(title: String, index: VariableIndex) -> Bool {
        if coursesSeen.contains(title) {
            suggestedMoves.append(Move(type: .DuplicateCourse, index: index, courses: [title]))
            conflicts++
            if shouldPrint { print("Already seen \(title)") }
            return true
        } else {
            coursesSeen.insert(title)
            return false
        }
    }
    
    func wipeGlobalVariables() {
        coursesSeen = []
        unusedVariables = []
        suggestedMoves = [Move]()
        conflicts = 0
        shouldPrint = false
        termPrecedingCourses = Dictionary<TermKey, Dictionary<String, VariableIndex>>()
        factorCourseTitles = factors.map() { _ in return [String]() }
    }
    
    func checkPrerequisite(title: String, index: VariableIndex) {
        if let prereqs = prerequisites[title] where prereqs.count > 0 {
            for prereq in prereqs {
                if let prereqVarIndex = termPrecedingCourses[.All]![prereq] {
                    if termPrecedingCourses[index.termKey]![prereq] == nil {
                        // If prereq exists in the schedule but after or in same term as this course, move prereq backward and course forward
                        suggestedMoves.append(Move(type: .SwapPrereq, index: prereqVarIndex, swapIndex: index, courses: [prereq]))
                        suggestedMoves.append(Move(type: .MovePrereq, index: prereqVarIndex, swapIndex: index, courses: [prereq]))
                        suggestedMoves.append(Move(type: .MovePostReq, index: index, swapIndex: prereqVarIndex, courses: [title]))
                        if shouldPrint { print("Prereq \(prereq) is not before \(title) – will try to swap") }
                        conflicts++
                    } else {
                        // If prereq exists and it's before this course then we're good!
                    }
                } else {
                    //If prereq is missing
                    if shouldPrint { print("\(index.termKey.rawValue) – \(title) missing prereq \(prereq)") }
                    suggestedMoves.append(Move(type: .PrereqMissing, index: index, swapIndex: nil, courses: [prereq]))
                    unusedVariables.append(index)
                    conflicts++
                }
            }
        }
    }
    
    func checkCourseSatisfiesFactors(title: String, index: VariableIndex, factors: [Factor]) {
        var usedAsRequirement = false
        for (i, factor) in factors.enumerate() {
            if factor.allPossible.contains(title) {
                checkPrerequisite(title, index: index)
                factorCourseTitles[i].append(title)
                usedAsRequirement = factorCourseTitles[i].count <= factor.count
                break
            }
        }
        if !usedAsRequirement {
            unusedVariables.append(index)
        }
    }
    
    func checkFactorsSatisfied(factors: [Factor]) {
        for (i, factor) in factors.enumerate() {
            let titles = factorCourseTitles[i]
            if titles.count < factor.count {
                if shouldPrint { print("\(factor.name) conflict. Have \(titles)\nNeed \(factor.count - titles.count) more.") }
                suggestedMoves.append(Move(type: .FactorMissing, index: nil, swapIndex: nil, courses: factor.rankedPossible))
                conflicts++
            }
        }
    }

    func conflictsAndFreeVariables(schedule: Schedule, shouldPrint: Bool) -> CheckerResult {
        wipeGlobalVariables()
        flipFactorOrder = !flipFactorOrder
        self.shouldPrint = shouldPrint
        let factors = flipFactorOrder ? reverseFactors : self.factors
        termPrecedingCourses = termPrecedingCourses(schedule)
        for (courseTitle, variableIndex) in requirementsEliminationList(schedule) {
            if checkIfSeen(courseTitle, index: variableIndex) {
                continue
            }
            checkCourseSatisfiesFactors(courseTitle, index: variableIndex, factors: factors)
        }
        checkFactorsSatisfied(factors)
        return CheckerResult(conflicts: conflicts, unusedVariables: unusedVariables, suggestedMoves: suggestedMoves)
    }
}