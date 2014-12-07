//
//  QDataParserDelegate.m
//  Coursica
//
//  Created by Regan Bell on 12/2/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "QDataParserDelegate.h"
#import <UIKit/UIKit.h>
#import "QComment.h"
#import "QScore.h"
#import "Course.h"
#import "AppDelegate.h"

@interface QDataParserDelegate ()

@property (strong, nonatomic) QScore *currentScore;
@property (strong, nonatomic) QComment *currentComment;
@property (assign) kParseMode mode;
@property (strong, nonatomic) NSNumberFormatter *sharedFormatter;

@end

@implementation QDataParserDelegate

- (void)updateQDataInMode:(kParseMode)mode {
        
    NSString *path = nil;
    
    switch (mode) {
        case kModeComment:
            path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Qcomments.csv"];
            break;
        case kModeScoreOverall:
            path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"QCourseOverall.csv"];
            break;
        case kModeScoreDifficulty:
            path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"QDifficulty.csv"];
            break;
        case KModeScoreWorkload:
            path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"QWorkload.csv"];
            break;
        case kModeScoreInstructor:
            path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Qinstructors.csv"];
            break;
            
        default:
            break;
    }
    
    NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    CHCSVParser *parser = [[CHCSVParser alloc] initWithCSVString:fileString];
    parser.delegate = self;
    parser.trimsWhitespace = YES;
    self.mode = mode;
    [parser parse];
}

- (NSNumberFormatter*)sharedFormatter {
    
    if (!_sharedFormatter) {
        _sharedFormatter = [[NSNumberFormatter alloc] init];
    }
    return _sharedFormatter;
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSEntityDescription *qScoreEntity = [NSEntityDescription entityForName:@"QScore" inManagedObjectContext:context];
    NSEntityDescription *qCommentEntity = [NSEntityDescription entityForName:@"QComment" inManagedObjectContext:context];
    
    if (self.mode == kModeComment)
        self.currentComment = [[QComment alloc] initWithEntity:qCommentEntity insertIntoManagedObjectContext:context];
    else {
        self.currentScore = [[QScore alloc] initWithEntity:qScoreEntity insertIntoManagedObjectContext:context];
        switch (self.mode) {
            case kModeScoreDifficulty:
                self.currentScore.type = @"difficulty";
                break;
            case KModeScoreWorkload:
                self.currentScore.type = @"workload";
                break;
            case kModeScoreInstructor:
                self.currentScore.type = @"instructor";
                break;
            case kModeScoreOverall:
                self.currentScore.type = @"overall";
                break;
            default:
                break;
        }
    }
    
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    
}

- (NSString*)substringWithoutEndCharacters:(NSString*)original {
    
    if (original.length < 2) {
        return original;
    }
    
    return [original substringWithRange:NSMakeRange(1, original.length - 2)];
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    
    if (self.mode == kModeComment) {
        switch (fieldIndex) {
            case 0:
                break;
            case 1:
                self.currentComment.catalogNumber = [self.sharedFormatter numberFromString:field];
            case 2:
                self.currentComment.year = field;
            case 3:
                self.currentComment.term = @([self.sharedFormatter numberFromString:field].intValue - 1);
                // In CSV fall is 1, spring is 2
                // We store as a bool, fall is 0 and spring is 1
            case 4:
                self.currentComment.comment = field;
            default:
                break;
        }
    }
    else if (self.mode == kModeScoreDifficulty || self.mode == KModeScoreWorkload || self.mode == kModeScoreOverall) {
        switch (fieldIndex) {
            case 0:
                break;
            case 1:
                break;
            case 2:
                self.currentScore.catalogNumber = [self.sharedFormatter numberFromString:[self substringWithoutEndCharacters:field]];
            case 3:
                self.currentScore.one = [self.sharedFormatter numberFromString:[self substringWithoutEndCharacters:field]];
            case 4:
                self.currentScore.two = [self.sharedFormatter numberFromString:[self substringWithoutEndCharacters:field]];
            case 5:
                self.currentScore.three = [self.sharedFormatter numberFromString:[self substringWithoutEndCharacters:field]];
            case 6:
                self.currentScore.four = [self.sharedFormatter numberFromString:[self substringWithoutEndCharacters:field]];
            case 7:
                self.currentScore.five = [self.sharedFormatter numberFromString:[self substringWithoutEndCharacters:field]];
            default:
                break;
        }
    }
    else if (self.mode == kModeScoreInstructor) {
        switch (fieldIndex) {
            case 0:
                break;
            case 1:
                break;
            case 2:
                break;
                
            default:
                break;
        }
    }
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error = nil;
    [context save:&error];
}

@end
