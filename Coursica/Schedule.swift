//
//  Schedule.swift
//  CoursicaMac
//
//  Created by Regan Bell on 11/30/15.
//  Copyright © 2015 Prestige Worldwide. All rights reserved.
//

import Foundation
import RealmSwift

enum TermKey: String {
    case FreshmanFall = "Freshman Fall"
    case FreshmanSpring = "Freshman Spring"
    case SophomoreFall = "Sophomore Fall"
    case SophomoreSpring = "Sophomore Spring"
    case JuniorFall = "Junior Fall"
    case JuniorSpring = "Junior Spring"
    case SeniorFall = "Senior Fall"
    case SeniorSpring = "Senior Spring"
    case All = "All"
    func before(key: TermKey) -> Bool {
        if key == .All { return true }
        return orderedVariableKeys.indexOf(self)! < orderedVariableKeys.indexOf(key)!
    }
}

let orderedVariableKeys: [TermKey] = [.FreshmanFall, .FreshmanSpring, .SophomoreFall, .SophomoreSpring, .JuniorFall, .JuniorSpring, .SeniorFall, .SeniorSpring]

class Schedule: CustomStringConvertible {
    let freshmanFall: Variable    
    let freshmanSpring: Variable  
    let sophomoreFall: Variable   
    let sophomoreSpring: Variable 
    let juniorFall: Variable      
    let juniorSpring: Variable    
    let seniorFall: Variable      
    let seniorSpring: Variable
    var variableDict = Dictionary<TermKey, Variable>()
    let realm: Realm
    
    var description: String {
        var variableDescriptions: [String] = []
        for key in orderedVariableKeys {
            variableDescriptions.append("\(key.rawValue)\n\(variable(key))")
        }
        return variableDescriptions.joinWithSeparator("\n")
    }
    
    func assignCourse(title: Int, index: VariableIndex) {
        variable(index.termKey).assignment.removeAtIndex(index.index)
        variable(index.termKey).assignment.insert(title, atIndex: index.index)
    }
    
    init(copy: Schedule?, assignment: String?, realm: Realm) {
        self.realm = realm
        if let copy = copy {
            freshmanFall = copy.freshmanFall.copy(assignment)
            freshmanSpring = copy.freshmanSpring.copy(assignment)
            sophomoreFall = copy.sophomoreFall.copy(assignment)
            sophomoreSpring = copy.sophomoreSpring.copy(assignment)
            juniorFall = copy.juniorFall.copy(assignment)
            juniorSpring = copy.juniorSpring.copy(assignment)
            seniorFall = copy.seniorFall.copy(assignment)
            seniorSpring = copy.seniorSpring.copy(assignment)
        } else {
            freshmanFall =    Variable(assignment: [])
            freshmanSpring =  Variable(assignment: [])
            sophomoreFall =   Variable(assignment: [])
            sophomoreSpring = Variable(assignment: [])
            juniorFall =   Variable(assignment: [])
            juniorSpring = Variable(assignment: [])
            seniorFall =   Variable(assignment: [])
            seniorSpring = Variable(assignment: [])
        }
        let orderedVariables = [freshmanFall, freshmanSpring, sophomoreFall, sophomoreSpring, juniorFall, juniorSpring, seniorFall, seniorSpring]
        for (key, value) in zip(orderedVariableKeys, orderedVariables) { variableDict[key] = value }
    }
    
    func variable(termKey: TermKey) -> Variable {
        return variableDict[termKey]!
    }
}