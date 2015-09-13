//
//  InfoCell.swift
//  Coursica
//
//  Created by Regan Bell on 7/19/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography
import RealmSwift
import TTTAttributedLabel

protocol InfoCellDelegate {
    func mapButtonPressed(urlString: String)
    func courseLinkPressed(course: Course)
    func facultyLinkPressed(faculty: Faculty)
    func expandedNeededFor()
}

class InfoCell: UITableViewCell {
    
    let redColor = UIColor(rgba: "#FF1F1F")
    
    let leftLabelMargin: CGFloat = 16
    var labelWidth: CGFloat {
        return (count(course.prerequisitesString) > 0 || Realm().objects(Course).filter(NSPredicate(format: "ANY prerequisites.title = %@", course.title)).count > 0) ? 80 : 70
    }
    
    let cardMargin: CGFloat = 10
    let rightLabelMargin: CGFloat = 10
    let labelDisplaySpacing: CGFloat = 6
    var maxDisplayLabelWidth: CGFloat {
        return UIScreen.mainScreen().bounds.size.width - cardMargin - leftLabelMargin - labelWidth - labelDisplaySpacing - rightLabelMargin - cardMargin
    }
    
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var roundedBackgroundView = UIView()
    
    var offeredLeftLabel: UILabel?
    var offeredDisplayLabel: UILabel?
    
    var instructorLeftLabel: UILabel!
    var instructorDisplayLabel: TTTAttributedLabel!
    
    var meetsLeftLabel: UILabel!
    var meetsDisplayLabel: UILabel!
    
    var meets_satisfiesGroup: ConstraintGroup!
    
    var satisfiesLeftLabel: UILabel!
    var satisfiesDisplayLabel: UILabel!
    
    var enrollmentLeftLabel: UILabel!
    var enrollmentDisplayLabel: UILabel!
    
    var prerequisitesLeftLabel: UILabel!
    var prerequisitesDisplayLabel: TTTAttributedLabel!
    
    var neededForLeftLabel: UILabel!
    var neededForDisplayLabel: TTTAttributedLabel!
    var neededForExpanded = false
    
    var course: Course!
    var delegate: InfoCellDelegate!
    
    let italic = UIFont(name: "AvenirNext-Italic", size: 13)!
    let bold = UIFont(name: "AvenirNext-Bold", size: 13)!
    
    func intFromMilitaryTime(var militaryTime: String) -> Int {
        
        let spaceComponents = militaryTime.componentsSeparatedByString(" ")
        if spaceComponents.count > 1 {
            militaryTime = spaceComponents[1]
        }
        
        let components = militaryTime.componentsSeparatedByString(":")
        let rawHours = components[0] as NSString
        let rawMinutes = components[1] as NSString
        return rawHours.integerValue * 10 + Int(rawMinutes.floatValue / 6.0)
    }
    
    func meetingsDoConflict(a: Meeting, b: Meeting) -> Bool {
        if a.day != b.day {
            return false
        }
        let aStartInt = intFromMilitaryTime(a.beginTime)
        let aEndInt  = intFromMilitaryTime(a.endTime)
        let bStartInt = intFromMilitaryTime(b.beginTime)
        let bEndInt   = intFromMilitaryTime(b.endTime)
        if aStartInt == bStartInt && aEndInt == bEndInt {
            return true
        } else if aStartInt >= bStartInt && aStartInt < bEndInt {
            return true
        } else if aEndInt > bStartInt && aEndInt <= bEndInt {
            return true
        }
        return false
    }
    
    func updateWithShoppingList(courses: [Course]) {
        if let first = course.meetings.first {
            var conflicts: Set<Course> = []
            for conflictCourse in courses {
                if conflictCourse.title == course.title || conflictCourse.term != course.term {
                    continue
                }
                for potentialConflict in conflictCourse.meetings {
                    for courseMeeting in course.meetings {
                        if meetingsDoConflict(courseMeeting, b: potentialConflict) {
                            conflicts.insert(conflictCourse)
                        }
                    }
                }
            }
            if conflicts.count > 0 {
                updateUIForConflicts(conflicts)
            }
        }
    }
    
