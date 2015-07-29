//
//  CoursicaViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class CoursicaViewController: UIViewController {
    
    func setNavigationBarTitle(title: String) {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        label.text = title
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        self.navigationItem.titleView = label
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
