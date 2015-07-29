//
//  NavigationController.swift
//  Coursica
//
//  Created by Regan Bell on 7/18/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        self.view.backgroundColor = coursicaBlue
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
