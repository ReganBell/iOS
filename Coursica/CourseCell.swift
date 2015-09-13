//
//  CourseCell.swift
//  Coursica
//
//  Created by Regan Bell on 7/30/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography

class CourseCell: ReportCell {
    
    func layoutWithReport(report: Report, legend: Bool) {
        
        commonSetup()
        layoutTitleLabel("Course")
        
        let map = [("Workload (hours per week)",  "Workload"),
            ("Assignments",                "Assignments"),
            ("Feedback",                   "Feedback"),
            ("Materials",                  "Materials"),
            ("Section",                    "Section"),
            ("Would You Recommend",        "Recommend")]
        
        for (index, pair) in enumerate(map) {
            for response in report.responses {
                let (questionKey, questionDisplay) = pair
                if response.question == questionKey {
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
    
    override func legendView() -> LegendView {
        return LegendView(titles: ["Better than similar courses", "Close to similar courses", "Worse than similar courses"], colors: [greenColor, yellowColor, redColor])
    }
}