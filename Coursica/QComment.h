//
//  QComment.h
//  Coursica
//
//  Created by Regan Bell on 12/2/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface QComment : NSManagedObject

@property (nonatomic, retain) NSNumber *catalogNumber;
@property (nonatomic, retain) NSNumber *term;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *comment;

@end
