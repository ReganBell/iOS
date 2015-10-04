//
//  CommentsViewController.swift
//  Coursica
//
//  Created by Regan Bell on 8/2/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class CommentsViewController: CoursicaViewController {

    @IBOutlet var tableView: UITableView!
    var report: Report!
    
    override func viewDidLoad() {
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        setNavigationBarTitle("Comments (\(report.comments.count))")
    }
}

extension CommentsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as! CommentTableViewCell
        cell.commentLabel?.text = report.comments[indexPath.row]
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return report.comments.count
    }
}
