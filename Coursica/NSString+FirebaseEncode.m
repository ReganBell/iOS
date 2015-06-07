//
//  NSString+FirebaseEncode.m
//  Coursica
//
//  Created by Regan Bell on 6/6/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "NSString+FirebaseEncode.h"

@implementation NSString (FirebaseEncode)

- (NSString*)stringEncodedAsFirebaseKey {
    
    NSString *string = self;
    NSArray *forbidden = @[@".", @"#", @"$", @"/", @"[", @"]"];
    for (int i = 0; i < forbidden.count; i++) {
        string = [string stringByReplacingOccurrencesOfString:forbidden[i] withString:[NSString stringWithFormat:@"&%d&", i]];
    }
    return string;
}

@end
