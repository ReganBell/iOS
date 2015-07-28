//
//  CoursesViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/14/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import RealmSwift
import PureLayout
import pop

class CoursesViewController: UIViewController, FiltersViewControllerDelegate {

    @IBOutlet var tableView: UITableView!
    var searchBarCenterY: NSLayoutConstraint!
    var coursicaTitleLabel: UILabel!
    var listsTitleLabel: UILabel!
    var listsTitleCenterY: NSLayoutConstraint!
    var coursicaTitleCenterY: NSLayoutConstraint!
    var listsButton: UIButton!
    var listsButtonCenterY: NSLayoutConstraint!
    var listsBackButton: UIButton!
    var listsBackButtonCenterY: NSLayoutConstraint!
    var cancelButtonCenterY: NSLayoutConstraint!
    var searchButtonCenterY: NSLayoutConstraint!
    var listsEditButtonCenterY: NSLayoutConstraint!
    var searchBar: UITextField!
    var _filtersController: FiltersViewController?
    var filtersController: FiltersViewController {
        get {
            if _filtersController == nil {
                _filtersController = self.createFiltersController()
            }
            return _filtersController!
        }
    }
    var _listsController: ListsViewController?
    var listsController: ListsViewController {
        get {
            if _listsController == nil {
                _listsController = self.createListsController()
            }
            return _listsController!
        }
    }
    var cancelButton: UIButton!
    var searchButton: UIButton!
    var listsEditButton: UIButton!
    var courses: Results<Course>?
    
    func titleLabel(title: String) -> UILabel {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        label.text = title
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }
    
    func navBarButton(title: String, imageNamed: String?, target: String?) -> UIButton {
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        let selector = target == nil ? title.lowercaseString + "ButtonPressed:" : target!
        button.addTarget(self, action: Selector(selector), forControlEvents: UIControlEvents.TouchUpInside)
        if let name = imageNamed {
            button.setImage(UIImage(named: name), forState: UIControlState.Normal)
        } else {
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        }
        return button
    }
    
    func navigationBar() -> UIView {
        let navBarView = UIView(frame: CGRect(origin: CGPointZero, size: self.navigationController!.navigationBar.frame.size))
        self.searchBar = self.createSearchBar()
        searchBar.alpha = 0
        navBarView.clipsToBounds = true
        navBarView.addSubview(searchBar)
        navBarView.autoPinEdgeToSuperviewEdge(ALEdge.Right, withInset: 20)
        navBarView.autoPinEdgeToSuperviewEdge(ALEdge.Left, withInset: 10)
        navBarView.autoSetDimension(ALDimension.Height, toSize: 29)
        self.searchBarCenterY = navBarView.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        
        self.coursicaTitleLabel = self.titleLabel("Coursica")
        navBarView.addSubview(coursicaTitleLabel)
        self.coursicaTitleCenterY = coursicaTitleLabel.autoAlignAxisToSuperviewAxis(ALAxis.Horizontal)
        let constant = UIScreen.mainScreen().bounds.size.width / 2 - 8;
        coursicaTitleLabel.autoConstrainAttribute(ALAttribute.Vertical, toAttribute:ALAttribute.Left, ofView:navBarView, withOffset:constant)
        
        self.listsTitleLabel = self.titleLabel("Lists");
        listsTitleLabel.alpha = 0;
        navBarView.addSubview(listsTitleLabel)
        listsTitleLabel.autoConstrainAttribute(ALAttribute.Vertical, toAttribute: ALAttribute.Left, ofView: navBarView, withOffset: constant)
        self.listsTitleCenterY = listsTitleLabel.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView:navBarView)
        
