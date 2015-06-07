//
//  QResponse.m
//  Coursica
//
//  Created by Regan Bell on 6/6/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "QResponse.h"
#import "QBaseline.h"

@implementation QResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{@"singleTermBaseline": @"baselines.single_term",
             @"threeYearBaseline": @"baselines.three_years",
             @"breakdown": @"breakdown",
             @"mean": @"mean",
             @"median": @"median"};
}

+ (NSValueTransformer*)singleTermBaselineJSONTransformer {
    
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[QBaseline class]];
}

+ (NSValueTransformer*)threeYearBaselineJSONTransformer {
    
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[QBaseline class]];
}

@end
