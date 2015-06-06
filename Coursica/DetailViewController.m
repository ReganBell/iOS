//
//  DetailViewController.m
//  Coursica
//
//  Created by Matthew Beatty on 11/25/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "DetailViewController.h"
#import "Course.h"
#import "AppDelegate.h"
#import "Faculty.h"
#import "Location.h"
#import "Meeting.h"
#import "GraphKit.h"
#import "QScore.h"
#import "CommentsViewController.h"
#import "UILabel+HeightCalculation.h"
#import "QReport.h"
#import <Firebase/Firebase.h>

#define CoursicaBlue [UIColor colorWithRed:31/255.0 green:148/255.0 blue:255/255.0 alpha:1.0]
#define UnselectedGray [UIColor colorWithRed:217/255.0 green:215/255.0 blue:215/255.0 alpha:1.0]

@interface DetailViewController () <GKBarGraphDataSource>

// References to the UI elements used in the controller's view
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *courseInstructorLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseMeetingLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseInfoLabel;

@property (weak, nonatomic) IBOutlet UILabel *overallLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet UILabel *workloadLabel;

@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UILabel *catalogNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *satisfiesLabel;

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIView *QScoreView;

@property (strong, nonatomic) QScore *overallScore;
@property (strong, nonatomic) QScore *difficultyScore;
@property (strong, nonatomic) QScore *workloadScore;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *qScoreButtons;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *qScoreLabels;
@property (assign) NSInteger selectedQScoreIndex;

