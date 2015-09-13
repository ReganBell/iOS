//
//  FacultyViewController.swift
//  Coursica
//
//  Created by Regan Bell on 9/11/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import Cartography
import RealmSwift

class FacultyViewController: CoursicaViewController {

    let faculty: Faculty
    let tableView = UITableView()
    var _courses: Results<Course>?
    var courses: Results<Course> {
        if _courses == nil {
            let sortByField = SortDescriptor(property: "shortField", ascending: true)
            let sortByNumber = SortDescriptor(property: "integerNumber", ascending: true)
            _courses = faculty.courses.sorted([sortByField, sortByNumber])
        }
        return _courses!
    }
    
    init(faculty: Faculty) {
        self.faculty = faculty
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTitle(faculty.fullName)
        tableView.backgroundColor = UIColor(white: 241/255.0, alpha: 1.0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        view.addSubview(tableView)
        constrain(view, tableView, {view, scrollView in
            scrollView.edges == view.edges
        })
        view.setTranslatesAutoresizingMaskIntoConstraints(true)
    }
}

extension FacultyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = CourseTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        let course = courses[indexPath.row]
        let plain = course.display.title
        let boldRange = (plain as NSString).rangeOfString(course.title)
        let fancy = NSMutableAttributedString(string: plain)
        let regularFont = UIFont(name: "AvenirNext-Regular", size: 14)
        let boldFont = UIFont(name: "AvenirNext-DemiBold", size: 17)
        fancy.addAttributes([NSFontAttributeName: regularFont!, NSForegroundColorAttributeName: UIColor(white: 150/255.0, alpha: 1)], range: NSMakeRange(0, count(plain)))
        fancy.addAttributes([NSFontAttributeName: boldFont!,    NSForegroundColorAttributeName: UIColor.blackColor()],                range: boldRange)
        cell.textLabel!.attributedText = fancy
        cell.colorBarView.backgroundColor = colorForPercentile(course.percentileSize)
        return cell as UITableViewCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let course: Course = courses[indexPath.row]
        let detailController = DetailViewController(course: course)
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? headerViewForTitle("Teaches", tableView: tableView) : nil
    }
    
    func headerViewForTitle(title: String, tableView: UITableView) -> UIView {
        
        let headerView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: tableView.bounds.size.width, height: 44)))
        headerView.backgroundColor = UIColor(white: 241/255.0, alpha: 1)
        let headerLabel = UILabel(frame: CGRectZero)
        headerLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        headerLabel.text = title
        headerLabel.sizeToFit()
        headerLabel.textColor = UIColor(white: 142/255.0, alpha: 1.0)
        headerView.addSubview(headerLabel)
        constrain(headerLabel, {header in
            header.center == header.superview!.center
        })
        return headerView
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faculty.courses.count
    }
}