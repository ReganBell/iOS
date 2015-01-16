//
//  TheScrapist.m
//  Coursica
//
//  Created by Regan Bell on 11/24/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "FullOnScrapist.h"
#import "TFHpple.h"
#import "AFNetworking.h"
#import "NSString+HTML.h"
#import "Course.h"
#import "AppDelegate.h"
#import "Faculty.h"
#import "Meeting.h"
#import "Location.h"

@interface FullOnScrapist ()

@property (strong, nonatomic) NSNumberFormatter *sharedFormatter;
@property (strong, nonatomic) NSRegularExpression *sharedParenthesesRegEx;
@property (strong, nonatomic) NSOperationQueue *requestQueue;

@end

@implementation FullOnScrapist

- (NSNumberFormatter *)sharedFormatter {
    
    if (!_sharedFormatter) {
        _sharedFormatter = [[NSNumberFormatter alloc] init];
    }
    return _sharedFormatter;
}

- (NSString*)textForCourseField:(NSString*)field onPage:(TFHpple*)coursePage {
    
    NSString *baseXPath = @"//div[@class='course-field course-course_";
    NSString *XPath = [NSString stringWithFormat:@"%@%@']/span[@class='course-field-value']", baseXPath, field];
    
    TFHppleElement *element = [coursePage peekAtSearchWithXPathQuery:XPath];
    return element.text;
}

- (NSOperationQueue*)requestQueue {
    
    if (!_requestQueue) {
        _requestQueue = [[NSOperationQueue alloc] init];
        [_requestQueue setMaxConcurrentOperationCount:20];
    }
    return _requestQueue;
}

