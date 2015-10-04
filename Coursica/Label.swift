//
//  Label.swift
//  Coursica
//
//  Created by Regan Bell on 9/7/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class Label: UILabel {

    init(text: String, font: UIFont, color: UIColor) {
        super.init(frame: CGRectZero)
        self.text = text
        self.font = font
        textColor = color
        backgroundColor = UIColor.whiteColor()
        opaque = true
        numberOfLines = 0
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
