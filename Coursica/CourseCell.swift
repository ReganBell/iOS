//
//  CourseCell.swift
//  Coursica
//
//  Created by Regan Bell on 7/30/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

class CourseCell: UITableViewCell {

    var roundedBackgroundView = UIView()
    var titleLabel: UILabel!
    var responseViews: [UIView] = []
    
    func layoutWithReport(report: Report) {
        
        roundedBackgroundView.backgroundColor = UIColor.whiteColor()
        self.contentView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        roundedBackgroundView.layer.cornerRadius = 4
        roundedBackgroundView.clipsToBounds = true
        self.contentView.addSubview(roundedBackgroundView)
        
        titleLabel = self.label("Course Breakdown")
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        titleLabel.textAlignment = .Center
        let width = UIScreen.mainScreen().bounds.size.width
        titleLabel.preferredMaxLayoutWidth = width - 60
        roundedBackgroundView.addSubview(titleLabel)
        
        for (index, question) in enumerate(["Workload (hours per week)", "Assignments", "Feedback", "Materials", "Section", "Would You Recommend"]) {
            for response in report.responses {
                if response.question == question {
                    let responseView = ResponseBarView(response: response)
                    responseView.response = response
                    responseView.delayTime = CFTimeInterval(index) * 0.1
                    roundedBackgroundView.addSubview(responseView)
                    responseViews.append(responseView)
                    break
                }
            }
        }
        
        if responseViews.count != 0 {
            constrain([titleLabel] + responseViews, replace: ConstraintGroup(), {views in
                let background = views.last!.superview!
                let title = views.first!
                let responseViews: [LayoutProxy] = Array(views[1..<views.count])
                for (index, view) in enumerate(responseViews) {
                    view.left == background.left + 10
                    view.right == background.right - 10
                    (index == 0) ? view.top == title.bottom + 10 : view.top == responseViews[index - 1].bottom + 10
                }
                let last = views.last!
                last.bottom == background.bottom - 10
            })
        }
        
        constrain(roundedBackgroundView, self.contentView, {background, cell in
            background.top == cell.top + 10
            background.left == cell.left + 10
            background.right == cell.right - 10
            background.bottom == cell.bottom - 10
        })
    }
    
    func label(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor.blackColor()
        label.backgroundColor = UIColor.whiteColor()
        label.opaque = true
        label.numberOfLines = 0
        return label
    }
}
