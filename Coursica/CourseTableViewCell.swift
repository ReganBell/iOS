//
//  CourseTableViewCell.swift
//  Coursica
//
//  Created by Regan Bell on 8/5/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

class CourseTableViewCell: UITableViewCell {

    var colorBarView = UIView()
    var separatorView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separatorView.backgroundColor = UIColor(white: 230/255.0, alpha: 1)
        self.contentView.addSubview(separatorView)
        
        colorBarView.backgroundColor = UIColor(white: 241/255.0, alpha: 1)
        self.contentView.addSubview(colorBarView)
        constrain(colorBarView, contentView, separatorView, block: {colorBar, contentView, separator in
            colorBar.left == contentView.left
            colorBar.top == contentView.top
            colorBar.bottom == contentView.bottom
            colorBar.width == ceil(UIScreen.mainScreen().bounds.size.width * 0.02)
            separator.left == colorBar.right
            separator.bottom == contentView.bottom
            separator.height == 0.5
            separator.right == contentView.right
        })
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}