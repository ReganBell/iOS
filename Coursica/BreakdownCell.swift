//
//  BreakdownCell.swift
//  Coursica
//
//  Created by Regan Bell on 7/9/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import Cartography
import pop

let percentileGraphInset: CGFloat = 10

enum GraphViewTab: Int {
    case Group = 1
    case All = 2
    case Size = 3
}

protocol BreakdownCellDelegate {
    
    func viewDetailedBreakdownPressed()
}

class BreakdownCell: UITableViewCell {
    
    var graphHasDoneInitialLoad: Bool = false
    var percentileGraphView = UIView()
    var percentileLabel: UILabel!
    var percentileCenterX: NSLayoutConstraint!
    var responses: NSDictionary = NSDictionary()
    var baselineButtons: [UIButton] = []
    var roundedBackgroundView: UIView!
    var circleView: UIView!
    var overallNumberLabel: UILabel!
    var overallLabel: UILabel!
    var noDataAvailableLabel: UILabel!
    var allButton: UIButton!
    var groupButton: UIButton!
    var sizeButton: UIButton!
    var breakdownButton = UIButton()
    var circle: CAShapeLayer!
    var report: Report!
    var course: Course!
    var selectedTab: GraphViewTab = .Size
    var delegate: BreakdownCellDelegate!
    
    func updateForNoBreakdownFound() {
        UIView.animateWithDuration(0.3, animations: {
            self.noDataAvailableLabel.alpha = 1
        })
    }
    
