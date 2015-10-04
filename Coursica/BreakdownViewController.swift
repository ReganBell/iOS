//
//  BreakdownViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/30/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

class BreakdownViewController: CoursicaViewController {

    let tableView = UITableView()
    var course: Course!
    var report: Report!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarTitle("\(course.shortField) \(course.number)")
        
        tableView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        view.addSubview(tableView)
        constrain(view, tableView, block: {view, scrollView in
            scrollView.edges == view.edges
        })
        view.translatesAutoresizingMaskIntoConstraints = true
    }
}

extension BreakdownViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = CourseCell(style: .Default, reuseIdentifier: "course")
            cell.layoutWithReport(report, legend: true)
            return cell
        } else {
            let cell = InstructorCell(style: .Default, reuseIdentifier: "instructor")
            let facultyReport = report.facultyReports[indexPath.row - 1]
            cell.layoutWithReport(facultyReport, legend: indexPath.row == 1)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + report.facultyReports.count
    }

}
