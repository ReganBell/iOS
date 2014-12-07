//
//  Course.m
//  Coursica
//
//  Created by Regan Bell on 11/23/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "Course.h"
#import "Faculty.h"
#import "Meeting.h"
#import "Location.h"
#import "AppDelegate.h"
#import "CHCSVParser.h"
#import "QScore.h"

@implementation Course

@dynamic catalogNumber;
@dynamic term;
@dynamic bracketed;
@dynamic field;
@dynamic number;
@dynamic title;
@dynamic courseDescription;
@dynamic prereqs;
@dynamic notes;
@dynamic faculty;
@dynamic prerequisites;
@dynamic locations;
@dynamic meetings;
@dynamic graduate;
@dynamic genEdOne;
@dynamic genEdTwo;

+ (void)updateCourses:(NSArray *)serverCourses {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSEntityDescription *courseEntity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:context];
    NSEntityDescription *facultyEntity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:context];
    NSEntityDescription *meetingEntity = [NSEntityDescription entityForName:@"Meeting" inManagedObjectContext:context];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:context];
    
    NSMutableDictionary *scoresDict = [NSMutableDictionary new];
    NSFetchRequest *qRequest = [NSFetchRequest fetchRequestWithEntityName:@"QScore"];
    NSArray *scores = [context executeFetchRequest:qRequest error:nil];
    for (QScore *score in scores) {
        [scoresDict setObject:score forKey:[NSString stringWithFormat:@"%d - %@", score.catalogNumber.intValue, score.type]];
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    NSDictionary *genEds = @{@"Aesthetic and Interpretive Understanding": @1,
                             @"Culture and Belief": @2,
                             @"Empirical and Mathematical Reasoning": @3,
                             @"Ethical Reasoning": @4,
                             @"Science of Living Systems": @5,
                             @"Science of the Physical Universe": @6,
                             @"Societies of the World": @7,
                             @"United States in the World": @8};
    
    NSDictionary *genEdAbbrvs = @{@"AESTH&INTP": @1,
                             @"CULTR&BLF": @2,
                             @"E&M-REASON": @3,
                             @"ETH-REASON": @4,
                             @"SCI-LIVSYS": @5,
                             @"SCI-PHYUNV": @6,
                             @"SOC-WORLD": @7,
                             @"US-WORLD": @8};
    
    for (NSDictionary *courseDict in serverCourses) {
        
        Course *newCourse = [[Course alloc] initWithEntity:courseEntity insertIntoManagedObjectContext:context];
        newCourse.catalogNumber = [formatter numberFromString:courseDict[@"cat_num"]];
        newCourse.term = courseDict[@"term"];
        newCourse.bracketed = courseDict[@"bracketed"];
        newCourse.field = courseDict[@"field"];
        newCourse.number = courseDict[@"number"];
        newCourse.prereqs = courseDict[@"prerequisites"];
        newCourse.title = courseDict[@"title"];
        newCourse.courseDescription = courseDict[@"description"];
        newCourse.notes = courseDict[@"notes"];
        
        NSDictionary *types = @{@"difficulty":@"qDifficulty", @"workload":@"qWorkload", @"overall":@"qOverall"};
        for (NSString *scoreType in types) {
            
            QScore *score = [scoresDict objectForKey:[NSString stringWithFormat:@"%d - %@", newCourse.catalogNumber.intValue, scoreType]];
            NSNumber *average = [NSNumber numberWithDouble:(score.one.doubleValue + score.two.doubleValue * 2 + score.three.doubleValue * 3 + score.four.doubleValue * 4 + score.five.doubleValue * 5) / (score.one.doubleValue + score.two.doubleValue + score.three.doubleValue + score.four.doubleValue + score.five.doubleValue)];
            [newCourse setValue:average forKey:[types objectForKey:scoreType]];
        }
        
        int genEdsFound = 0;
        NSNumber *fieldGenEd = nil;
        
        for (NSString *genEdAbbrv in genEdAbbrvs) {
            if ([newCourse.field isEqualToString:genEdAbbrv]) {
                newCourse.genEdOne = genEdAbbrvs[genEdAbbrv];
                fieldGenEd = newCourse.genEdOne;
                genEdsFound++;
            }
        }
        
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
                } else {
                    NSLog(@"ALERT a course has more than two gen-eds");
                }
            }
        }
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:nil];
        NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:newCourse.number options:0 range:NSMakeRange(0, [newCourse.number length])];
        
        if (rangeOfFirstMatch.location == NSNotFound) {
            newCourse.graduate = [NSNumber numberWithBool:NO];
        } else {
            NSString *substringForFirstMatch = [newCourse.number substringWithRange:rangeOfFirstMatch];
            double number = [formatter numberFromString:substringForFirstMatch].doubleValue;
            if ((number >= 200 && number < 1000) || (number >= 2000)) {
                newCourse.graduate = [NSNumber numberWithBool:YES];
            } else
                newCourse.graduate = [NSNumber numberWithBool:NO];
        }
        
        for (NSDictionary *professor in courseDict[@"faculty"]) {
            
            Faculty *faculty = [[Faculty alloc] initWithEntity:facultyEntity insertIntoManagedObjectContext:context];
            faculty.first = professor[@"first"];
            faculty.middle = professor[@"middle"];
            faculty.last = professor[@"last"];
            faculty.suffix = professor[@"suffix"];
            [newCourse addFacultyObject:faculty];
        }
        
        for (NSDictionary *meeting in courseDict[@"schedule"]) {
            
            Meeting *newMeeting = [[Meeting alloc] initWithEntity:meetingEntity insertIntoManagedObjectContext:context];
            newMeeting.day = [formatter numberFromString:meeting[@"day"]];
            newMeeting.type = meeting[@"type"];
            newMeeting.optional = meeting[@"optional"];
            newMeeting.beginTime = meeting[@"begin_time"];
            newMeeting.endTime = meeting[@"end_time"];
            [newCourse addMeetingsObject:newMeeting];
        }
        
        for (NSDictionary *location in courseDict[@"locations"]) {
            
            Location *newLocation = [[Location alloc] initWithEntity:locationEntity insertIntoManagedObjectContext:context];
            newLocation.type = location[@"type"];
            newLocation.building = location[@"building"];
            newLocation.room = location[@"room"];
            [newCourse addLocationsObject:newLocation];
        }
    }
    
    NSError *error = nil;
    [context save:&error];
    if (error) {
        NSLog(@"Error saving context: %@", error);
    }
}

@end
