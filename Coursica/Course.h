//
//  Course.h
//  Coursica
//
//  Created by Regan Bell on 11/23/14.
//  Matthew Beatty
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSNumber * bracketed;
@property (nonatomic, retain) NSString * catalogNumber;
@property (nonatomic, retain) NSString * courseDescription;
@property (nonatomic, retain) NSString * examGroup;
@property (nonatomic, retain) NSNumber * genEdOne;
@property (nonatomic, retain) NSNumber * genEdTwo;
@property (nonatomic, retain) NSNumber * graduate;
@property (nonatomic, retain) NSString * longField;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * prereqs;
@property (nonatomic, retain) NSNumber * qDifficulty;
@property (nonatomic, retain) NSNumber * qOverall;
@property (nonatomic, retain) NSNumber * qWorkload;
@property (nonatomic, retain) NSNumber *searchScore;
@property (nonatomic, retain) NSString * shortField;
@property (nonatomic, retain) NSString * term;
@property (nonatomic, retain) NSString * title;

@property (nonatomic, retain) NSSet *faculty;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) NSSet *meetings;
@property (nonatomic, retain) NSSet *prerequisites;
@property (nonatomic, retain) NSSet *qReports;

// Actual NSNumber representation of course number, used so that classes won't be ordered by string comparison
// For instance we want it to go 11, 13, 14, 131 -- not 11, 13, 131, 14
@property (nonatomic, retain) NSNumber *decimalNumber;

@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addFacultyObject:(NSManagedObject *)value;
- (void)removeFacultyObject:(NSManagedObject *)value;
- (void)addFaculty:(NSSet *)values;
- (void)removeFaculty:(NSSet *)values;

- (void)addqReportsObject:(NSManagedObject *)value;
- (void)removeqReportsObject:(NSManagedObject *)value;
- (void)addqReports:(NSSet *)values;
- (void)removeqReports:(NSSet *)values;

- (void)addPrerequisitesObject:(Course *)value;
- (void)removePrerequisitesObject:(Course *)value;
- (void)addPrerequisites:(NSSet *)values;
- (void)removePrerequisites:(NSSet *)values;

- (void)addLocationsObject:(NSManagedObject *)value;
- (void)removeLocationsObject:(NSManagedObject *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

- (void)addMeetingsObject:(NSManagedObject *)value;
- (void)removeMeetingsObject:(NSManagedObject *)value;
- (void)addMeetings:(NSSet *)values;
- (void)removeMeetings:(NSSet *)values;

- (NSString *)purifyString:(NSString *)string;
- (NSString *)displayTitle;

+ (void)updateCourses:(NSArray*)serverCourses;
+ (void)updateQData;

@end
