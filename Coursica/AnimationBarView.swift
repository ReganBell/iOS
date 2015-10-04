//
//  AnimationBarView.swift
//  Coursica
//
//  Created by Matthew Beatty on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("This class does not support NSCoding")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let delayTime: CFTimeInterval = 1.0
        let barHeight: CGFloat = 16
        
        let bar = UIView(frame: CGRectMake(0, 0, 0, barHeight))
        bar.layer.cornerRadius = self.cornerRadius
        bar.backgroundColor = color
        animationBar.addSubview(bar)
        
        var widthConstraint: NSLayoutConstraint!
        constrain(bar, block: {bar in
            widthConstraint = (bar.width == 0)
            bar.left == bar.superview!.left
            bar.bottom == bar.superview!.bottom
            bar.height == barHeight
        })

        let widthAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        widthAnim.fromValue = NSNumber(integer: 0)
        widthAnim.toValue = NSNumber(float: Float(self.width))
        widthAnim.duration = 4
        widthAnim.beginTime = CACurrentMediaTime() + delayTime
        widthConstraint.pop_addAnimation(widthAnim, forKey: "widthAnim")
    }
    
    func updateWithDictionary(dictionary: NSDictionary) {
        addSubview(animationBar)
        constrain(animationBar, block: {animationBar in
            let superview = animationBar.superview!
            animationBar.top == superview.top
            animationBar.left == superview.left + 2
            animationBar.right == superview.right - 2
            animationBar.bottom == superview.bottom - 2
        })
    }
}