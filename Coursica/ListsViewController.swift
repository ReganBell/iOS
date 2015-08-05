//
//  ListsViewController.swift
//  Coursica
//
//  Created by Regan Bell on 6/24/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography
import pop
import Alamofire

let coursicaBlue = UIColor(red:31/255.0, green:148/255.0, blue:255/255.0, alpha:1.0)
let importButtonWidth: CGFloat = 212

protocol ListsViewControllerDelegate {
    func didSelectTempCourse(tempCourse: TempCourse)
}

class ListsViewController: UIViewController {
    
    var lists: [CourseList] = []
    var tableView = UITableView()
    var delegate: ListsViewControllerDelegate?
    var promptLabel: UILabel!
    var passwordField: UITextField!
    var importSubmitButton: UIButton!
    var importProgressBarBackground: UIView!
    var importProgressBar: UIView!
    var progressBarConstraint: NSLayoutConstraint!
    var coursesAdded: Int = 0
    var coursesToAdd: Int = 0
    var listsAdded: Int = 0
    var listsToAdd: Int = 0
    
    override func viewDidLoad() {
        self.view.addSubview(tableView)
        tableView.backgroundColor = UIColor(white: 241/255.0, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        constrain(tableView, {table in
            table.edges == table.superview!.edges
        })
        self.layoutImportFooterView()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.refreshLists()
    }
    
    func refreshLists() {
        
        weak var weakSelf = self
        CourseList.fetchListsForCurrentUserWithCompletion({lists in
            if let lists = lists {
                weakSelf!.lists = lists
                weakSelf!.tableView.reloadData()
            }
        })
    }
    
    func layoutImportFooterView() {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 135))
        footerView.backgroundColor = tableView.backgroundColor
        
        let promptLabel = UILabel(frame: CGRectZero)
        promptLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        promptLabel.text = "Already have lists saved in CS50 Courses?"
        promptLabel.sizeToFit()
        promptLabel.textColor = UIColor(white: 142/255.0, alpha: 1.0)
        footerView.addSubview(promptLabel)
        constrain(promptLabel, {prompt in
            prompt.top == prompt.superview!.top + 20
            prompt.centerX == prompt.superview!.centerX
        })
        self.promptLabel = promptLabel
        
        let passwordField = UITextField(frame: CGRect(x: 0, y: 0, width: importButtonWidth, height: 41))
        passwordField.placeholder = "password"
        passwordField.layer.cornerRadius = 4.0
        passwordField.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        passwordField.backgroundColor = UIColor.whiteColor()
        passwordField.secureTextEntry = true
        footerView.addSubview(passwordField)
        constrain(passwordField, promptLabel, {passwordField, prompt in
            passwordField.centerX == passwordField.superview!.centerX
            passwordField.top == prompt.bottom + 10
            passwordField.width == importButtonWidth
            passwordField.height == 41
        })
        passwordField.addTarget(self, action: "passwordDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        self.passwordField = passwordField
        
        let leftInsetView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 41))
        leftInsetView.backgroundColor = passwordField.backgroundColor;
        passwordField.leftView = leftInsetView
        passwordField.leftViewMode = UITextFieldViewMode.Always
        
        let rightInsetView = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 41))
        rightInsetView.setTitle("Go", forState: UIControlState.Normal)
        rightInsetView.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        rightInsetView.hidden = true
        rightInsetView.addTarget(self, action: "goButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        rightInsetView.backgroundColor = coursicaBlue
        passwordField.rightViewMode = UITextFieldViewMode.Always
        passwordField.rightView = rightInsetView
        importSubmitButton = rightInsetView
        
        let importButton = UIButton(frame: CGRect(x: 0, y: 0, width: importButtonWidth, height: 41))
        importButton.setTitle("Import", forState: UIControlState.Normal)
        importButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        importButton.backgroundColor = coursicaBlue
        importButton.layer.cornerRadius = 4.0
        importButton.addTarget(self, action: "importButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        footerView.addSubview(importButton)

        let progressBarBackground = UIView(frame: CGRect(x: 0, y: 0, width: importButtonWidth, height: 41))
        progressBarBackground.backgroundColor = UIColor.whiteColor()
        progressBarBackground.layer.cornerRadius = 4.0
        progressBarBackground.clipsToBounds = true
        progressBarBackground.alpha = 0
        footerView.addSubview(progressBarBackground)
        constrain(passwordField, importButton, progressBarBackground, {passwordField, importButton, progressBackground in
            align(centerX: passwordField, importButton, progressBackground)
            align(top: passwordField, importButton, progressBackground)
            align(left: passwordField, importButton, progressBackground)
            align(right: passwordField, importButton, progressBackground)
            align(bottom: passwordField, importButton, progressBackground)
        })
        importProgressBarBackground = progressBarBackground
        
        let progressBar = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 41))
        progressBar.backgroundColor = coursicaBlue
        progressBarBackground.addSubview(progressBar)
        constrain(progressBar, {progress in
            progress.left == progress.superview!.left
            progress.top == progress.superview!.top
            self.progressBarConstraint = (progress.width == 0)
            progress.height == progress.superview!.height
        })
        self.importProgressBar = progressBar
        
        tableView.tableFooterView = footerView
    }
    
    func goButtonPressed(button: UIButton) {
        self.importProgressBarBackground?.alpha = 1
        self.animateImportPercentComplete(0.4, duration: 15, message: "Logging you in...")
        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
        ListsImporter.shared.getListsWithPassword(passwordField.text!)
    }
    
    func passwordDidChange(textField: UITextField) {
        self.importSubmitButton?.hidden = count(textField.text) < 1
    }
    
    func importButtonPressed(importButton: UIButton) {
        ListsImporter.shared.getLogIn({success, errorMessage in
            
        })
        UIView.animateWithDuration(0.3, animations: {
            importButton.alpha = 0
            self.promptLabel?.text = "Re-enter the password you use with your HUID"
            self.passwordField?.becomeFirstResponder()
        })
    }
    
    func headerViewForList(list: CourseList, tableView: UITableView) -> UIView {
        
        let headerView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: tableView.bounds.size.width, height: 44)))
        headerView.backgroundColor = UIColor(white: 241/255.0, alpha: 1)
        let headerLabel = UILabel(frame: CGRectZero)
        headerLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        headerLabel.text = list.name
        headerLabel.sizeToFit()
        headerLabel.textColor = UIColor(white: 142/255.0, alpha: 1.0)
        headerView.addSubview(headerLabel)
        constrain(headerLabel, {header in
            header.center == header.superview!.center
        })
        return headerView
    }
    
    func animateImportPercentComplete(percentComplete: CGFloat, duration: CFTimeInterval, message: String) {
        
        let progressAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        progressAnim.toValue = NSNumber(float: Float(importButtonWidth * percentComplete))
        progressAnim.duration = duration
        self.progressBarConstraint?.pop_removeAllAnimations()
        self.progressBarConstraint?.pop_addAnimation(progressAnim, forKey: "progressAnim")

    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
}

