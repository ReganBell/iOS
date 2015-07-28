////
////  FiltersViewController.swift
////  Coursica
////
////  Created by Regan Bell on 7/20/15.
////  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
////
//
//import Cartography
//
//protocol FiltersViewControllerDelegate {
//    
//    func filtersDidChange()
//    func keyboardShouldDismiss()
//}
//
//class FiltersViewController: UIViewController {
//
//    var delegate: FiltersViewControllerDelegate!
//    var genEdButtons: [UIButton]!
//    var termButtons: [UIButton]!
//    var genEdLabels: [UIButton]!
//    var cards: [UIView]!
//    var genEdImageView: [UIImageView]!
//    var scrollView = UIScrollView()
//    
//    func barWithTitles(titles: [String], var arrayToSaveTo: [UIButton]) -> UIView {
//        
//        let termBar = UIView()
//        termBar.backgroundColor = UIColor.whiteColor()
//        termBar.layer.cornerRadius = 4
//        scrollView.addSubview(termBar)
//        
//        let buttonFont = UIFont(name: "AvenirNext-Medium", size: 15)
//        let buttonColor = UIColor(white: 215/255.0, alpha: 1.0)
//        
//        let fallButton = UIButton()
//        fallButton.titleLabel?.font = buttonFont
//        fallButton.titleLabel?.textColor = buttonColor
//        fallButton.setTitle(titles[0], forState: .Normal)
//        termBar.addSubview(fallButton)
//        
//        let springButton = UIButton()
//        springButton.titleLabel?.font = buttonFont
//        springButton.titleLabel?.textColor = buttonColor
//        springButton.setTitle(titles[1], forState: .Normal)
//        termBar.addSubview(springButton)
//        
//        let bothButton = UIButton()
//        bothButton.titleLabel?.font = buttonFont
//        bothButton.titleLabel?.textColor = buttonColor
//        bothButton.setTitle(titles[2], forState: .Normal)
//        termBar.addSubview(bothButton)
//        
//        constrain(fallButton, springButton, bothButton, {fall, spring, both in
//            let bar = fall.superview!
//            fall.top == bar.top
//            fall.left == bar.left
//            fall.bottom == bar.bottom
//            fall.width == bar.width * 0.33
//            both.top == bar.top
//            both.right == bar.right
//            both.bottom == bar.bottom
//            both.width == bar.width * 0.33
//            spring.top == bar.top
//            spring.left == fall.right
//            spring.bottom == bar.bottom
//            spring.right == both.left * 0.33
//        })
//        
//        return termBar
//    }
//    
//    override func viewDidLoad() {
//        
//        view.addSubview(scrollView)
//        constrain(scrollView, {scrollView in
//            scrollView.edges == scrollView.superview!.edges
//        })
//        
//        let termBar = self.barWithTitles(["Fall", "Spring", "Both"], arrayToSaveTo: termButtons)
//        constrain(termBar, {term in
//            term.top == term.superview!.top + 10
//            term.left == term.superview!.left + 10
//            term.right == term.right - 10
//            term.height == 50
//        })
//        
//        let genEdBar = self.barWithTitles(["Undergrad", "Graduate", "Both"], arrayToSaveTo: genEdButtons)
//        constrain(genEdBar, termBar, {genEd, term in
//            genEd.top == term.bottom + 10
//            genEd.left == genEd.superview!.left + 10
//            genEd.right == genEd.right - 10
//            genEd.height == 50
//        })
//
//        
//    }
//}