    func updateUIForConflicts(conflicts: Set<Course>) {
        
        meetsDisplayLabel.attributedText = attributedMeetsStringForCourse(course, conflicts: true)
        
        let conflictsLeftLabel = leftItalicLabel("Conflicts:")
        var labels: [UILabel] = []
        for conflict in conflicts {
            labels.append(displayLabel(attributedConflictStringForCourse(conflict)))
        }
        constrain(conflictsLeftLabel, meetsDisplayLabel, replace: meets_satisfiesGroup, {conflicts, meets in
            conflicts.top == meets.bottom + 10
        })
        constrain([conflictsLeftLabel] + labels, {labels in
            let left = labels[0]
            for (index, label) in enumerate(labels) {
                if index == 0 {continue}
                if index == 1 {label.top == left.top}
                else {
                    label.top == labels[index - 1].bottom + 10
                }
            }
        })
        constrain(labels.last!, satisfiesLeftLabel, {last, satisfies in
            satisfies.top == last.bottom + 10
        })
    }
    
    func attributedConflictStringForCourse(course: Course) -> NSAttributedString {
        let courseName = course.shortField + " " + course.number
        let conflictTime = course.display.meetingsLetters
        let conflict =  courseName + "   " + conflictTime
        let attributedConflict = NSMutableAttributedString(string: conflict)
        attributedConflict.addFontAndColor(bold, color: redColor, substring: courseName)
        attributedConflict.addFontAndColor(italic, color: UIColor.grayColor(), substring: conflictTime)
        return attributedConflict
    }
    
    func leftItalicLabel(text: String) -> UILabel {
        let italicLabel = label(text)
        italicLabel.font = italic
        italicLabel.textAlignment = .Right
        roundedBackgroundView.addSubview(italicLabel)
        constrain(italicLabel, {label in
            label.width == self.labelWidth
            label.height == 18
            label.left == label.superview!.left + self.leftLabelMargin
        })
        return italicLabel
    }
    
    func displayLabel(text: NSObject) -> UILabel {
        let displayLabel = label("")
        displayLabel.preferredMaxLayoutWidth = maxDisplayLabelWidth
        displayLabel.textAlignment = .Left
        displayLabel.font = bold
        roundedBackgroundView.addSubview(displayLabel)
        constrain(displayLabel, {display in
            display.left == display.superview!.left + self.leftLabelMargin + self.labelWidth + self.labelDisplaySpacing
            display.right == display.superview!.right - self.rightLabelMargin
        })

        switch text {
        case let plainText as String: displayLabel.text = plainText
        case let attributedText as NSAttributedString: displayLabel.attributedText = attributedText
        default: fatalError("Unexpected display text type")
        }
        return displayLabel
    }
    
    func attributedInstructorsLabelForCourse(course: Course) -> TTTAttributedLabel {
        let prerequisitesInstructorsLabel = TTTAttributedLabel(frame: CGRectZero)
        let attributes =
           [NSForegroundColorAttributeName:  coursicaBlue,
            NSUnderlineColorAttributeName:   coursicaBlue,
            NSUnderlineStyleAttributeName:   NSNumber(integer: 0)]
        prerequisitesInstructorsLabel.activeLinkAttributes = attributes
        prerequisitesInstructorsLabel.linkAttributes = attributes
        let string = course.display.faculty
        let attributed = NSMutableAttributedString(string: string)
        attributed.addFont(bold, substring: string)
        prerequisitesInstructorsLabel.attributedText = attributed
        for faculty in course.faculty {
            if !faculty.last.isEmpty {
                let matchString = faculty.fullName
                prerequisitesInstructorsLabel.addLinkToAddress([matchString: faculty], withRange: (string as NSString).rangeOfString(matchString))
            }
        }
        prerequisitesInstructorsLabel.delegate = self
        prerequisitesInstructorsLabel.backgroundColor = UIColor.whiteColor()
        prerequisitesInstructorsLabel.opaque = true
        prerequisitesInstructorsLabel.numberOfLines = 0
        prerequisitesInstructorsLabel.preferredMaxLayoutWidth = maxDisplayLabelWidth
        roundedBackgroundView.addSubview(prerequisitesInstructorsLabel)
        return prerequisitesInstructorsLabel
    }
    
