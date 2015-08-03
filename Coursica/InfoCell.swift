//
//  InfoCell.swift
//  Coursica
//
//  Created by Regan Bell on 7/19/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography
import UIKit

class InfoCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    
//    func configureLocationLabel() {
//        
//        self.courseLocationLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
//        self.courseLocationLabel.delegate = self
//        let locationString = self.course.display.locations
//        if locationString == "TBD" {
//            self.courseLocationLabel.text = locationString
//        } else {
//            self.courseLocationLabel.text = locationString + " Map"
//            let range = (self.courseLocationLabel.text! as NSString).rangeOfString("Map")
//            let location = self.course.locations.first!
//            let encodedSearch = location.building.stringByReplacingOccurrencesOfString(" ", withString: "+")
//            let mapURL = NSURL(string: "https://m.harvard.edu/map/map?search=Search&filter=\(encodedSearch)&feed=*")
//            self.courseLocationLabel.addLinkToURL(mapURL!, withRange: range)
//        }
//    }

    func updateWithCourse(course: Course) {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.whiteColor()
        self.contentView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        backgroundView.layer.cornerRadius = 4
        self.contentView.addSubview(backgroundView)
        
        let maxDisplayLabelWidth = UIScreen.mainScreen().bounds.size.width - 10 - 22 - 10 - 35
        
        titleLabel = self.label(course.title)
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 17)
        titleLabel.textAlignment = .Center
        let width = UIScreen.mainScreen().bounds.size.width
        titleLabel.preferredMaxLayoutWidth = width - 60
        
        descriptionLabel = self.label(course.courseDescription)
        descriptionLabel.font = UIFont(name: "Avenir Next", size: 13)
        descriptionLabel.preferredMaxLayoutWidth = width - 46
        backgroundView.addSubview(descriptionLabel)
        backgroundView.addSubview(titleLabel)
        
        constrain(titleLabel, descriptionLabel, backgroundView, {title, description, view in
            title.left == view.left + 20
            title.right == view.right - 20
            title.top == view.top + 10
            description.left == view.left + 16
            description.right == view.right - 10
            description.top == title.bottom + 10
        })
        
        let italic = UIFont(name: "AvenirNext-Italic", size: 13)
        let bold = UIFont(name: "AvenirNext-Bold", size: 13)
        
        let instructorLabel = self.label("Instructor:")
        instructorLabel.font = italic
        instructorLabel.textAlignment = .Right
        backgroundView.addSubview(instructorLabel)
        constrain(instructorLabel, descriptionLabel, {instructor, description in
            instructor.left == instructor.superview!.left + 16
            instructor.top == description.bottom + 10
            instructor.width == 70
            instructor.height == 18
        })
        
        let instructorDisplayLabel = self.label(course.display.faculty)
        instructorDisplayLabel.font = bold
        instructorDisplayLabel.textAlignment = .Left
        instructorDisplayLabel.preferredMaxLayoutWidth = maxDisplayLabelWidth
        backgroundView.addSubview(instructorDisplayLabel)
        constrain(instructorDisplayLabel, instructorLabel, {display, label in
            display.left == label.right + 6
            display.top == label.top
            display.right == display.superview!.right - 10
        })

        let meetsLabel = self.label("Meets:")
        meetsLabel.font = italic
        meetsLabel.textAlignment = .Right
        backgroundView.addSubview(meetsLabel)
        constrain(meetsLabel, instructorLabel, instructorDisplayLabel, {meets, instructor, instructorDisplay in
            meets.left == instructor.left
            meets.width == 70
            meets.height == 18
            meets.top == instructorDisplay.bottom + 10
        })
        
        let meetsDisplayLabel = self.label("")
        meetsDisplayLabel.preferredMaxLayoutWidth = maxDisplayLabelWidth
        let meets = course.display.meetings + " in " + course.display.locations
        let attributedMeets = NSMutableAttributedString(string: meets)
        attributedMeets.addAttribute(NSFontAttributeName, value: bold!, range: NSMakeRange(0, count(meets)))
        let greenColor = UIColor(red: 30/255.0, green: 190/255.0, blue: 56/255.0, alpha: 1.0)
        attributedMeets.addAttribute(NSForegroundColorAttributeName, value: greenColor, range: (meets as NSString).rangeOfString(course.display.meetings))
        attributedMeets.addAttribute(NSFontAttributeName, value: italic!, range: (meets as NSString).rangeOfString("in"))
        attributedMeets.addAttribute(NSFontAttributeName, value: italic!, range: (meets as NSString).rangeOfString("in"))
        meetsDisplayLabel.attributedText = attributedMeets
        meetsDisplayLabel.textAlignment = .Left
        backgroundView.addSubview(meetsDisplayLabel)
        constrain(meetsDisplayLabel, meetsLabel, instructorDisplayLabel, {display, label, instructor in
            display.left == instructor.left
            display.top == label.top
            display.right == display.superview!.right - 10
        })
        
        let satisfiesLabel = self.label("Satisifies:")
        satisfiesLabel.font = italic
        satisfiesLabel.textAlignment = .Right
        backgroundView.addSubview(satisfiesLabel)
        constrain(satisfiesLabel, meetsDisplayLabel, {satisfies, meets in
            satisfies.left == satisfies.superview!.left + 16
            satisfies.top == meets.bottom + 10
            satisfies.width == 70
            satisfies.height == 18
        })
        
        let satisfiesDisplayLabel = self.label(course.display.genEds)
        satisfiesDisplayLabel.font = bold
        satisfiesDisplayLabel.textAlignment = .Left
        satisfiesDisplayLabel.preferredMaxLayoutWidth = maxDisplayLabelWidth
        backgroundView.addSubview(satisfiesDisplayLabel)
        constrain(satisfiesDisplayLabel, satisfiesLabel, {display, label in
            display.left == label.right + 6
            display.top == label.top
            display.right == display.superview!.right - 10
        })
        
        var last = satisfiesDisplayLabel
        
        if course.enrollment != 0 {
            let enrollmentLabel = self.label("Enrollment:")
            enrollmentLabel.font = italic
            enrollmentLabel.textAlignment = .Right
            backgroundView.addSubview(enrollmentLabel)
            constrain(enrollmentLabel, satisfiesDisplayLabel, {enrollment, satisfies in
                enrollment.left == enrollment.superview!.left + 16
                enrollment.top == satisfies.bottom + 10
                enrollment.width == 70
                enrollment.height == 18
            })
            
            let enrollmentDisplayLabel = self.label("")
            enrollmentDisplayLabel.preferredMaxLayoutWidth = maxDisplayLabelWidth
            let enrollment = "\(course.enrollment)" + " " + course.display.enrollmentSource
            let attributedEnrollment = NSMutableAttributedString(string: enrollment)
            attributedEnrollment.addAttribute(NSFontAttributeName, value: bold!, range: NSMakeRange(0, count(enrollment)))
            attributedEnrollment.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, count(enrollment)))
            attributedEnrollment.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: (enrollment as NSString).rangeOfString(course.display.enrollmentSource))
            attributedEnrollment.addAttribute(NSFontAttributeName, value: italic!, range: (enrollment as NSString).rangeOfString(course.display.enrollmentSource))
            enrollmentDisplayLabel.attributedText = attributedEnrollment
            enrollmentDisplayLabel.textAlignment = .Left
            backgroundView.addSubview(enrollmentDisplayLabel)
            constrain(enrollmentDisplayLabel, enrollmentLabel, {display, label in
                display.left == label.right + 6
                display.top == label.top
                display.right == display.superview!.right - 10
            })
            last = enrollmentDisplayLabel
        }
        
        constrain(backgroundView, last, {background, last in
            last.bottom == background.bottom - 10
        })
        
        constrain(backgroundView, self.contentView, {background, cell in
            background.top == cell.top + 10
            background.left == cell.left + 10
            background.right == cell.right - 10
            background.bottom == cell.bottom - 10
        })
    }
    
    func label(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor.blackColor()
        label.backgroundColor = UIColor.whiteColor()
        label.opaque = true
        label.numberOfLines = 0
        return label
    }
}
