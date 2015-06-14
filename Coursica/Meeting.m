//
//  Meeting.m
//  Coursica
//
//  Created by Regan Bell on 11/23/14.
//  Matthew Beatty
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "Meeting.h"
#import "Course.h"


@implementation Meeting

@dynamic day;
@dynamic type;
@dynamic optional;
@dynamic beginTime;
@dynamic endTime;
@dynamic course;

+ (NSString *)standardTimeFromMilitaryTime:(NSString *)militaryTimeString {
    
    NSString *rawHourString = [militaryTimeString componentsSeparatedByString:@":"][0];
    NSString *rawMinuteString = [militaryTimeString componentsSeparatedByString:@":"][1];
    
    NSString *minuteString = ([rawMinuteString intValue] == 0) ? @"":[NSString stringWithFormat:@":%@", rawMinuteString];
    NSString *hourString = ([rawHourString intValue] > 12) ? [NSString stringWithFormat:@"%d", rawHourString.intValue - 12] : rawHourString;
    
    return [NSString stringWithFormat:@"%@%@", hourString, minuteString];
}

+ (NSString *)abbreviatedStringForDayNumber:(NSNumber*)dayNumber {
    
    switch (dayNumber.intValue)
    {
        case 0:
            return @"Sun";
        case 1:
            return @"Mon";
        case 2:
            return @"Tues";
        case 3:
            return @"Wed";
        case 4:
            return @"Thurs";
        case 5:
            return @"Fri";
        case 6:
            return @"Sat";
        default:
            return nil;
    }
}

- (NSString *)displayString {
    
    return [NSString stringWithFormat:@"%@-%@", [self.class standardTimeFromMilitaryTime:self.beginTime], [self.class standardTimeFromMilitaryTime:self.endTime]];
}

@end