    func attributedPrerequisitesLabel(course: Course) -> TTTAttributedLabel {
        let prerequisitesDisplayLabel = TTTAttributedLabel(frame: CGRectZero)
        let attributes =
           [NSForegroundColorAttributeName: coursicaBlue,
            NSUnderlineColorAttributeName:  coursicaBlue,
            NSUnderlineStyleAttributeName:  NSNumber(integer: 0)]
        prerequisitesDisplayLabel.activeLinkAttributes = attributes
        prerequisitesDisplayLabel.linkAttributes = attributes
        prerequisitesDisplayLabel.attributedText = attributedPrerequisitesString(course)
        for match in PrerequisitesParser().processPrerequisiteString(course) {
            prerequisitesDisplayLabel.addLinkToAddress([match.course.title: match.course], withRange: match.range)
        }
        prerequisitesDisplayLabel.delegate = self
        prerequisitesDisplayLabel.backgroundColor = UIColor.whiteColor()
        prerequisitesDisplayLabel.opaque = true
        prerequisitesDisplayLabel.numberOfLines = 0
        prerequisitesDisplayLabel.preferredMaxLayoutWidth = maxDisplayLabelWidth
        roundedBackgroundView.addSubview(prerequisitesDisplayLabel)
        return prerequisitesDisplayLabel
    }
    
    func neededForString(neededFor: Results<Course>) -> String {
        var string = ""
        for (i, course) in enumerate(neededFor) {
            if i < (neededForExpanded ? 100000 : 2) {
                string += (string.isEmpty ? "":", ") + "\(course.shortField) \(course.number)"
            } else {
                string += ", and \(neededFor.count - 2) more..."
                break
            }
        }
        return string
    }
    
    func configureAttributedNeededForLabel(label: TTTAttributedLabel, neededFor: Results<Course>) {
        let attributes =
           [NSForegroundColorAttributeName: coursicaBlue,
            NSUnderlineColorAttributeName:  coursicaBlue,
            NSUnderlineStyleAttributeName:  NSNumber(integer: 0)]
        neededForDisplayLabel.activeLinkAttributes = attributes
        neededForDisplayLabel.linkAttributes = attributes
        let source = neededForString(neededFor)
        let attributedNeededFor = NSMutableAttributedString(string: source)
        attributedNeededFor.addFont(bold, substring: source)
        neededForDisplayLabel.attributedText = attributedNeededFor
        for (i, course) in enumerate(neededFor) {
            if i < (neededForExpanded ? 100000 : 2) {
                neededForDisplayLabel.addLinkToAddress(["\(course.shortField) \(course.number)": course], withRange: (source as NSString).rangeOfString("\(course.shortField) \(course.number)"))
            } else {
                neededForDisplayLabel.addLinkToAddress(["more": "more"], withRange: (source as NSString).rangeOfString("\(neededFor.count - 2) more..."))
                break
            }
        }
        neededForDisplayLabel.delegate = self
        neededForDisplayLabel.backgroundColor = UIColor.whiteColor()
        neededForDisplayLabel.opaque = true
        neededForDisplayLabel.numberOfLines = 0
        neededForDisplayLabel.preferredMaxLayoutWidth = maxDisplayLabelWidth
    }
    
    func attributedMeetsStringForCourse(course: Course, conflicts: Bool) -> NSAttributedString {
        let locationsString = course.display.locations == "TBD" ? course.display.locations : (course.display.locations + " Map")
        let meetsString = course.display.meetingsShort + " in " + locationsString
        let attributedMeets = NSMutableAttributedString(string: meetsString)
        attributedMeets.addFont(bold, substring: meetsString)
        let greenColor = UIColor(red: 30/255.0, green: 190/255.0, blue: 56/255.0, alpha: 1.0)
        attributedMeets.addColor(conflicts ? redColor : greenColor, substring: course.display.meetingsShort)
        attributedMeets.addColor(coursicaBlue, substring: "Map")
        attributedMeets.addAttribute(NSUnderlineColorAttributeName, value: coursicaBlue, substring: "Map")
        attributedMeets.addAttribute(NSUnderlineStyleAttributeName, value: NSNumber(integer: 1), substring: "Map")
        attributedMeets.addFont(italic, substring: "in")
        return attributedMeets
    }
    
    func attributedEnrollmentStringForCourse(course: Course) -> NSAttributedString {
        let enrollmentString = "\(course.enrollment)" + " " + course.display.enrollmentSource
        let attributedEnrollment = NSMutableAttributedString(string: enrollmentString)
        attributedEnrollment.addFontAndColor(bold, color: UIColor.blackColor(), substring: enrollmentString)
        attributedEnrollment.addFontAndColor(italic, color: UIColor.grayColor(), substring: course.display.enrollmentSource)
        return attributedEnrollment
    }
    
