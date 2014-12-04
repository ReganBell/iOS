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

+ (void)updateCourses:(NSArray *)serverCourses {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSEntityDescription *courseEntity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:context];
    NSEntityDescription *facultyEntity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:context];
    NSEntityDescription *meetingEntity = [NSEntityDescription entityForName:@"Meeting" inManagedObjectContext:context];
    NSEntityDescription *locationEntity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:context];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
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
            NSLog(@"%@", newLocation);
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
