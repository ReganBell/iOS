//
//  Containers+RandomElement.swift
//  Coursica
//
//  Created by Regan Bell on 12/19/15.
//  Copyright © 2015 Prestige Worldwide. All rights reserved.
//

import Foundation

extension Array {
    func randomElement() -> Element? {
        if count == 0 { return nil }
        return self[Int(arc4random() % UInt32(count))]
    }
}

extension Set {
    func randomElement() -> Element {
        let n = Int(arc4random_uniform(UInt32(count)))
        let i = startIndex.advancedBy(n)
        return self[i]
    }
}