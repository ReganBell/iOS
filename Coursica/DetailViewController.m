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
//#import "UIViewController+BButton.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *courseInstructorLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseMeetingLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseInfoLabel;

@property (nonatomic, weak) IBOutlet GKBarGraph *graphView;
@property (nonatomic, assign) BOOL green;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //[(UIScrollView *)self.view setContentSize:CGSizeMake(320, 1000)];
    
    NSLog(@"Gen Eds: %@, %@ - %@", self.course.genEdOne, self.course.genEdTwo, self.course.notes);
    
    self.title = [NSString stringWithFormat:@"%@ %@", self.course.field, self.course.number];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:56.0/255.0 green:93.0/255.0 blue:165.0/255.0 alpha:1] forKey:UITextAttributeTextColor]];

    self.titleLabel.text = self.course.title;

    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"QScore"];
    request.predicate = [NSPredicate predicateWithFormat:@"catalogNumber = %@", self.course.catalogNumber];
    NSArray *scores = [context executeFetchRequest:request error:nil];
    
    self.textView.text = [NSString stringWithFormat:@"%@", self.course.courseDescription];
    
    [self.textView setEditable:NO];
    
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
    
    self.courseInstructorLabel.text = [NSString stringWithFormat:@"Instructor: %@", facultyString];
    self.courseMeetingLabel.text = [NSString stringWithFormat:@"Meeting Time: %@", meetingString];
    self.courseLocationLabel.text = [NSString stringWithFormat:@"Location: %@", locationString];
    
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
