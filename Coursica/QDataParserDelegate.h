//
//  QDataParserDelegate.h
//  Coursica
//
//  Created by Regan Bell on 12/2/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

typedef enum {
    
    kModeComment,
    kModeScoreOverall,
    kModeScoreDifficulty,
    KModeScoreWorkload,
    kModeScoreInstructor
    
} kParseMode;

@interface QDataParserDelegate : NSObject <CHCSVParserDelegate>

- (void)updateQDataInMode:(kParseMode)mode;

@end
