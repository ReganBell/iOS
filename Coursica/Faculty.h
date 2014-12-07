//
//  Faculty.h
//  Coursica
//
//  Created by Regan Bell on 11/23/14.
//  Matthew Beatty
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Faculty : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * first;
@property (nonatomic, retain) NSString * middle;
@property (nonatomic, retain) NSString * last;
@property (nonatomic, retain) NSString * suffix;
@property (nonatomic, retain) NSSet *courses;
@end

@interface Faculty (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(Course *)value;
- (void)removeCoursesObject:(Course *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

@end
