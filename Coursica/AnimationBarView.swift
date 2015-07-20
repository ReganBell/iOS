//
//  AnimationBarView.swift
//  Coursica
//
//  Created by Matthew Beatty on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import PureLayout
import pop

let barInset: CGFloat = 0

class AnimationBarView: UIView {
    
    var color: UIColor = UIColor(red:31/255.0, green:148/255.0, blue:100/255.0, alpha:1.0)
    var cornerRadius: CGFloat = 8
    var width: CGFloat = 100;
    
    var animationBar = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    init (width: CGFloat, color: UIColor) {
        super.init(frame: CGRectZero)
        self.width = width
        self.color = color
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("This class does not support NSCoding")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        var delayTime: CFTimeInterval = 1.0
        var barHeight: CGFloat = 16
        
        let bar = UIView(frame: CGRectMake(0, 0, 0, barHeight))
        bar.layer.cornerRadius = self.cornerRadius
        bar.backgroundColor = color
        self.animationBar.addSubview(bar)
        
        let widthConstraint = bar.autoSetDimension(ALDimension.Width, toSize: 0)
        let widthAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        widthAnim.fromValue = NSNumber(integer: 0)
        widthAnim.toValue = NSNumber(float: Float(self.width))
        widthAnim.duration = 4
        widthAnim.beginTime = CACurrentMediaTime() + delayTime
        widthConstraint.pop_addAnimation(widthAnim, forKey: "widthAnim")
        
        bar.autoSetDimension(ALDimension.Height, toSize: barHeight)
        bar.autoPinEdgeToSuperviewEdge(ALEdge.Leading, withInset: 0)
        bar.autoPinEdgeToSuperviewEdge(ALEdge.Bottom, withInset: 0)
    }
    
    func updateWithDictionary(dictionary: NSDictionary) {
        
        let width = self.frame.width
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        
        self.addSubview(animationBar)
        

        animationBar.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2), excludingEdge: ALEdge.Top)
        animationBar.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Top, ofView: superview, withOffset: 0)
        
//        var label = UILabel(frame: CGRectMake(0, 0, 40, 20))
//        label.center = CGPointMake(160, 284)
//        label.textAlignment = NSTextAlignment.Center
//        label.text = "4.3"
//        label.font = UIFont(name: label.font.fontName, size: 6)
//        label.textColor = UIColor.whiteColor()
//        self.animationBar.addSubview(label)
//
//        label.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Left, ofView: superview, withOffset: 2)
//        label.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Top, ofView: superview, withOffset: 0)
//
//        self.animationBar.bringSubviewToFront(label)
        
    }
    
}
