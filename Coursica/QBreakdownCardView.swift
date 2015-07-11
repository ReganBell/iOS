//
//  QBreakdownCardView.swift
//  Coursica
//
//  Created by Regan Bell on 7/9/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import PureLayout
import pop

let percentileGraphInset: CGFloat = 10

class QBreakdownCardView: UIView {
    
    var percentileGraphView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var responses: NSDictionary = NSDictionary()
    var baselineButtons: [UIButton] = []
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        var delayTime: CFTimeInterval = 0.1
        for subview in self.percentileGraphView.subviews {
            subview.removeFromSuperview()
            delayTime = 0
        }
        
        let graphWidth = self.percentileGraphView.bounds.width - percentileGraphInset * 2
        var spacing: CGFloat = 0
        var barWidth: CGFloat = 0
        var barCountInt = 0
        let barCounts: [CGFloat] = [20, 33, 50]
        for barCount in barCounts {
            barCountInt = Int(barCount)
            spacing = (graphWidth - barCount) / (barCount * 2 - 1)
            barWidth = spacing + 1
            if barWidth < 10 {
                break
            }
        }
        
        var heights: [CGFloat] = [1, 1, 2, 4, 5, 7, 10, 14, 20, 28, 40, 35, 31, 28, 22, 15, 13, 10, 8, 4, 2, 1]
        
        let currentIndex = 16

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
            heightAnim.duration = 1
            let delay: CFTimeInterval = Double(i) * delayTime
            heightAnim.beginTime = CACurrentMediaTime() + delay
            heightConstraint.pop_addAnimation(heightAnim, forKey: "heightAnim")
            
