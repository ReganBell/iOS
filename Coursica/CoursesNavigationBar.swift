//
//  CoursesNavigationBar.swift
//  Coursica
//
//  Created by Regan Bell on 7/19/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

protocol CoursesNavigationBarDelegate: UITextFieldDelegate {
    
    func listsButtonPressed(button: UIButton)
    func listsBackButtonPressed(button: UIButton)
    func searchButtonPressed(button: UIButton)
    func cancelFiltersButtonPressed(button: UIButton)
}

class CoursesNavigationBar: UIView {
    
    var delegate: CoursesNavigationBarDelegate!
    
    var barView = UIView()
    var statusBarHeightConstraint: NSLayoutConstraint!
    
    // Title
    var coursicaTitleLabel: UILabel!
    var listsTitleLabel: UILabel!
    var searchBar: UITextField!
    
    // Right Button
    var cancelButton: UIButton!
    var searchButton: UIButton!
    var listsEditButton: UIButton!

    // Left Button
    var listsButton: UIButton!
    var listsBackButton: UIButton!


    func initialLayout(delegate: CoursesNavigationBarDelegate) {
        
        self.delegate = delegate
        self.backgroundColor = coursicaBlue
        self.clipsToBounds = true
        
        self.addSubview(barView)
        constrain(barView, self, {bar, view in
            self.statusBarHeightConstraint = (bar.top == view.top + 20)
            bar.left == view.left
            bar.right == view.right
            bar.bottom == view.bottom
        })
        
        coursicaTitleLabel = self.titleLabel("Coursica")
        listsTitleLabel = self.titleLabel("Lists")
        barView.addSubview(coursicaTitleLabel)
        barView.addSubview(listsTitleLabel)
        constrain(coursicaTitleLabel, listsTitleLabel, barView, {coursica, lists, bar in
            coursica.height == 20
            lists.height == 20
            coursica.center == bar.center
            lists.center == bar.center
        })
        
        searchBar = self.bar()
        constrain(searchBar, barView, {search, nav in
            search.centerY == nav.centerY
            search.height == nav.height - 10
            search.left == nav.left + 10
        })
        
        cancelButton = self.navBarButton("Cancel", imageNamed: nil, target: "cancelFiltersButtonPressed:")
        listsEditButton = self.navBarButton("Edit", imageNamed: nil, target: "editListsButtonPressed:")
        searchButton = self.navBarButton("Search", imageNamed: "Search", target: nil)
        barView.addSubview(cancelButton)
        barView.addSubview(listsEditButton)
        barView.addSubview(searchButton)
        constrain(cancelButton, listsEditButton, searchButton, {cancel, edit, search in
            align(top: cancel, edit, search, cancel.superview!)
            align(bottom: cancel, edit, search, cancel.superview!)
            align(right: cancel, edit, search, cancel.superview!)
            cancel.width == 75
            edit.width == 75
            search.width == 75
        })
        
        constrain(searchBar, cancelButton, {search, cancel in
            search.right == cancel.left
        })
        
        listsButton = self.navBarButton("Lists", imageNamed: "Lists", target: nil)
        listsBackButton = self.navBarButton("Back", imageNamed: nil, target: "listsBackButtonPressed:")
        barView.addSubview(listsButton)
        barView.addSubview(listsBackButton)
        constrain(listsButton, listsBackButton, {lists, back in
            align(top: lists, back, back.superview!)
            align(bottom: lists, back, back.superview!)
            align(left: lists, back, back.superview!)
            back.width == 75
            lists.width == 75
        })
        
        self.setListsShowing(false)
        self.setFiltersShowing(false)
    }
    
    func setListsShowing(showing: Bool) {
        let unhideViews = showing ? [listsTitleLabel, listsEditButton, listsBackButton] : [coursicaTitleLabel, searchButton, listsButton]
        let hideViews = showing ? [coursicaTitleLabel, searchButton, listsButton] : [listsTitleLabel, listsEditButton, listsBackButton]
        self.toggleViews(unhideViews, hide: false, showing: showing)
        self.toggleViews(hideViews, hide: true, showing: showing)
    }
    
    func setFiltersShowing(showing: Bool) {
        let unhideViews = showing ? [cancelButton, searchBar] : [listsButton, coursicaTitleLabel, searchButton]
        let hideViews = showing ? [listsButton, coursicaTitleLabel, searchButton] : [searchBar, cancelButton]
        self.toggleViews(unhideViews, hide: false, showing: showing)
        self.toggleViews(hideViews, hide: true, showing: showing)
    }
    
    func toggleViews(views: [UIView], hide: Bool, showing: Bool) {
        let translate: CGFloat = hide ? (showing ? -20 : 20) : 0
        let alpha: CGFloat = hide ? 0 : 1
        for view in views {
            view.layer.transform = CATransform3DMakeTranslation(0, translate, 0)
            view.alpha = alpha
        }
    }
    
    func bar() -> UITextField {
        
        let bar = UITextField()
        self.addSubview(bar)
        bar.backgroundColor = UIColor(red: 31/255.0, green: 117/255.0, blue: 1, alpha: 1)
        bar.layer.cornerRadius = 4
        bar.setTranslatesAutoresizingMaskIntoConstraints(false)
        bar.returnKeyType = UIReturnKeyType.Search
        bar.delegate = delegate
        let font = UIFont(name: "AvenirNext-Medium", size: 14)!
        bar.font = font
        bar.textColor = UIColor.whiteColor()
        let leftSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        bar.leftViewMode = UITextFieldViewMode.Always
        bar.leftView = leftSpacerView
        let style = bar.defaultTextAttributes[NSParagraphStyleAttributeName]?.mutableCopy() as! NSMutableParagraphStyle
        style.minimumLineHeight = bar.font.lineHeight - (bar.font.lineHeight - font.lineHeight) / 2.0
        let string = "Search for courses"
        let placeholder = NSMutableAttributedString(string: string)
        placeholder.addAttribute(NSForegroundColorAttributeName, value: UIColor(white: 1, alpha: 0.4), range: NSMakeRange(0, count(string)))
        placeholder.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, count(string)))
        placeholder.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, count(string)))
        bar.attributedPlaceholder = placeholder
        return bar
    }
    
    func titleLabel(title: String) -> UILabel {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        label.text = title
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }
    
    func navBarButton(title: String, imageNamed: String?, target: String?) -> UIButton {
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        let selector = target == nil ? title.lowercaseString + "ButtonPressed:" : target!
        button.addTarget(self.delegate, action: Selector(selector), forControlEvents: UIControlEvents.TouchUpInside)
        if let name = imageNamed {
            button.setImage(UIImage(named: name), forState: UIControlState.Normal)
        } else {
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
            button.setTitle(title, forState: .Normal)
        }
        return button
    }
}
