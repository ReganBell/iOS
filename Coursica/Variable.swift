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
    var assignment: [String]  = []
//    let domain: Results<Course>
    var conflicts = 0
    init(assignment: [String]) {//, domain: Results<Course>) {
        self.assignment = assignment
//        self.domain = domain
    }
    var description: String {
        return assignment.map({ return "    \($0)" }).joinWithSeparator("\n")
    }
    func copy(without: String?) -> Variable {
        if let without = without {
            return Variable(assignment: assignment)//, domain: domain.filter("title != '\(without.title)'"))
        } else {
            return Variable(assignment: assignment)//, domain: domain)
        }
    }
}