@property (weak, nonatomic) IBOutlet UIButton *viewCommentsButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *graphControl;
@property (nonatomic, weak) IBOutlet GKBarGraph *graphView;
@property (nonatomic, assign) BOOL green;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notesHeightConstraint;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    Firebase *root = [[Firebase alloc] initWithUrl:@"glaring-heat-9505.firebaseIO.com/MODGRK 100: Advanced Modern Greek: Introduction to Modern Greek Literature"];
    
    [root observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
    }];
    
    // Sets title bar appearance for the view
    CGRect frame = CGRectMake(0, 0, 0, 0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
    label.text = [NSString stringWithFormat:@"%@ %@", self.course.shortField, self.course.number];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    self.titleLabel.text = self.course.title;
    self.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];

    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@", self.course.courseDescription];
    self.descriptionLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];
    
    NSMutableString *facultyString = [NSMutableString new];
    
    // Formats information from Faculty object for the view
    if (![self.course.faculty count] == 0)
    {
        // Lists faculty names
        for (Faculty *faculty in self.course.faculty)
        {
            [facultyString appendFormat:@"%@ %@, ", faculty.first, faculty.last];
        }
        facultyString = [[facultyString substringToIndex:[facultyString length] - 2] mutableCopy];
    }
    else
    {
        // If no faculty listed, then faculty is TBD
        [facultyString appendString:@"TBD"];
    }
    
    NSMutableString *meetingString = [NSMutableString new];
    
    // Formats the course meeting time for use in the view
    // Sorts days so they can be printed in order in label
    if (![self.course.meetings count] == 0)
    {
        NSString *dayString;
        NSString *startTime;
        NSString *endTime;
        // Sorts set of course meeting days
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"day" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 intValue] > [obj2 intValue])
                return NSOrderedDescending;
            else if ([obj1 intValue] < [obj2 intValue])
                return NSOrderedAscending;
            else
                return NSOrderedSame;
        }];
        NSArray *sortedMeetingTimes = [self.course.meetings sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        // Turns number day into abbreviation
        for (Meeting *meeting in sortedMeetingTimes)
        {
            
            switch ([meeting.day intValue])
            {
                case 0:
                    dayString = @"Sun";
                    break;
                case 1:
                    dayString = @"Mon";
                    break;
                case 2:
                    dayString = @"Tues";
                    break;
                case 3:
                    dayString = @"Wed";
                    break;
                case 4:
                    dayString = @"Thurs";
                    break;
                case 5:
                    dayString = @"Fri";
                    break;
                default:
                    dayString = @"Sat";
                    break;
            }
            [meetingString appendFormat:@"%@, ", dayString];
        }
        meetingString = [[meetingString substringToIndex:[meetingString length] - 2] mutableCopy];
        
        for (Meeting *meeting in sortedMeetingTimes)
        {
            // Converts course times from military to standard time
            startTime = meeting.beginTime;
            NSString *startHour = [startTime componentsSeparatedByString:@":"][0];
            NSString *startMin = [startTime componentsSeparatedByString:@":"][1];
            if ([startHour intValue] > 12)
            {
                int newStartHour = [startHour intValue] - 12;
                if ([startMin intValue] == 0)
                {
                    startTime = [NSString stringWithFormat:@"%d", newStartHour];
                }
                else
                {
                    startTime = [NSString stringWithFormat:@"%d:%d", newStartHour, [startMin intValue]];
                }
            }
            else
            {
                if ([startMin intValue] == 0)
                {
                    startTime = [NSString stringWithFormat:@"%d", [startHour intValue]];
                }
                else
                {
                    startTime = [NSString stringWithFormat:@"%d:%d", [startHour intValue], [startMin intValue]];
                }
            }
            
            endTime = meeting.endTime;
            NSString *endHour = [endTime componentsSeparatedByString:@":"][0];
            NSString *endMin = [endTime componentsSeparatedByString:@":"][1];
            if ([endHour intValue] > 12)
            {
                int newEndHour = [endHour intValue] - 12;
                if ([endMin intValue] == 0)
                {
                    endTime = [NSString stringWithFormat:@"%d", newEndHour];
                }
                else
                {
                    endTime = [NSString stringWithFormat:@"%d:%d", newEndHour, [endMin intValue]];
                }
            }
            else
            {
                if ([endMin intValue] == 0)
                {
                    endTime = [NSString stringWithFormat:@"%d", [endHour intValue]];
                }
                else
                {
                    endTime = [NSString stringWithFormat:@"%d:%d", [endHour intValue], [endMin intValue]];
                }
                endTime = [endTime substringToIndex:[endTime length] - 3];
            }
            
        }
        
        [meetingString appendFormat:@" from %@-%@", startTime, endTime];
    }
    else
    {
        [meetingString appendString:@"TBD"];
    }
    
    // Gives location of the course
    NSMutableString *locationString = [NSMutableString new];
    if (![self.course.locations count] == 0)
    {
        for (Location *location in self.course.locations)
        {
            [locationString appendFormat:@"%@ %@", location.building, location.room];
        }
    }
    else
    {
        [locationString appendString:@"TBD"];
    }
    
    // Does varied text coloring in the label, repeated for most information labels
    NSString *instructorString = [NSString stringWithFormat:@"%@", facultyString];
    NSMutableAttributedString *instructorLabel = [[NSMutableAttributedString alloc] initWithString:instructorString];
    
    // More text coloring scheme work
    NSString *tempMeetingString = [NSString stringWithFormat:@"%@", meetingString];
    NSMutableAttributedString *meetingLabel = [[NSMutableAttributedString alloc] initWithString:tempMeetingString];
    
    NSString *tempLocationString = [NSString stringWithFormat:@"%@", locationString];
    NSMutableAttributedString *locationLabel = [[NSMutableAttributedString alloc] initWithString:tempLocationString];
    
    
    self.courseInstructorLabel.attributedText = instructorLabel;
    
    self.courseMeetingLabel.attributedText = meetingLabel;
    //CGFloat width =  [self.courseMeetingLabel.text sizeWithAttributes:[UIFont fontWithName:@"AvenirNext-Bold" size:13]].width;
    
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
    NSDictionary *userAttributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
    const CGSize textSize = [self.courseMeetingLabel.text sizeWithAttributes: userAttributes];
    CGFloat textWidth = textSize.width;
    
    
    self.courseMeetingLabel.frame = CGRectMake(self.courseMeetingLabel.frame.origin.x, self.courseMeetingLabel.frame.origin.y, textWidth+2.0, self.courseMeetingLabel.frame.size.height);
    
    self.courseLocationLabel.attributedText = locationLabel;
    
    // Gets Gen. Ed. requirements of the course from numerical gen. ed. listings
    NSString *genEdString;
    if ([self.course.genEdOne intValue] == 0)
    {
        genEdString = @"None";
    }
    else
    {
    switch ([self.course.genEdOne intValue]) {
        case 1:
            genEdString = @"Aesthetic and Interpretive Understanding";
            break;
        case 2:
            genEdString = @"Culture and Belief";
            break;
        case 3:
            genEdString = @"Empirical and Mathematical Reasoning";
            break;
        case 4:
            genEdString = @"Ethical Reasoning";
            break;
        case 5:
            genEdString = @"Science of Living Systems";
            break;
        case 6:
            genEdString = @"Science of the Physical Universe";
            break;
        case 7:
            genEdString = @"Societies of the World";
            break;
        case 8:
            genEdString = @"United States in the World";
            break;
            
        default:
            break;
    }
    // Checks if the courses satisfies a second gen. ed. requirement
    if ([self.course.genEdTwo intValue] != 0)
    {
        switch ([self.course.genEdTwo intValue]) {
            case 1:
                genEdString = [genEdString stringByAppendingString:@", Aesthetic and Interpretive Understanding"];
                break;
            case 2:
                genEdString = [genEdString stringByAppendingString:@", Culture and Belief"];
                break;
            case 3:
                genEdString = [genEdString stringByAppendingString:@", Empirical and Mathematical Reasoning"];
                break;
            case 4:
                genEdString = [genEdString stringByAppendingString:@", Ethical Reasoning"];
                break;
            case 5:
                genEdString = [genEdString stringByAppendingString:@", Science of Living Systems"];
                break;
            case 6:
                genEdString = [genEdString stringByAppendingString:@", Science of the Physical Universe"];
                break;
            case 7:
                genEdString = [genEdString stringByAppendingString:@", Societies of the World"];
                break;
            case 8:
                genEdString = [genEdString stringByAppendingString:@", United States in the World"];
                break;
                
            default:
                break;
        }
    }
    }
    // Says if no Gen. Ed. fulfillments were found
    if (!genEdString) {
        genEdString = @"None";
    }
    
    // Text color formatting
    NSString *tempNotesString = [NSString stringWithFormat:@"Notes: %@", self.course.notes];
    NSMutableAttributedString *notesLabel = [[NSMutableAttributedString alloc] initWithString:tempNotesString];
    [notesLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,7)];
    [notesLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(7, self.course.notes.length)];
    
