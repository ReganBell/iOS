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

let importButtonWidth: CGFloat = 212

protocol ListsViewControllerDelegate {
    func didSelectCourse(listableCourse: ListableCourse)
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
    var secretLoginWebView: LoginWebView?
    var listsAdded: Int = 0
    var listsToAdd: Int = 0
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: self.view.window)
        view.addSubview(tableView)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(white: 241/255.0, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .OnDrag
        constrain(tableView, block: {table in
            table.edges == table.superview!.edges
        })
        layoutImportFooterView()
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshLists()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let height = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size.height {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height + 20, right: 0)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = UIEdgeInsetsZero
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
        constrain(promptLabel, block: {prompt in
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
        constrain(passwordField, promptLabel, block: {passwordField, prompt in
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
        constrain(passwordField, importButton, progressBarBackground, block: {passwordField, importButton, progressBackground in
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
        constrain(progressBar, block: {progress in
            progress.left == progress.superview!.left
            progress.top == progress.superview!.top
            self.progressBarConstraint = (progress.width == 0)
            progress.height == progress.superview!.height
        })
        self.importProgressBar = progressBar
        
        tableView.tableFooterView = footerView
    }
    
    func goButtonPressed(button: UIButton) {
        importProgressBarBackground?.alpha = 1
        animateImportPercentComplete(0.4, duration: 15, message: "Logging you in...")
        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
        secretLoginWebView?.tryUsernameWhenReady(HUID, password: self.passwordField!.text!)

//        ListsImporter.shared.getListsWithPassword(passwordField.text!)
    }
    
    func passwordDidChange(textField: UITextField) {
        importSubmitButton?.hidden = (textField.text?.characters.count ?? 0) < 1
    }
    
    func importButtonPressed(importButton: UIButton) {
        
        let secretWebView = LoginWebView()
        secretWebView.loginDelegate = self
        self.view.insertSubview(secretWebView, atIndex: 0)
        constrain(secretWebView, block: {webView in
            webView.edges == webView.superview!.edges
        })
        secretWebView.loadLoginScreen()
        self.secretLoginWebView = secretWebView
        
//        ListsImporter.shared.getLogIn({success, errorMessage in
//            
//        })
        UIView.animateWithDuration(0.3, animations: {
            importButton.alpha = 0
            self.promptLabel?.text = "Enter the password you use with your HUID"
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
        constrain(headerLabel, block: {header in
            header.center == header.superview!.center
        })
        return headerView
    }
    
    func animateImportPercentComplete(percentComplete: CGFloat, duration: CFTimeInterval, message: String) {
        
        promptLabel?.text = message
        let progressAnim = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        progressAnim.toValue = NSNumber(float: Float(importButtonWidth * percentComplete))
        progressAnim.duration = duration
        progressBarConstraint?.pop_removeAllAnimations()
        progressBarConstraint?.pop_addAnimation(progressAnim, forKey: "progressAnim")
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}

extension ListsViewController: LoginWebViewDelegate {
    
    func didDownloadList(list: CourseList) {
        listsAdded += 1
        
        for course in list.courses {
            CourseList.addCourseToListWithName(list.name, listableCourse: course, completionBlock: {error in
                if error != nil {
                    print(error, terminator: "")
                } else {
                    if self.listsAdded == self.listsToAdd {
                        
                        self.promptLabel?.text = "Success!"
                        let progressAnim = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                        progressAnim.toValue = NSNumber(float: Float(importButtonWidth))
                        progressAnim.completionBlock = {animation, finished in
                            self.layoutImportFooterView()
                        }
                        self.progressBarConstraint?.pop_removeAllAnimations()
                        self.progressBarConstraint?.pop_addAnimation(progressAnim, forKey: "progressAnim")
                        self.refreshLists()
                    }
                }
            })
        }
    }
    
    func didTimeout() {
        self.refreshLists()
        self.layoutImportFooterView()
    }
    
    func didLoadCS50CoursesSuccessfullyWithLists(lists: [CourseList]) {
        
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "didTimeout", userInfo: nil, repeats: false)
        
        self.secretLoginWebView?.removeFromSuperview()
        self.secretLoginWebView = nil
        
        self.listsToAdd = lists.count
        
        self.animateImportPercentComplete(0.9, duration: 5, message: "Downloading lists...")
        
        for list in lists {
            let parameters = ["id":list.id, "sortDir":"null", "sortField":"null"]
            
            Alamofire.request(.POST, "https://courses.cs50.net/lists/getFromSolr", parameters: parameters)
                .responseJSON { request, response, result in
                    switch result {
                    case .Success(let dictionary):
                        if let dictionary = dictionary as? NSDictionary {
                            list.setCoursesFromJSON(dictionary)
                            self.didDownloadList(list)
                        }
                    case .Failure(_, let error):
                        print(error)
                    }
            }
        }
    }
    
    func didLoginSuccessfullyWithHUID(huid: String) {
        self.animateImportPercentComplete(0.6, duration: 1, message: "Importing...")
    }
    
    func didFailWithError(error: LoginErrorType) {
        
        self.secretLoginWebView?.removeFromSuperview()
        self.secretLoginWebView = nil

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
                listableCourse: lists[sourceIndexPath.section].courses[sourceIndexPath.row])
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
        return headerViewForList(lists[section], tableView: tableView)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.didSelectCourse(lists[indexPath.section].courses[indexPath.row])
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? CourseTableViewCell ?? CourseTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        let listableCourse = lists[indexPath.section].courses[indexPath.row]
        let plain = listableCourse.displayTitle
        let boldRange = (plain as NSString).rangeOfString(listableCourse.title)
        let fancy = NSMutableAttributedString(string: plain)
        let regularFont = UIFont(name: "AvenirNext-Regular", size: 14)
        let boldFont = UIFont(name: "AvenirNext-DemiBold", size: 17)
        fancy.addAttributes([NSFontAttributeName: regularFont!, NSForegroundColorAttributeName: UIColor(white: 150/255.0, alpha: 1)], range: NSMakeRange(0, plain.characters.count))
        fancy.addAttributes([NSFontAttributeName: boldFont!,    NSForegroundColorAttributeName: UIColor.blackColor()],                range: boldRange)
        cell.textLabel!.attributedText = fancy
        if let course = listableCourse as? Course {
            cell.colorBarView.backgroundColor = colorForPercentile(course.percentileSize)
        }
        return cell as UITableViewCell
    }
}