    func attributedPrerequisitesString(course: Course) -> NSAttributedString {
        let string = course.prerequisitesString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "."))
        let attributedPrerequisites = NSMutableAttributedString(string: string)
        attributedPrerequisites.addFont(bold, substring: string)
        return attributedPrerequisites
    }
    
    func mapButtonPressed() {
        let encodedSearch = course.locations.first!.building.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let mapURLString = "https://m.harvard.edu/map/map?search=Search&filter=\(encodedSearch)&feed=*"
        delegate.mapButtonPressed(mapURLString)
    }

    func updateWithCourse(course: Course) {
        
        self.course = course
        roundedBackgroundView.backgroundColor = UIColor.whiteColor()
        contentView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        roundedBackgroundView.layer.cornerRadius = 4
        contentView.addSubview(roundedBackgroundView)
        
        titleLabel = label(course.title)
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 17)
        titleLabel.textAlignment = .Center
        let width = UIScreen.mainScreen().bounds.size.width
        titleLabel.preferredMaxLayoutWidth = width - 60
        
        descriptionLabel = label(course.courseDescription)
        descriptionLabel.font = UIFont(name: "Avenir Next", size: 13)
        descriptionLabel.preferredMaxLayoutWidth = width - 46
        roundedBackgroundView.addSubview(descriptionLabel)
        roundedBackgroundView.addSubview(titleLabel)
        
        constrain(titleLabel, descriptionLabel, roundedBackgroundView, {title, description, view in
            title.left == view.left + 20
            title.right == view.right - 20
            title.top == view.top + 10
            description.left == view.left + self.leftLabelMargin
            description.right == view.right - self.rightLabelMargin
            description.top == title.bottom + 10
        })
        
        if count(course.term) > 0 {
            
            offeredLeftLabel = leftItalicLabel("Offered:")
            constrain(offeredLeftLabel!, descriptionLabel, {instructor, description in
                instructor.top == description.bottom + 10
            })
            
            offeredDisplayLabel = displayLabel(course.term.capitalizedString)
            constrain(offeredDisplayLabel!, offeredLeftLabel!, {display, leftLabel in
                display.top == leftLabel.top
            })
        }
        
        instructorLeftLabel = course.faculty.count > 1 ? leftItalicLabel("Instructors:") : leftItalicLabel("Instructor:")
        var aboveLabel = (offeredDisplayLabel == nil) ? descriptionLabel : offeredDisplayLabel
        constrain(instructorLeftLabel, aboveLabel, {instructor, above in
            instructor.top == above.bottom + 10
        })
        
        instructorDisplayLabel = attributedInstructorsLabelForCourse(course)
        constrain(instructorDisplayLabel, {display in
            display.left == display.superview!.left + self.leftLabelMargin + self.labelWidth + self.labelDisplaySpacing
            display.right == display.superview!.right - self.rightLabelMargin
        })
        constrain(instructorDisplayLabel, instructorLeftLabel, {display, leftLabel in
            display.top == leftLabel.top
        })

        meetsLeftLabel = leftItalicLabel("Meets:")
        constrain(meetsLeftLabel, instructorDisplayLabel, {meets, instructorDisplay in
            meets.top == instructorDisplay.bottom + 10
        })
        
        meetsDisplayLabel = displayLabel(attributedMeetsStringForCourse(course, conflicts: false))
        meetsDisplayLabel.userInteractionEnabled = true
        if course.display.locations != "TBD" {
            let mapButton = UIButton()
            mapButton.addTarget(self, action: "mapButtonPressed", forControlEvents: .TouchUpInside)
            mapButton.backgroundColor = UIColor.clearColor()
            addSubview(mapButton)
            constrain(mapButton, meetsDisplayLabel, {button, displayLabel in
                button.edges == displayLabel.edges
            })
        }
        constrain(meetsDisplayLabel, meetsLeftLabel, instructorDisplayLabel, {display, label, instructor in
            display.top == label.top
        })
        
        satisfiesLeftLabel = leftItalicLabel("Satisfies:")
        meets_satisfiesGroup = constrain(satisfiesLeftLabel, meetsDisplayLabel, {satisfies, meets in
            satisfies.top == meets.bottom + 10
        })
        
        satisfiesDisplayLabel = displayLabel(course.display.genEds)
        constrain(satisfiesDisplayLabel, satisfiesLeftLabel, {display, leftLabel in
            display.top == leftLabel.top
        })
        
        var lastLabel = satisfiesDisplayLabel
        var abovePrerequisitesLabel = satisfiesDisplayLabel
        
        if course.enrollment != 0 {
            enrollmentLeftLabel = leftItalicLabel("Enrollment:")
            constrain(enrollmentLeftLabel, satisfiesDisplayLabel, {enrollment, satisfies in
                enrollment.top == satisfies.bottom + 10
            })
            
            enrollmentDisplayLabel = displayLabel(attributedEnrollmentStringForCourse(course))
            constrain(enrollmentDisplayLabel, enrollmentLeftLabel, {display, label in
                display.top == label.top
            })
            lastLabel = enrollmentDisplayLabel
            abovePrerequisitesLabel = enrollmentDisplayLabel
        }
        
        if count(course.prerequisitesString) > 0 {
            prerequisitesLeftLabel = leftItalicLabel("Prerequisites:")
            constrain(prerequisitesLeftLabel, abovePrerequisitesLabel, {prereq, above in
                prereq.top == above.bottom + 10
            })
            
            prerequisitesDisplayLabel = attributedPrerequisitesLabel(course)
            constrain(prerequisitesDisplayLabel, {display in
                display.left == display.superview!.left + self.leftLabelMargin + self.labelWidth + self.labelDisplaySpacing
                display.right == display.superview!.right - self.rightLabelMargin
            })
            constrain(prerequisitesDisplayLabel, prerequisitesLeftLabel, {display, left in
                display.top == left.top
            })
            
            lastLabel = prerequisitesDisplayLabel
        }
        
        let sortByEnrollment = SortDescriptor(property: "enrollment", ascending: false)
        let neededFor = Realm().objects(Course).filter(NSPredicate(format: "ANY prerequisites.title = %@", course.title)).sorted([sortByEnrollment])
        if neededFor.count > 0 {
            neededForLeftLabel = leftItalicLabel("Needed for:")
            var aboveLabel: UILabel = abovePrerequisitesLabel
            if count(course.prerequisitesString) > 0 {
                aboveLabel = prerequisitesDisplayLabel
            }
            constrain(neededForLeftLabel, aboveLabel, {prereq, above in
                prereq.top == above.bottom + 10
            })
            
            neededForDisplayLabel = TTTAttributedLabel(frame: CGRectZero)
            configureAttributedNeededForLabel(neededForDisplayLabel, neededFor: neededFor)
            roundedBackgroundView.addSubview(neededForDisplayLabel)
            constrain(neededForDisplayLabel, {display in
                display.left == display.superview!.left + self.leftLabelMargin + self.labelWidth + self.labelDisplaySpacing
                display.right == display.superview!.right - self.rightLabelMargin
            })
            constrain(neededForDisplayLabel, neededForLeftLabel, {display, left in
                display.top == left.top
            })
            
            lastLabel = neededForDisplayLabel
        }
        
        for course in neededFor {
            println(course.display.title)
        }
        
        constrain(roundedBackgroundView, lastLabel, {background, last in
            last.bottom == background.bottom - 10
        })
        
        constrain(roundedBackgroundView, self.contentView, {background, cell in
            background.top == cell.top + 10
            background.left == cell.left + self.cardMargin
            background.right == cell.right - self.cardMargin
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

extension InfoCell: TTTAttributedLabelDelegate {
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithAddress addressComponents: [NSObject : AnyObject]!) {
        if let course = addressComponents.values.first as? Course {
            delegate.courseLinkPressed(course)
        }
        if let faculty = addressComponents.values.first as? Faculty {
            delegate.facultyLinkPressed(faculty)
        }
        if let _ = addressComponents.values.first as? String {
            neededForExpanded = true
            let sortByEnrollment = SortDescriptor(property: "enrollment", ascending: false)
            let neededFor = Realm().objects(Course).filter(NSPredicate(format: "ANY prerequisites.title = %@", course.title)).sorted([sortByEnrollment])
            configureAttributedNeededForLabel(neededForDisplayLabel, neededFor: neededFor)
            delegate.expandedNeededFor()
        }
    }
}

extension NSMutableAttributedString {
    
    func addAttribute(name: String, value: NSObject, substring: String) {
        let range = (string as NSString).rangeOfString(substring)
        if range.location != NSNotFound {
            addAttribute(name, value: value, range: range)
        }
    }
    
    func addColor(color: UIColor, substring: String) {
        addAttribute(NSForegroundColorAttributeName, value: color, substring: substring)
    }
    
    func addFont(font: UIFont, substring: String) {
        addAttribute(NSFontAttributeName, value: font, substring: substring)
    }
    
    func addFontAndColor(font: UIFont, color: UIColor, substring: String) {
        addFont(font, substring: substring)
        addColor(color, substring: substring)
    }
}