//    NSString *tempCatNumString = [NSString stringWithFormat:@"Catalog Number: %@", [self.course.catalogNumber stringValue]];
//    NSMutableAttributedString *catNumLabel = [[NSMutableAttributedString alloc] initWithString:tempCatNumString];
//    [catNumLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,16)];
//    [catNumLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(16, [self.course.catalogNumber stringValue].length)];
//    
//    
    NSString *tempGenEdString = [NSString stringWithFormat:@"%@", genEdString];
    NSMutableAttributedString *genEdLabel = [[NSMutableAttributedString alloc] initWithString:tempGenEdString];

//    self.notesLabel.attributedText = notesLabel;
//    self.catalogNumLabel.attributedText = catNumLabel;
    self.satisfiesLabel.attributedText = genEdLabel;
    
    
    self.courseMeetingLabel.frame = CGRectMake(self.courseMeetingLabel.frame.origin.x, self.courseMeetingLabel.frame.origin.y, textWidth+2.0, self.courseMeetingLabel.frame.size.height);
    
    self.courseLocationLabel.attributedText = locationLabel;
    
    
   // FIGURING OUT HOW TO AUTO EXTEND/SHRINK INFOVIEW
//    CGFloat satisfiesBottom = self.satisfiesLabel.frame.origin.y + self.satisfiesLabel.frame.size.height;
//    
//    CGRect newFrame = self.infoView.frame;
//    newFrame.size.height = satisfiesBottom + 10;
//    
//    //CGRect textViewFrame = CGRectMake (0, 0, 144, 132);
//    [self.infoView setFrame:newFrame];
//    
//    
//    [self.view setNeedsLayout];
    
//     Retrieves Q scores for course
//    NSArray *qTypes = @[@"difficulty", @"workload", @"overall"];
//    NSMutableDictionary *qScoresDict = [NSMutableDictionary new];
//    for (NSString *type in qTypes) {
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"QScore"];
//        request.predicate = [NSPredicate predicateWithFormat:@"catalogNumber = %@ AND type = %@", self.course.catalogNumber, type];
//        NSArray *result = [context executeFetchRequest:request error:nil];
//        if (result.count == 0)
//            return;
//        
//        QScore *score = result[0];
//        [qScoresDict setObject:score forKey:type];
//    }
    
