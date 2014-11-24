//
//  Location.h
//  Coursica
//
//  Created by Regan Bell on 11/23/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * building;
@property (nonatomic, retain) NSString * room;
@property (nonatomic, retain) NSSet *course;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addCourseObject:(Course *)value;
- (void)removeCourseObject:(Course *)value;
- (void)addCourse:(NSSet *)values;
- (void)removeCourse:(NSSet *)values;

@end
