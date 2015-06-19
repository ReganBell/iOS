//
//  QReport.m
//  Coursica
//
//  Created by Regan Bell on 4/20/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "QReport.h"
#import "QResponse.h"

@implementation QReport

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

+ (NSValueTransformer*)responsesJSONTransformer {
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSDictionary *rawDictionary = (NSDictionary*)value;
        NSMutableDictionary *responsesDictionary = [NSMutableDictionary dictionary];
        
        [rawDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *title = (NSString*)key;
            NSDictionary *responseDictionary = (NSDictionary*)obj;
            NSError *error = nil;
            QResponse *response = [MTLJSONAdapter modelOfClass:[QResponse class] fromJSONDictionary:responseDictionary error:&error];
            response.title = title;
            responsesDictionary[title] = response;
        }];
        
        return responsesDictionary;
    }];
}

@end
