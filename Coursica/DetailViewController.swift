//
//  DetailViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import RealmSwift
import TTTAttributedLabel
import Cartography

class DetailViewController: CoursicaViewController {
    
    var course: Course!
    var report: Report?
    var reportLookupFailed: Bool = false
    
    var breakdownCell: BreakdownCell!
    
    var tableView = UITableView()
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var courseInstructorLabel: UILabel!
    @IBOutlet var courseMeetingLabel: UILabel!
    @IBOutlet var courseLocationLabel: TTTAttributedLabel!
    @IBOutlet var courseInfoLabel: UILabel!
    @IBOutlet var satisfiesLabel: UILabel!
    
    class func detailViewControllerWithTempCourse(tempCourse: TempCourse) -> DetailViewController {
        let course = Realm().objects(Course).filter("number = '\(tempCourse.number)' AND shortField = '\(tempCourse.shortField)'").first!
        return self.detailViewControllerWithCourse(course)
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
        self.view.addSubview(tableView)
        constrain(self.view, tableView, {view, scrollView in
            scrollView.edges == view.edges
        })
        self.view.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        self.setNavigationBarTitle("\(course.shortField) \(course.number)")
//        self.configureLocationLabel()
        self.getReportFromServer()
//        self.breakdownView.updateWithDictionary(NSDictionary(dictionary: ["responses": NSDictionary()]))
    }
    
    func layoutCourseInfoCard() {
        self.titleLabel.text = self.course.title
        self.titleLabel.textColor = UIColor.blackColor()
        
        self.descriptionLabel.text = self.course.courseDescription
        self.descriptionLabel.textColor = UIColor.blackColor()
        
        self.configureLocationLabel()
        self.courseInstructorLabel.attributedText = NSAttributedString(string: self.course.display.faculty)
        self.courseMeetingLabel.attributedText = NSAttributedString(string: self.course.display.meetings)
        self.satisfiesLabel.attributedText = NSAttributedString(string: self.course.display.genEds)
    }
    
    func configureLocationLabel() {
        
        self.courseLocationLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        self.courseLocationLabel.delegate = self
        let locationString = self.course.display.locations
        if locationString == "TBD" {
            self.courseLocationLabel.text = locationString
        } else {
            self.courseLocationLabel.text = locationString + " Map"
            let range = (self.courseLocationLabel.text! as NSString).rangeOfString("Map")
            let location = self.course.locations.first!
            let encodedSearch = location.building.stringByReplacingOccurrencesOfString(" ", withString: "+")
            let mapURL = NSURL(string: "https://m.harvard.edu/map/map?search=Search&filter=\(encodedSearch)&feed=*")
            self.courseLocationLabel.addLinkToURL(mapURL!, withRange: range)
        }
    }
    
    func getReportFromServer() {
        let urlString = "glaring-heat-9505.firebaseIO.com/\(self.course.display.serverTitle)"
        let root = Firebase(url: urlString)
        weak var weakSelf = self
        root.observeSingleEventOfType(FEventType.Value, withBlock: {snapshot in
            if let report = ReportParser.reportFromSnapshot(snapshot) {
                self.report = report
                weakSelf?.breakdownCell.updateWithReport(report)
            } else {
                self.reportLookupFailed = true
                weakSelf?.breakdownCell.updateForNoBreakdownFound()
            }
        })
    }
    
    func viewCommentsButtonClicked(button: UIButton) {
//        
//        if report.comments.count > 0 {
//            let commentsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("commentsController") as! CommentsViewController
//            self.navigationController?.pushViewController(commentsController, animated: true)
//        } else {
////            [self.viewCommentsButton setTitle:@"No comments reported :(" forState:UIControlStateNormal];
//        }
        
    }
}

extension DetailViewController: BreakdownCellDelegate {
    
    func viewDetailedBreakdownPressed() {
//        let breakdownController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("QBreakdownViewController") as! QBreakdownViewController
        let breakdownController = BreakdownViewController()
        breakdownController.report = report!
        breakdownController.course = course
//        breakdownController.course = self.course
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
            cell.updateWithCourse(course)
            return cell
        } else {
            breakdownCell = tableView.dequeueReusableCellWithIdentifier("breakdown") as? BreakdownCell ?? BreakdownCell(style: .Default, reuseIdentifier: "breakdown")
            breakdownCell.delegate = self
            breakdownCell.initialLayoutWithCourse(course)
            if let _ = report {
                breakdownCell.updateWithReport(report!)
            } else if reportLookupFailed {
                breakdownCell.updateForNoBreakdownFound()
            }
            return breakdownCell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}

extension DetailViewController: TTTAttributedLabelDelegate {
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        
        let mapController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mapController") as! MapViewController
        mapController.request = NSURLRequest(URL: url)
        mapController.title = self.course.locations.first!.building
        self.navigationController?.pushViewController(mapController, animated: true)
    }
}
