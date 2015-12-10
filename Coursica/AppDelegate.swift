//
//  AppDelegate.swift
//  Coursica
//
//  Created by Regan Bell on 7/18/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

import UIKit
import RealmSwift
import Fabric
import Crashlytics

extension Array {
    func randomElement() -> Element? {
        if count == 0 { return nil }
        return self[Int(arc4random() % UInt32(count))]
    }
}

extension Set {
    func randomElement() -> Element {
        let n = Int(arc4random_uniform(UInt32(count)))
        let i = startIndex.advancedBy(n)
        return self[i]
    }
}

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
    
    var firebaseForbidden: [String] { return [".", "#", "$", "/", "[", "]"] }
    
    var asFirebaseKey: String {
        var string = self
        for (i, forbidden) in firebaseForbidden.enumerate() {
            string = string.stringByReplacingOccurrencesOfString(forbidden, withString: "&\(i)&")
        }
        return string
    }
    
    var decodedFirebaseKey: String {
        var string = self
        for (i, forbidden) in firebaseForbidden.enumerate() {
            string = string.stringByReplacingOccurrencesOfString("&\(i)&", withString: forbidden)
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

@available(iOS 9.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var allGroupScores: Dictionary<String, [Double]>!
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
    var realm: Realm!
    var factorChecker: FactorChecker!
    
    func coursesJSONFromDisk() -> NSDictionary {
        let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("final_results copy", ofType: "json")!)!
        return (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! NSDictionary
    }
    
    func calculatePercentiles(courses: Results<Course>) {
        allGroupScores = Dictionary<String, [Double]>()
        allScores = []
        for course in courses {
            if course.overall != 0 {
                allScores.append(course.overall)
                var groupScores = allGroupScores[course.shortField] ?? []
                groupScores.append(course.overall)
                allGroupScores.updateValue(groupScores, forKey: course.shortField)
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
        allScores = allScores.sort(<)
        var sortedGroupScores = Dictionary<String, [Double]>()
        for (group, array) in allGroupScores {
            sortedGroupScores[group] = array.sort(<)
        }
        allGroupScores = sortedGroupScores
        for range in allSizeScores {
            range.scores.sortInPlace(<)
        }
    }
    
    func arrayForGraphTab(tab: GraphViewTab, course: Course) -> [Double] {
        switch tab {
        case .All:    return self.allScores
        case .Group:  return self.allGroupScores[course.shortField]!
        case .Size:
            for range in self.allSizeScores {
                if range.contains(course.enrollment) {return range.scores}
            }
        }
        return []
    }
    
    func savePercentilesOnCourses(courses: Results<Course>) {
        for course in courses {
            if course.overall < 0.1 {
                course.percentileAll = -1
                course.percentileGroup = -1
                course.percentileSize = -1
                continue
            }
            let tabs: [GraphViewTab] = [.All, .Group, .Size]
            for tab in tabs {
                let sortedScores = arrayForGraphTab(tab, course: course)
                let index = sortedScores.indexOf(course.overall)!
                let percentile = Double(index) / Double(sortedScores.count)
                let percentileInt = Int(percentile * 100)
                switch tab {
                case .All: course.percentileAll = percentileInt
                case .Group: course.percentileGroup = percentileInt
                case .Size: course.percentileSize = percentileInt
                }
            }
        }
    }
    
    func extractQData() {
        let json = coursesJSONFromDisk()
        var courseDict: [String: Course] = Dictionary<String,Course>()
        let courses = try! Realm().objects(Course)
        if courses.count != 0 {
            for course in courses {
                courseDict[course.display.serverTitle] = course
            }
            try! Realm().write {
                for (key, value) in json {
                    var mostRecent = Key(string: "fall1870")
                    for (id, _) in (value as! NSDictionary) {
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
                    let average = FacultyAverage()
                    average.question = question
                    average.score = self.averageOf(scores)
                    try! Realm().add(average, update: false)
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
    
    func factorMissingMove(schedule: Schedule, result: CheckerResult, move: Move, termUpperBound: TermKey) -> Schedule {
        var variableIndex = result.unusedVariables.randomElement()!
        var domain = factorChecker.domain(variableIndex.termKey)
        var course = move.courses!.randomElement()!
        var variablesTried = 0
        while !variableIndex.termKey.before(termUpperBound) || !domain.contains(course) {
            variableIndex = result.unusedVariables.randomElement()!
            domain = factorChecker.domain(variableIndex.termKey)
            course = move.courses!.randomElement()!
            variablesTried++
            if variablesTried > 10 {
                break
            }
        }
//        print("\n** Solving factor with \(course) assigned to \(variableIndex.termKey.rawValue)\n")
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
        newSchedule.assignCourse(course, index: variableIndex)
        return newSchedule
    }
    
    func duplicateCourseMove(schedule: Schedule, result: CheckerResult, move: Move) -> Schedule {
        let duplicateCourse = move.courses!.first!
        var newCourse: String?
        for suggestedMove in result.suggestedMoves {
            // Look for a prereq or requirement constraint that needs satisfying, replace this duplicate with a course from its domain
            if !(suggestedMove.type == .PrereqMissing || suggestedMove.type == .FactorMissing) {
                continue
            }
            if let moveCourses = suggestedMove.courses {
                for course in moveCourses {
                    if factorChecker.domain(move.index!.termKey).contains(course) && duplicateCourse != course {
                        newCourse = course
                        break
                    }
                }
                if newCourse != nil { break }
            }
        }
        let course = newCourse ?? factorChecker.domain(move.index!.termKey).randomElement()
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
//        print("\n** Replacing duplicate \(duplicateCourse) with \(course)\n")
        newSchedule.assignCourse(course, index: move.index!)
        return newSchedule
    }
    
    func variableWithTerm(term: Int, variables: [VariableIndex]) -> VariableIndex? {
        for variable in variables {
            if variable.termKey == orderedVariableKeys[term] {
                return variable
            }
        }
        return nil
    }
    
    func targetTerm(current: Int, cap: Int) -> Int {
        let range = arc4random() % UInt32(abs(cap - current))
        let negative = current > cap ? -1 : 1
        return current + negative * Int(range)
    }
    
    func movePrereqMove(schedule: Schedule, result: CheckerResult, move: Move, forward: Bool) -> Schedule {
        
        let courseToMove = move.courses!.first!
        let courseToMoveIndex = orderedVariableKeys.indexOf(move.index!.termKey)!
        let cap = forward ? orderedVariableKeys.count - 1 : 0
        // If a course is at the beginning of schedule, we can't move it earlier; likewise if it is at the end
        if courseToMoveIndex == cap { return schedule }
        var destinationTerm = self.targetTerm(courseToMoveIndex, cap: cap)
        var destinationVariable = variableWithTerm(destinationTerm, variables: result.unusedVariables) ?? variableWithTerm(destinationTerm, variables: [0, 1, 2, 3].map { return VariableIndex(termKey: orderedVariableKeys[destinationTerm], index: $0) })!
        var swapCourse = schedule.variable(destinationVariable.termKey).assignment[destinationVariable.index]
        var tries = 0
        var index = 0
        while !factorChecker.domain(destinationVariable.termKey).contains(courseToMove) || !factorChecker.domain(move.index!.termKey).contains(swapCourse) {
            destinationTerm = self.targetTerm(courseToMoveIndex, cap: cap)
            if tries < 10 {
                destinationVariable = variableWithTerm(destinationTerm, variables: result.unusedVariables) ?? variableWithTerm(destinationTerm, variables: [0, 1, 2, 3].map { return VariableIndex(termKey: orderedVariableKeys[destinationTerm], index: $0) })!
            } else {
                destinationVariable = VariableIndex(termKey: orderedVariableKeys[destinationTerm], index: index)
                index++; if index == 4 { index = 0 }
            }
            swapCourse = schedule.variable(destinationVariable.termKey).assignment[destinationVariable.index]
            tries++
            if tries > 50 {
                return schedule
            }
        }
//        print("\n** Moving \(move.courses!.first!) \(forward ? "forward" : "backward"), swapping with \(swapCourse)\n")
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
        newSchedule.assignCourse(move.courses!.first!, index: destinationVariable)
        newSchedule.assignCourse(swapCourse, index: move.index!)
        return newSchedule
    }
    
    func timeConflictMove(schedule: Schedule, result: CheckerResult, move: Move) -> Schedule {
        // Half the time swap the course with a different course, half the time give it a new assignment
        if arc4random() % 2 == 0 {
            return movePrereqMove(schedule, result: result, move: move, forward: (arc4random() % 2) == 0)
        } else {
            return duplicateCourseMove(schedule, result: result, move: move)
        }
    }
    
    func swapPrereqMove(schedule: Schedule, result: CheckerResult, move: Move) -> Schedule {
        let prereqIndex = move.index!
        let courseIndex = move.swapIndex!
        let prereq = schedule.variable(prereqIndex.termKey).assignment[prereqIndex.index]
        let course = schedule.variable(courseIndex.termKey).assignment[courseIndex.index]
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
        if factorChecker.domain(courseIndex.termKey).contains(prereq) && factorChecker.domain(prereqIndex.termKey).contains(course) && prereqIndex.termKey != courseIndex.termKey {
            newSchedule.variable(courseIndex.termKey).assignment[courseIndex.index] = prereq
            newSchedule.variable(prereqIndex.termKey).assignment[prereqIndex.index] = course
            return newSchedule
        } else {
            let forwardSchedule = movePrereqMove(schedule, result: result, move: Move(type: .MovePrereq, index: move.index!, swapIndex: move.swapIndex!, courses: [prereq]), forward: false)
            return movePrereqMove(forwardSchedule, result: result, move: Move(type: .MovePostReq, index: move.swapIndex!, swapIndex: move.index!, courses: [course]), forward: true)
            //                        suggestedMoves.append(Move(type: .MovePrereq, index: prereqVarIndex, swapIndex: index, courses: [prereq]))
            //                        suggestedMoves.append(Move(type: .MovePostReq, index: index, swapIndex: prereqVarIndex, courses: [title]))
        }
    }

    func qScoreReplaceMove(schedule: Schedule, move: Move) -> Schedule {
        let variableIndex = move.index!
        let domain = factorChecker.sortedDomain(variableIndex.termKey)
        var course = ""; var continuePickingExpo = true; var i = 0
        while continuePickingExpo {
            // Bias towards high-ranked domain values by exponentially decaying probability of selection, but still maintain a low probability that any given course is picked
            if arc4random() % 3 == 0 || i == domain.count - 1 {
                course = domain[i]
                continuePickingExpo = false
            } else {
                i++
            }
        }
        let oldCourse = move.courses!.first!
        let newSchedule = Schedule(copy: schedule, assignment: nil, realm: realm)
//        print("\n** Replacing low Q score course \(oldCourse) (\(factorChecker.qScores[oldCourse]) with \(course) (\(factorChecker.qScores[course])\n")
        newSchedule.assignCourse(course, index: variableIndex)
        return newSchedule
    }

    
    func generateSuccessor(schedule: Schedule, result: CheckerResult) -> Schedule {
        var newSchedule: Schedule? = nil
        if let move = result.suggestedMoves.randomElement() {
            switch move.type {
            case .FactorMissing: newSchedule = factorMissingMove(schedule, result: result, move: move, termUpperBound: .All)
            case .MovePrereq: newSchedule = movePrereqMove(schedule, result: result, move: move, forward: false)
            case .MovePostReq: newSchedule = movePrereqMove(schedule, result: result, move: move, forward: true)
            case .SwapPrereq: newSchedule = swapPrereqMove(schedule, result: result, move: move)
            case .TimeConflict: newSchedule = timeConflictMove(schedule, result: result, move: move)
            case .PrereqMissing: newSchedule = factorMissingMove(schedule, result: result, move: move, termUpperBound: move.index!.termKey)
            case .DuplicateCourse: newSchedule = duplicateCourseMove(schedule, result: result, move: move)
            case .WorkloadSwap: newSchedule = swapPrereqMove(schedule, result: result, move: move)
            case .QScoreReplace: newSchedule = qScoreReplaceMove(schedule, move: move)
            }
        }
//        print("\(newSchedule!)")
        return newSchedule!
    }
    
//    func randomSchedule() -> Schedule {
//        let schedule = Schedule(copy: nil, assignment: nil, realm: realm)
//        for termKey in orderedVariableKeys {
//            let domain = self.domain(termKey)
//            let variable = schedule.variable(termKey)
//            while variable.assignment.count < 4 {
//                variable.assignment.append(domain.randomElement())
//            }
//        }
//        return schedule
//    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        let config = Realm.Configuration(
            // Get the path to the bundled file
            path: NSBundle.mainBundle().pathForResource("seed", ofType:"realm"),
            // Open the file in read-only mode as application bundles are not writeable
            readOnly: true)
        
        // Open the Realm with the configuration
        realm = try! Realm(configuration: config)
        
//        let versionKey = "modelVersion"
//        let modelVersion = NSUserDefaults.standardUserDefaults().integerForKey(versionKey)
//        
//        if let buildNumber = (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? NSString)?.integerValue where buildNumber > modelVersion {
//            let path = NSBundle.mainBundle().pathForResource("seed", ofType: "realm")!
//            do {
//                if let defaultPath = Realm.Configuration.defaultConfiguration.path {
//                    try NSFileManager.defaultManager().copyItemAtPath(path, toPath: defaultPath)
//                } else {
//                    fatalError("No default Realm path found\n")
//                }
//            } catch {
////                fatalError("Error copying realm file.\n")
//            }
//            NSUserDefaults.standardUserDefaults().setInteger(buildNumber, forKey: versionKey)
//        }
//        
//        setSchemaVersion(5, realmPath: Realm.Configuration.defaultConfiguration.path!, migrationBlock: {migration, oldSchemaVersion in
//            if oldSchemaVersion < 5 {
//                
//            }
//        })
//        
//        if let courses = try? Realm().objects(Course)  {
//            calculatePercentiles(courses)
//            Search.shared.buildIndex(courses)
//        }

        self.factorChecker = FactorChecker(realm: realm)
        var searchSchedule = factorChecker.initialAssignment(self)
        var oldResult = factorChecker.analyze(searchSchedule, shouldPrint: true)
        var schedulesExplored = 1; var stallCount = 0.0
        while oldResult.conflicts > 0 {
            schedulesExplored++
            let successor = generateSuccessor(searchSchedule, result: oldResult)
            let newResult = factorChecker.analyze(successor, shouldPrint: false)
//            if oldResult.conflicts > newResult.conflicts {//  {
//                print("\(oldResult.conflicts)->\(newResult.conflicts) \(oldResult.averageQScore)->\(newResult.averageQScore) \(oldResult.highestWorkloadDeviation)->\(newResult.highestWorkloadDeviation) in \(schedulesExplored) steps\n\n\(searchSchedule)")
//                oldResult = newResult
//                searchSchedule = successor
//                stallCount = 0
//            }
            if oldResult.conflicts >= newResult.conflicts && oldResult.averageQScore - 5 <= newResult.averageQScore && oldResult.highestWorkloadDeviation >= newResult.highestWorkloadDeviation - 0.05 {
                //oldResult.averageQScore <= newResult.averageQScore && oldResult.highestWorkloadDeviation >= newResult.highestWorkloadDeviation {
//                print("\(oldResult.conflicts)->\(newResult.conflicts) \(oldResult.averageQScore)->\(newResult.averageQScore) \(oldResult.highestWorkloadDeviation)->\(newResult.highestWorkloadDeviation) in \(schedulesExplored) steps\n\n\(searchSchedule)")
                oldResult = newResult
                searchSchedule = successor
                stallCount++
            }
            if schedulesExplored % 1000 == 0 {
                searchSchedule = factorChecker.initialAssignment(self)
                oldResult = factorChecker.analyze(searchSchedule, shouldPrint: false)
            }
            if oldResult.conflicts == 0 {
                let newResult = factorChecker.analyze(successor, shouldPrint: true)
            }
        }
        print("Solution found, Q: \(oldResult.averageQScore), Workload: \(oldResult.highestWorkloadDeviation). Explored \(schedulesExplored) schedules\n\(searchSchedule)")
        factorChecker.analyze(searchSchedule, shouldPrint: true)
//        Realm().write({
//            var facultyDict = Dictionary<String, Faculty>()
//            var deleteAfter: [Faculty] = []
//            for course in courses {
//                for faculty in course.faculty {
//                    faculty.courses.append(course)
//                }
//            }
//            for faculty in Realm().objects(Faculty) {
//                let fullName = faculty.fullName
//                if let existing = facultyDict[fullName] {
//                    for course in faculty.courses {
//                        existing.courses.append(course)
//                        course.faculty.removeAtIndex(course.faculty.indexOf(faculty)!)
//                        course.faculty.append(existing)
//                    }
//                    deleteAfter.append(faculty)
//                } else {
//                    facultyDict[fullName] = faculty
//                }
//            }
//            Realm().delete(deleteAfter)
//            for course in courses {
//                if !course.prerequisitesString.isEmpty {
//                    for match in PrerequisitesParser().processPrerequisiteString(course) {
//                        course.prerequisites.append(match.course)
//                    }
//                }
//            }
//        })
//        Realm().write {
//            self.savePercentilesOnCourses(courses)
//        }
//        self.extractQData()
//        let error = Realm().writeCopyToPath(NSBundle.mainBundle().resourcePath!.stringByAppendingPathComponent("seed"), encryptionKey: nil)
//        println(NSBundle.mainBundle().resourcePath!.stringByAppendingPathComponent("seed"))

        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let navigationController = NavigationController(rootViewController: CoursesViewController())
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        if !NSUserDefaults.standardUserDefaults().boolForKey("loggedIn") {
            let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("loginController") as! LoginViewController
            loginController.delegate = self
            navigationController.presentViewController(loginController, animated: false, completion: nil)
        }
        return true
    }
}

@available(iOS 9.0, *)
extension AppDelegate: LoginViewControllerDelegate {
    
    func userDidLoginWithHUID(HUID: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(HUID, forKey: "huid")
        defaults.setBool(true, forKey: "loggedIn")
    }
}
