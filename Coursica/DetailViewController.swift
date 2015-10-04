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
    
    let course: Course
    var report: Report?
    var reportLookupFailed: Bool = false
    
    var infoCell: InfoCell?
    var breakdownCell: BreakdownCell?
    
    var tableView = UITableView()
    
    init(course: Course) {
        self.course = course
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: "addCourseButtonPressed")
        
        setNavigationBarTitle("\(course.shortField) \(course.number)")
        getReportFromServer()
        getListsToFindConflicts()
    }
    
    func getListsToFindConflicts() {
        weak var weakSelf = self
        if course.meetings.count > 0 {
            CourseList.fetchListsForCurrentUserWithCompletion({lists in
                if let lists = lists {
                    for list in lists {
                        if list.name == "Courses I'm Shopping" {
                            var courses: [Course] = []
                            for listableCourse in list.courses {
                                if let course = listableCourse as? Course {
                                    courses.append(course)
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
        for listName in CourseList.listNames() {
            let action = UIAlertAction(title: listName, style: .Default, handler: {action in
                CourseList.addCourseToListWithName(listName, listableCourse: self.course, completionBlock: nil)
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
    
    func headerViewForTitle(title: String, tableView: UITableView) -> UIView {
        
        let headerView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: tableView.bounds.size.width, height: 44)))
        headerView.backgroundColor = UIColor(white: 241/255.0, alpha: 1)
        let headerLabel = UILabel(frame: CGRectZero)
        headerLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        headerLabel.text = title
        headerLabel.sizeToFit()
        headerLabel.textColor = UIColor(white: 142/255.0, alpha: 1.0)
        headerView.addSubview(headerLabel)
        constrain(headerLabel, block: {header in
            header.center == header.superview!.center
        })
        return headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("info") as? InfoCell ?? InfoCell()
            cell.delegate = self
            cell.updateWithCourse(course)
            self.infoCell = cell
            return cell
        } else if indexPath.row == 1 {
            if course.overall > 0.01 {
                let breakdownCell = BreakdownCell(style: .Default, reuseIdentifier: "breakdown")
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
                let cell = UITableViewCell()
                cell.contentView.addSubview(headerViewForTitle("No Q Data is available", tableView: tableView))
                cell.contentView.backgroundColor = UIColor.clearColor()
                return cell
            }
        } else {
            let commentsCell = CommentsCell()
            commentsCell.layoutForReport(report)
            commentsCell.delegate = self
            return commentsCell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return course.overall > 0.01 ? 3 : 2
    }
}

extension DetailViewController: InfoCellDelegate {
    func mapButtonPressed(urlString: String) {
        navigationController?.pushViewController(MapViewController(urlString: urlString), animated: true)
    }
    
    func courseLinkPressed(course: Course) {
        navigationController?.pushViewController(DetailViewController(course: course), animated: true)
    }
    
    func facultyLinkPressed(faculty: Faculty) {
        navigationController?.pushViewController(FacultyViewController(faculty: faculty), animated: true)
    }
    
    func expandedNeededFor() {
        tableView.beginUpdates()
        tableView.endUpdates()
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