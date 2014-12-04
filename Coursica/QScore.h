//
//  QScore.h
//  Coursica
//
//  Created by Regan Bell on 12/2/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface QScore : NSManagedObject

@property (nonatomic, retain) NSNumber * one;
@property (nonatomic, retain) NSNumber * two;
@property (nonatomic, retain) NSNumber * three;
@property (nonatomic, retain) NSNumber * four;
@property (nonatomic, retain) NSNumber * five;

@property (nonatomic, retain) NSString * type; // overall, workload, instructor, difficulty

@property (nonatomic, retain) NSNumber * catalogNumber;

@end