    func updateWithReport(report: Report) {
        self.report = report
        var workload: Response?
        var instructor: Response?
        for response in report.responses {
            if response.question == "Workload (hours per week)" {
                workload = response
            }
        }
        if let facultyReport = report.facultyReports.first {
            for response in facultyReport.responses {
                if response.question == "Instructor Overall" {
                    instructor = response
                }
            }
        }
        
        var index = 0
        for (title, response) in [("Workload", workload), ("Instructor", instructor)] {
            let mean = response?.mean
            if mean == nil {
                continue
            }
            
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 22))
            let scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 22))
            scoreLabel.font = UIFont(name: "AvenirNext-Bold", size: 15)
            scoreLabel.text = NSString(format: "%.1f", mean!) as String

            scoreLabel.textAlignment = NSTextAlignment.Right
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 22))
            titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
            titleLabel.text = title + ":  "
            titleLabel.textAlignment = NSTextAlignment.Right
            backgroundView.addSubview(scoreLabel)
            backgroundView.addSubview(titleLabel)
            constrain(scoreLabel, titleLabel, block: {score, title in
                score.right == score.superview!.right
                title.right == score.left
                align(top: score.superview!, score, title)
                align(bottom: score.superview!, score, title)
                score.width == 30
                title.width == 80
            })
            roundedBackgroundView.addSubview(backgroundView)
            constrain(backgroundView, circleView, block: {background, circle in
                background.top == background.superview!.top + (33 + 25 * CGFloat(index))
                background.right == background.superview!.right - 40 ~ 750
                background.left >= circle.right + 10
                background.width == 110
                background.height == 22
            })
            index++
        }

        allButton.setTitle("all courses", forState: .Normal)
        groupButton.setTitle(course.shortField.lowercaseString, forState: .Normal)
        sizeButton.setTitle("size", forState: .Normal)
        breakdownButton.hidden = false
    }
    
    func initialLayoutWithCourse(course: Course) {
        self.course = course
        
        roundedBackgroundView = UIView()
        roundedBackgroundView.backgroundColor = UIColor.whiteColor()
        contentView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        roundedBackgroundView.layer.cornerRadius = 4
        roundedBackgroundView.clipsToBounds = true
        contentView.addSubview(roundedBackgroundView)
        
        noDataAvailableLabel = UILabel()
        noDataAvailableLabel.text = "No Q Breakdown available"
        noDataAvailableLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        noDataAvailableLabel.textColor = UIColor(white: 216/255.0, alpha: 1.0)
        noDataAvailableLabel.alpha = 0
        roundedBackgroundView.addSubview(noDataAvailableLabel)
        
        constrain(noDataAvailableLabel, block: {label in
            label.centerX == label.superview!.centerX
            label.centerY == label.superview!.centerY + 40
        })
        
        let radius = 120;
        circleView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        circle = CAShapeLayer()
        circle.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: radius, height: radius), cornerRadius: 120).CGPath
        circle.fillColor = UIColor.clearColor().CGColor
        circle.lineWidth = 8
        circle.strokeEnd = 0
        circleView.layer.addSublayer(circle)
        roundedBackgroundView.addSubview(circleView)
        constrain(circleView, block: {circle in
            circle.height == 120
            circle.width == 120
            circle.top == circle.superview!.top + 20
            circle.left == circle.superview!.left + 40
        })
        
        overallNumberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 48, height: 41))
        overallNumberLabel.font = UIFont(name: "AvenirNext-Bold", size: 40)
        circleView.addSubview(overallNumberLabel)
        constrain(overallNumberLabel, block: {overall in
            overall.centerY == overall.superview!.centerY - 5
            overall.centerX == overall.superview!.centerX
        })
        
        overallLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 48, height: 41))
        overallLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        circleView.addSubview(overallLabel)
        constrain(overallLabel, block: {overall in
            overall.centerY == overall.superview!.centerY + 20
            overall.centerX == overall.superview!.centerX
        })
        
        roundedBackgroundView.addSubview(percentileGraphView)
        constrain(percentileGraphView, circleView, block: {graph, circle in
            graph.top == circle.bottom + 15
            graph.left == graph.superview!.left + percentileGraphInset
            graph.right == graph.superview!.right - percentileGraphInset
            graph.height == 120
        })
        
        allButton = baselineButton("")
        allButton.tag = GraphViewTab.All.rawValue
        groupButton = baselineButton("")
        groupButton.tag = GraphViewTab.Group.rawValue
        sizeButton = baselineButton("")
        sizeButton.tag = GraphViewTab.Size.rawValue
        
        sizeButton.selected = true
        sizeButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 15)
        
        constrain(sizeButton, groupButton, percentileGraphView, block: {size, group, graph in
            size.centerX == size.superview!.centerX
            size.top == graph.bottom + 40
            size.height == 20
            group.centerX == size.superview!.right * 0.20
            group.top == graph.bottom + 40
            group.height == 20
        })
        constrain(sizeButton, allButton, percentileGraphView, block: {size, all, graph in
            all.centerX == size.superview!.right * 0.80
            all.top == graph.bottom + 40
            all.height == 20
        })
        
        self.baselineButtons = [allButton, groupButton, sizeButton]
        
        constrain(roundedBackgroundView, contentView, block: {background, cell in
            background.top == cell.top + 5
            background.left == cell.left + 10
            background.right == cell.right - 10
            background.bottom == cell.bottom - 10
        })
        
        if course.overall != 0 {
            overallLabel.text = "Overall"
            let score = course.overall

            overallNumberLabel.text = NSString(format: "%.1f", score) as String
        }
        
        breakdownButton.hidden = true
        breakdownButton.backgroundColor = coursicaBlue
        breakdownButton.setTitle("View detailed breakdown", forState: .Normal)
        breakdownButton.addTarget(self, action: "breakdownButtonPressed:", forControlEvents: .TouchUpInside)
        breakdownButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        roundedBackgroundView.addSubview(breakdownButton)
        constrain(sizeButton, roundedBackgroundView, breakdownButton, block: {size, background, breakdown in
            breakdown.top == size.bottom + 20
            breakdown.left == background.left
            breakdown.right == background.right
            breakdown.height == 44
            breakdown.bottom == background.bottom
        })
    }
    
    func breakdownButtonPressed(button: UIButton) {
        self.delegate.viewDetailedBreakdownPressed()
    }
    
    func startCircleAnimation(percentile: Int) {
        let strokeAnim = POPBasicAnimation(propertyNamed: kPOPShapeLayerStrokeEnd)
        strokeAnim.fromValue = NSNumber(integer: 0)
        strokeAnim.toValue = NSNumber(integer: 1)
        strokeAnim.duration = 2
        circle.strokeColor = colorForPercentile(percentile).CGColor
        circle.pop_addAnimation(strokeAnim, forKey: "strokeAnim")
    }
    
    func arrayForCurrentGraphTab() -> [Double] {
        if #available(iOS 9.0, *) {
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            switch self.selectedTab {
            case .All:    return delegate.allScores
            case .Group:  return delegate.allGroupScores[course.shortField]!
            case .Size:
                for range in delegate.allSizeScores {
                    if range.contains(course.enrollment) {return range.scores}
                }
            }
            return []
        } else {
            return []
        }
    }
    
    func eraseGraph() {
        for subview in self.percentileGraphView.subviews {
            subview.removeFromSuperview()
        }
        self.percentileLabel?.removeFromSuperview()
        self.percentileLabel = nil
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let graphWidth = UIScreen.mainScreen().bounds.size.width - 40
        if course.overall == 0 || graphWidth == 0 {
            return
        }
        
        self.eraseGraph()
        
        let spacing: CGFloat = 3
        let barWidth: CGFloat = 4
        let barCountFloat = (graphWidth - barWidth) / (barWidth + spacing)
        let barCountInt = Int(barCountFloat)
        
        var heights: [CGFloat] = []
        
        let sortedScores = arrayForCurrentGraphTab()
        let index = sortedScores.indexOf(course.overall)!
        let percentileWidth = 2.0 / Double(barCountInt)
        var scoreIndex = 0
        var cumulativeHeight: CGFloat = 1.0
        for i in 1...barCountInt {
            let maxScoreForCurrentWindow = 3.0 + percentileWidth * Double(i)
            while scoreIndex != sortedScores.count && sortedScores[scoreIndex] <= maxScoreForCurrentWindow {
                cumulativeHeight++
                scoreIndex++
            }
            heights.append(cumulativeHeight)
        }
        let percentile = Double(index) / Double(sortedScores.count)
        let percentileInt = Int(percentile * 100)
        
        let scaleFactor = 120.0 / heights.maxElement()!
        heights = heights.map({height in return height * scaleFactor})

        let rawGraphWidth = (spacing + barWidth) * barCountFloat + barWidth
        let roundedGraphWidth = (spacing + barWidth) * CGFloat(barCountInt) + barWidth
        let initialOffset: CGFloat = (rawGraphWidth - roundedGraphWidth) / 2 + 8
        
        var courseIndexBarView: UIView?
        for (i, height) in heights.enumerate() {
            let bar = UIView(frame: CGRectMake(0, 0, barWidth, 0))
            bar.layer.cornerRadius = barWidth / 2
            bar.backgroundColor = UIColor(white: 216/255.0, alpha: 1.0)
            
            let courseIndex = Int(percentile * Double(barCountInt))
            if i == courseIndex {
                bar.backgroundColor = colorForPercentile(percentileInt)
                courseIndexBarView = bar
            }
            
            self.percentileGraphView.addSubview(bar)
            
            var heightConstraint: NSLayoutConstraint!
            let leadingSpacing = initialOffset + CGFloat(i) * (barWidth + spacing)
            
            constrain(bar, block: {bar in
                heightConstraint = (bar.height == 0.1)
                bar.width == barWidth
                bar.left == bar.superview!.left + leadingSpacing
                bar.bottom == bar.superview!.bottom
            })
            
            let heightAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            heightAnim.fromValue = NSNumber(integer: 0)
            heightAnim.toValue = NSNumber(float: Float(height))
            let delaySpacing: CFTimeInterval = self.graphHasDoneInitialLoad ? 0 : 0.05
            heightAnim.duration = self.graphHasDoneInitialLoad ? 0.5 : 1
            let delay: CFTimeInterval = Double(i) * delaySpacing
            heightAnim.beginTime = CACurrentMediaTime() + delay
            heightConstraint.pop_addAnimation(heightAnim, forKey: "heightAnim")
        }
        
        percentileLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        percentileLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        percentileLabel.text = "\(percentileInt)\(self.suffixForInt(percentileInt)) percentile"
        percentileLabel.textAlignment = .Center
        startCircleAnimation(percentileInt)
        roundedBackgroundView.addSubview(percentileLabel)
        constrain(percentileLabel, courseIndexBarView!, percentileGraphView, block: {percentile, bar, graph in
            percentile.top == graph.bottom + 5
            percentile.centerX == bar.centerX ~ 750
            percentile.left == graph.left
            percentile.right <= graph.right
        })
    }
    
    func suffixForInt(int: Int) -> String {
        switch int {
        case 11, 12, 13: return "th"
        default:
            switch int % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }
    
    func baselineButtonPressed(button: UIButton) {
        
        if button.selected {
            let nudgeAnim = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
            nudgeAnim.velocity = 100
            button.pop_addAnimation(nudgeAnim, forKey: "nudgeAnim")
        } else {
            button.selected = false
            for otherButton in self.baselineButtons {
                otherButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 15)
                otherButton.selected = false
            }
            button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 15)
        }
        
        self.selectedTab = GraphViewTab(rawValue: button.tag)!
        
        switch button.tag {
        default:
            self.layoutSubviews()
        }
    }
    
    func baselineButton(title: String) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 22))
        button.titleLabel?.font = UIFont(name: "Avenir-Light", size: 15)
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.addTarget(self, action: "baselineButtonPressed:", forControlEvents: .TouchUpInside)
        roundedBackgroundView.addSubview(button)
        return button
    }
}