//     Sets the controller's Q score variables
    //self.overallScore = qScoresDict[@"overall"];
    
//    self.overallScore =  [[QScore alloc] init];
//    self.overallScore.one = @1;
//    self.overallScore.two = @2;
//    self.overallScore.three = @3;
//    self.overallScore.four = @4;
//    self.overallScore.five = @5;
//    
//    self.difficultyScore = [[QScore alloc] init];
//    self.difficultyScore.one = @4;
//    self.difficultyScore.two = @2;
//    self.difficultyScore.three = @7;
//    self.difficultyScore.four = @4;
//    self.difficultyScore.five = @1;
//    
//    self.workloadScore = [[QScore alloc] init];
//    self.workloadScore.one = @0;
//    self.workloadScore.two = @2;
//    self.workloadScore.three = @4;
//    self.workloadScore.four = @3;
//    self.workloadScore.five = @4;
//    
//    
//    self.course.qOverall = @4.2;
//    self.course.qDifficulty = @3.5;
//    self.course.qWorkload = @2.1;

    
    //NSString *tempOverallString = [NSString stringWithFormat:@"Q Overall/n%0.2f", [self.course.qOverall doubleValue]];
    NSString *tempOverallString = [NSString stringWithFormat:@"Q Overall\n4.2"];
    NSMutableAttributedString *overallLabel = [[NSMutableAttributedString alloc] initWithString:tempOverallString];
    
    //NSString *tempDifficultyString = [NSString stringWithFormat:@"Difficulty/n%0.2f", [self.course.qDifficulty doubleValue]];
    NSString *tempDifficultyString = [NSString stringWithFormat:@"Difficulty\n3.4"];
    NSMutableAttributedString *difficultyLabel = [[NSMutableAttributedString alloc] initWithString:tempDifficultyString];
    
    //NSString *tempWorkloadString = [NSString stringWithFormat:@"Workload/n%0.2f", [self.course.qWorkload doubleValue]];
    NSString *tempWorkloadString = [NSString stringWithFormat:@"Workload\n2.4"];
    NSMutableAttributedString *workloadLabel = [[NSMutableAttributedString alloc] initWithString:tempWorkloadString];
    
    self.overallLabel.attributedText = overallLabel;
    self.difficultyLabel.attributedText = difficultyLabel;
    self.workloadLabel.attributedText = workloadLabel;
    
    
    // Sets all the information for the Q score bar graph
    // From example of how to implement the graph on the graph's Github repository
    // Michalkonturek/GraphKit (the source of the bar graph)
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor gk_cloudsColor];
    
//    NSArray *properties = @[@"one", @"two", @"three", @"four", @"five"];
//    NSInteger largest = 5;
//    NSString *largestBar;
    // Adjusts percentages for graph from Q data so the largest
    // Answer (the largest bar) will completely fill the bar, like CS50 courses online
