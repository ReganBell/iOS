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
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let graphWidth = self.percentileGraphView.bounds.width - percentileGraphInset * 2
        let spacing: CGFloat = (graphWidth - 20) / 39
        let barWidth: CGFloat = spacing + 1
        
        let heights: [CGFloat] = [1, 1, 2, 4, 5, 7, 10, 14, 20, 28, 40, 35, 31, 28, 22, 15, 13, 10, 8, 4, 2, 1]
        
        let currentIndex = 16
        
        for i in 0...20 {
            let height: CGFloat = heights[i] * 3
            let bar = UIView(frame: CGRectMake(0, 0, barWidth, 0))
            bar.layer.cornerRadius = barWidth / 2
            bar.backgroundColor = i == currentIndex ? UIColor(red:31/255.0, green:148/255.0, blue:255/255.0, alpha:1.0) : UIColor(white: 216/255.0, alpha: 1.0)
            self.percentileGraphView.addSubview(bar)
            let heightConstraint = bar.autoSetDimension(ALDimension.Height, toSize: 0)
            
            let heightAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            heightAnim.fromValue = NSNumber(integer: 0)
            heightAnim.toValue = NSNumber(float: Float(height))
            heightAnim.duration = 2
            let delay: CFTimeInterval = Double(i) * 0.1
            heightAnim.beginTime = CACurrentMediaTime() + delay
            heightConstraint.pop_addAnimation(heightAnim, forKey: "heightAnim")
            
            bar.autoSetDimension(ALDimension.Width, toSize: barWidth)
            let leadingSpacing = CGFloat(i) * (barWidth + spacing)
            bar.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: leadingSpacing)
            bar.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 0)
        }
    }
    
    func updateWithDictionary(dictionary: NSDictionary) {
        
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
        for (index, title) in enumerate(["Workload", "Instructor", "Difficulty"]) {
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 22))
            let scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 22))
            scoreLabel.font = UIFont(name: "AvenirNext-Bold", size: 15)
            scoreLabel.text = "4.4"
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
    }
}