        self.listsButton = self.navBarButton("Lists", imageNamed: "ListIcon", target: nil)
        navBarView.addSubview(listsButton)
        listsButton.autoSetDimension(ALDimension.Width, toSize: 27)
        listsButton.autoSetDimension(ALDimension.Height, toSize: 19)
        listsButton.autoPinEdgeToSuperviewEdge(ALEdge.Left)
        self.listsButtonCenterY = listsButton.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView:navBarView)
        
        self.listsBackButton = self.navBarButton("Back", imageNamed: nil, target: "listsBackButtonPressed:")
        navBarView.addSubview(listsBackButton)
        listsBackButton.alpha = 0
        listsBackButton.autoSetDimension(ALDimension.Width, toSize: 50)
        listsBackButton.autoSetDimension(ALDimension.Height, toSize: 20)
        listsBackButton.autoPinEdgeToSuperviewEdge(ALEdge.Left)
        self.listsBackButtonCenterY = listsBackButton.autoAlignAxis(ALAxis.Horizontal, toSameAxisOfView:navBarView)
        return navBarView
    }
    
    func createSearchBar() -> UITextField {
        let searchBar = UITextField()
        searchBar.backgroundColor = UIColor(red: 31/255.0, green: 117/255.0, blue: 1, alpha: 1)
        searchBar.layer.cornerRadius = 4
        searchBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        searchBar.returnKeyType = UIReturnKeyType.Search
        searchBar.delegate = self
        let font = UIFont(name: "AvenirNext-Medium", size: 14)!
        searchBar.font = font
        searchBar.textColor = UIColor.whiteColor()
        let leftSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        searchBar.leftViewMode = UITextFieldViewMode.Always
        searchBar.leftView = leftSpacerView
        let style = searchBar.defaultTextAttributes[NSParagraphStyleAttributeName]?.mutableCopy() as! NSMutableParagraphStyle
        style.minimumLineHeight = searchBar.font.lineHeight - (searchBar.font.lineHeight - font.lineHeight) / 2.0
        let string = "Search for courses"
        let placeholder = NSMutableAttributedString(string: string)
        placeholder.addAttribute(NSForegroundColorAttributeName, value: UIColor(white: 1, alpha: 0.4), range: NSMakeRange(0, count(string)))
        placeholder.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, count(string)))
        placeholder.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, count(string)))
        searchBar.attributedPlaceholder = placeholder
        return searchBar
    }
    
    func rightButtonView() -> UIView {
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        self.cancelButton = self.navBarButton("Cancel", imageNamed: nil, target: nil)
        self.searchButton = self.navBarButton("Search", imageNamed: "SmallSearch", target: nil)
        self.listsEditButton = self.navBarButton("Edit", imageNamed: nil, target: nil)
        buttonView.addSubview(cancelButton)
        buttonView.addSubview(searchButton)
        buttonView.addSubview(listsEditButton)
        self.cancelButtonCenterY = self.constraintWithAttribute(NSLayoutAttribute.CenterY, inArray: cancelButton.autoCenterInSuperview())
        self.searchButtonCenterY = self.constraintWithAttribute(NSLayoutAttribute.CenterY, inArray: searchButton.autoCenterInSuperview())
        self.listsEditButtonCenterY = self.constraintWithAttribute(NSLayoutAttribute.CenterY, inArray: listsEditButton.autoCenterInSuperview())
        searchButton.autoSetDimensionsToSize(CGSize(width: 24, height: 24))
        self.cancelButton.alpha = 0;
        self.listsEditButton.alpha = 0;
        return buttonView
    }
    
    func createFiltersController() -> FiltersViewController {
        let filtersController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("filtersController") as! FiltersViewController
        filtersController.delegate = self
        filtersController.view.alpha = 0
        self.view.addSubview(filtersController.view)
        return filtersController
    }
    
    func createListsController() -> ListsViewController {
        let listsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("listsController") as! ListsViewController
        listsController.delegate = self
        listsController.view.alpha = 0
        self.view.addSubview(listsController.view)
        return listsController
    }
    
    func constraintWithAttribute(attribute: NSLayoutAttribute, inArray array: NSArray) -> NSLayoutConstraint? {
        for object in array {
            let constraint = object as! NSLayoutConstraint
            if constraint.firstAttribute == attribute {
                return constraint
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Courses"
        self.updateCoursesData()
        self.layoutNavigationBar()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.opaque = true
        self.navigationController?.navigationBar.translucent = false
        self.tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "NavBarBg"), forBarMetrics: UIBarMetrics.Default)
    }
    
    func updateCoursesData() {
        
        let courses = Realm().objects(Course)
        if courses.count == 0 {
            CS50Downloader.getCourses({self.tableView.reloadData()})
        }
    }
    
    func layoutNavigationBar() {
        self.navigationItem.titleView = self.navigationBar()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButtonView())
    }
    
    func setListsShowing(showing: Bool) {
        
        if !showing {
            searchBar.resignFirstResponder()
        }
        
        let unhideViews = showing ? [listsTitleLabel, listsBackButton, listsEditButton] : [coursicaTitleLabel, searchButton, listsButton]
        let hideViews = showing ? [coursicaTitleLabel, searchButton, listsButton] : [listsTitleLabel, listsBackButton, listsEditButton]
        let moveInConstraints = showing ? [listsTitleCenterY, listsBackButtonCenterY, listsEditButtonCenterY] : [coursicaTitleCenterY, searchButtonCenterY, listsButtonCenterY]
        let moveOutConstraints = showing ? [coursicaTitleCenterY, searchButtonCenterY, listsButtonCenterY] : [listsTitleCenterY, listsBackButtonCenterY, listsEditButtonCenterY]
        
        let popTo: (NSObject, AnyObject, String) -> Void = {object, toValue, property in
            let anim = POPBasicAnimation(propertyNamed: property)
            anim.toValue = toValue
            anim.duration = 0.3
            object.pop_removeAllAnimations()
            object.pop_addAnimation(anim, forKey: "popTo")
        }
        moveInConstraints.map({constraint in popTo(constraint, NSNumber(integer: 0), kPOPLayoutConstraintConstant)})
        moveOutConstraints.map({constraint in popTo(constraint, NSNumber(integer: showing ? -20 : 20), kPOPLayoutConstraintConstant)})
        unhideViews.map({view in popTo(view, NSNumber(integer: 1), kPOPViewAlpha)})
        hideViews.map({view in popTo(view, NSNumber(integer: 0), kPOPViewAlpha)})
        self.listsController.viewDidAppear(true)
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {self.listsController.view.alpha = showing ? 1 : 0}, completion: nil)
    }
    
    func setFiltersShowing(showing: Bool, searchActive: Bool) {
        
        if !showing {
            searchBar.resignFirstResponder()
        }
        
        let unhideViews = showing ? [searchBar, cancelButton] : [coursicaTitleLabel, searchButton, listsButton]
        let hideViews = showing ? [coursicaTitleLabel, searchButton, listsButton] : [searchBar, cancelButton]
        let moveInConstraints = showing ? [searchBarCenterY, cancelButtonCenterY] : [coursicaTitleCenterY, searchButtonCenterY, listsButtonCenterY]
        let moveOutConstraints = showing ? [coursicaTitleCenterY, searchButtonCenterY, listsButtonCenterY] : [searchBarCenterY, cancelButtonCenterY]
        
        if !searchActive {
            let popTo: (NSObject, AnyObject, String) -> Void = {object, toValue, property in
                let anim = POPBasicAnimation(propertyNamed: property)
                anim.toValue = toValue
                anim.duration = 0.3
                object.pop_removeAllAnimations()
                object.pop_addAnimation(anim, forKey: "popTo")
            }
            moveInConstraints.map({constraint in popTo(constraint, NSNumber(integer: 0), kPOPLayoutConstraintConstant)})
            moveOutConstraints.map({constraint in popTo(constraint, NSNumber(integer: showing ? -20 : 20), kPOPLayoutConstraintConstant)})
            unhideViews.map({view in popTo(view, NSNumber(integer: 1), kPOPViewAlpha)})
            hideViews.map({view in popTo(view, NSNumber(integer: 0), kPOPViewAlpha)})
        }
        UIView.animateWithDuration(0.3, animations: {self.filtersController.view.alpha = showing ? 1 : 0})
    }
    
    func updatePredicate(predicate: NSPredicate) {
        let bracketed = NSPredicate(format: "bracketed = %@", NSNumber(bool: false))
        self.courses = Realm().objects(Course).filter(NSCompoundPredicate.andPredicateWithSubpredicates([bracketed, predicate]))
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.tableView.reloadData()
    }
    
    func filtersDidChange() {
        
        if count(searchBar.text) < 0 {
            self.searchBar.resignFirstResponder()
            return
        }
        
        Search.shared.assignScoresForSearch(searchBar.text)
        self.updatePredicate(NSPredicate(format: "searchScore > %f", 0.05))
        self.setFiltersShowing(false, searchActive: true)
    }
    
    
    func searchButtonPressed(button: UIButton) {
        self.setFiltersShowing(true, searchActive: false)
    }
    
    func keyboardShouldDismiss() {
        searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CoursesViewController: ListsViewControllerDelegate {
    
    func didSelectTempCourse(tempCourse: TempCourse) {
        self.navigationController?.pushViewController(DetailViewController.detailv , animated: <#Bool#>)
    }
}

extension CoursesViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.setFiltersShowing(true, searchActive: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.filtersDidChange()
        return true
    }
}