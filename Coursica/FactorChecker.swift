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
    case DuplicateCourse, FactorMissing, SwapPrereq, MovePrereq, MovePostReq, PrereqMissing, TimeConflict, WorkloadSwap, QScoreReplace
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
    var highestWorkloadDeviation: Double
    var averageQScore: Double
}

@available(iOS 9.0, *)
class FactorChecker {
    
    var freshmanFallSorted: [String] = []
    var freshmanSpringSorted: [String] = []
    var upperClassmanFallSorted: [String] = []
    var upperClassmanSpringSorted: [String] = []
    
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
    var workloads = Dictionary<String, Double>()
    var qScores = Dictionary<String, Double>()
    var meetings = Dictionary<String, List<Meeting>>()
    var termsTimeChecked = Set<TermKey>()
    var highestWorkloadDeviation = 0.0
    var averageQScore = 0.0
    
    init(realm: Realm) {
        
        let allCourses = realm.objects(Course).filter(NSPredicate(format: "graduate = false AND enrollment > 10", false, 10)).sorted("percentileSize", ascending: false)//.map() { return $0.title }
        for course in allCourses.filter(NSPredicate(format: "term != %@", "SPRING")).sorted("percentileSize", ascending: false) {
            freshmanFallCourses.insert(course.displayTitle)
            freshmanFallSorted.append(course.displayTitle)
            if course.shortField != "EXPOS" && course.shortField != "FRSEMR" {
                upperClassmanFallCourses.insert(course.displayTitle)
                upperClassmanFallSorted.append(course.displayTitle)
            }
        }
        for course in allCourses.filter(NSPredicate(format: "term != %@", "FALL")).sorted("percentileSize", ascending: false) {
            freshmanSpringCourses.insert(course.displayTitle)
            freshmanSpringSorted.append(course.displayTitle)
            if course.shortField != "EXPOS" && course.shortField != "FRSEMR" {
                upperClassmanSpringCourses.insert(course.displayTitle)
                upperClassmanSpringSorted.append(course.displayTitle)
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
            self.workloads[displayTitle] = course.workload
            self.qScores[displayTitle] = course.overall
            self.prerequisites[displayTitle] = prereqs
            self.prerequisiteStrings[displayTitle] = course.prerequisitesString
            self.meetings[displayTitle] = course.meetings
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
    
    func sortedDomain(termKey: TermKey) -> [String] {
        switch termKey {
        case .FreshmanFall: return freshmanFallSorted
        case .FreshmanSpring: return freshmanSpringSorted
        default: return termKey.rawValue.containsString("Spring") ? upperClassmanSpringSorted : upperClassmanFallSorted
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
    
    func meetingsDoConflict(a: Meeting, b: Meeting) -> Bool {
        if a.day != b.day {
            return false
        }
        let aStartInt = intFromMilitaryTime(a.beginTime)
        let aEndInt  = intFromMilitaryTime(a.endTime)
        let bStartInt = intFromMilitaryTime(b.beginTime)
        let bEndInt   = intFromMilitaryTime(b.endTime)
        if aStartInt == bStartInt && aEndInt == bEndInt {
            return true
        } else if aStartInt >= bStartInt && aStartInt < bEndInt {
            return true
        } else if aEndInt > bStartInt && aEndInt <= bEndInt {
            return true
        }
        return false
    }
    
    func intFromMilitaryTime(var militaryTime: String) -> Int {
        
        let spaceComponents = militaryTime.componentsSeparatedByString(" ")
        if spaceComponents.count > 1 {
            militaryTime = spaceComponents[1]
        }
        
        let components = militaryTime.componentsSeparatedByString(":")
        let rawHours = components[0] as NSString
        if components.count > 1 {
            let rawMinutes = components[1] as NSString
            return rawHours.integerValue * 10 + Int(rawMinutes.floatValue / 6.0)
        } else {
            return rawHours.integerValue * 10
        }
    }
    
    func checkIfSeen(title: String, index: VariableIndex) -> Bool {
        if coursesSeen.contains(title) {
            suggestedMoves.append(Move(type: .DuplicateCourse, index: index, swapIndex: nil, courses: [title]))
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
        termsTimeChecked = Set<TermKey>()
        averageQScore = 0.0
        highestWorkloadDeviation = 0.0
    }
    
    func checkPrerequisite(title: String, index: VariableIndex) {
        if let prereqs = prerequisites[title] where prereqs.count > 0 {
            for prereq in prereqs {
                if let prereqVarIndex = termPrecedingCourses[.All]![prereq] {
                    if termPrecedingCourses[index.termKey]![prereq] == nil {
                        // If prereq exists in the schedule but after or in same term as this course, move prereq backward and course forward
                        suggestedMoves.append(Move(type: .SwapPrereq, index: prereqVarIndex, swapIndex: index, courses: [prereq]))
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
        checkPrerequisite(title, index: index)
        for (i, factor) in factors.enumerate() {
            if factor.allPossible.contains(title) {
                factorCourseTitles[i].append(title)
                usedAsRequirement = factorCourseTitles[i].count <= factor.count
                break
            }
        }
        if !usedAsRequirement {
            unusedVariables.append(index)
        }
    }
    
    // fixed variables
    // pivot for prereq swap
    
    func coursesDoConflict(course: String, conflictCourse: String) -> Bool {
        if let courseMeetings = meetings[course], conflictMeetings = meetings[conflictCourse] {
            for potentialConflict in conflictMeetings {
                for courseMeeting in courseMeetings {
                    if meetingsDoConflict(courseMeeting, b: potentialConflict) {
                        if shouldPrint { print("Conflict: \(course) and \(conflictCourse) can't meet at \(courseMeeting.display.title) and \(potentialConflict.display.title)") }
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func sortedWorkloadVar(variable: Variable, ascending: Bool) -> [(String, Double, Int)] {
        var list: [(String, Double, Int)] = []
        for (i, course) in variable.assignment.enumerate() { list.append((course, workloads[course]!, i)) }
        return list.sort() { A, B in let (_, a, _) = A; let (_, b, _) = B; return ascending ? a < b : b < a }
    }
    
    func analyzeTermQScores(courses: [(String, VariableIndex)]) {
        let sorted = courses.sort() { qScores[$0.0] < qScores[$1.0]}
        averageQScore = sorted.reduce(0.0) { return $0 + qScores[$1.0]! } / Double(sorted.count)
        for i in 0..<2 {
            suggestedMoves.append(Move(type: .QScoreReplace, index: sorted[i].1, swapIndex: nil, courses: [sorted[i].0]))
        }
    }
    
    func analyzeTermWorkloads(schedule: Schedule) {
        let variables = orderedVariableKeys.map() { return schedule.variable($0) }
        let variableWorkloads = variables.map() { $0.assignment.reduce(0, combine: { $0 + workloads[$1]! }) }
        let targetAverage = variableWorkloads.reduce(0, combine: +) / 8.0
        var highestWorkload = 0.0; var highestWorkloadVar: Int?
        var lowestWorkload = 9999.0; var lowestWorkloadVar: Int?
        for i in 0..<variables.count {
            let workload = variableWorkloads[i]
            if workload > highestWorkload {
                highestWorkload = workload
                highestWorkloadVar = i
            }
            if workload < lowestWorkload {
                lowestWorkload = workload
                lowestWorkloadVar = i
            }
        }
        let highestSorted = sortedWorkloadVar(variables[highestWorkloadVar!], ascending: false)
        let lowestSorted = sortedWorkloadVar(variables[lowestWorkloadVar!], ascending: true)
        for i in 0..<lowestSorted.count {
            let highest = highestSorted[i]; let lowest = lowestSorted[i]
            if highest.1 > lowest.1 {
                suggestedMoves.append(Move(type: .WorkloadSwap, index: VariableIndex(termKey: orderedVariableKeys[highestWorkloadVar!], index: highest.2), swapIndex: VariableIndex(termKey: orderedVariableKeys[lowestWorkloadVar!], index: lowest.2), courses: [highest.0]))
            } else {
                break
            }
        }
        let highDeviation = abs(highestWorkload - targetAverage); let lowDeviation = abs(lowestWorkload - targetAverage);
        highestWorkloadDeviation = highDeviation > lowDeviation ? highDeviation : lowDeviation
        print("Workloads (absolute, deviation) : \(variableWorkloads.map() { return ($0, $0 - targetAverage) })")
    }
    
    func checkTermForMeetingTimeConflicts(index: VariableIndex, schedule: Schedule) {
        let term = index.termKey
        if termsTimeChecked.contains(term) {
            return
        }
        termsTimeChecked.insert(term)
        let courses = schedule.variable(term).assignment
        for (i, course) in courses.enumerate() {
            for j in (i+1)..<courses.count {
                let conflictCourse = courses[j]
                if coursesDoConflict(course, conflictCourse: conflictCourse) {
                    conflicts++
                    // Randomly choose one of the two conflicting courses to try to move
                    if arc4random() % 2 == 0 {
                        suggestedMoves.append(Move(type: .TimeConflict, index: VariableIndex(termKey: term, index: i), swapIndex: nil, courses: [course]))
                    } else {
                        suggestedMoves.append(Move(type: .TimeConflict, index: VariableIndex(termKey: term, index: j), swapIndex: nil, courses: [conflictCourse]))
                    }
                }
            }
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

    func analyze(schedule: Schedule, shouldPrint: Bool) -> CheckerResult {
        wipeGlobalVariables()
        flipFactorOrder = !flipFactorOrder
        self.shouldPrint = shouldPrint
        let factors = flipFactorOrder ? reverseFactors : self.factors
        termPrecedingCourses = termPrecedingCourses(schedule)
        let courses = requirementsEliminationList(schedule)
        for (courseTitle, variableIndex) in courses {
            if checkIfSeen(courseTitle, index: variableIndex) {
                continue
            }
            checkTermForMeetingTimeConflicts(variableIndex, schedule: schedule)
            checkCourseSatisfiesFactors(courseTitle, index: variableIndex, factors: factors)
        }
        analyzeTermWorkloads(schedule)
        analyzeTermQScores(courses)
        checkFactorsSatisfied(factors)
        return CheckerResult(conflicts: conflicts, unusedVariables: unusedVariables, suggestedMoves: suggestedMoves, highestWorkloadDeviation: highestWorkloadDeviation, averageQScore: averageQScore)
    }
}