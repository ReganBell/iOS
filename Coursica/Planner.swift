//
//  Planner.swift
//  Coursica
//
//  Created by Regan Bell on 12/19/15.
//  Copyright © 2015 Prestige Worldwide. All rights reserved.
//

import Foundation
import RealmSwift

@available(iOS 9.0, *)
class Planner {
    
    var realm: Realm!
    var factorChecker: FactorChecker!
    
    // **** CS 182 code starts here!
    // If a factor is unfulfilled, we locate an unused variable and assign it a course from that factor's domain
    func factorMissingMove(schedule: Schedule, result: CheckerResult, move: Move, termUpperBound: TermKey) -> Schedule {
        var variableIndex = result.unusedVariables.randomElement()!
        var domain = factorChecker.domain(variableIndex.termKey)
        var course = move.courses!.randomElement()!
        var variablesTried = 0
        while !variableIndex.termKey.before(termUpperBound) || !domain.contains(course) {
            variableIndex = result.unusedVariables.randomElement()!
            domain = factorChecker.domain(variableIndex.termKey)
            course = move.courses!.randomElement()!
            variablesTried++
            if variablesTried > 10 {
                break
            }
        }
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
        newSchedule.assignCourse(course, index: variableIndex)
        return newSchedule
    }
    
    // If a course is a duplicate, we search through the other moves to find one that wants to assign a course, and assign that course where the duplicate is
    func duplicateCourseMove(schedule: Schedule, result: CheckerResult, move: Move) -> Schedule {
        let duplicateCourse = move.courses!.first!
        var newCourse: Int?
        for suggestedMove in result.suggestedMoves {
            // Look for a prereq or requirement constraint that needs satisfying, replace this duplicate with a course from its domain
            if !(suggestedMove.type == .PrereqMissing || suggestedMove.type == .FactorMissing) {
                continue
            }
            if let moveCourses = suggestedMove.courses {
                for course in moveCourses {
                    if factorChecker.domain(move.index!.termKey).contains(course) && duplicateCourse != course {
                        newCourse = course
                        break
                    }
                }
                if newCourse != nil { break }
            }
        }
        let course = newCourse ?? factorChecker.domain(move.index!.termKey).randomElement()
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
        newSchedule.assignCourse(course, index: move.index!)
        return newSchedule
    }
    
    func variableWithTerm(term: Int, variables: [VariableIndex]) -> VariableIndex? {
        for variable in variables {
            if variable.termKey == orderedVariableKeys[term] {
                return variable
            }
        }
        return nil
    }
    
    // Find a random term between the current term and the beginning or end of the schedule depending on whch direction we are moving
    func targetTerm(current: Int, cap: Int) -> Int {
        let range = arc4random() % UInt32(abs(cap - current))
        let negative = current > cap ? -1 : 1
        return current + negative * Int(range)
    }
    
    // Move a course (could be a prereq, or a course that has a prereq) forward or backward so that the preq will be behind the course that needs it and the constraint will no longer be violated
    func movePrereqMove(schedule: Schedule, result: CheckerResult, move: Move, forward: Bool) -> Schedule {
        
        let courseToMove = move.courses!.first!
        let courseToMoveIndex = orderedVariableKeys.indexOf(move.index!.termKey)!
        let cap = forward ? orderedVariableKeys.count - 1 : 0
        // If a course is at the beginning of schedule, we can't move it earlier; likewise if it is at the end
        if courseToMoveIndex == cap { return schedule }
        var destinationTerm = self.targetTerm(courseToMoveIndex, cap: cap)
        var destinationVariable = variableWithTerm(destinationTerm, variables: result.unusedVariables) ?? variableWithTerm(destinationTerm, variables: [0, 1, 2, 3].map { return VariableIndex(termKey: orderedVariableKeys[destinationTerm], index: $0) })!
        var swapCourse = schedule.variable(destinationVariable.termKey).assignment[destinationVariable.index]
        var tries = 0
        var index = 0
        while !factorChecker.domain(destinationVariable.termKey).contains(courseToMove) || !factorChecker.domain(move.index!.termKey).contains(swapCourse) {
            destinationTerm = self.targetTerm(courseToMoveIndex, cap: cap)
            if tries < 10 {
                destinationVariable = variableWithTerm(destinationTerm, variables: result.unusedVariables) ?? variableWithTerm(destinationTerm, variables: [0, 1, 2, 3].map { return VariableIndex(termKey: orderedVariableKeys[destinationTerm], index: $0) })!
            } else {
                destinationVariable = VariableIndex(termKey: orderedVariableKeys[destinationTerm], index: index)
                index++; if index == 4 { index = 0 }
            }
            swapCourse = schedule.variable(destinationVariable.termKey).assignment[destinationVariable.index]
            tries++
            if tries > 50 {
                return schedule
            }
        }
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
        newSchedule.assignCourse(move.courses!.first!, index: destinationVariable)
        newSchedule.assignCourse(swapCourse, index: move.index!)
        return newSchedule
    }
    
    func timeConflictMove(schedule: Schedule, result: CheckerResult, move: Move) -> Schedule {
        // Half the time swap the course with a different course, half the time give it a new assignment
        if arc4random() % 2 == 0 {
            return movePrereqMove(schedule, result: result, move: move, forward: (arc4random() % 2) == 0)
        } else {
            return duplicateCourseMove(schedule, result: result, move: move)
        }
    }
    
