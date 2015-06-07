//
//  QResponse.h
//  Coursica
//
//  Created by Regan Bell on 6/6/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "Mantle.h"

@class QBaseline;

@interface QResponse : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString     * title;
@property (strong, nonatomic) QBaseline * singleTermBaseline;
@property (strong, nonatomic) QBaseline * threeYearBaseline;
@property (strong, nonatomic) NSArray      * breakdown;
@property (strong, nonatomic) NSNumber     * mean;
@property (strong, nonatomic) NSNumber     * median;

@end
