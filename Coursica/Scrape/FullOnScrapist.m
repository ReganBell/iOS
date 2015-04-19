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
#import "SearchManager.h"

@interface FullOnScrapist ()

@property (strong, nonatomic) NSNumberFormatter *sharedFormatter;
@property (strong, nonatomic) NSRegularExpression *sharedParenthesesRegEx;
@property (strong, nonatomic) NSOperationQueue *requestQueue;
@property (strong, nonatomic) NSMutableDictionary *fieldsDict;
@property (strong, nonatomic) NSMutableDictionary *uniqueCourses;

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
    
    // Create fields dict to use to assign field abbreviations
    
    NSError *error;
    
    NSString *shortString = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ShortFields"] encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    NSString *longString = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LongFields"] encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    NSArray *shortFields = [shortString componentsSeparatedByString:@",\n"];
    NSArray *longFields = [longString componentsSeparatedByString:@",\n"];
    
    self.fieldsDict = [NSMutableDictionary dictionary];
    
    int i = 0;
    for (NSString *longField in longFields) {
        [self.fieldsDict setObject:shortFields[i] forKey:longField];
        i++;
    }

    //Scrape search results pages 0-566
    
    for (int i = 60; i < 100; i++) {
        
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
}

- (void)setTitleFieldNumberOfCourse:(Course*)newCourse fromRawTitle:(NSString*)rawTitle {
    
    // "Dramatic Arts 101. Introduction to Theater"
    NSScanner *scanner = [[NSScanner alloc] initWithString:rawTitle];
    NSString *fieldAndNumber;
    NSString *title;
    
    // "Dramatic Arts 101."
    [scanner scanUpToString:@". " intoString:&fieldAndNumber];
    [scanner setScanLocation:scanner.scanLocation + 2];
    
    // "Introduction to Theater"
    [scanner scanUpToString:@"" intoString:&title];
    
    title = [self sanitizedCourseTitle:title];
    
    // Check if course is bracketed, e.g. "[Introduction to Computer Science]" meaning it isn't currently being offered but is still in the catalog
    NSRange range = [title rangeOfString:@"]"];
    if (range.location == (title.length - 1)) {
        newCourse.bracketed = @YES;
        newCourse.title = [NSString stringWithFormat:@"[%@", title];
    } else {
        newCourse.bracketed = @NO;
        newCourse.title = title;
    }
    
    // Some fieldAndNumbers are like Aesthetic and Interpretive Understanding 59 (formerly Culture and Belief 54)
    // We remove anything inside parentheses
    range = NSMakeRange(0, fieldAndNumber.length);
    fieldAndNumber = [self.sharedParenthesesRegEx stringByReplacingMatchesInString:fieldAndNumber options:0 range:range withTemplate:@""];
    fieldAndNumber = [fieldAndNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *comps = [fieldAndNumber componentsSeparatedByString:@" "];
    NSString *number = [comps lastObject];
    newCourse.number = [number stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    // So we can rank classes by their actual numeric value, not by string comparison ("131" shouldn't come before "14")
    NSScanner *numberScanner = [NSScanner scannerWithString:newCourse.number];
    NSInteger decimalNumber = -1;
    BOOL success = [numberScanner scanInteger:&decimalNumber];
    if (success) {
        newCourse.decimalNumber = @(decimalNumber);
    } else
        newCourse.decimalNumber = @(-1);
    
    NSString *field = [fieldAndNumber stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@", number] withString:@""];
    NSScanner *fieldScanner = [[NSScanner alloc] initWithString:field];
    [fieldScanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"*[]"]];
    NSString *trimmed;
    [fieldScanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&trimmed];
    
    NSString *longField = [trimmed stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    newCourse.longField = longField;
    
    NSString *shortField = self.fieldsDict[longField];
    if (shortField == nil) {
        
        NSArray *components = [longField componentsSeparatedByString:@" "];
        shortField = [components[0] uppercaseString];
    }
    newCourse.shortField = shortField;
}

- (void)setGenEdsForCourse:(Course*)newCourse {
    
    NSDictionary *genEds = @{@"Aesthetic and Interpretive Understanding": @1,
                             @"Culture and Belief": @2,
                             @"Empirical and Mathematical Reasoning": @3,
                             @"Ethical Reasoning": @4,
                             @"Science of Living Systems": @5,
                             @"Science of the Physical Universe": @6,
                             @"Societies of the World": @7,
                             @"Study of the Past": @8,
                             @"United States in the World": @9};
    
    NSDictionary *genEdAbbrvs = @{@"AESTH&INTP": @1,
                                  @"CULTR&BLF": @2,
                                  @"E&M-REASON": @3,
                                  @"ETH-REASON": @4,
                                  @"SCI-LIVSYS": @5,
                                  @"SCI-PHYUNV": @6,
                                  @"SOC-WORLD": @7,
                                  @"US-WORLD": @9};
    
    int genEdsFound = 0;
    NSNumber *fieldGenEd = nil;
    
    // Lots of classes with a gen ed as their field don't report the gen ed they satisfy in their notes section so we have to get it from the field name
    for (NSString *genEdAbbrv in genEdAbbrvs) {
        if ([newCourse.shortField isEqualToString:genEdAbbrv]) {
            newCourse.genEdOne = genEdAbbrvs[genEdAbbrv];
            fieldGenEd = newCourse.genEdOne;
            genEdsFound++;
        }
    }
    
    // Scan through the notes of every class looking for mention of a gen ed it satisfies, save that on the course object
    for (NSString *genEd in genEds) {
        NSRange range = [newCourse.notes rangeOfString:genEd];
        if (range.location != NSNotFound) {
            NSNumber *genEdNum = genEds[genEd];
            if (genEdNum.intValue == fieldGenEd.intValue) {
                continue;
            }
            if (genEdsFound == 0) {
                newCourse.genEdOne = genEdNum;
                genEdsFound++;
            } else if (genEdsFound == 1) {
                newCourse.genEdTwo = genEdNum;
                genEdsFound++;
            }
        }
    }
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
    [self setTitleFieldNumberOfCourse:newCourse fromRawTitle:titleElement.text];
    
    Course *existingCourse = self.uniqueCourses[newCourse.title];
    if (existingCourse) {
        [context deleteObject:newCourse];
        return;
    } else
        [self.uniqueCourses setObject:newCourse forKey:newCourse.title];
    
    NSString *rawCatNum = [self textForCourseField:@"catalog_number" onPage:coursePage];
    newCourse.catalogNumber = rawCatNum;
    
    NSString *rawFaculty = [self textForCourseField:@"faculty_text" onPage:coursePage];
    NSSet *newFaculty = [self facultyFromRawString:rawFaculty withEntity:facultyEntity context:context];
    [newCourse addFaculty:newFaculty];
    
    newCourse.graduate = [self graduateForCourse:newCourse];
    
//    NSString *rawCredit = [self textForCourseField:@"credit_amount" onPage:coursePage];
    
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
    
    NSString *description = [self textForCourseField:@"description" onPage:coursePage];
    if (description.length == 0)
        newCourse.courseDescription = @"No course description provided.";
    else
        newCourse.courseDescription = description;
    
    NSString *rawPrereqs = [self textForCourseField:@"prerequisites" onPage:coursePage];
    newCourse.prereqs = rawPrereqs;
    
    NSString *rawNotes = [self textForCourseField:@"notes" onPage:coursePage];
    newCourse.notes = rawNotes;
    
    [self setGenEdsForCourse:newCourse];
    
    [context save:nil];
}

- (NSString*)sanitizedCourseTitle:(NSString*)title {
    
//    NSMutableCharacterSet *allowedChars = [NSMutableCharacterSet lowercaseLetterCharacterSet];
//    [allowedChars formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
//    [allowedChars formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
//    [allowedChars formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    
//    title =
    
    return [title stringByReplacingOccurrencesOfString:@" - (New Course)" withString:@""];
    
//    NSScanner *scanitizer = [NSScanner scannerWithString:title];
//    NSString *cleanTitle;
//    [scanitizer scanCharactersFromSet:allowedChars intoString:&cleanTitle];
//    
//    return cleanTitle;
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

- (NSNumber*)graduateForCourse:(Course*)course {
    
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:nil];
//    
//    // Find out whether is a class is for undergraduates or graduates by the number
//    // First we regex out the course number (a lot of them have weird letters and periods)
//    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:numberString options:0 range:NSMakeRange(0, [numberString length])];
//    
//    if (rangeOfFirstMatch.location == NSNotFound) {
//        // Some undergraduate courses' number will just be a letter and regex won't find anything
//        return [NSNumber numberWithBool:NO];
//    } else {
//        // Extract the number string and turn into a real number
//        NSString *substringForFirstMatch = [numberString substringWithRange:rangeOfFirstMatch];
//        double number = [self.sharedFormatter numberFromString:substringForFirstMatch].doubleValue;
    
    int number = course.decimalNumber.doubleValue;
    
    // Course numbering scheme explained: http://www.registrar.fas.harvard.edu/courses-exams/courses-instruction/introductory-notes
    if ((number >= 200 && number < 1000) || (number >= 2000)) {
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
    
    if (!rawString) {
        return nil;
    }
    
    if ([rawString rangeOfString:@"to be determined" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        return nil;
    }
    
    NSLog(@"Parsing raw faculty: %@", rawString);
    
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
    
    NSLog(@"fullNames: %@", facultyFullNames);
    
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
