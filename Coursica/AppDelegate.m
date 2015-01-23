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
#import "CHCSVParser.h"
#import "QDataParserDelegate.h"
#import "Course.h"
#import "QScore.h"
#import "FullOnScrapist.h"

@interface AppDelegate ()

@property (strong, nonatomic) MMDrawerController *drawerController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
//    FullOnScrapist *scrapist = [FullOnScrapist new];
//    [scrapist scrapeSearchResultsPage];
    
    NSError *error;

//    NSString *shortString = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ShortFields"] encoding:NSUTF8StringEncoding error:&error];
//    NSString *longString = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LongFields"] encoding:NSUTF8StringEncoding error:&error];
//    
//    NSArray *shortFields = [shortString componentsSeparatedByString:@",\n"];
//    NSArray *longFields = [longString componentsSeparatedByString:@",\n"];
//    
//    NSMutableDictionary *fieldsDict = [NSMutableDictionary dictionary];
//    
//    int i = 0;
//    for (NSString *longField in longFields) {
//        [fieldsDict setObject:shortFields[i] forKey:longField];
//        i++;
//    }
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    [request setPropertiesToFetch:@[@"longField", @"title"]];
    request.predicate = [NSPredicate predicateWithFormat:@"bracketed = %@", @NO];
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:nil];
//    NSMutableDictionary *uniqueTitles = [NSMutableDictionary dictionary];
//    
//    NSNumberFormatter *formatter = [NSNumberFormatter new];
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:nil];
    
    NSMutableDictionary *titleInvertedIndex = [NSMutableDictionary dictionary];
    
    NSMutableCharacterSet *allowedChars = [NSMutableCharacterSet lowercaseLetterCharacterSet];
    [allowedChars formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    [allowedChars formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    [allowedChars formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
//    NSMutableArray *titleTokenSets = [NSMutableArray array];
    
    for (Course *course in array) {
        
        NSScanner *scanitizer = [NSScanner scannerWithString:course.title];
        NSString *cleanTitle;
        [scanitizer scanCharactersFromSet:allowedChars intoString:&cleanTitle];
        
        NSMutableSet *uniqueTerms = [NSMutableSet set];
        NSArray *allTerms = [cleanTitle componentsSeparatedByString:@" "];
        for (NSString *term in allTerms) {
            [uniqueTerms addObject:[term lowercaseString]];
        }
        course.titleTokenSet = uniqueTerms;
        for (NSString *unique in uniqueTerms) {
            
            NSNumber *addOne;
            
            NSMutableDictionary *termDict = titleInvertedIndex[unique];
            if (termDict) {
                NSNumber *occurences = termDict[@"n"];
                termDict[@"n"] = @(occurences.intValue + 1);
            } else {
                termDict = [NSMutableDictionary dictionary];
                termDict[@"n"] = @1;
            }
            
            NSMutableArray *termCourses = termDict[@"courses"];
            if (termCourses.count == 0) {
                termCourses = [NSMutableArray array];
                [termCourses addObject:course];
            } else {
                [termCourses addObject:course];
            }
            termDict[@"courses"] = termCourses;
            titleInvertedIndex[unique] = termDict;
        }
        
//        Course *existingCourse = uniqueTitles[course.title];
//        if (existingCourse) {
//            [context deleteObject:course];
//        } else
//            [uniqueTitles setObject:course forKey:course.title];
//        
//        NSRange range = [course.title rangeOfString:@"]"];
//        NSInteger location = range.location;
//        if (location == (course.title.length - 1)) {
//            course.bracketed = @YES;
//        } else {
//            course.bracketed = @NO;
//        }
//        
//        course.number = [course.number stringByReplacingOccurrencesOfString:@")" withString:@""];
        
//        // Find out whether is a class is for undergraduates or graduates by the number
//        // First we regex out the course number (a lot of them have weird letters and periods)
//        NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:course.number options:0 range:NSMakeRange(0, [course.number length])];
//        
//        if (rangeOfFirstMatch.location == NSNotFound) {
//            // Some undergraduate courses' number will just be a letter and regex won't find anything
//            course.graduate = [NSNumber numberWithBool:NO];
//        } else {
//            // Extract the number string and turn into a real number
//            NSString *substringForFirstMatch = [course.number substringWithRange:rangeOfFirstMatch];
//            double number = [formatter numberFromString:substringForFirstMatch].doubleValue;
//            
//            // Course numbering scheme explained: http://www.registrar.fas.harvard.edu/courses-exams/courses-instruction/introductory-notes
//            if ((number >= 200 && number < 1000) || (number >= 2000)) {
//                course.graduate = [NSNumber numberWithBool:YES];
//            } else
//                course.graduate = [NSNumber numberWithBool:NO];
//        }
        
//        NSString *field = course.longField;
//        NSScanner *scanner = [[NSScanner alloc] initWithString:field];
//        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"*[]"]];
//        NSString *trimmed;
//        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&trimmed];
//        
//        NSString *longField = [trimmed stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
//        
//        NSString *shortField = fieldsDict[longField];
//        if (shortField == nil) {
//            
//            NSArray *components = [longField componentsSeparatedByString:@" "];
//            shortField = [components[0] uppercaseString];
//        }
//        course.shortField = shortField;
//
//        [set addObject:final];
    }
    
    for (NSString *term in titleInvertedIndex) {
        
        NSMutableDictionary *termDict = titleInvertedIndex[term];
        NSNumber *occurences = termDict[@"n"];
        double idf = log(array.count / occurences.doubleValue);
        termDict[@"idf"] = @(idf);
    }
    
    [context save:nil];
    
    NSString *search = @"nazi cinema";
    NSArray *searchTerms = [search componentsSeparatedByString:@" "];
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    for (NSString *term in searchTerms) {
        
        NSMutableDictionary *termDict = titleInvertedIndex[term];
        if (!termDict) {
            continue;
        }
        
        NSNumber *idfNum = termDict[@"idf"];
        double idf = idfNum.doubleValue;
        
        for (Course *course in termDict[@"courses"]) {
            
                NSDictionary *result = results[course.objectID];
                NSNumber *newScore;
                if (result) {
                    NSNumber *oldScore = result[@"score"];
                    newScore = @(oldScore.doubleValue + idf);
                } else {
                    newScore = idfNum;
                }
                
                results[course.objectID] = @{@"score":newScore, @"course":course};
        }
    }
    
    NSMutableArray *unsorted = [NSMutableArray array];
    
    for (NSString *catNum in results) {
        [unsorted addObject:[results objectForKey:catNum]];
    }
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO];

    NSArray *sortedResults = [unsorted sortedArrayUsingDescriptors:@[descriptor]];
    for (NSDictionary *result in sortedResults) {
        Course *course = result[@"course"];
        NSLog(@"\n%@\n%@", course.title, result[@"score"]);
    }
    
//
//    
//    NSArray *unsorted = [set allObjects];
//    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES];
//    
//    NSLog(@"%@", [unsorted sortedArrayUsingDescriptors:@[descriptor]]);
    
    // Only parse CSV files if we have no Q data
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"QScore"];
//    NSUInteger count = [context countForFetchRequest:request error:nil];
//    if (count > 0) {
//        return YES;
//    }
    
//    // Start CSV parsing operations, using CHCSVParser objects wrapped up in QDataParserDelegate objects
//    QDataParserDelegate *commentDelegate = [[QDataParserDelegate alloc] init];
//    [commentDelegate updateQDataInMode:kModeComment];
//    
//    QDataParserDelegate *difficultyDelegate = [[QDataParserDelegate alloc] init];
//    [difficultyDelegate updateQDataInMode:kModeScoreDifficulty];
//    
//    QDataParserDelegate *overallDelegate = [[QDataParserDelegate alloc] init];
//    [overallDelegate updateQDataInMode:kModeScoreOverall];
//    
//    QDataParserDelegate *workloadDelegate = [[QDataParserDelegate alloc] init];
//    [workloadDelegate updateQDataInMode:KModeScoreWorkload];

    return YES;
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
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
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
