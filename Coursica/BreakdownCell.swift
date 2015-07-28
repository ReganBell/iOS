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
    case Department = 1
    case All = 2
    case Size = 3
}

class BreakdownCell: UITableViewCell {
    
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
    var departmentButton: UIButton!
    var sizeButton: UIButton!
    var circle: CAShapeLayer!
    var report: Report!
    var course: Course!
    var selectedTab: GraphViewTab = .All
    
    func updateForNoBreakdownFound() {
        UIView.animateWithDuration(0.3, animations: {
            self.noDataAvailableLabel.alpha = 1
        })
    }
    
    func updateWithReport(report: Report) {
        self.report = report
        var overall: Response?
        var workload: Response?
        var instructor: Response?
        var section: Response?
        for response in report.responses {
            if response.question == "Course Overall" {
                overall = response
            }
            if response.question == "Workload (hours per week)" {
                workload = response
            }
            if response.question == "Instructor" {
                instructor = response
            }
            if response.question == "Section" {
                section = response
            }
        }

        overallLabel.text = "Overall"
        let score = overall?.mean ?? 4.5
        overallNumberLabel.text = NSString(format: "%.1f", score) as String
        self.startCircleAnimation()

        var buttonViews: [UIView] = []
        var index = 0
        for (title, response) in [("Workload", workload), ("Instructor", instructor), ("Section", section)] {
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
            constrain(scoreLabel, titleLabel, {score, title in
                score.right == score.superview!.right
                title.right == score.left
                align(top: score.superview!, score, title)
                align(bottom: score.superview!, score, title)
                score.width == 30
                title.width == 80
            })
            roundedBackgroundView.addSubview(backgroundView)
            constrain(backgroundView, {background in
                background.top == background.superview!.top + (33 + 25 * CGFloat(index))
                background.right == background.superview!.right - 40
                background.width == 110
                background.height == 22
            })
            index++
        }

        allButton.setTitle("all courses", forState: .Normal)
        departmentButton.setTitle("department", forState: .Normal)
        sizeButton.setTitle("size", forState: .Normal)
        self.layoutSubviews()
    }
    
