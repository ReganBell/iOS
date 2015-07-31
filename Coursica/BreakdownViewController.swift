//
//  BreakdownViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/30/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

class BreakdownViewController: CoursicaViewController {

    var tableView = UITableView()
    var course: Course!
    var report: Report!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        self.view.addSubview(tableView)
        constrain(self.view, tableView, {view, scrollView in
            scrollView.edges == view.edges
        })
        self.view.setTranslatesAutoresizingMaskIntoConstraints(true)
    }
}

extension BreakdownViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            let cell = tableView.dequeueReusableCellWithIdentifier("info") as? InfoCell ?? InfoCell()
//            cell.updateWithCourse(course)
//            return cell
//        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("course") as? CourseCell ?? CourseCell(style: .Default, reuseIdentifier: "course")
            cell.layoutWithReport(report)
            return cell
//        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}