//    for (NSString *property in properties)
//    {
//        if([[self.overallScore valueForKey:property] intValue] > largest)
//        {
//            largestBar = property;
//            NSNumber *tempNum = [self.overallScore valueForKey:property];
//            largest = [tempNum intValue];
//        }
//    }

    [self updateGraphWithBreakdown:[self.course.mostRecentReport.overallBreakdown componentsSeparatedByString:@","]];
    
    self.graphView.barWidth = 28;
    self.graphView.barHeight = 150;
    self.graphView.marginBar = 16;
    self.graphView.animationDuration = 2.0;
    
    self.graphView.dataSource = self;
    
    [self.graphView draw];
    
    self.green = YES;
    
    float height = [UILabel heightForString:self.descriptionLabel.text width:self.descriptionLabel.bounds.size.width - 40 font:self.descriptionLabel.font];
    self.descriptionHeightConstraint.constant = height;
    
    //height = [UILabel heightForString:tempNotesString width:self.notesLabel.bounds.size.width - 60 font:self.notesLabel.font];
    //self.notesHeightConstraint.constant = height;
    
    [self.view setNeedsLayout];
    
    int j = 0;
    for (UIButton *qScoreButton in self.qScoreButtons) {
        [qScoreButton addTarget:self action:@selector(qScoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        qScoreButton.tag = j;
        j++;
    }
    
//    [self selectButton:self.qScoreButtons[1] inArray:self.qScoreLabels];
}

- (void)updateGraphWithBreakdown:(NSArray*)breakdown {
    
    if (!breakdown.count) {
        return;
    }
    
    self.labels = [NSArray arrayWithArray:breakdown];
    
    NSMutableArray *data = [NSMutableArray array];
    
    double largest = 0;
    for (NSString *valueString in breakdown) {
        NSInteger doubleValue = valueString.doubleValue;
        if (doubleValue > largest)
            largest = doubleValue;
    }
    
    // Calculates ratio to proportion all the scores
    double ratio = 100.0/largest;
    
    for (NSString *valueString in breakdown) {
        NSInteger doubleValue = valueString.doubleValue;
        [data addObject:@(doubleValue*ratio)];
    }
    
    self.data = [NSArray arrayWithArray:data];
}

- (void)qScoreButtonPressed:(UIButton*)senderButton {
    
    self.selectedQScoreIndex = senderButton.tag;
    [self selectButton:senderButton inArray:self.qScoreLabels];
    for (UIButton *button in self.qScoreButtons) {
        if (button.selected && button.tag != senderButton.tag) {
            [self selectButton:button inArray:self.qScoreLabels];
        }
    }
}

- (void)selectButton:(UIButton*)button inArray:(NSArray*)array {
    
    if (button.selected == NO)
    {
        for (UIButton *buttons in self.qScoreButtons)
        {
            buttons.selected = NO;
            UILabel *label = array[buttons.tag];
            [label setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:13]];
        }
        
        button.selected = YES;
        UILabel *label = array[button.tag];
        [label setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:13]];
        
        switch (button.tag) {
            case 0:
                [self updateGraph:0];
                break;
            case 1:
                [self updateGraph:1];
                break;
            case 2:
                [self updateGraph:2];
                break;
            default:
                break;
        }
    }
}

- (void)updateGraph:(NSInteger)data {
    
    if (data == 0) {
        self.labels = @[@"1", @"3", @"4", @"5", @"5"];
        
        NSArray *properties = @[@"one", @"two", @"three", @"four", @"five"];
        NSInteger largest = 5;
        NSString *largestBar;
        NSNumber *ratio = [NSNumber numberWithDouble:((double)100/(double)largest)];
        self.data = @[[NSNumber numberWithDouble:1.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:3.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:4.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:5.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:5.0*ratio.doubleValue]
                      ];
        
    }
    else if (data == 1)
    {
        self.labels = @[@"2", @"3", @"4", @"1", @"5"];
        
        NSArray *properties = @[@"one", @"two", @"three", @"four", @"five"];
        NSInteger largest = 5;
        NSString *largestBar;
        NSNumber *ratio = [NSNumber numberWithDouble:((double)100/(double)largest)];
        self.data = @[[NSNumber numberWithDouble:2.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:3.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:4.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:1.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:5.0*ratio.doubleValue]
                      ];
    }
    else
    {
        self.labels = @[@"4", @"3", @"2", @"5", @"2"];
        
        NSArray *properties = @[@"one", @"two", @"three", @"four", @"five"];
        NSInteger largest = 5;
        NSString *largestBar;
        NSNumber *ratio = [NSNumber numberWithDouble:((double)100/(double)largest)];
        self.data = @[[NSNumber numberWithDouble:4.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:3.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:2.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:5.0*ratio.doubleValue],
                      [NSNumber numberWithDouble:2.0*ratio.doubleValue]
                      ];
    }
    
    
//    self.graphView.barWidth = 28;
//    self.graphView.barHeight = 150;
//    self.graphView.marginBar = 16;
//    self.graphView.animationDuration = 2.0;
    
    self.graphView.dataSource = self;
    
    [self.graphView draw];
    
    self.green = YES;
        
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)viewCommentsButtonClicked:(id)sender {
    
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentsViewController *controller = [main instantiateViewControllerWithIdentifier:@"comments"];
    controller.course = self.course;
    [self.navigationController pushViewController:controller animated:YES];
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

// Code from third-party GraphKit repository for bar graph on Github
#pragma mark - GKBarGraphDataSource

- (NSInteger)numberOfBars {
    return [self.data count];
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index {
    NSString *valueString = self.data[index];
    return @(valueString.intValue);
}

- (UIColor *)colorForBarAtIndex:(NSInteger)index {
    return [UIColor colorWithRed:31.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1];
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
