//
//  LegendBarView.swift
//  Coursica
//
//  Created by Regan Bell on 9/6/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import Cartography

class LegendBarView: UIView {

    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
    let titleLabel = UILabel()
    
    init(title: String, color: UIColor) {
        super.init(frame: CGRectZero)
        backgroundColor = UIColor.whiteColor()
        opaque = true
        
        circleView.backgroundColor = color
        circleView.layer.cornerRadius = 8
        addSubview(circleView)
        
        titleLabel.text = title
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.backgroundColor = UIColor.whiteColor()
        titleLabel.opaque = true
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        addSubview(titleLabel)
        
        constrain(self, circleView, titleLabel, block: {container, circle, title in
            circle.left == container.left
            circle.width == 16
            circle.height == 16
            circle.centerY == container.centerY
            title.top == container.top
            title.left == circle.right + 10
            title.right == container.right
            container.height == 20
        })
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