- (void)scrapeSearchResultsPage {
    
    //Scrape search results pages 0-566
    
    for (int i = 0; i < 567; i++) {
        
        NSString *coursePageURLString = [NSString stringWithFormat:@"http://www.registrar.fas.harvard.edu/courses-exams/course-catalog?search_api_views_fulltext=&page=%d", i];
        
        NSURL *url = [NSURL URLWithString:coursePageURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation  alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self createCoursesFromResultsPageData:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [self.requestQueue addOperation:operation];
        
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        
//        
//        [manager GET:coursePageURLString parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
//            
//            [self createCoursesFromResultsPageData:responseObject];
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error fetching lists: %@", error);
//        }];
    }
}

- (void)createCoursesFromResultsPageData:(NSData*)pageData {
    
    TFHpple *coursesPage = [TFHpple hppleWithHTMLData:pageData];
    
    NSString *courseLinkXPath = @"//span[@class='qtip-link']/a";
    NSArray *courseLinks = [coursesPage searchWithXPathQuery:courseLinkXPath];
    
    for (TFHppleElement *linkElement in courseLinks) {
        
        NSString *linkString = linkElement.attributes[@"href"];
        
        NSURL *url = [NSURL URLWithString:linkString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"dl'ed %@", linkString);
            [self createCourseFromCoursePageData:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [self.requestQueue addOperation:operation];
    }
//
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        [manager GET:linkString parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *responseObject) {
//            
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error fetching lists: %@", error);
//        }];
}

- (void)createCourseFromCoursePageData:(NSData*)pageData {
    
    TFHpple *coursePage = [TFHpple hppleWithHTMLData:pageData];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSEntityDescription *courseEntity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:context];
    NSEntityDescription *facultyEntity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:context];
    NSEntityDescription *meetingEntity = [NSEntityDescription entityForName:@"Meeting" inManagedObjectContext:context];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:context];
    
    Course *newCourse = [[Course alloc] initWithEntity:courseEntity insertIntoManagedObjectContext:context];
    
    NSString *titleXPath = @"//h1[@id='page-title']";
    TFHppleElement *titleElement = [coursePage peekAtSearchWithXPathQuery:titleXPath];
    
    // "Dramatic Arts 101. Introduction to Theater"
    NSString *rawTitle = titleElement.text;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:rawTitle];
    NSString *fieldAndNumber;
    NSString *title;
    [scanner scanUpToString:@"." intoString:&fieldAndNumber];
    [scanner setScanLocation:scanner.scanLocation + 2];
    [scanner scanUpToString:@"" intoString:&title];
    
    newCourse.title = title;
    
    NSArray *comps = [fieldAndNumber componentsSeparatedByString:@" "];
    NSString *number = [comps lastObject];
    newCourse.number = number;
    
    NSString *field = [fieldAndNumber stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@", number] withString:@""];
    //            newCourse.shortField = field;
    newCourse.longField = field;
    
    NSString *rawCatNum = [self textForCourseField:@"catalog_number" onPage:coursePage];
    newCourse.catalogNumber = rawCatNum;
    
    NSString *rawFaculty = [self textForCourseField:@"faculty_text" onPage:coursePage];
    NSSet *newFaculty = [self facultyFromRawString:rawFaculty withEntity:facultyEntity context:context];
    [newCourse addFaculty:newFaculty];
    
    NSString *rawLevel = [self textForCourseField:@"level" onPage:coursePage];
    newCourse.graduate = [self graduateForRawCourseLevel:rawLevel];
    
    //            NSString *rawCredit = [self textForCourseField:@"credit_amount" onPage:coursePage];
    
    NSString *rawTerm = [self textForCourseField:@"term" onPage:coursePage];
    newCourse.term = [self termForRawTermString:rawTerm];
    
    NSString *rawMeeting = [self textForCourseField:@"meeting_text" onPage:coursePage];
    if (rawMeeting.length == 0) {
        NSLog(@"Error! No meeting string for %@", newCourse.title);
    } else {
        NSSet *newMeetings = [self meetingsForRawMeetingsString:rawMeeting];
        [newCourse addMeetings:newMeetings];
    }
    
    NSString *rawExamGroup = [self textForCourseField:@"exam_group" onPage:coursePage];
    
    
    NSString *rawDescription = [self textForCourseField:@"description" onPage:coursePage];
    newCourse.courseDescription = rawDescription;
    
    NSString *rawPrereqs = [self textForCourseField:@"prerequisites" onPage:coursePage];
    NSString *rawNotes = [self textForCourseField:@"notes" onPage:coursePage];
    
    [context save:nil];
}

- (NSSet*)meetingsForRawMeetingsString:(NSString*)rawString {

    NSScanner *scanner = [[NSScanner alloc] initWithString:rawString];
    NSString *dayString;
    // Meeting string "rawString" is structured like:
    
    // Tu., Th., 2 - 3:30, and a weekly section to be arranged.
    
    // The days of the week the course will meet always come before the meeting time, and the meeting time is always the same for each day the course meets
    // So we can divide the string into one half that has the meeting days, and another half that has the meeting times
    
    // We do this by scanning the first half into "dayString" until we find a number
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&dayString];
    
    // The other half of the string contains the meeting times
    NSString *timeString;
    [scanner scanUpToString:@"" intoString:&timeString];
    
    NSMutableSet *meetings = [[NSMutableSet alloc] init];
    
    // Optional meeting days are surrounded with parens like (Tu.)
    // We grab those with regex and create meeting objects for them with "optional" property set to YESp
    NSArray *optionalDays = [self.sharedParenthesesRegEx matchesInString:dayString options:0 range:NSMakeRange(0, dayString.length)];
    for (NSTextCheckingResult *result in optionalDays) {
        
        NSString *optionalDay = [dayString substringWithRange:result.range];
        [meetings addObjectsFromArray:[self meetingsInString:optionalDay optional:YES]];
        dayString = [dayString stringByReplacingOccurrencesOfString:optionalDay withString:@""];
    }
    
    [meetings addObjectsFromArray:[self meetingsInString:dayString optional:NO]];
    
    NSError *error;
    NSRegularExpression *timeRegEx = [NSRegularExpression regularExpressionWithPattern:@"[0-9:]+" options:0 error:&error];
    if (timeString.length == 0) {
        NSLog(@"Error! no timeString, full text was: %@", rawString);
    } else {
        NSArray *times = [timeRegEx matchesInString:timeString options:0 range:NSMakeRange(0, timeString.length)];
        
        if (times.count == 1 || times.count == 2) {
            int timeIndex = 0;
            for (NSTextCheckingResult *result in times) {
                if (timeIndex == 0) {
                    for (Meeting *meeting in meetings) {
                        meeting.beginTime = [timeString substringWithRange:result.range];
                        if (times.count == 1) {
                            meeting.endTime = [self oneHourLaterEndTimeString:meeting.beginTime];
                        }
                    }
                }
                else {
                    for (Meeting *meeting in meetings) {
                        meeting.endTime = [timeString substringWithRange:result.range];
                    }
                }
                timeIndex++;
            }
        } else {
            NSLog(@"Error: Weird number of times in timeString: %@", rawString);
        }
    }

    if (meetings.count) {
        return meetings;
    } else
        return nil;
}

