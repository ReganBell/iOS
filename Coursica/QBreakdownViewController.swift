//
//  QBreakdownViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/13/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

class QBreakdownViewController: CoursicaViewController {
//    var report: QReport
    var course: Course!
    
    var cards: [UIView]!
    @IBOutlet var generalView: UIView!
    
    @IBOutlet var recommendScoreLabel: UILabel!
    @IBOutlet var workloadHoursLabel: UILabel!
    @IBOutlet var mostlyTakenAsLabel: UILabel!
    @IBOutlet var enrollmentLabel: UILabel!
    
    @IBOutlet var assignmentsScoreLabel: UILabel!
    @IBOutlet var feedbackScoreLabel: UILabel!
    @IBOutlet var materialsScoreLabel: UILabel!
    @IBOutlet var sectionsScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarTitle("\(course.shortField) \(course.number)")
        for card in cards {
            card.layer.cornerRadius = 4
        }
        let formatter = NSNumberFormatter()
        formatter.roundingMode = NSNumberFormatterRoundingMode.RoundHalfUp
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        
//        if let recommend = self.report.responses["Would You Recommend"] as? QResponse {
//            recommendScoreLabel.text = formatter.stringFromNumber(recommend.mean)
//        }
//        if let workload = self.report.responses["Workload (hours per week)"] {
//            let workloadHours = workload.mean.floatValue * 3
//            workloadHoursLabel.text =
//        }
        self.enrollmentLabel.text = "104"
    }
}
