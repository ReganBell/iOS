//
//  Meeting.h
//  Coursica
//
//  Created by Regan Bell on 11/23/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Meeting : NSManagedObject

@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * optional;
@property (nonatomic, retain) NSString * beginTime;
@property (nonatomic, retain) NSString * endTime;
@property (nonatomic, retain) Course *course;

@end
