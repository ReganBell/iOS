//
//  InstructorCell.swift
//  Coursica
//
//  Created by Regan Bell on 9/7/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import RealmSwift

class InstructorCell: ReportCell {
    
    func layoutWithReport(report: FacultyReport, legend: Bool) {
        
        commonSetup()
        layoutTitleLabel(report.name.decodedFirebaseKey)
        
        let map =
        [("Instructor Overall",                                 "Overall"),
            ("Effective Lectures or Presentations",                 "Lectures"),
            ("Accessible Outside Class",                            "Accessible"),
            ("Generates Enthusiasm",                                "Enthusiasm"),
            ("Facilitates Discussion & Encourages Participation",   "Discussion"),
            ("Gives Useful Feedback",                               "Feedback"),
            ("Returns Assignments in Timely Fashion",               "Turnaround")]
        
        for (index, pair) in map.enumerate() {
            for response in report.responses {
                let (questionKey, questionDisplay) = pair
                if response.question == questionKey {
                    if let average = (try? Realm().objects(FacultyAverage).filter("question = %@", questionKey))?.first {
                        let baseline = Baseline()
                        baseline.group = average.score
                        baseline.size = average.score
                        response.baselineSingleTerm = baseline
                    }
                    let responseView = ResponseBarView(response: response, title: questionDisplay)
                    responseView.response = response
                    responseView.delayTime = CFTimeInterval(index) * 0.1
                    roundedBackgroundView.addSubview(responseView)
                    responseViews.append(responseView)
                    break
                }
            }
        }
        
        layoutResponseViews(legend)
    }
}