- (NSString*)oneHourLaterEndTimeString:(NSString*)beginTime {
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:beginTime];
    NSString *hourString = nil;
    NSString *minuteString = @"";
    [scanner scanUpToString:@":" intoString:&hourString];
    [scanner scanUpToString:@"" intoString:&minuteString];
    
    NSInteger hour = [self.sharedFormatter numberFromString:hourString].integerValue;
    hour++;
    if (hour > 12) {
        hour -= 12;
    }
    return [NSString stringWithFormat:@"%ld%@", hour, minuteString];
}

- (NSMutableArray*)meetingsInString:(NSString*)string optional:(BOOL)optional {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSEntityDescription *meetingEntity = [NSEntityDescription entityForName:@"Meeting" inManagedObjectContext:context];
    
    NSMutableArray *meetingSet = [[NSMutableArray alloc] init];
    
    NSDictionary *days = @{@"M.":@1, @"Tu.":@2, @"W.":@3, @"Th.":@4, @"F.":@5};
    for (NSString *dayAbbrv in days) {
        
        BOOL found = [string rangeOfString:dayAbbrv].location != NSNotFound;
        if (found) {
            Meeting *meeting = [[Meeting alloc] initWithEntity:meetingEntity insertIntoManagedObjectContext:context];
            meeting.day = days[dayAbbrv];
            meeting.optional = [NSNumber numberWithBool:optional];
            [meetingSet addObject:meeting];
        }
    }
    return meetingSet;
}

