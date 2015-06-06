//
//  AppDelegate.m
//  Coursica
//
//  Created by Regan Bell on 11/9/14.
//  Matthew Beatty
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "AppDelegate.h"
#import "MMDrawerController.h"
#import "CoursesViewController.h"
#import "FiltersViewController.h"
#import "LoginViewController.h"
#import "NavigationController.h"
#import "CHCSVParser.h"
#import "QDataParserDelegate.h"
#import "Course.h"
#import "QScore.h"
#import "FullOnScrapist.h"
#import "SearchManager.h"
#import "Faculty.h"
#import "ScrapeViewController.h"
#import "QReport.h"
#import "QFacultyReport.h"
#import <Parse/Parse.h>

@interface AppDelegate () <LoginViewControllerDelegate>

@property (strong, nonatomic) MMDrawerController *drawerController;
@property (strong, nonatomic) NSMutableDictionary *dataErrors;

@end

@implementation AppDelegate


- (void)dataErrorForKey:(NSString*)key title:(NSString*)title term:(NSString*)term year:(NSString*)year {
    
    if (!self.dataErrors) {
        self.dataErrors = [NSMutableDictionary dictionary];
    }
    
    NSNumber *errors = self.dataErrors[key];
    if (!errors) {
        errors = @1;
    } else
        errors = @(errors.intValue + 1);
    self.dataErrors[key] = errors;
    
    NSLog(@"Error no. %d! No data found for key: %@  course: %@ term: %@, year: %@", errors.intValue, key, title, term, year);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"90HBwxg6buByKw7MKrwS6503CrjmZ1QlnsPPMvNY"
                  clientKey:@"AHhRu1tDs4PXTk2xbRfxa43psk6ucr8qe8NNDAgs"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    NSFetchRequest *reportsFetch = [NSFetchRequest fetchRequestWithEntityName:@"QReport"];
    for (QReport *report in [[self managedObjectContext] executeFetchRequest:reportsFetch error:nil]) {
        [[self managedObjectContext] deleteObject:report];
    }
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Faculty"];
    [fetch setPropertiesToFetch:@[@"first", @"last"]];
    NSArray *allFaculty = [[self managedObjectContext] executeFetchRequest:fetch error:nil];
    NSMutableDictionary *facultyDict = [NSMutableDictionary dictionary];
    for (Faculty *faculty in allFaculty) {
        NSString *key = [NSString stringWithFormat:@"%@ %@", faculty.first, faculty.last];
        facultyDict[key] = faculty;
    }
    
    NSFetchRequest *courseFetch = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    NSArray *allCourses = [[self managedObjectContext] executeFetchRequest:courseFetch error:nil];
    NSMutableDictionary *allCourseDict = [NSMutableDictionary dictionary];
    for (Course *course in allCourses) {
        NSString *key = course.displayTitle;
        allCourseDict[key] = course;
    }
    
//    NSEntityDescription *reportEntity = [NSEntityDescription entityForName:@"QReport" inManagedObjectContext:[self managedObjectContext]];
//    NSEntityDescription *facultyReportEntity = [NSEntityDescription entityForName:@"QFacultyReport" inManagedObjectContext:[self managedObjectContext]];
//    
//    NSString *resultsPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"real_results.json"];
//    NSData *rawData = [NSData dataWithContentsOfFile:resultsPath];
//    NSDictionary *scrapedQResults = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingAllowFragments error:nil];
//    NSMutableArray *parseObjects = [NSMutableArray array];
//    for (NSString *courseTitle in scrapedQResults) {
//        NSDictionary *courseDict = scrapedQResults[courseTitle];
//        for (NSString *termYear in courseDict) {
//            NSDictionary *reportDict = courseDict[termYear];
//            if (!reportDict) {
//                [self dataErrorForKey:termYear title:courseTitle term:@"" year:@""];
//                continue;
//            }
//            
//            NSString *term = reportDict[@"term"];
//            if (!term) {
//                [self dataErrorForKey:@"term" title:courseTitle term:@"" year:@""];
//                continue;
//            }
//            NSString *year = reportDict[@"year"];
//            if (!year) {
//                [self dataErrorForKey:@"year" title:courseTitle term:term year:@""];
//                continue;
//            }
//            QReport *newReport = [[QReport alloc] initWithEntity:reportEntity insertIntoManagedObjectContext:[self managedObjectContext]];
//            newReport.term = [term isEqualToString:@"fall"] ? @1 : @2;  //@1 for fall, @2 for spring
//            newReport.year = year;
//            Course *courseObject = allCourseDict[courseTitle];
//            [courseObject addqReportsObject:newReport];
//            
//            if (!newReport.course) {
//                NSLog(@"Could not find course: %@ in allCourses", courseTitle);
//                continue;
//            }
//            
//            PFObject *report = [PFObject objectWithClassName:@"QReport"];
//            PFObject *course = [PFObject objectWithClassName:@"Course"];
//            PFRelation *reports = [course relationForKey:@"reports"];
//            course[@"title"] = courseTitle;
//            
//            report[@"term"] = term;
//            report[@"year"] = year;
//            
//            NSString *enrollmentString = reportDict[@"enrollment"];
//            if (!enrollmentString.length) {
//                [self dataErrorForKey:@"enrollment" title:courseTitle term:term year:year];
//            }
//            newReport.enrollment = @(enrollmentString.intValue);
//            report[@"enrollment"] = @(enrollmentString.intValue);
//            
//            NSArray *rawComments = reportDict[@"comments"];
//            if (!rawComments) {
//                [self dataErrorForKey:@"comments" title:courseTitle term:term year:year];
//            }
//            NSMutableArray *commentsArray = [NSMutableArray array];
//            for (NSString *rawComment in rawComments) {
//                NSString *cleanComment = [rawComment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                [commentsArray addObject:cleanComment];
//            }
//            report[@"comments"] = commentsArray;
//            PFRelation *responses = [report relationForKey:@"responses"];
//            
//            NSDictionary *answersDict = reportDict[@"answers"];
//            
//            for (NSString *keyword in @[@"overall", @"materials", @"assignments", @"feedback", @"section", @"workload", @"recommend"]) {
//                
//                NSDictionary *responseDict = nil;
//                for (NSString *key in answersDict) {
//                    if ([key.lowercaseString containsString:keyword]) {
//                        responseDict = answersDict[key];
//                    }
//                }
//                if (!responseDict) {
//                    [self dataErrorForKey:[NSString stringWithFormat:@"%@-response", keyword] title:courseTitle term:term year:year];
//                    continue;
//                }
//                
//                PFObject *response = [PFObject objectWithClassName:@"QResponse"];
//                response[@"type"] = keyword;
//                
//                NSArray *breakdown = responseDict[@"breakdown"];
//                response[@"breakdown"] = breakdown;
//                NSString *breakdownString = [breakdown componentsJoinedByString:@","];
//                if (breakdownString) {
//                    [newReport setValue:breakdownString forKey:[NSString stringWithFormat:@"%@Breakdown", keyword]];
//                } else
//                    [self dataErrorForKey:[NSString stringWithFormat:@"%@-breakdown", keyword] title:courseTitle term:term year:year];
//                
//                NSNumber *mean = responseDict[@"mean"];
//                response[@"mean"] = mean;
//                if (mean) {
//                    [newReport setValue:mean forKey:keyword];
//                } else
//                    [self dataErrorForKey:keyword title:courseTitle term:term year:year];
//                
//                NSNumber *median = responseDict[@"median"];
//                response[@"median"] = median;
//                if (median) {
//                    [newReport setValue:median forKey:[NSString stringWithFormat:@"%@Median", keyword]];
//                } else
//                    [self dataErrorForKey:[NSString stringWithFormat:@"%@-median", keyword] title:courseTitle term:term year:year];
//                
//                NSNumber *baseline = responseDict[@"baselines"][@"single_term"][@"dept"];
//                if (baseline) {
//                    response[@"baseline"] = baseline;
//                    [newReport setValue:median forKey:[NSString stringWithFormat:@"%@Baseline", keyword]];
//                } else
//                    [self dataErrorForKey:[NSString stringWithFormat:@"%@-baseline", keyword] title:courseTitle term:term year:year];
//                
//                [response saveInBackgroundWithBlock:^(BOOL success, NSError *error){
//                    [responses addObject:response];
//                    [report saveEventually];
//                }];
//            }
//            
//            PFRelation *facultyReports = [report relationForKey:@"facultyReports"];
//            NSDictionary *instructorsDict = reportDict[@"faculty"];
//            for (NSString *facultyString in instructorsDict) {
//                NSDictionary *instructorDict = instructorsDict[facultyString];
////                QFacultyReport *facultyReport = [[QFacultyReport alloc] initWithEntity:facultyReportEntity insertIntoManagedObjectContext:[self managedObjectContext]];
////                facultyReport.report = newReport;
//                NSArray *components = [facultyString componentsSeparatedByString:@", "];
//                NSString *last = components[0];
//                NSString *first = components[1];
////                Faculty *faculty = facultyDict[[NSString stringWithFormat:@"%@ %@", first, last]];
////                if (faculty) {
////                    facultyReport.faculty = faculty;
////                } else {
////                    
////                }
//                PFObject *faculty = [PFObject objectWithClassName:@"Faculty"];
//                faculty[@"first"] = first;
//                faculty[@"last"] = last;
//                PFObject *facultyReport = [PFObject objectWithClassName:@"FacultyReport"];
//                PFRelation *facultyRelation = [facultyReport relationForKey:@"faculty"];
//                PFRelation *responses = [facultyReport relationForKey:@"responses"];
//                
//                for (NSString *keyword in @[@"overall", @"lectures", @"accessible", @"enthusiasm", @"discussion", @"feedback", @"timely"]) {
//                    
//                    NSDictionary *responseDict = nil;
//                    for (NSString *key in instructorDict) {
//                        if ([key.lowercaseString containsString:keyword]) {
//                            responseDict = instructorDict[key];
//                        }
//                    }
//                    if (!responseDict) {
//                        [self dataErrorForKey:[NSString stringWithFormat:@"%@-response-%@ %@", keyword, first, last] title:courseTitle term:term year:year];
//                        continue;
//                    }
//                    PFObject *response = [PFObject objectWithClassName:@"QResponse"];
//                    response[@"type"] = keyword;
//                    
//                    response[@"breakdown"] = responseDict[@"breakdown"];
//                    
//                    NSNumber *mean = responseDict[@"mean"];
//                    response[@"mean"] = mean;
//                    if (mean) {
//                        [facultyReport setValue:mean forKey:keyword];
//                    } else
//                        [self dataErrorForKey:[NSString stringWithFormat:@"%@-%@ %@", keyword, first, last] title:courseTitle term:term year:year];
//                    
//                    NSNumber *baseline = responseDict[@"baselines"][@"single_term"][@"dept"];
//                    if (baseline) {
//                        [facultyReport setValue:baseline forKey:[NSString stringWithFormat:@"%@Baseline", keyword]];
//                        response[@"baseline"] = baseline;
//                    } else
//                        [self dataErrorForKey:[NSString stringWithFormat:@"%@-baseline-%@ %@", keyword, first, last] title:courseTitle term:term year:year];
//                    
//                    [response saveInBackgroundWithBlock:^(BOOL success, NSError *error){
//                        [responses addObject:response];
//                        [faculty saveInBackgroundWithBlock:^(BOOL success, NSError *error){
//                            [facultyRelation addObject:faculty];
//                            [facultyReport saveInBackgroundWithBlock:^(BOOL success, NSError *error){
//                                [facultyReports addObject:facultyReport];
//                                [report saveEventually];
//                            }];
//                        }];
//                    }];
//                }
//            }
//            [report saveInBackgroundWithBlock:^(BOOL success, NSError *error){
//                [reports addObject:report];
//                [course saveInBackground];
//            }];
//        }
//    }
    
//    [[self managedObjectContext] save:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    // Build inverted index for search
    // We might want to save this into NSUserDefaults
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SearchManager sharedSearchManager];
    });
    // Set up scraping view controller; comment out for standard login flow
    
//    ScrapeViewController *scrapeController = [main instantiateViewControllerWithIdentifier:@"scrapeController"];
//    self.window.rootViewController = scrapeController;
//    [self.window makeKeyAndVisible];
    
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NavigationController *navigationController = [main instantiateViewControllerWithIdentifier:@"navigationController"];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"])
    {
        LoginViewController *loginController = [main instantiateViewControllerWithIdentifier:@"loginController"];
        loginController.delegate = self;
        [navigationController presentViewController:loginController animated:NO completion:nil];
    }

    return YES;
}

- (void)userDidLogin {
    
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loggedIn"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.prestige.Coursica" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Coursica" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Coursica.sqlite"];
    
    //Uncomment to delete store:
//    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
