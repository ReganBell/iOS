//
//  DetailViewController.h
//  Coursica
//
//  Created by Matthew Beatty on 11/25/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphKit.h"

@class Course;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Course *course;

@property (nonatomic, readonly, strong) NSArray *data;
@property (nonatomic, readonly, strong) NSArray *labels;

@end
