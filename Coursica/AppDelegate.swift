//
//  AppDelegate.swift
//  Coursica
//
//  Created by Regan Bell on 7/18/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import RealmSwift

class Key {
    var term: String = ""
    var year: String = ""
    var string: String { get { return "\(self.term)\(self.year)"}}
    init(string: String) {
        self.year = NSRegularExpression(pattern: "[0-9]+")?.firstMatchInWholeString(string) ?? ""
        self.term = string.stringByReplacingOccurrencesOfString(self.year, withString: "")
    }
    class func compare(a: Key, b: Key) -> Key {
        switch a.year.caseInsensitiveCompare(b.year) {
        case .OrderedAscending: //a = 2012, b = 2013
            return b
        case .OrderedDescending: //a = 2013, b = 2012
            return a
        case .OrderedSame:
            if a.term == "fall" {
                return a
            } else {
                return b
            }
        }
    }
}

extension String {
    
    func encodedAsFirebaseKey() -> String {
        var string = self
        for (i, forbidden) in enumerate([".", "#", "$", "/", "[", "]"]) {
            string = string.stringByReplacingOccurrencesOfString(forbidden, withString: "&\(i)&")
        }
        return string
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var allDepartmentScores: Dictionary<String, [Double]>!
    var allScores: [Double]!
    
    func coursesJSONFromDisk() -> NSDictionary {
        let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("final_results copy", ofType: "json")!)
        return NSJSONSerialization.JSONObjectWithData(data!, options: .allZeros, error: NSErrorPointer()) as! NSDictionary
    }
    
    func calculatePercentiles() {
        let allCourses = Realm().objects(Course)
        allDepartmentScores = Dictionary<String, [Double]>()
        allScores = []
        for course in allCourses {
            if course.overall != 0 {
                allScores.append(course.overall)
                var departmentScores = allDepartmentScores[course.shortField] ?? []
                departmentScores.append(course.overall)
                allDepartmentScores.updateValue(departmentScores, forKey: course.shortField)
            }
        }
        allScores.sort(<)
        for (department, var array) in allDepartmentScores {
            array.sort(<)
        }
    }
    
    func extractQData() {
        let json = self.coursesJSONFromDisk()
        var courseDict: [String: Course] = Dictionary<String,Course>()
        let courses = Realm().objects(Course)
        if courses.count != 0 {
            for course in courses {
                courseDict[course.display.serverTitle] = course
            }
            Realm().write {
                for (key, value) in json {
                    var mostRecent = Key(string: "fall1870")
                    for (id, dict) in (value as! NSDictionary) {
                        mostRecent = Key.compare(Key(string: id as! String), b: mostRecent)
                    }
                    let mostRecentReport = (value as! NSDictionary)[mostRecent.string] as! NSDictionary
//                    println("trying to match \(key)")
                    if let course = courseDict[(key as! String)] {
                        if let enrollmentString = mostRecentReport["enrollment"] as? NSString {
                            course.enrollment = enrollmentString.integerValue
                            course.enrollmentSource = mostRecent.string
                        }
                        if let responses = mostRecentReport["responses"] as? NSDictionary {
                            if let overall = responses["Course Overall"] as? NSDictionary {
                                if let meanString = overall["mean"] as? NSNumber {
                                    course.overall = meanString.doubleValue
                                }
                            }
                            if let workload = responses["Workload (hours per week)"] as? NSDictionary {
                                if let meanString = workload["mean"] as? NSNumber {
                                    course.workload = meanString.doubleValue
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont(name: "AvenirNext-DemiBold", size: 14)!, NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let navigationController = NavigationController(rootViewController: CoursesViewController())
        navigationController.navigationBar.setBackgroundImage(UIImage(named:"NavBarBg"), forBarMetrics: .Default)
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.navigationBar.opaque = true
        navigationController.navigationBar.translucent = false
        self.extractQData()
        self.calculatePercentiles()
        
        self.window!.rootViewController = navigationController
        self.window!.makeKeyAndVisible()
        if !NSUserDefaults.standardUserDefaults().boolForKey("loggedIn") {
            let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("loginController") as! LoginViewController
            loginController.delegate = self
            navigationController.presentViewController(loginController, animated: false, completion: nil)
        }
        return true
    }
}

extension AppDelegate: LoginViewControllerDelegate {
    
    func userDidLoginWithHUID(huid: String!) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(huid, forKey: "huid")
        defaults.setBool(true, forKey: "loggedIn")
    }
}
