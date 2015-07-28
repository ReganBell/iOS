//
//  CoursesSearchBarView.swift
//  Coursica
//
//  Created by Regan Bell on 7/19/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

class CoursesSearchBarView: UIView {

    var searchBar: UITextField!
    
    func initialLayout(delegate: UITextFieldDelegate) {
        

        
        constrain(self, searchBar, {view, bar in
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.top == view.superview!.top
            view.bottom == view.superview!.bottom
            bar.left == view.left + 10
            bar.right == view.right - 75
            bar.top == view.top + 5
            bar.bottom == view.bottom - 5
        })
    }
    
    func setFiltersShowing(showing: Bool) {
        searchBar.alpha = showing ? 1 : 0
        searchBar.transform = showing ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, 20)
    }
}
