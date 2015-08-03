//
//  CommentsCell.swift
//  Coursica
//
//  Created by Regan Bell on 8/2/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

protocol CommentsCellDelegate {
    func viewCommentsButtonPressed(commentsCell: CommentsCell)
}

class CommentsCell: UITableViewCell {

    var viewCommentsButton = UIButton()
    var delegate: CommentsCellDelegate!
    
    func layoutForReport(report: Report?) {
        self.contentView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        viewCommentsButton.backgroundColor = coursicaBlue
        viewCommentsButton.layer.cornerRadius = 4
        viewCommentsButton.setTitle("View Q Comments", forState: .Normal)
        viewCommentsButton.addTarget(self, action: "viewCommentsButtonPressed:", forControlEvents: .TouchUpInside)
        viewCommentsButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        self.contentView.addSubview(viewCommentsButton)
        constrain(viewCommentsButton, self.contentView, {button, cell in
            button.top == cell.top + 5
            button.left == cell.left + 10
            button.right == cell.right - 10
            button.bottom == cell.bottom - 10
            button.height == 44
        })
    }
    
    func viewCommentsButtonPressed(button: UIButton) {
        self.delegate.viewCommentsButtonPressed(self)
    }
}