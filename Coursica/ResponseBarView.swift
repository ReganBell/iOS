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

    let greenColor = UIColor(red:31/255.0, green:148/255.0, blue:100/255.0, alpha:1.0)
    
    let labelWidth: CGFloat = 104
    var leftMargin: CGFloat { get { return labelWidth + 10.0} }
    var maxBarWidth: CGFloat { get { return UIScreen.mainScreen().bounds.size.width - 20 - leftMargin } }
    
    var bar = UIView()
    var barContainer = UIView()
    var label = UILabel()
    var barWidthConstraint: NSLayoutConstraint!
    var response: Response!
    var delayTime: CFTimeInterval = 0
    
    init (response: Response) {
        super.init(frame: CGRectZero)
        
        barContainer.backgroundColor = UIColor.whiteColor()
        self.addSubview(barContainer)
        
        bar.layer.cornerRadius = 8
        bar.backgroundColor = greenColor
        barContainer.addSubview(bar)
        
        label.text = response.question
        label.font = UIFont(name: "AvenirNext-DemiBoldItalic", size: 15)
        label.backgroundColor = UIColor.whiteColor()
        label.textColor = UIColor.blackColor()
        label.opaque = true
        label.textAlignment = .Right
        label.numberOfLines = 0
        self.addSubview(label)
        
        label.preferredMaxLayoutWidth = labelWidth
        
        constrain(bar, label, self, {bar, label, view in
            label.left == view.left
            label.top == view.top
            label.width == self.labelWidth
            label.bottom == view.bottom
            let barContainer = bar.superview!
            barContainer.left == label.right + 10
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
        widthAnim.duration = 3
        widthAnim.beginTime = CACurrentMediaTime() + delayTime
        barWidthConstraint.pop_addAnimation(widthAnim, forKey: "widthAnim")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
