//
//  Variable.swift
//  CoursicaMac
//
//  Created by Regan Bell on 12/1/15.
//  Copyright © 2015 Prestige Worldwide. All rights reserved.
//

import Foundation
import RealmSwift

class Variable: CustomStringConvertible {
    var assignment: [Int]  = []
    var conflicts = 0
    init(assignment: [Int]) {
        self.assignment = assignment
    }
    var description: String {
        return assignment.map({ return "    \($0)" }).joinWithSeparator("\n")
    }
    func copy(without: String?) -> Variable {
        if let without = without {
            return Variable(assignment: assignment)
        } else {
            return Variable(assignment: assignment)
        }
    }
}