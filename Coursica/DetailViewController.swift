//
//  DetailViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import RealmSwift
import Cartography

class DetailViewController: CoursicaViewController {
    
    var course: Course!
    var report: Report?
    var reportLookupFailed: Bool = false
    
    var infoCell: InfoCell?
    var breakdownCell: BreakdownCell?
    
    var tableView = UITableView()
    
    class func detailViewControllerWithTempCourse(tempCourse: TempCourse) -> DetailViewController? {
        if let course = tempCourse.course {
            return self.detailViewControllerWithCourse(course)
        } else {
            return nil
        }
    }
    
    class func detailViewControllerWithCourse(course: Course) -> DetailViewController {
        let controller = DetailViewController()
        controller.course = course
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let enrollment = course.enrollment
        let overall = course.overall
        let workload = course.workload
        
        tableView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        view.addSubview(tableView)
        constrain(view, tableView, {view, scrollView in
            scrollView.edges == view.edges
        })
        view.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: "addCourseButtonPressed")
        
        setNavigationBarTitle("\(course.shortField) \(course.number)")
        getReportFromServer()
        getListsToFindConflicts()
    }
    
    func getListsToFindConflicts() {
        weak var weakSelf = self
        if course.meetings.count > 0 {
            TempCourseList.fetchListsForCurrentUserWithCompletion({lists in
                if let lists = lists {
                    for list in lists {
                        if list.name == "Courses I'm Shopping" {
                            var courses: [Course] = []
                            for tempCourse in list.courses {
                                if let course = tempCourse.course {
                                    courses.append(tempCourse.course!)
                                }
                            }
                            weakSelf?.tableView.beginUpdates()
                            weakSelf?.infoCell?.updateWithShoppingList(courses)
                            weakSelf?.tableView.endUpdates()
                        }
                    }
                }
            })
        }
    }
    
    func addCourseButtonPressed() {
        let alertController = UIAlertController(title: "Add to Lists", message: "Keep track of courses with Lists.", preferredStyle: .ActionSheet)
        for listName in TempCourseList.listNames() {
            let action = UIAlertAction(title: listName, style: .Default, handler: {action in
                TempCourseList.addCourseToListWithName(listName, course: self.course)
            })
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func getReportFromServer() {
        let urlString = "glaring-heat-9505.firebaseIO.com/\(self.course.display.serverTitle)"
        let root = Firebase(url: urlString)
        weak var weakSelf = self
        root.observeSingleEventOfType(FEventType.Value, withBlock: {snapshot in
            if let report = ReportParser.reportFromSnapshot(snapshot) {
                self.report = report
                weakSelf?.breakdownCell?.updateWithReport(report)
            } else {
                self.reportLookupFailed = true
                weakSelf?.breakdownCell?.updateForNoBreakdownFound()
            }
        })
    }
}

extension DetailViewController: BreakdownCellDelegate {
    
    func viewDetailedBreakdownPressed() {
        let breakdownController = BreakdownViewController()
        breakdownController.report = report!
        breakdownController.course = course
        self.navigationController?.pushViewController(breakdownController, animated: true)
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("info") as? InfoCell ?? InfoCell()
            cell.delegate = self
            cell.updateWithCourse(course)
            self.infoCell = cell
            return cell
        } else if indexPath.row == 1 {
            let breakdownCell = tableView.dequeueReusableCellWithIdentifier("breakdown") as? BreakdownCell ?? BreakdownCell(style: .Default, reuseIdentifier: "breakdown")
            breakdownCell.delegate = self
            breakdownCell.initialLayoutWithCourse(course)
            if let _ = report {
                breakdownCell.updateWithReport(report!)
            } else if reportLookupFailed {
                breakdownCell.updateForNoBreakdownFound()
            }
            self.breakdownCell = breakdownCell
            return breakdownCell
        } else {
            let commentsCell = CommentsCell()
            commentsCell.layoutForReport(report)
            commentsCell.delegate = self
            return commentsCell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}

extension DetailViewController: InfoCellDelegate {
    func mapButtonPressed(urlString: String) {
        navigationController?.pushViewController(MapViewController(urlString: urlString), animated: true)
    }
}

extension DetailViewController: CommentsCellDelegate {
    
    func viewCommentsButtonPressed(commentsCell: CommentsCell) {

        if report?.comments.count > 0 {
            let commentsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("commentsController") as! CommentsViewController
            commentsController.report = report
            self.navigationController?.pushViewController(commentsController, animated: true)
        } else {
            commentsCell.viewCommentsButton.setTitle("No comments found", forState: .Normal)
        }
    }
}