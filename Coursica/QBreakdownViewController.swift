//
//  QBreakdownViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class QBreakdownViewController: CoursicaViewController {
    
    var tableView: UITableView!
    
    @IBOutlet var generalView: UIView!
    @IBOutlet var courseView: UIView!
    @IBOutlet var instructorView: UIView!
    
    @IBOutlet var recommendScoreLabel: UILabel!
    @IBOutlet var workloadHoursLabel: UILabel!
    @IBOutlet var mostlyTakenAsLabel: UILabel!
    @IBOutlet var enrollmentLabel: UILabel!
    
    @IBOutlet var assignmentsScoreLabel: UILabel!
    @IBOutlet var feedbackScoreLabel: UILabel!
    @IBOutlet var materialsScoreLabel: UILabel!
    @IBOutlet var sectionsScoreLabel: UILabel!
    
    @IBOutlet var assignmentsAnimBarView: AnimationBarView!
    @IBOutlet var feedbackAnimBarView: AnimationBarView!
    @IBOutlet var materialsAnimBarView: AnimationBarView!
    @IBOutlet var sectionsAnimBarView: AnimationBarView!
    
    @IBOutlet var overallAnimBarView: AnimationBarView!
    @IBOutlet var lecturesAnimBarView: AnimationBarView!
    @IBOutlet var accessiblityAnimBarView: AnimationBarView!
    @IBOutlet var enthusiasmAnimBarView: AnimationBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarTitle("Q Breakdown")
        for card in [generalView, courseView, instructorView] {
            card.layer.cornerRadius = 4
        }
        
        for bar in [assignmentsAnimBarView, feedbackAnimBarView, materialsAnimBarView, sectionsAnimBarView, overallAnimBarView, lecturesAnimBarView, accessiblityAnimBarView, enthusiasmAnimBarView] {
            bar.updateWithDictionary(NSDictionary())
        }
        
//        let formatter = NSNumberFormatter()
//        formatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
//        formatter.maximumFractionDigits = 1
//        formatter.minimumFractionDigits = 1
//        
////        if let recommend = self.report.responses["Would You Recommend"] as? QResponse {
////            recommendScoreLabel.text = formatter.stringFromNumber(recommend.mean)
////        }
////        if let workload = self.report.responses["Workload (hours per week)"] {
////            let workloadHours = workload.mean.floatValue * 3
////            workloadHoursLabel.text =
////        }
//        self.enrollmentLabel.text = "104"
    }
}
