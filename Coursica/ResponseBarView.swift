//
//  ResponseBarView.swift
//  Coursica
//
//  Created by Regan Bell on 7/30/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography
import pop

class ResponseBarView: UIView {
    
    let labelWidth: CGFloat = 104
    let scoreWidth: CGFloat = 25
    var leftMargin: CGFloat { get { return labelWidth + 10.0} }
    var maxBarWidth: CGFloat { get { return UIScreen.mainScreen().bounds.size.width - 20 - leftMargin - scoreWidth - 35 } }
    
    var bar = UIView()
    var barContainer = UIView()
    var questionLabel = UILabel()
    var scoreLabel = UILabel()
    var barWidthConstraint: NSLayoutConstraint!
    var response: Response!
    var delayTime: CFTimeInterval = 0

    init (response: Response, title: String) {
        super.init(frame: CGRectZero)
        
        barContainer.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        barContainer.layer.cornerRadius = 8
        self.addSubview(barContainer)
        
        bar.layer.cornerRadius = 8
        bar.backgroundColor = yellowColor
        barContainer.addSubview(bar)
        
        questionLabel.text = title
        questionLabel.font = UIFont(name: "AvenirNext-DemiBoldItalic", size: 15)
        questionLabel.backgroundColor = UIColor.whiteColor()
        questionLabel.textColor = UIColor.blackColor()
        questionLabel.opaque = true
        questionLabel.textAlignment = .Right
        questionLabel.numberOfLines = 0
        self.addSubview(questionLabel)
        
        if let baseline = response.baselineSingleTerm where baseline.group > 0.1 {
            let epsilon = 0.1
            var similarBaseline = (baseline.group + baseline.size) / 2
            if title == "Workload" {
                similarBaseline = similarBaseline * 0.36
            }
            if response.mean > similarBaseline + epsilon {
                bar.backgroundColor = questionLabel.text == "Workload" ? redColor : greenColor
            } else if response.mean < similarBaseline - epsilon {
                bar.backgroundColor = questionLabel.text == "Workload" ? greenColor : redColor
            }
        }
        
        let scoreString = NSString(format: "%.1f", response.mean) as String
        scoreLabel.text = scoreString
        scoreLabel.font = UIFont(name: "AvenirNext-DemiBoldItalic", size: 15)
        scoreLabel.backgroundColor = UIColor.whiteColor()
        scoreLabel.textColor = UIColor.blackColor()
        scoreLabel.opaque = true
        scoreLabel.textAlignment = .Left
        scoreLabel.numberOfLines = 0
        self.addSubview(scoreLabel)
        
        questionLabel.preferredMaxLayoutWidth = labelWidth
        
        constrain(bar, questionLabel, scoreLabel, block: {bar, question, score in
            let view = question.superview!
            question.left == view.left
            question.top == view.top
            question.width == self.labelWidth
            question.bottom == view.bottom
            score.right == view.right
            score.top == view.top
            score.width == self.scoreWidth
            score.height == 20
            let barContainer = bar.superview!
            barContainer.left == question.right + 10
            barContainer.width == self.maxBarWidth
            barContainer.centerY == view.centerY
            barContainer.height == 16
            bar.left == barContainer.left
            bar.top == barContainer.top
            bar.bottom == barContainer.bottom
            self.barWidthConstraint = (bar.width == 0)
        })
    }
    
    override func layoutSubviews() {                
        let widthAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        widthAnim.fromValue = NSNumber(integer: 0)
        widthAnim.toValue = NSNumber(float: Float(response.mean / 5.0) * Float(maxBarWidth))
        widthAnim.duration = 2
        widthAnim.beginTime = CACurrentMediaTime() + delayTime
        barWidthConstraint.pop_addAnimation(widthAnim, forKey: "widthAnim")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
