//
//  ReportCell.swift
//  Coursica
//
//  Created by Regan Bell on 7/30/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography
import RealmSwift

class ReportCell: UITableViewCell {
    
    let roundedBackgroundView = UIView()
    var titleLabel: Label!
    var responseViews: [ResponseBarView] = []

    func commonSetup() {
        roundedBackgroundView.backgroundColor = UIColor.whiteColor()
        contentView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        roundedBackgroundView.layer.cornerRadius = 4
        roundedBackgroundView.clipsToBounds = true
        contentView.addSubview(roundedBackgroundView)
    }
    
    func layoutTitleLabel(title: String) {
        titleLabel = Label(text: title,
                           font: UIFont(name: "AvenirNext-Bold", size: 16)!,
                          color: UIColor.blackColor())
        titleLabel.textAlignment = .Center
        let width = UIScreen.mainScreen().bounds.size.width - 60
        titleLabel.preferredMaxLayoutWidth = width
        roundedBackgroundView.addSubview(titleLabel)
        
        constrain(titleLabel, {title in
            title.centerX == title.superview!.centerX
            title.width == width
            title.top == title.superview!.top + 10
        })
    }
    
    func layoutResponseViews(legend: Bool) {
        if responseViews.count == 0 {
            return
        }
        
        constrain([titleLabel] + responseViews, replace: ConstraintGroup(), {views in
            let background = views.last!.superview!
            let title = views.first!
            let responseViews: [LayoutProxy] = Array(views[1..<views.count])
            for (index, view) in enumerate(responseViews) {
                view.left == background.left + 10
                view.right == background.right - 10
                (index == 0) ? view.top == title.bottom + 20 : view.top == responseViews[index - 1].bottom + 10
            }
        })
        
        let bottomSpacing = constrain(responseViews.last!, roundedBackgroundView, {last, background in
            background.bottom == last.bottom + 25
        })
        
        if legend {
            let legendView = self.legendView()
            roundedBackgroundView.addSubview(legendView)
            
            constrain(legendView, responseViews.last!, replace: bottomSpacing, {legend, lastResponseView in
                let background = legend.superview!
                legend.top == lastResponseView.bottom
                legend.centerX == background.centerX + 15
                legend.bottom == background.bottom - 25
            })
        }
        
        constrain(roundedBackgroundView, contentView, {background, cell in
            background.top == cell.top + 10
            background.left == cell.left + 10
            background.right == cell.right - 10
            background.bottom == cell.bottom - 10
        })
    }
    
    func legendView() -> LegendView {
        return LegendView(titles: ["Better than average", "Close to average", "Worse than average"], colors: [greenColor, yellowColor, redColor])
    }
}