//
//  BreakdownCell.swift
//  Coursica
//
//  Created by Regan Bell on 7/9/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import Cartography
import PureLayout
import pop

let percentileGraphInset: CGFloat = 10

class BreakdownCell: UITableViewCell {
    
    var percentileGraphView = UIView()
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
        for (index, tuple) in enumerate([("Workload", workload), ("Instructor", instructor), ("Section", section)]) {
            let (title, response) = tuple
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
                background.right == background.superview!.right - 20
                background.width == 110
                background.height == 22
            })
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
        allButton.tag = 0
        allButton.selected = true
        
        departmentButton = self.baselineButton("")
        departmentButton.tag = 1
        
        sizeButton = self.baselineButton("")
        sizeButton.tag = 2
        
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
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if report == nil {
            return
        }
        
        var delayTime: CFTimeInterval = 0.05
        for subview in self.percentileGraphView.subviews {
            subview.removeFromSuperview()
            delayTime = 0
        }
        
        let graphWidth = UIScreen.mainScreen().bounds.size.width - percentileGraphInset * 2 - 40
        var spacing: CGFloat = 0
        var barWidth: CGFloat = 0
        var barCountInt = 0
        let barCounts: [CGFloat] = [20, 33, 50]
        for barCount in barCounts {
            barCountInt = Int(barCount)
            barWidth = graphWidth / (barCount + barCount - 1)
            spacing = barWidth
            if barWidth < 10 {
                break
            }
        }
        
        var heights: [CGFloat] = []
        var currentIndex = 19
        
        if course.overall != 0 {
            
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let allPercentile = Double(find(delegate.allScores, course.overall)!) / Double(delegate.allScores.count)
            let departmentPercentile = Double(find(delegate.allDepartmentScores[course.shortField]!, course.overall)!) / Double(delegate.allScores.count)
            let barCountFloat = Double(barCountInt)
            let percentileWidth = Double(2.0 / barCountFloat)
            var scoreIndex = 0
            for i in 1...barCountInt {
                let maxScoreForCurrentWindow = 3.0 + percentileWidth * Double(i)
                var windowCount: CGFloat = 0
                while delegate.allDepartmentScores[course.shortField]![scoreIndex] <= maxScoreForCurrentWindow {
                    windowCount++
                    scoreIndex++
                    if scoreIndex == delegate.allDepartmentScores[course.shortField]!.count {
                        break
                    }
                }
                heights.append(windowCount)
            }
            
            currentIndex = Int(departmentPercentile * barCountFloat)
            println("All: \(allPercentile * 100) Department: \(departmentPercentile * 100)")
        }
        
        if heights.count == 0 {
            heights = [1, 1, 2, 4, 5, 7, 10, 14, 20, 28, 40, 35, 31, 28, 22, 15, 13, 10, 8, 4, 2, 1]
        }
        
        let tallestBar = maxElement(heights)
        let scaleFactor = 40.0 / tallestBar
        heights = heights.map({height in return height * scaleFactor})
        

        for i in 0...barCountInt {
            let height: CGFloat = heights[i % heights.count] * 3
            let bar = UIView(frame: CGRectMake(0, 0, barWidth, 0))
            bar.layer.cornerRadius = barWidth / 2
            bar.backgroundColor = i == currentIndex ? UIColor(red:31/255.0, green:148/255.0, blue:255/255.0, alpha:1.0) : UIColor(white: 216/255.0, alpha: 1.0)
            self.percentileGraphView.addSubview(bar)
            let heightConstraint = bar.autoSetDimension(ALDimension.Height, toSize: 0)
            
            let heightAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            heightAnim.fromValue = NSNumber(integer: 0)
            heightAnim.toValue = NSNumber(float: Float(height))
            heightAnim.duration = delayTime == 0 ? 0.5 : 1
            let delay: CFTimeInterval = Double(i) * delayTime
            heightAnim.beginTime = CACurrentMediaTime() + delay
            heightConstraint.pop_addAnimation(heightAnim, forKey: "heightAnim")
            
            bar.autoSetDimension(ALDimension.Width, toSize: barWidth)
            let barOffset = CGFloat(i) * barWidth
            let spacingOffset = CGFloat(i - 1) * barWidth
            let leadingSpacing = barOffset + spacingOffset
            bar.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: leadingSpacing)
            bar.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 0)
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
