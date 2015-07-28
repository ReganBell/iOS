//
//  DetailViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class DetailViewController: CoursicaViewController {
    
    var report: QReport!
    var course: Course!
    
    @IBOutlet var infoView: UIView!
    @IBOutlet var qBreakdownView: QBreakdownCardView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var courseInstructorLabel: UILabel!
    @IBOutlet var courseMeetingLabel: UILabel!
    @IBOutlet var courseLocationLabel: TTTAttributedLabel!
    @IBOutlet var courseInfoLabel: UILabel!
    @IBOutlet var satisfiesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutCourseInfoCard()
        self.configureLocationLabel()
        self.getCourseData()
        self.qBreakdownView.updateWithDictionary(NSDictionary(dictionary: ["responses": NSDictionary()]))
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
    
    func getCourseData() {
        let root = Firebase(url: "glaring-heat-9505.firebaseIO.com/\(self.course.display.title.stringEncodedAsFirebaseKey())")
        root.observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
            if snapshot.value is NSNull {
                return
            } else {
                for reportDictionary in snapshot.value.allValues {
                    let report = QReport()
                    report.setFieldsWithList(["term", "year", "enrollment", "comments", "responses"], data: reportDictionary as! NSDictionary)
                    self.report = report
                }
            }
        })
    }
    
    func viewCommentsButtonClicked(button: UIButton) {
        
        if report.comments.count > 0 {
            let commentsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("commentsController") as! CommentsViewController
            self.navigationController?.pushViewController(commentsController, animated: true)
        } else {
//            [self.viewCommentsButton setTitle:@"No comments reported :(" forState:UIControlStateNormal];
        }
        
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
