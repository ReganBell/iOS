//
//  AppDelegate.swift
//  Coursica
//
//  Created by Regan Bell on 7/18/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

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

class SizeRange {
    
    var start: Int
    var end: Int
    var scores: [Double] = []
    init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
    func contains(n: Int) -> Bool { return n >= start && n <= end }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var allDepartmentScores: Dictionary<String, [Double]>!
    var allScores: [Double]!
    let range = Range<Int>(start: 0, end: 10)
    var allSizeScores: [SizeRange] =
        [SizeRange(start: 1, end: 10),
         SizeRange(start: 11, end: 25),
         SizeRange(start: 26, end: 50),
         SizeRange(start: 51, end: 100),
         SizeRange(start: 101, end: 200),
         SizeRange(start: 201, end: 500),
         SizeRange(start: 501, end: 10000)]
    var facultyScores: [String: [Double]] = Dictionary<String, [Double]>()
    var facultyAverages: [String: Double] = Dictionary<String, Double>()
    
    func coursesJSONFromDisk() -> NSDictionary {
        let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("final_results copy", ofType: "json")!)!
        return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as! NSDictionary
    }
    
    func calculatePercentiles(courses: Results<Course>) {
        allDepartmentScores = Dictionary<String, [Double]>()
        allScores = []
        for course in courses {
            if course.overall != 0 {
                allScores.append(course.overall)
                var departmentScores = allDepartmentScores[course.shortField] ?? []
                departmentScores.append(course.overall)
                allDepartmentScores.updateValue(departmentScores, forKey: course.shortField)
                if course.enrollment != 0 {
                    for range in allSizeScores {
                        if range.contains(course.enrollment) {
                            range.scores.append(course.overall)
                            break
                        }
                   }
                }
            }
        }
        allScores = sorted(allScores, <)
        var sortedDepartmentScores = Dictionary<String, [Double]>()
        for (department, var array) in allDepartmentScores {
            sortedDepartmentScores[department] = sorted(array, <)
        }
        allDepartmentScores = sortedDepartmentScores
        var scoresBySize: [((Int, Int), [Double])] = []
        for range in allSizeScores {
            range.scores.sort(<)
        }
    }
    
    func extractQData() {
        let json = self.coursesJSONFromDisk()
        var courseDict: [String: Course] = Dictionary<String,Course>()
        let courses = Realm().objects(Course)
        if courses.count != 0 {
            for course in courses {
//                if course.title == "Introduction to Computer Science I" {
//                    courseDict["COMPSCI 50: Introduction to Computer Science I"] = course
//                    continue
//                }
                courseDict[course.display.serverTitle] = course
            }
            Realm().write {
                for (key, value) in json {
                    var mostRecent = Key(string: "fall1870")
                    for (id, dict) in (value as! NSDictionary) {
                        mostRecent = Key.compare(Key(string: id as! String), b: mostRecent)
                    }
                    let mostRecentReport = (value as! NSDictionary)[mostRecent.string] as! NSDictionary
                    let report = ReportParser.reportFromDictionary(mostRecentReport)
                    for faculty in report!.facultyReports {
                        for response in faculty.responses {
                            if let scores = self.facultyScores[response.question] {
                                self.facultyScores[response.question] = scores + [response.mean]
                            } else {
                                self.facultyScores[response.question] = [response.mean]
                            }
                        }
                    }
                    
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
                for (question, scores) in self.facultyScores {
                    self.facultyAverages[question] = self.averageOf(scores)
                }
            }
        }
    }
    
    func averageOf(numbers: [Double]) -> Double {
        if numbers.count == 0 {
            return 0
        }
        
        var sum = 0.0
        for number in numbers {
            sum += number
        }
        
        return sum / Double(numbers.count)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        Realm.defaultPath = NSBundle.mainBundle().pathForResource("seed", ofType: "realm")!
        
        let courses = Realm().objects(Course)
        self.calculatePercentiles(courses)
        Search.shared.buildIndex(courses)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont(name: "AvenirNext-DemiBold", size: 14)!, NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let navigationController = NavigationController(rootViewController: CoursesViewController())
        navigationController.navigationBar.setBackgroundImage(UIImage(named:"NavBarBg"), forBarMetrics: .Default)
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.navigationBar.opaque = true
        navigationController.navigationBar.translucent = false
//        self.extractQData()
//        let error = Realm().writeCopyToPath(NSBundle.mainBundle().resourcePath!.stringByAppendingPathComponent("seed"), encryptionKey: nil)
        
        
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
    
    func userDidLoginWithHUID(HUID: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(HUID, forKey: "huid")
        defaults.setBool(true, forKey: "loggedIn")
    }
}
