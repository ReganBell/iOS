//
//  QBreakdownViewController.m
//  Coursica
//
//  Created by Matthew Beatty on 7/1/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "DetailViewController.h"
#import "Course.h"
#import "AppDelegate.h"
#import "Faculty.h"
#import "Location.h"
#import "Meeting.h"
#import "QScore.h"
#import "CommentsViewController.h"
#import "QBreakdownViewController.h"
#import "UILabel+HeightCalculation.h"
#import "QReport.h"
#import <Firebase/Firebase.h>
#import "NSString+FirebaseEncode.h"
#import "QFacultyReport.h"
#import "Mantle.h"
#import "QResponse.h"
#import "TTTAttributedLabel.h"
#import "MapViewController.h"
#import "Coursica-Swift.h"
#import <pop/POPAnimation.h>

@interface QBreakdownViewController () <NSFetchedResultsControllerDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *cards;
@property (weak, nonatomic) IBOutlet UIView *generalView;
@property (weak, nonatomic) IBOutlet UIView *courseView;
@property (weak, nonatomic) IBOutlet UIView *instructorView;

@property (weak, nonatomic) IBOutlet AnimationBarView *assignmentsAnimBarView;
@property (weak, nonatomic) IBOutlet AnimationBarView *feedbackAnimBarView;
@property (weak, nonatomic) IBOutlet AnimationBarView *materialsAnimBarView;
@property (weak, nonatomic) IBOutlet AnimationBarView *sectionsAnimBarView;

@property (weak, nonatomic) IBOutlet AnimationBarView *overallAnimBarView;
@property (weak, nonatomic) IBOutlet AnimationBarView *lecturesAnimBarView;
@property (weak, nonatomic) IBOutlet AnimationBarView *accessiblityAnimBarView;
@property (weak, nonatomic) IBOutlet AnimationBarView *enthusiasmAnimBarView;

@property (nonatomic, strong) IBOutletCollection(AnimationBarView) NSArray *animationBars;

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
    //[self pullBreakdownData];
    for (AnimationBarView *bar in self.animationBars) {
        [bar updateWithDictionary:@{}];
    }
    
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

    //NSLog(@"Dictionary: %@", [self.report.responses description]);
    
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