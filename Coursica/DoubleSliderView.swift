////
////  DoubleSliderView.swift
////  Coursica
////
////  Created by Regan Bell on 8/2/15.
////  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
////
//
//import Cartography
//
//class DoubleSliderView: UIView {
//    
//    var titleLabel: UILabel!
//    var rightLabel: UILabel!
//    var leftLabel:  UILabel!
//    var slider = NMRangeSlider()
//    
//    var font = UIFont(name: "AvenirNext-Medium", size: 14)
//    var textColor = UIColor(white: 155/255.0, alpha: 1)
//    var valueChanged: (UILabel, UILabel, NMRangeSlider) -> Void = {left, right, slider in
//        left.text = NSString(format: "%.1f", slider.lowerValue) as String
//        right.text = NSString(format: "%.1f", slider.upperValue) as String
//    }
//
//    func label(title: String) -> UILabel {
//        let label = UILabel()
//        label.font = font
//        label.text = title
//        label.textColor = textColor
//        label.textAlignment = .Center
//        self.addSubview(label)
//        constrain(label, {label in
//            label.height == 20
//        })
//        return label;
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    init(title: String) {
//        super.init(frame: CGRectZero)
//        titleLabel = self.label(title)
//        leftLabel = self.label("")
//        rightLabel = self.label("")
//        let handleImage = UIImage(named: "SliderTab")
//        slider.lowerHandleImageNormal = handleImage
//        slider.upperHandleImageNormal = handleImage
//        slider.lowerHandleImageHighlighted = handleImage
//        slider.upperHandleImageHighlighted = handleImage
//        slider.minimumValue = 1
//        slider.maximumValue = 5
//        slider.lowerValue = 2
//        slider.upperValue = 5
//        slider.tintColor = coursicaBlue
//        slider.addTarget(self, action: "sliderValueChanged:", forControlEvents: .ValueChanged)
//        self.addSubview(slider)
//        
//        constrain(titleLabel, self, slider, {title, view, slider in
//            title.top == view.top
//            title.centerX == view.centerX
//            slider.height == 40
//            slider.left == view.left
//            slider.right == view.right
//            slider.top == title.bottom
//        })
//        
//        constrain(leftLabel, rightLabel, titleLabel, {left, right, title in
//            left.width == 53
//            right.width == 53
//            title.width == 120
//            left.centerY == title.centerY - 2
//            right.centerY == title.centerY - 2
//        })
//        
//        constrain(leftLabel, rightLabel, slider, {left, right, slider in
//            left.centerX == slider.left - 10
//            right.centerX == slider.right + 10
//        })
//        
//        self.sliderValueChanged(slider)
//    }
//    
//    func sliderValueChanged(slider: NMRangeSlider) {
//        self.valueChanged(leftLabel, rightLabel, slider)
//    }
//}