            bar.autoSetDimension(ALDimension.Width, toSize: barWidth)
            let leadingSpacing = CGFloat(i) * (barWidth + spacing)
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
        
//        switch button.tag {
//        default:
//            self.layoutSubviews()
//        }
    }
    
    func updateWithDictionary(dictionary: NSDictionary) {
        
        responses = dictionary["responses"] as! NSDictionary
        let width = self.frame.width
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        let radius = 120;
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: radius, height: radius), cornerRadius: 120).CGPath
        circle.fillColor = UIColor.clearColor().CGColor
        circle.strokeColor = UIColor(red: 31/255.0, green: 1, blue: 170/255.0, alpha: 1).CGColor
        circle.lineWidth = 8
        circleView.layer.addSublayer(circle)
        self.addSubview(circleView)
        circleView.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 20)
        circleView.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 40)
        circleView.autoSetDimension(ALDimension.Width, toSize: 120)
        circleView.autoSetDimension(ALDimension.Height, toSize: 120)
        
        let strokeAnim = POPBasicAnimation(propertyNamed: kPOPShapeLayerStrokeEnd)
        strokeAnim.fromValue = NSNumber(integer: 0)
        strokeAnim.toValue = NSNumber(integer: 1)
        strokeAnim.duration = 2
        circle.pop_addAnimation(strokeAnim, forKey: "strokeAnim")
        
        let overallNumberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 48, height: 41))
        overallNumberLabel.text = "4.5"
        overallNumberLabel.font = UIFont(name: "AvenirNext-Bold", size: 40)
        circleView.addSubview(overallNumberLabel)
        overallNumberLabel.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: circleView, withOffset: -5)
        overallNumberLabel.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        
        let overallLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 48, height: 41))
        overallLabel.text = "Overall"
        overallLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        circleView.addSubview(overallLabel)
        overallLabel.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: circleView, withOffset: 20)
        overallLabel.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        
        self.addSubview(percentileGraphView)
        percentileGraphView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: percentileGraphInset, bottom: 60, right: percentileGraphInset), excludingEdge: ALEdge.Top)
        percentileGraphView.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: circleView, withOffset: 15)
        
        var buttonViews: [UIView] = []
        for (index, pair) in enumerate([("Workload", "Workload (hours per week)"), ("Instructor", "Instructor"), ("Difficulty", "Difficulty")]) {
            let (title, key) = pair
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 22))
            let scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 22))
            scoreLabel.font = UIFont(name: "AvenirNext-Bold", size: 15)
            scoreLabel.text = "4.4"
            if let response = responses[key] as? NSDictionary {
                scoreLabel.text = response["mean"] as? String
            }
            scoreLabel.textAlignment = NSTextAlignment.Right
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 22))
            titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
            titleLabel.text = title + ":  "
            titleLabel.textAlignment = NSTextAlignment.Right
            backgroundView.addSubview(scoreLabel)
            backgroundView.addSubview(titleLabel)
            scoreLabel.autoPinEdgeToSuperviewEdge(ALEdge.Trailing)
            scoreLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top)
            scoreLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
            scoreLabel.autoSetDimension(ALDimension.Width, toSize: 30)
            titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Leading)
            titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top)
            titleLabel.autoPinEdgeToSuperviewEdge(ALEdge.Bottom)
            self.addSubview(backgroundView)
            titleLabel.autoSetDimension(ALDimension.Width, toSize: 80)
            let topSpacing: CGFloat = CGFloat(33 + 25 * index)
            backgroundView.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: topSpacing)
            backgroundView.autoPinEdgeToSuperviewEdge(ALEdge.Trailing, withInset: 48)
            backgroundView.autoSetDimension(ALDimension.Width, toSize: 110)
            backgroundView.autoSetDimension(ALDimension.Height, toSize: 22)
        }
        
        let allCoursesButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 22))
        allCoursesButton.setTitle("all courses", forState: UIControlState.Normal)
        allCoursesButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 15)
        allCoursesButton.titleLabel?.textAlignment = NSTextAlignment.Center
        allCoursesButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        allCoursesButton.tag = 0
        allCoursesButton.selected = true
        allCoursesButton.addTarget(self, action: "baselineButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(allCoursesButton)
        allCoursesButton.autoSetDimension(ALDimension.Width, toSize: 90)
        allCoursesButton.autoSetDimension(ALDimension.Height, toSize: 22)
        allCoursesButton.autoAlignAxisToSuperviewAxis(ALAxis.Vertical)
        allCoursesButton.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: percentileGraphView, withOffset: 30)
        
        let departmentButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 22))
        departmentButton.setTitle("department", forState: UIControlState.Normal)
        departmentButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 15)
        departmentButton.titleLabel?.textAlignment = NSTextAlignment.Center
        departmentButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        departmentButton.tag = 1
        departmentButton.addTarget(self, action: "baselineButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(departmentButton)
        departmentButton.autoSetDimension(ALDimension.Width, toSize: 90)
        departmentButton.autoSetDimension(ALDimension.Height, toSize: 22)
        departmentButton.autoPinEdge(ALEdge.Trailing, toEdge: ALEdge.Leading, ofView: allCoursesButton, withOffset: -30)
        departmentButton.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: allCoursesButton, withOffset: 0)
        
        let sizeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 22))
        sizeButton.setTitle("size", forState: UIControlState.Normal)
        sizeButton.titleLabel?.font = UIFont(name: "Avenir-Light", size: 15)
        sizeButton.titleLabel?.textAlignment = NSTextAlignment.Center
        sizeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        sizeButton.tag = 2
        sizeButton.addTarget(self, action: "baselineButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(sizeButton)
        sizeButton.autoSetDimension(ALDimension.Width, toSize: 90)
        sizeButton.autoSetDimension(ALDimension.Height, toSize: 22)
        sizeButton.autoPinEdge(ALEdge.Leading, toEdge: ALEdge.Trailing, ofView: allCoursesButton, withOffset: 30)
        sizeButton.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView: allCoursesButton, withOffset: 0)
        
        self.baselineButtons = [allCoursesButton, departmentButton, sizeButton]
    }
}
