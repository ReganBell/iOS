//
//  InstructorCell.swift
//  Coursica
//
//  Created by Regan Bell on 7/30/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography
import RealmSwift

class InstructorCell: UITableViewCell {
    
    var roundedBackgroundView = UIView()
    var titleLabel: UILabel!
    var responseViews: [ResponseBarView] = []
    var allButton: UIButton!
    var departmentButton: UIButton!
    var sizeButton: UIButton!
    var baselineButtons: [UIButton]!
    var selectedTab: GraphViewTab = .All
    
    func layoutWithReport(report: FacultyReport) {
        
        roundedBackgroundView.backgroundColor = UIColor.whiteColor()
        contentView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        roundedBackgroundView.layer.cornerRadius = 4
        roundedBackgroundView.clipsToBounds = true
        contentView.addSubview(roundedBackgroundView)
        
        titleLabel = label(report.name)
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        titleLabel.textAlignment = .Center
        let width = UIScreen.mainScreen().bounds.size.width - 60
        titleLabel.preferredMaxLayoutWidth = width
        roundedBackgroundView.addSubview(titleLabel)
        
        constrain(titleLabel, {title in
            title.centerX == title.superview!.centerX
            title.width == width
            title.top == title.superview!.top + 10
        })
        
        let map = [("Instructor Overall",                           "Overall"),
            ("Effective Lectures or Presentations",                 "Lectures"),
            ("Accessible Outside Class",                            "Accessible"),
            ("Generates Enthusiasm",                                "Enthusiasm"),
            ("Facilitates Discussion & Encourages Participation",   "Discussion"),
            ("Gives Useful Feedback",                               "Feedback"),
            ("Returns Assignments in Timely Fashion",               "Turnaround")]
        
        for (index, pair) in enumerate(map) {
            for response in report.responses {
                let (questionKey, questionDisplay) = pair
                if response.question == questionKey {
                    if let average = Realm().objects(FacultyAverage).filter("question = %@", questionKey).first {
                        let baseline = Baseline()
                        baseline.group = average.score
                        baseline.size = average.score
                        response.baselineSingleTerm = baseline
                    }
                    let responseView = ResponseBarView(response: response, title: questionDisplay)
                    responseView.response = response
                    responseView.delayTime = CFTimeInterval(index) * 0.1
                    roundedBackgroundView.addSubview(responseView)
                    responseViews.append(responseView)
                    break
                }
            }
        }

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
        
        let aboveAverageLegend = self.legendView(greenColor, title: "Better than average")
        let averageLegend = self.legendView(yellowColor, title: "Close to average")
        let belowAverageLegend = self.legendView(redColor, title: "Worse than average")
        
        constrain([responseViews.last!] + [aboveAverageLegend, averageLegend, belowAverageLegend], replace: ConstraintGroup(), {views in
            let background = views.last!.superview!
            let lastResponseView = views.first!
            let legendViews: [LayoutProxy] = Array(views[1..<views.count])
            for (index, view) in enumerate(legendViews) {
                view.width == 220
                view.centerX == background.centerX + 10
                (index == 0) ? view.top == lastResponseView.bottom + 25 : view.top == legendViews[index - 1].bottom + 10
            }
            let lastLegendView = legendViews.last!
            lastLegendView.bottom == background.bottom - 25
        })
        
        constrain(roundedBackgroundView, self.contentView, {background, cell in
            background.top == cell.top + 10
            background.left == cell.left + 10
            background.right == cell.right - 10
            background.bottom == cell.bottom - 10
        })
    }
    
    func legendView(color: UIColor, title: String) -> UIView {
        
        let containerView = UIView()
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.opaque = true
        roundedBackgroundView.addSubview(containerView)
        
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        circleView.backgroundColor = color
        circleView.layer.cornerRadius = 8
        containerView.addSubview(circleView)
        
        let titleLabel = self.label(title)
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        titleLabel.backgroundColor = UIColor.whiteColor()
        containerView.addSubview(titleLabel)
        
        constrain(containerView, circleView, titleLabel, {container, circle, title in
            circle.left == container.left
            circle.width == 16
            circle.height == 16
            circle.top == container.top
            circle.bottom == container.bottom
            title.top == container.top
            title.height == 16
            title.left == circle.right + 10
            title.right == container.right
        })
        return containerView
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
