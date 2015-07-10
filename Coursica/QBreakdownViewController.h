
//
//  QBreakdownViewController.h
//  Coursica
//
//  Created by Matthew Beatty on 7/1/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QReport;
@class Course;

@interface QBreakdownViewController : UIViewController

@property (strong, nonatomic) QReport *report;
@property (strong, nonatomic) Course *course;

@end