- (NSString*)termForRawTermString:(NSString*)rawTerm {
    
    BOOL fall = ([rawTerm rangeOfString:@"fall" options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL spring = ([rawTerm rangeOfString:@"spring" options:NSCaseInsensitiveSearch].location != NSNotFound);
    if (fall && spring) {
        return @"BOTH";
    } else if (fall) {
        return @"FALL";
    } else if (spring)
        return @"SPRING";
    else {
        return nil;
    }
}

- (NSNumber*)graduateForRawCourseLevel:(NSString*)rawLevel {
    
    BOOL graduate = ([rawLevel rangeOfString:@"Graduates" options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL both = ([rawLevel rangeOfString:@"and" options:NSCaseInsensitiveSearch].location != NSNotFound);
    if (graduate && !both) {
        return [NSNumber numberWithBool:YES];
    } else
        return [NSNumber numberWithBool:NO];
}

- (NSRegularExpression*)sharedParenthesesRegEx {
 
    if (!_sharedParenthesesRegEx) {
        _sharedParenthesesRegEx = [[NSRegularExpression alloc] initWithPattern:@"\\(.+?\\)" options:0 error:nil];
    }
    return _sharedParenthesesRegEx;
}

- (NSSet*)facultyFromRawString:(NSString*)rawString withEntity:(NSEntityDescription*)entity context:(NSManagedObjectContext*)context {
    
    // String could look as gnarly as:
    // Cliff Taubes, Rosalie Belanger-Rioux, Sarah Chisholm, Nina Zipser, and members of the Department (fall term) Jameel Al-Aidroos, Rosalie Belanger-Rioux, Yu-Wen Hsu, and members of the Dpartment (spring term)
    // "Jack L. Goldsmith (Law School) and Bruce Schneier (Law School)"
    // "David J. Malan and Jelani Nelson"
    // "David Malan"
    
    if ([rawString rangeOfString:@"to be determined"].location != NSNotFound) {
        return nil;
    }
    
    NSMutableString *string = [NSMutableString stringWithString:rawString];
    [self.sharedParenthesesRegEx replaceMatchesInString:string options:0 range:NSMakeRange(0, rawString.length) withTemplate:@""];
    
    NSArray *facultyFullNames = nil;
    
    // Faculty strings look like:
    // List with ands: "David Malan and Eric Rentschler" or
    // List with commas: "Janet Gyatso, David Malan, and Eric Rentschler"
    NSRange commaRange = [string rangeOfString:@","];
    
    // If there are any commas we usually have a list with commas
    if (commaRange.location != NSNotFound) {
        
        NSRange range = [string rangeOfString:@"and "];
        if (range.location != NSNotFound) {
            
            // "Janet Gyatso, David Malan, and Eric Rentschler" becomes ""Janet Gyatso, David Malan, Eric Rentschler"
            [string deleteCharactersInRange:[string rangeOfString:@"and "]];
        }
        
        facultyFullNames = [string componentsSeparatedByString:@", "];
    } else {
        
        NSRange andRange = [string rangeOfString:@"and"];
        
        if (andRange.location != NSNotFound) {
            facultyFullNames = [string componentsSeparatedByString:@" and "];
        } else
            facultyFullNames = @[string];
    }
    
    NSMutableSet *facultySet = [NSMutableSet set];
    
    for (NSString *fullName in facultyFullNames) {
        
        // "Members of the Department" shows up sometimes, this isn't a faculty member
        if ([fullName rangeOfString:@"department" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            continue;
        }
        
        NSArray *names = [fullName componentsSeparatedByString:@" "];
        
        NSMutableDictionary *professorDictionary = [NSMutableDictionary dictionary];
        Faculty *newFaculty = [[Faculty alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        
        if (names.count < 2 || names.count > 3) {
            // problem
            if (names.count > 3) {
                names = [names subarrayWithRange:NSMakeRange(0, 3)];
            }
        }
        
        newFaculty.first = [names firstObject];
        newFaculty.last = [names lastObject];
        if (names.count == 3) {
            [professorDictionary setObject:names[1] forKey:@"middle"];
        }
        
        [facultySet addObject:newFaculty];
    }
    
    return facultySet;
}

- (NSMutableDictionary*)locationsFromRawString:(NSString*)rawString {
    
    return [NSMutableDictionary dictionary];
}

- (NSString*)catalogNumberFromRawString:(NSString*)rawString {
    
    // Raw catalog number strings look like "Catalog Number: 4949 Enrollment capped at 12"
    // There's a tab or /t after the number, before "Enrollment"
    // So numberString is "Catalog Number: 4949"
    // And components[2] is "4949"
    
    NSArray *tabComps = [rawString componentsSeparatedByString:@"	"];
    NSString *numberString = tabComps[0];
    NSArray *spaceComps = [numberString componentsSeparatedByString:@" "];
    return spaceComps[2];
}

- (NSString*)courseTitleFromTitleNode:(TFHppleElement*)element {
    
    if (element.children.count > 1) {
        TFHppleElement *child = element.children[1];
        return [child.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n[]*"]];
    }
    else
        return [element.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n[]*"]];

}

@end
