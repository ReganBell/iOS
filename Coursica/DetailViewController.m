//
//  DetailViewController.m
//  Coursica
//
//  Created by Regan Bell on 11/25/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "DetailViewController.h"
#import "Course.h"
#import "Faculty.h"
#import "Location.h"
#import "Meeting.h"
#import "GraphKit.h"
//#import "UIViewController+BButton.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *uiTextView;

@property (weak, nonatomic) IBOutlet UILabel *courseInfoLabel;

@property (nonatomic, weak) IBOutlet GKBarGraph *graphView;
@property (nonatomic, assign) BOOL green;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //[(UIScrollView *)self.view setContentSize:CGSizeMake(320, 1000)];

    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@ \n %@", self.course.field, self.course.number, self.course.title];
    
    self.uiTextView.text = [NSString stringWithFormat:@"%@", self.course.courseDescription];
    
    [self.uiTextView setEditable:NO];
    
    NSMutableString *facultyString;
    
    for (Faculty *faculty in self.course.faculty) {
        [facultyString stringByAppendingFormat:@"%@ %@, ", faculty.first, faculty.last];
    }
    
    NSMutableString *meetingString;
    
    for (Meeting *meeting in self.course.meetings) {
        [meetingString stringByAppendingFormat:@"%@ %@-%@, ", meeting.day, meeting.beginTime, meeting.endTime];
    }
    
    NSMutableString *locationString;
    
    for (Location *location in self.course.locations) {
        [locationString stringByAppendingFormat:@"%@ %@", location.building, location.room];
    }
    
    self.courseInfoLabel.text = [NSString stringWithFormat:@"Instructor: testing\nMeeting Time: %@\nLocation: %@", meetingString, locationString];
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //[self setupButtons];
    
    self.view.backgroundColor = [UIColor gk_cloudsColor];
    
    self.data = @[@65, @10, @90, @50, @75];
    self.labels = @[@"65", @"10", @"90", @"50", @"75"];
    
        self.graphView.barWidth = 22;
        self.graphView.barHeight = 140;
        self.graphView.marginBar = 16;
        self.graphView.animationDuration = 2.0;
    
    self.graphView.dataSource = self;
    
    [self.graphView draw];
    
    self.green = YES;
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onButtonFill:(id)sender {
    [self.graphView draw];
}

- (IBAction)onButtonChange:(id)sender {
    self.green = !self.green;
    self.graphView.barColor = (self.green) ? [UIColor gk_turquoiseColor] : [UIColor gk_amethystColor];
}

- (IBAction)onButtonReset:(id)sender {
    [self.graphView reset];
}


#pragma mark - GKBarGraphDataSource

- (NSInteger)numberOfBars {
    return [self.data count];
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index {
    return [self.data objectAtIndex:index];
}

- (UIColor *)colorForBarAtIndex:(NSInteger)index {
    id colors = @[[UIColor gk_peterRiverColor],
                  [UIColor gk_peterRiverColor],
                  [UIColor gk_peterRiverColor],
                  [UIColor gk_peterRiverColor],
                  [UIColor gk_peterRiverColor]
                  ];
    return [colors objectAtIndex:index];
}

//- (UIColor *)colorForBarBackgroundAtIndex:(NSInteger)index {
//    return [UIColor redColor];
//}

- (CFTimeInterval)animationDurationForBarAtIndex:(NSInteger)index {
    CGFloat percentage = [[self valueForBarAtIndex:index] doubleValue];
    percentage = (percentage / 100);
    return (self.graphView.animationDuration * percentage);
}

- (NSString *)titleForBarAtIndex:(NSInteger)index {
    return [self.labels objectAtIndex:index];
}


/*
#pragma mark - Navigation
 
 

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
