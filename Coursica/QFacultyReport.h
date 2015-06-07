//
//  QFacultyReport.h
//  Coursica
//
//  Created by Regan Bell on 6/6/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "Mantle.h"

@interface QFacultyReport : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString     * fullName;
@property (strong, nonatomic) NSDictionary * responses;

@end
