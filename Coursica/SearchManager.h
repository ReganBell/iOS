//
//  SearchManager.h
//  Coursica
//
//  Created by Regan Bell on 1/25/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Course;

@interface SearchManager : NSObject

+ (SearchManager*)sharedSearchManager;
- (void)addCourseToSearchIndex:(Course*)course;
- (void)calculateIDFs;
- (NSArray*)coursesForSearch:(NSString*)search;

@end
