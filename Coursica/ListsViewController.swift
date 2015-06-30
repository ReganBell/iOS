//
//  ListsViewController.swift
//  Coursica
//
//  Created by Regan Bell on 6/24/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit

@objc protocol ListsViewControllerDelegate {
    func didSelectList()
}

class ListsViewController: UIViewController {
    
    var lists: [List] = List.testDictionary()
    @IBOutlet var tableView: UITableView?
    var delegate: ListsViewControllerDelegate?
    
    override func viewDidLoad() {
        
        tableView!.tableFooterView = UIView()
                
        var label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 17)
        label.text = "Lists"
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        let HUID = NSUserDefaults.standardUserDefaults().objectForKey("huid") as! String
//        let firebaseRoot: Firebase = Firebase(url: "glaring-heat-9505.firebaseIO.com/\(HUID)/zzzzz")
//        firebaseRoot.observeSingleEventOfType(FEventType.Value, withBlock: { snapshot in
//            if let value = snapshot.value {
//                
//                self.tableView?.reloadData()
//            }
//        })
    }
    
    func headerViewForList(list: List, tableView: UITableView) -> UIView {
        
        var headerView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: tableView.bounds.size.width, height: 44)))
        
        var headerLabel = UILabel(frame: CGRectZero)
        headerLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        headerLabel.text = list.name
        headerLabel.sizeToFit()
        headerLabel.textColor = UIColor(white: 142/255.0, alpha: 1.0)
        
        headerView.addSubview(headerLabel)
        headerLabel.autoCenterInSuperview()
        return headerView
    }
}

extension ListsViewController: UITableViewDataSource, UITableViewDelegate {
    
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
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        let course = self.lists[indexPath.section].courses[indexPath.row]
        
        let plain = "\(course.shortField) \(course.number) - \(course.title)"
        let boldRange = (plain as NSString).rangeOfString(course.title)
        var fancy = NSMutableAttributedString(string: plain)
        
        let regularFont = UIFont(name: "AvenirNext-Regular", size: 14)
        let boldFont = UIFont(name: "AvenirNext-DemiBold", size: 17)
        let regularColor = UIColor(white: 150/255.0, alpha: 1)
        let boldColor = UIColor.blackColor()
        let wholeRange = NSMakeRange(0, count(plain))
        fancy.addAttribute(NSFontAttributeName, value: regularFont!, range: wholeRange)
        fancy.addAttribute(NSForegroundColorAttributeName, value: regularColor, range: wholeRange)
        fancy.addAttribute(NSFontAttributeName, value: boldFont!, range: boldRange)
        fancy.addAttribute(NSForegroundColorAttributeName, value: boldColor, range: boldRange)
        cell!.textLabel!.attributedText = fancy
        return cell!;
    }
}