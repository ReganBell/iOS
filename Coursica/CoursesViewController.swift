//
//  CoursesViewController.swift
//  Coursica
//
//  Created by Regan Bell on 7/14/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import RealmSwift
import pop
import Cartography

class CoursesViewController: CoursicaViewController, FiltersViewControllerDelegate {

    var containerView = UIView()
    var tableView: UITableView = UITableView()
    var navigationBar: CoursesNavigationBar!
    var navigationBarHeightConstraint: NSLayoutConstraint!
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
    
    func createFiltersController() -> FiltersViewController {
        let filtersController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("filtersController") as! FiltersViewController
        filtersController.delegate = self
        filtersController.view.alpha = 0
        containerView.addSubview(filtersController.view)
        constrain(filtersController.view, {filters in
            filters.edges == filters.superview!.edges
        })
        return filtersController
    }
    
    func createListsController() -> ListsViewController {
        let listsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("listsController") as! ListsViewController
        listsController.delegate = self
        listsController.view.alpha = 0
        containerView.addSubview(listsController.view)
        constrain(listsController.view, {lists in
            lists.edges == lists.superview!.edges
        })
        return listsController
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Courses"
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.addSubview(containerView)
        
        containerView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        constrain(tableView, {tableView in
            tableView.edges == tableView.superview!.edges
        })
        navigationBar = CoursesNavigationBar()
        navigationBar.initialLayout(self)
        self.view.addSubview(navigationBar)
        constrain(navigationBar, containerView, self.view, {navigationBar, container, view in
            align(left: navigationBar, view, container)
            align(right: navigationBar, view, container)
            navigationBar.top == view.top
            self.navigationBarHeightConstraint = (navigationBar.height == 64)
            container.top == navigationBar.bottom
            container.bottom == view.bottom
        })
        self.view.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        self.tableView.tableFooterView = UIView()
        self.updateCoursesData()
    }
    
    func sortedCourses(courses: Results<Course>) -> Results<Course> {
        let sortByField = SortDescriptor(property: "shortField", ascending: true)
        let sortByNumber = SortDescriptor(property: "integerNumber", ascending: true)
        return courses.sorted([sortByField, sortByNumber])
    }
    
    func updateCoursesData() {
        
        courses = self.sortedCourses(Realm().objects(Course))
        if courses!.count == 0 {
            CS50Downloader.getCourses({
                self.courses! = self.sortedCourses(Realm().objects(Course))
                self.tableView.reloadData()
            })
        }
    }
    
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
    
    func setListsShowing(showing: Bool) {
        self.toggleViews(showing, searchActive: false, filters: false)
    }
    
    func setFiltersShowing(showing: Bool, searchActive: Bool) {
        self.toggleViews(showing, searchActive: searchActive, filters: true)
    }
    
    func toggleViews(showing: Bool, searchActive: Bool, filters: Bool) {

        if !showing {
            navigationBar.searchBar.resignFirstResponder()
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                if filters {
                    if !searchActive {
                        self.navigationBar.setFiltersShowing(showing)
                    }
                    self.filtersController.view.alpha = showing ? 1 : 0
                } else {
                    self.navigationBar.setListsShowing(showing)
                    self.listsController.viewDidAppear(true)
                    self.listsController.view.alpha = showing ? 1 : 0
                }
        }, completion: nil)
    }
    
    func updatePredicate(filter: NSPredicate?, search: NSPredicate?) {
        var predicates = [NSPredicate(format: "bracketed = %@", NSNumber(bool: false))]

        for optional in [filter, search] {
            if let predicate = optional {
                predicates.append(predicate)
            }
        }
        if let _ = search {
            self.courses = Realm().objects(Course).filter(NSCompoundPredicate.andPredicateWithSubpredicates(predicates)).sorted("searchScore", ascending: false)
        } else {
            self.courses = self.sortedCourses(Realm().objects(Course).filter(NSCompoundPredicate.andPredicateWithSubpredicates(predicates)))
        }
        self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.tableView.reloadData()
    }
    
    func filtersDidChange() {
        
        if !navigationBar.searchBar.text.isEmpty {
            Search.shared.assignScoresForSearch(navigationBar.searchBar.text)
            self.updatePredicate(filtersController.filters(), search: NSPredicate(format: "searchScore > %f", 0.05))
        } else {
            self.updatePredicate(filtersController.filters(), search: nil)
        }
        self.setFiltersShowing(false, searchActive: true)
    }
    
    func editListsButtonPressed(button: UIButton) {
        button.selected = !button.selected
        button.setTitle(button.selected ? "Done" : "Edit", forState: .Normal)
        self.listsController.setEditing(button.selected, animated: true)
    }
    
    func keyboardShouldDismiss() {
        navigationBar.searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CoursesViewController: ListsViewControllerDelegate {
    
    func didSelectTempCourse(tempCourse: TempCourse) {
        self.navigationController?.pushViewController(DetailViewController.detailViewControllerWithTempCourse(tempCourse) , animated: true)
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

extension CoursesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell ?? UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        let course = self.courses![indexPath.row]
        let plain = course.display.title
        let boldRange = (plain as NSString).rangeOfString(course.title)
        let fancy = NSMutableAttributedString(string: plain)
        let regularFont = UIFont(name: "AvenirNext-Regular", size: 14)
        let boldFont = UIFont(name: "AvenirNext-DemiBold", size: 17)
        fancy.addAttributes([NSFontAttributeName: regularFont!, NSForegroundColorAttributeName: UIColor(white: 150/255.0, alpha: 1)], range: NSMakeRange(0, count(plain)))
        fancy.addAttributes([NSFontAttributeName: boldFont!,    NSForegroundColorAttributeName: UIColor.blackColor()],                range: boldRange)
        cell.textLabel!.attributedText = fancy
        return cell as UITableViewCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let course: Course = self.courses![indexPath.row]
        let detailController = DetailViewController.detailViewControllerWithCourse(course)
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses?.count ?? 0
    }
}

extension CoursesViewController: CoursesNavigationBarDelegate {
    
    func listsButtonPressed(button: UIButton) {
        self.setListsShowing(true)
    }
    
    func listsBackButtonPressed(button: UIButton) {
        self.setListsShowing(false)
    }
    
    func searchButtonPressed(button: UIButton) {
        self.setFiltersShowing(true, searchActive: false)
    }
    
    func cancelFiltersButtonPressed(button: UIButton) {
        self.setFiltersShowing(false, searchActive: false)
        navigationBar.searchBar.text = ""
        Search.shared.clearSearchScores()
        self.updatePredicate(nil, search: nil)
    }
}