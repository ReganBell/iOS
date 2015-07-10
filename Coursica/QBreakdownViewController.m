//
//  QBreakdownViewController.m
//  Coursica
//
//  Created by Matthew Beatty on 7/1/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "QBreakdownViewController.h"
#import "AppDelegate.h"
#import "UILabel+HeightCalculation.h"
#import "QReport.h"
#import "QResponse.h"
#import "Course.h"
#import "CommentTableViewCell.h"
#import "TTTAttributedLabel.h"
#import <pop/POPAnimation.h>

@interface QBreakdownViewController () <NSFetchedResultsControllerDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *cards;
@property (weak, nonatomic) IBOutlet UIView *generalView;

@property (weak, nonatomic) IBOutlet UILabel *recommendScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *workloadHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *mostlyTakenAsLabel;
@property (weak, nonatomic) IBOutlet UILabel *enrollmentLabel;

@property (weak, nonatomic) IBOutlet UILabel *assignmentsScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *materialsScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *sectionsScoreLabel;

@end

@implementation QBreakdownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutCourseInfoCard];
    [self layoutNavigationBar];
    [self pullBreakdownData];
    
}

- (void)layoutNavigationBar {
    
    // Sets title bar appearance for the view
    CGRect frame = CGRectMake(0, 0, 0, 0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
    label.text = [NSString stringWithFormat:@"%@ %@", self.course.shortField, self.course.number];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;
}

- (void)layoutCourseInfoCard {
    
    for (UIView *card in self.cards) {
        card.layer.cornerRadius = 4.0f;
        card.clipsToBounds = YES;
    }
    
}

- (void)pullBreakdownData {

    NSLog(@"Dictionary: %@", [self.report.responses description]);
    
    for(NSString *key in [self.report.responses allKeys]) {
        NSLog(@"%@", self.report);
        //if ([key isEqualToString:@"Would You Recommend"])
            //NSLog(@"FOUND IT");
    }

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:1];
    [formatter setMinimumFractionDigits:1];
    
    QResponse *recResponse = [self.report.responses objectForKey:@"Would You Recommend"];
    self.recommendScoreLabel.text = [formatter stringFromNumber:recResponse.mean];
    
    QResponse *workhoursResponse = [self.report.responses objectForKey:@"Workload (hours per week)"];
    NSNumber *workloadHours = @([workhoursResponse.mean floatValue] * 3);
    self.workloadHoursLabel.text = [formatter stringFromNumber:workloadHours];
    
    //self.enrollmentLabel.text = [self.report.enrollment stringValue];
    self.enrollmentLabel.text = @"104";
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end