    // If we have a prereq that's in front or in the same term as the course that needs it, we try to swap them to remedy that
    // If we can directly swap them without violating a domain, we do, otherwise we move them both opposite directions and swap them indirectly
    func swapPrereqMove(schedule: Schedule, result: CheckerResult, move: Move) -> Schedule {
        let prereqIndex = move.index!
        let courseIndex = move.swapIndex!
        let prereq = schedule.variable(prereqIndex.termKey).assignment[prereqIndex.index]
        let course = schedule.variable(courseIndex.termKey).assignment[courseIndex.index]
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
        if factorChecker.domain(courseIndex.termKey).contains(prereq) && factorChecker.domain(prereqIndex.termKey).contains(course) && prereqIndex.termKey != courseIndex.termKey {
            newSchedule.variable(courseIndex.termKey).assignment[courseIndex.index] = prereq
            newSchedule.variable(prereqIndex.termKey).assignment[prereqIndex.index] = course
            return newSchedule
        } else {
            let forwardSchedule = movePrereqMove(schedule, result: result, move: Move(type: .MovePrereq, index: move.index!, swapIndex: move.swapIndex!, courses: [prereq]), forward: false)
            return movePrereqMove(forwardSchedule, result: result, move: Move(type: .MovePostReq, index: move.swapIndex!, swapIndex: move.index!, courses: [course]), forward: true)
        }
    }
    
    // Find a low Q score course and replace it with a high qscore course
    func qScoreReplaceMove(schedule: Schedule, move: Move) -> Schedule {
        let variableIndex = move.index!
        let domain = factorChecker.sortedDomain(variableIndex.termKey)
        var course = -1; var continuePickingExpo = true; var i = 0
        while continuePickingExpo {
            // Bias towards high-ranked domain values by exponentially decaying probability of selection, but still maintain a low probability that any given course is picked
            if arc4random() % 3 == 0 || i == domain.count - 1 {
                course = domain[i]
                continuePickingExpo = false
            } else {
                i++
            }
        }
        let oldCourse = move.courses!.first!
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
        newSchedule.assignCourse(course, index: variableIndex)
        return newSchedule
    }
    
    // Generate a successor based on a move selected uniformly at random
    func generateSuccessor(schedule: Schedule, result: CheckerResult) -> Schedule {
        var newSchedule: Schedule? = nil
        if let move = result.suggestedMoves.randomElement() {
            switch move.type {
            case .FactorMissing: newSchedule = factorMissingMove(schedule, result: result, move: move, termUpperBound: .All)
            case .MovePrereq: newSchedule = movePrereqMove(schedule, result: result, move: move, forward: false)
            case .MovePostReq: newSchedule = movePrereqMove(schedule, result: result, move: move, forward: true)
            case .SwapPrereq: newSchedule = swapPrereqMove(schedule, result: result, move: move)
            case .TimeConflict: newSchedule = timeConflictMove(schedule, result: result, move: move)
            case .PrereqMissing: newSchedule = factorMissingMove(schedule, result: result, move: move, termUpperBound: move.index!.termKey)
            case .DuplicateCourse: newSchedule = duplicateCourseMove(schedule, result: result, move: move)
            case .WorkloadSwap: newSchedule = swapPrereqMove(schedule, result: result, move: move)
            case .QScoreReplace: newSchedule = qScoreReplaceMove(schedule, move: move)
            }
        }
        return newSchedule!
    }
    
    // Used for evaluating difference between initial assignment that is biased towards a solution
    func randomSchedule() -> Schedule {
        let schedule = Schedule(copy: nil, assignment: nil, realm: realm)
        for termKey in orderedVariableKeys {
            let domain = factorChecker.domain(termKey)
            let variable = schedule.variable(termKey)
            while variable.assignment.count < 4 {
                variable.assignment.append(domain.randomElement())
            }
        }
        return schedule
    }
    
    func solveSchedule() {
        let config = Realm.Configuration(
            // Get the path to the bundled file
            path: NSBundle.mainBundle().pathForResource("seed", ofType:"realm"),
            // Open the file in read-only mode as application bundles are not writeable
            readOnly: true)
        
        // Open the Realm with the configuration
        realm = try! Realm(configuration: config)
        
        // Initialize factor domains and factor checker
        self.factorChecker = FactorChecker(realm: realm)
        var searchSchedule = factorChecker.initialAssignment()
        var oldResult = factorChecker.analyze(searchSchedule, shouldPrint: true)
        var schedulesExplored = 1
        NSLog("Starting")
        while oldResult.conflicts > 0 {
            schedulesExplored++
            let successor = generateSuccessor(searchSchedule, result: oldResult)
            let newResult = factorChecker.analyze(successor, shouldPrint: false)
            if oldResult.conflicts >= newResult.conflicts && oldResult.averageQScore - 5 <= newResult.averageQScore && oldResult.highestWorkloadDeviation >= newResult.highestWorkloadDeviation - 0.05 {
                if oldResult.conflicts > newResult.conflicts {
                    print("\(oldResult.conflicts)->\(newResult.conflicts) \(oldResult.averageQScore)->\(newResult.averageQScore) \(oldResult.highestWorkloadDeviation)->\(newResult.highestWorkloadDeviation) in \(schedulesExplored) steps\n\n")
                    factorChecker.printSchedule(searchSchedule)
                }
                oldResult = newResult
                searchSchedule = successor
            }
            
            if schedulesExplored % 1000 == 0 {
                searchSchedule = factorChecker.initialAssignment()
                oldResult = factorChecker.analyze(searchSchedule, shouldPrint: false)
            }
        }
        NSLog("Done")
        
        // *** CS 182 code ends here!
    }
}