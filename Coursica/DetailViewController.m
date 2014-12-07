//
//  DetailViewController.m
//  Coursica
//
//  Created by Regan Bell on 11/25/14.
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
//#import "UIViewController+BButton.h"

@interface DetailViewController ()

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

@property (strong, nonatomic) QScore *overallScore;
@property (strong, nonatomic) QScore *difficultyScore;
@property (strong, nonatomic) QScore *workloadScore;

@property (weak, nonatomic) IBOutlet UISegmentedControl *graphControl;

@property (nonatomic, weak) IBOutlet GKBarGraph *graphView;
@property (nonatomic, assign) BOOL green;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
    label.text = [NSString stringWithFormat:@"%@ %@", self.course.field, self.course.number];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;

    self.titleLabel.text = self.course.title;
    self.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];

    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];

    NSArray *qTypes = @[@"difficulty", @"workload", @"overall"];
    NSMutableDictionary *qScoresDict = [NSMutableDictionary new];
    for (NSString *type in qTypes) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"QScore"];
        request.predicate = [NSPredicate predicateWithFormat:@"catalogNumber = %@ AND type = %@", self.course.catalogNumber, type];
         QScore *score = [context executeFetchRequest:request error:nil][0];
        [qScoresDict setObject:score forKey:type];
    }
    
    self.overallScore = qScoresDict[@"overall"];
    self.difficultyScore = qScoresDict[@"difficulty"];
    self.workloadScore = qScoresDict[@"workload"];
    
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@", self.course.courseDescription];
    self.descriptionLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];
    
    NSMutableString *facultyString = [NSMutableString new];
    
    if (![self.course.faculty count] == 0)
    {
        for (Faculty *faculty in self.course.faculty)
        {
            [facultyString appendFormat:@"%@ %@ ", faculty.first, faculty.last];
        }
    }
    else
    {
        [facultyString appendString:@"TBD"];
    }
    
    NSMutableString *meetingString = [NSMutableString new];
    
    if (![self.course.meetings count] == 0)
    {
        NSString *dayString;
        NSString *startTime;
        NSString *endTime;
        for (Meeting *meeting in self.course.meetings)
        {
            
            switch ([meeting.day intValue])
            {
                case 0:
                    dayString = @"Sun, ";
                    break;
                case 1:
                    dayString = @"Mon, ";
                    break;
                case 2:
                    dayString = @"Tues, ";
                    break;
                case 3:
                    dayString = @"Wed, ";
                    break;
                case 4:
                    dayString = @"Thurs, ";
                    break;
                case 5:
                    dayString = @"Fri, ";
                    break;
                default:
                    dayString = @"Sat, ";
                    break;
            }

            [meetingString appendFormat:@"%@ ", dayString];
            startTime = meeting.beginTime;
            endTime = meeting.endTime;
        }
        [meetingString appendFormat:@"%@ - %@", startTime, endTime];
    }
    else
    {
        [meetingString appendString:@"TBD"];
    }
    
    NSMutableString *locationString = [NSMutableString new];
