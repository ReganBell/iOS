//
//  QReport.h
//  Coursica
//
//  Created by Regan Bell on 4/20/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "Mantle.h"

@class Course, FDataSnapshot;

@interface QReport : MTLModel <MTLJSONSerializing>

@property (nonatomic, retain) NSString * term;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSNumber * enrollment;
@property (nonatomic, retain) NSArray  * comments;
@property (nonatomic, retain) NSDictionary * responses;

@end