    func initialLayoutWithCourse(course: Course) {
        self.course = course
        let width = self.frame.width
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        roundedBackgroundView = UIView()
        roundedBackgroundView.backgroundColor = UIColor.whiteColor()
        self.contentView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        roundedBackgroundView.layer.cornerRadius = 4
        self.contentView.addSubview(roundedBackgroundView)
        
        noDataAvailableLabel = UILabel()
        noDataAvailableLabel.text = "No Q Breakdown available"
        noDataAvailableLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        noDataAvailableLabel.textColor = UIColor(white: 216/255.0, alpha: 1.0)
        noDataAvailableLabel.alpha = 0
        roundedBackgroundView.addSubview(noDataAvailableLabel)
        
        constrain(noDataAvailableLabel, {label in
            label.centerX == label.superview!.centerX
            label.centerY == label.superview!.centerY + 40
        })
        
        let radius = 120;
        circleView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        circle = CAShapeLayer()
        circle.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: radius, height: radius), cornerRadius: 120).CGPath
        circle.fillColor = UIColor.clearColor().CGColor
        circle.strokeColor = UIColor(red: 31/255.0, green: 1, blue: 170/255.0, alpha: 1).CGColor
        circle.lineWidth = 8
        circle.strokeEnd = 0
        circleView.layer.addSublayer(circle)
        roundedBackgroundView.addSubview(circleView)
        constrain(circleView, {circle in
            circle.height == 120
            circle.width == 120
            circle.top == circle.superview!.top + 20
            circle.left == circle.superview!.left + 40
        })
        
        overallNumberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 48, height: 41))
        overallNumberLabel.font = UIFont(name: "AvenirNext-Bold", size: 40)
        circleView.addSubview(overallNumberLabel)
        constrain(overallNumberLabel, {overall in
            overall.centerY == overall.superview!.centerY - 5
            overall.centerX == overall.superview!.centerX
        })
        
        overallLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 48, height: 41))
        overallLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        circleView.addSubview(overallLabel)
        constrain(overallLabel, {overall in
            overall.centerY == overall.superview!.centerY + 20
            overall.centerX == overall.superview!.centerX
        })
        
        roundedBackgroundView.addSubview(percentileGraphView)
        constrain(percentileGraphView, circleView, {graph, circle in
            graph.top == circle.bottom + 25
            graph.left == graph.superview!.left + percentileGraphInset
            graph.right == graph.superview!.right - percentileGraphInset
            graph.height == 120
        })
        
        allButton = self.baselineButton("")
        allButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 15)
        allButton.tag = GraphViewTab.All.rawValue
        allButton.selected = true
        
        departmentButton = self.baselineButton("")
        departmentButton.tag = GraphViewTab.Department.rawValue
        
        sizeButton = self.baselineButton("")
        sizeButton.tag = GraphViewTab.Size.rawValue
        
        constrain(allButton, departmentButton, percentileGraphView, {all, department, graph in
            all.centerX == all.superview!.centerX
            all.top == graph.bottom + 30
            all.height == 20
            all.width == 90
            department.right == all.left - 20
            department.top == graph.bottom + 30
            department.height == 20
            department.width == 90
        })
        constrain(allButton, sizeButton, percentileGraphView, {all, size, graph in
            size.left == all.right + 20
            size.top == graph.bottom + 30
            size.width == 90
            size.height == 20
            size.bottom == size.superview!.bottom - 20
        })
        
        self.baselineButtons = [allButton, departmentButton, sizeButton]
        
        constrain(roundedBackgroundView, self.contentView, {background, cell in
            background.top == cell.top + 5
            background.left == cell.left + 10
            background.right == cell.right - 10
            background.bottom == cell.bottom - 10
        })
        
        if course.overall != 0 {
            overallLabel.text = "Overall"
            let score = course.overall
            overallNumberLabel.text = NSString(format: "%.1f", score) as String
            self.startCircleAnimation()
        }
    }
    
    func startCircleAnimation() {
        let strokeAnim = POPBasicAnimation(propertyNamed: kPOPShapeLayerStrokeEnd)
        strokeAnim.fromValue = NSNumber(integer: 0)
        strokeAnim.toValue = NSNumber(integer: 1)
        strokeAnim.duration = 2
        circle.pop_addAnimation(strokeAnim, forKey: "strokeAnim")
    }
    
    func arrayForCurrentGraphTab() -> [Double] {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        switch self.selectedTab {
        case .All:        return delegate.allScores
        case .Department: return delegate.allDepartmentScores[course.shortField]!
        case .Size:
            for range in delegate.allSizeScores {
                if range.contains(course.enrollment) {return range.scores}
            }
        }
        return []
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        return
        
        if report == nil {
            return
        }
        
        var delayTime: CFTimeInterval = 0.05
        for subview in self.percentileGraphView.subviews {
            subview.removeFromSuperview()
            delayTime = 0
        }
        self.percentileLabel?.removeFromSuperview()
        self.percentileLabel = nil
        
        let graphWidth = UIScreen.mainScreen().bounds.size.width - 40
        if graphWidth == 0 {
            return
        }
        var spacing: CGFloat = 7
        var barWidth: CGFloat = 8
        var barCountFloat = (graphWidth - barWidth) / (barWidth + spacing)
        var barCountInt = Int(barCountFloat)
        
        var heights: [CGFloat] = []
        var courseIndex = 0
        
        if course.overall == 0 {
            return
        }
        
        let sortedScores = self.arrayForCurrentGraphTab()
        let index = find(sortedScores, course.overall)!
        let percentileWidth = 2.0 / Double(barCountInt)
        var scoreIndex = 0
        var runningHeight: CGFloat = 0.0
        for i in 1...barCountInt {
            let maxScoreForCurrentWindow = 3.0 + percentileWidth * Double(i)
            while sortedScores[scoreIndex] <= maxScoreForCurrentWindow {
                runningHeight++
                scoreIndex++
                if scoreIndex == sortedScores.count {
                    break
                }
            }
            heights.append(runningHeight)
            if scoreIndex == sortedScores.count {
                break
            }
        }
        let percentile = Double(index) / Double(sortedScores.count)
        courseIndex = Int(percentile * Double(barCountInt))
        
        let tallestBar = maxElement(heights)
        let scaleFactor = 120.0 / tallestBar
        heights = heights.map({height in return height * scaleFactor})

        let rawGraphWidth = (spacing + barWidth) * barCountFloat + barWidth
        let roundedGraphWidth = (spacing + barWidth) * CGFloat(barCountInt) + barWidth
        let initialOffset: CGFloat = (graphWidth - roundedGraphWidth) / 2
        
        var courseIndexBarView: UIView?
        for (i, height) in enumerate(heights) {
            let bar = UIView(frame: CGRectMake(0, 0, barWidth, 0))
            bar.layer.cornerRadius = barWidth / 2
            bar.backgroundColor = UIColor(white: 216/255.0, alpha: 1.0)
            if i == courseIndex {
                bar.backgroundColor = UIColor(red:31/255.0, green:148/255.0, blue:255/255.0, alpha:1.0)
                courseIndexBarView = bar
            }
            
            self.percentileGraphView.addSubview(bar)
            
            var heightConstraint: NSLayoutConstraint!
            let leadingSpacing = initialOffset + CGFloat(i) * (barWidth + spacing)
            
            constrain(bar, {bar in
                heightConstraint = (bar.height == 0.1)
                bar.width == barWidth
                bar.left == bar.superview!.left + leadingSpacing
                bar.bottom == bar.superview!.bottom
            })
            
            let heightAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            heightAnim.fromValue = NSNumber(integer: 0)
            heightAnim.toValue = NSNumber(float: Float(height))
            heightAnim.duration = delayTime == 0 ? 0.5 : 1
            let delay: CFTimeInterval = Double(i) * delayTime
            heightAnim.beginTime = CACurrentMediaTime() + delay
            heightConstraint.pop_addAnimation(heightAnim, forKey: "heightAnim")
        }
        
        percentileLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        percentileLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        let percentileInt = Int(percentile * 100)
        percentileLabel.text = "\(percentileInt)\(self.suffixForInt(percentileInt)) percentile"
        percentileLabel.textAlignment = .Center
        self.addSubview(percentileLabel)
        constrain(percentileLabel, courseIndexBarView!, percentileGraphView, {percentile, bar, graph in
            percentile.top == graph.bottom + 5
            percentile.centerX == bar.centerX ~ 750
            percentile.left >= graph.left
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
            self.layoutSubviews()
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