extension ListsViewController: LoginWebViewDelegate {
    
    func didDownloadList(list: CourseList) {
        coursesToAdd += list.courses.count
        listsAdded += 1
        
        for tempCourse in list.courses {
            CourseList.addTempCourseToListWithName(list.name, tempCourse: tempCourse, completionBlock: {error in
                if error != nil {
                    print(error)
                } else {
                    self.coursesAdded++
                    let maybePluralCourses = self.coursesAdded == 1 ? "course" : "courses"
                    self.promptLabel?.text = "Downloaded \(self.coursesAdded)/\(self.coursesToAdd) \(maybePluralCourses)..."
                    if self.listsAdded == self.listsToAdd && self.coursesAdded == self.coursesToAdd {
                        
                        self.promptLabel?.text = "Success!"
                        let progressAnim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                        progressAnim.toValue = NSNumber(float: Float(importButtonWidth))
                        self.progressBarConstraint?.pop_removeAllAnimations()
                        self.progressBarConstraint?.pop_addAnimation(progressAnim, forKey: "progressAnim")
                        self.refreshLists()
                    }
                }
            })
        }
    }
    
    func didLoadCS50CoursesSuccessfullyWithLists(lists: [CourseList]) {
        
        self.listsToAdd = lists.count
        
        self.animateImportPercentComplete(0.9, duration: 1, message: "Downloading lists...")
        
        for list in lists {
            coursesToAdd += list.courses.count
            let parameters = ["id":list.id, "sortDir":"null", "sortField":"null"]
            
            Alamofire.request(.POST, "https://courses.cs50.net/lists/getFromSolr", parameters: parameters)
                .responseJSON { (request, response, JSON, error) in
                    
                    if let dictionary = JSON as? NSDictionary {
                        list.setCoursesFromJSON(dictionary)
                        self.didDownloadList(list)
                    } else {
                        println(error)
                    }
            }
        }
    }
    
    func didLoginSuccessfullyWithHUID(huid: String) {
        self.animateImportPercentComplete(0.6, duration: 10, message: "Importing...")
    }
    
    func didFailWithError(error: LoginErrorType) {
        
        self.progressBarConstraint?.pop_removeAllAnimations()
        self.importProgressBarBackground?.alpha = 0

        switch error {
        case .NetworkError:
            self.promptLabel?.text = "Error connecting to the network :("
        case .InvalidCredentials:
            self.promptLabel?.text = "Incorrect password :("
            let shakeAnim = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
            shakeAnim.springBounciness = 10
            shakeAnim.velocity = NSNumber(integer: 500)
            self.passwordField?.pop_addAnimation(shakeAnim, forKey: "shake")
        }
        
    }
}

extension ListsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let list = lists[indexPath.section]
            let tempCourse = list.courses[indexPath.row]
            let shouldDeleteSection = list.removeTempCourse(tempCourse)
            if shouldDeleteSection {
                lists.removeAtIndex(indexPath.section)
                tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
            } else {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.section != destinationIndexPath.section {
            CourseList.moveCourseFromList(lists[sourceIndexPath.section],
                toList: lists[destinationIndexPath.section],
                tempCourse: lists[sourceIndexPath.section].courses[sourceIndexPath.row])
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return lists.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists[section].courses.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headerViewForList(lists[section], tableView: tableView)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.delegate!.didSelectTempCourse(lists[indexPath.section].courses[indexPath.row])
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell ?? UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        let course = self.lists[indexPath.section].courses[indexPath.row]
        
        let plain = "\(course.shortField) \(course.number) - \(course.title)"
        let boldRange = (plain as NSString).rangeOfString(course.title)
        let fancy = NSMutableAttributedString(string: plain)
        let regularFont = UIFont(name: "AvenirNext-Regular", size: 14)
        let boldFont = UIFont(name: "AvenirNext-DemiBold", size: 17)
        fancy.addAttributes([NSFontAttributeName: regularFont!, NSForegroundColorAttributeName: UIColor(white: 150/255.0, alpha: 1)], range: NSMakeRange(0, count(plain)))
        fancy.addAttributes([NSFontAttributeName: boldFont!,    NSForegroundColorAttributeName: UIColor.blackColor()],                range: boldRange)
        cell.textLabel!.attributedText = fancy
        return cell as UITableViewCell
    }
}