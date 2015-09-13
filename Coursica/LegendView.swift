//
//  LegendView.swift
//  Coursica
//
//  Created by Regan Bell on 9/6/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

class LegendView: UIView {

    var legendBarViews: [LegendBarView] = []
    
    init(titles: [String], colors: [UIColor]) {
        super.init(frame: CGRectZero)
        for (title, color) in zip(titles, colors) {
            let legendBarView = LegendBarView(title: title, color: color)
            addSubview(legendBarView)
            legendBarViews.append(legendBarView)
        }
        
        constrain([self] + legendBarViews, replace: ConstraintGroup(), {views in
            let container = views[0]; let legendViews: [LayoutProxy] = Array(views[1..<views.count])
            for (index, view) in enumerate(legendViews) {
                view.left == container.left
                view.right == container.right
                if index == 0 {
                    view.top == container.top + 25
                } else {
                    view.top == legendViews[index - 1].bottom + 10
                }
            }
            legendViews.last!.bottom == container.bottom
        })
    }

    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