//    NSLog(@"%@", self.course.locations);
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
    
    NSString *instructorString = [NSString stringWithFormat:@"Instructor: %@", facultyString];
    NSMutableAttributedString *instructorLabel = [[NSMutableAttributedString alloc] initWithString:instructorString];
    [instructorLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,12)];
    [instructorLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(12, facultyString.length)];
    
    NSString *tempMeetingString = [NSString stringWithFormat:@"Meeting Time: %@", meetingString];
    NSMutableAttributedString *meetingLabel = [[NSMutableAttributedString alloc] initWithString:tempMeetingString];
    [meetingLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,14)];
    [meetingLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(14, meetingString.length)];
    
    NSString *tempLocationString = [NSString stringWithFormat:@"Location: %@", locationString];
    NSMutableAttributedString *locationLabel = [[NSMutableAttributedString alloc] initWithString:tempLocationString];
    [locationLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,10)];
    [locationLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(10, locationString.length)];
    
    self.courseInstructorLabel.attributedText = instructorLabel;
    self.courseMeetingLabel.attributedText = meetingLabel;
    self.courseLocationLabel.attributedText = locationLabel;
    
    NSString *tempOverallString = [NSString stringWithFormat:@"Overall: %0.2f", [self.course.qOverall doubleValue]];
    NSMutableAttributedString *overallLabel = [[NSMutableAttributedString alloc] initWithString:tempOverallString];
    [overallLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,9)];
    [overallLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(9, 4)];
    
    NSString *tempDifficultyString = [NSString stringWithFormat:@"Difficulty: %0.2f", [self.course.qDifficulty doubleValue]];
    NSMutableAttributedString *difficultyLabel = [[NSMutableAttributedString alloc] initWithString:tempDifficultyString];
    [difficultyLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,12)];
    [difficultyLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(12, 4)];
    
    NSString *tempWorkloadString = [NSString stringWithFormat:@"Workload: %0.2f", [self.course.qWorkload doubleValue]];
    NSMutableAttributedString *workloadLabel = [[NSMutableAttributedString alloc] initWithString:tempWorkloadString];
    [workloadLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,10)];
    [workloadLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(10, 4)];
    
    self.overallLabel.attributedText = overallLabel;
    self.difficultyLabel.attributedText = difficultyLabel;
    self.workloadLabel.attributedText = workloadLabel;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //[self setupButtons];
    
    self.view.backgroundColor = [UIColor gk_cloudsColor];
    
    self.labels = @[[self.overallScore.one stringValue], [self.overallScore.two stringValue], [self.overallScore.three stringValue], [self.overallScore.four stringValue], [self.overallScore.five stringValue]];
    
    NSArray *properties = @[@"one", @"two", @"three", @"four", @"five"];
    NSInteger largest = 0;
    NSString *largestBar;
    for (NSString *property in properties)
    {
        if([[self.overallScore valueForKey:property] intValue] > largest)
        {
            largestBar = property;
            NSNumber *tempNum = [self.overallScore valueForKey:property];
            largest = [tempNum intValue];
        }
    }
    
    NSNumber *ratio = [NSNumber numberWithDouble:((double)100/(double)largest)];
    
    self.data = @[[NSNumber numberWithDouble:self.overallScore.one.doubleValue*ratio.doubleValue],
                  [NSNumber numberWithDouble:self.overallScore.two.doubleValue*ratio.doubleValue],
                  [NSNumber numberWithDouble:self.overallScore.three.doubleValue*ratio.doubleValue],
                  [NSNumber numberWithDouble:self.overallScore.four.doubleValue*ratio.doubleValue],
                  [NSNumber numberWithDouble:self.overallScore.five.doubleValue*ratio.doubleValue]
                 ];
    
        self.graphView.barWidth = 22;
        self.graphView.barHeight = 140;
        self.graphView.marginBar = 16;
        self.graphView.animationDuration = 2.0;
    
    self.graphView.dataSource = self;
    
    //GKBar *bar = self.graphView.bars[0];
    //bar.percentage = 0.94;
    //self.graphView.bars[0].setPercentage = 0.94;
    
    [self.graphView draw];
    
    self.green = YES;
    
    NSString *genEdString;
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
    
    NSString *tempNotesString = [NSString stringWithFormat:@"Notes: %@", self.course.notes];
    NSMutableAttributedString *notesLabel = [[NSMutableAttributedString alloc] initWithString:tempNotesString];
    [notesLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,7)];
    [notesLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(7, self.course.notes.length)];
    
    NSString *tempCatNumString = [NSString stringWithFormat:@"Catalog Number: %@", [self.course.catalogNumber stringValue]];
    NSMutableAttributedString *catNumLabel = [[NSMutableAttributedString alloc] initWithString:tempCatNumString];
    [catNumLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,16)];
    [catNumLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(16, [self.course.catalogNumber stringValue].length)];
    
    NSString *tempGenEdString = [NSString stringWithFormat:@"Satisfies: %@", genEdString];
    NSMutableAttributedString *genEdLabel = [[NSMutableAttributedString alloc] initWithString:tempGenEdString];
    [genEdLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,11)];
    [genEdLabel addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(11, genEdString.length)];

    self.notesLabel.attributedText = notesLabel;
    self.catalogNumLabel.attributedText = catNumLabel;
    self.satisfiesLabel.attributedText = genEdLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)graphControlIndexChange:(id)sender {
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.graphView.barWidth = 22;
    self.graphView.barHeight = 140;
    self.graphView.marginBar = 16;
    self.graphView.animationDuration = 2.0;

    QScore *newScores;
    
    switch (self.graphControl.selectedSegmentIndex)
    {
        case 0:
            newScores = self.overallScore;
            break;
        case 1:
            newScores = self.difficultyScore;
            break;
        case 2:
            newScores = self.workloadScore;
            break;
            
        default:
            break;
    }
    
    self.labels = @[[newScores.one stringValue], [newScores.two stringValue], [newScores.three stringValue], [newScores.four stringValue], [newScores.five stringValue]];
    
    NSArray *properties = @[@"one", @"two", @"three", @"four", @"five"];
    NSInteger largest = 0;
    NSString *largestBar;
    for (NSString *property in properties)
    {
        if([[newScores valueForKey:property] intValue] > largest)
        {
            largestBar = property;
            NSNumber *tempNum = [newScores valueForKey:property];
            largest = [tempNum intValue];
        }
    }
    
    NSNumber *ratio = [NSNumber numberWithDouble:((double)100/(double)largest)];
    
    self.data = @[[NSNumber numberWithDouble:newScores.one.doubleValue*ratio.doubleValue],
                  [NSNumber numberWithDouble:newScores.two.doubleValue*ratio.doubleValue],
                  [NSNumber numberWithDouble:newScores.three.doubleValue*ratio.doubleValue],
                  [NSNumber numberWithDouble:newScores.four.doubleValue*ratio.doubleValue],
                  [NSNumber numberWithDouble:newScores.five.doubleValue*ratio.doubleValue]
                  ];
    
    [self.graphView draw];
    
    self.green = YES;
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
    id colors = @[[UIColor colorWithRed:31.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1],
                  [UIColor colorWithRed:31.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1],
                  [UIColor colorWithRed:31.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1],
                  [UIColor colorWithRed:31.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1],
                  [UIColor colorWithRed:31.0/255.0 green:148.0/255.0 blue:255.0/255.0 alpha:1]
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
