//
//  Course.h
//  Coursica
//
//  Created by Regan Bell on 11/23/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSString * catalogNumber;
@property (nonatomic, retain) NSString * term;
@property (nonatomic, retain) NSNumber * bracketed;
@property (nonatomic, retain) NSString * field;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * courseDescription;
@property (nonatomic, retain) NSString * prereqs;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSSet *faculty;
@property (nonatomic, retain) NSSet *prerequisites;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) NSSet *meetings;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addFacultyObject:(NSManagedObject *)value;
- (void)removeFacultyObject:(NSManagedObject *)value;
- (void)addFaculty:(NSSet *)values;
- (void)removeFaculty:(NSSet *)values;

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

@end
