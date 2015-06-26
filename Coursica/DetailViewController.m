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
#import "NSString+FirebaseEncode.h"
#import "QFacultyReport.h"
#import "Mantle.h"
#import "QResponse.h"
#import "Meeting.h"
#import "TTTAttributedLabel.h"
#import "MapViewController.h"

typedef enum {
    
    GraphTabWorkload,
    GraphTabOverall
    
} GraphTabIndex;

#define CoursicaBlue [UIColor colorWithRed:31/255.0 green:148/255.0 blue:255/255.0 alpha:1.0]
#define UnselectedGray [UIColor colorWithRed:217/255.0 green:215/255.0 blue:215/255.0 alpha:1.0]

@interface DetailViewController () <GKBarGraphDataSource, TTTAttributedLabelDelegate>

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *cards;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIView *QScoreView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *courseInstructorLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseMeetingLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *courseLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *satisfiesLabel;

@property (weak, nonatomic) IBOutlet UILabel *overallLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet UILabel *workloadLabel;

@property (strong, nonatomic) QScore *overallScore;
@property (strong, nonatomic) QScore *difficultyScore;
@property (strong, nonatomic) QScore *workloadScore;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *qScoreButtons;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *qScoreLabels;

@property (weak, nonatomic) IBOutlet UIButton *viewCommentsButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *graphControl;
@property (nonatomic, weak) IBOutlet GKBarGraph *graphView;
@property (nonatomic, assign) BOOL green;

@property (strong, nonatomic) QReport *report;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notesHeightConstraint;

@property (nonatomic, readwrite, strong) NSArray *data;
@property (nonatomic, readwrite, strong) NSArray *labels;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self layoutCourseInfoCard];
    [self layoutNavigationBarTitle];
    [self pullCourseData];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    MapViewController *mapController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mapController"];
    mapController.request = [NSURLRequest requestWithURL:url];
    Location *location = self.course.locations.anyObject;
    mapController.title = location.building;
    [self.navigationController pushViewController:mapController animated:YES];
}
- (void)pullCourseData {
    
    NSString *encoded = [self.course.displayTitle stringEncodedAsFirebaseKey];
    NSString *urlString = [NSString stringWithFormat:@"glaring-heat-9505.firebaseIO.com/%@", encoded];
    Firebase *root = [[Firebase alloc] initWithUrl:urlString];
    
    [root observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSError *error = nil;
        if (snapshot.value == [NSNull null]) {
            return;
        }
        for (NSDictionary *reportDictionary in [snapshot.value allValues]) {
            QReport *report = [MTLJSONAdapter modelOfClass:[QReport class] fromJSONDictionary:reportDictionary error:&error];
            if (error) {
                NSLog(@"%@", error);
            } else {
                [self updateUIWithQReport:report];
            }
        }
    }];
}

- (void)layoutNavigationBarTitle {
    
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
    
    self.titleLabel.text = self.course.title;
    self.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];
    
    for (UIView *card in self.cards) {
        card.layer.cornerRadius = 4.0f;
        card.clipsToBounds = YES;
    }
    
    self.viewCommentsButton.layer.cornerRadius = 4.0f;
    
    self.descriptionLabel.text = self.course.courseDescription;
    self.descriptionLabel.textColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    [self configureLocationLabel];
    self.courseInstructorLabel.attributedText = [self.course facultyDisplayString];
    self.courseMeetingLabel.attributedText = [self.course meetingDisplayString];
    self.satisfiesLabel.attributedText = [self.course genEdDisplayString];
}

- (void)configureLocationLabel {
    
    self.courseLocationLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.courseLocationLabel.delegate = self;
    NSString *locationString = [self.course locationDisplayString];
    if ([locationString isEqualToString:@"TBD"]) {
        self.courseLocationLabel.text = locationString;
    } else {
        self.courseLocationLabel.text = [locationString stringByAppendingString:@" Map"];
        NSRange range = [self.courseLocationLabel.text rangeOfString:@"Map"];
        Location *location = self.course.locations.anyObject;
        NSString *encodedSearch = [location.building stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *mapURL = [NSString stringWithFormat:@"https://m.harvard.edu/map/map?search=Search&filter=%@&feed=*", encodedSearch];
        [self.courseLocationLabel addLinkToURL:[NSURL URLWithString:mapURL] withRange:range];
    }
}

- (void)updateUIWithQReport:(QReport*)report {
    
    self.report = report;
    
    QResponse *overallResponse = report.responses[@"Course Overall"];
    if (overallResponse) {
        NSString *overallString = [NSString stringWithFormat:@"Q Overall %0.2f", overallResponse.mean.doubleValue];
        self.overallLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:overallString];
    }
    
    QResponse *workloadResponse = report.responses[@"Workload (hours per week)"];
    if (workloadResponse) {
        NSString *workloadString = [NSString stringWithFormat:@"Workload %0.2f", workloadResponse.mean.doubleValue];
        self.workloadLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:workloadString];
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.graphView.barWidth = 28;
    self.graphView.barHeight = 150;
    self.graphView.marginBar = 16;
    self.graphView.animationDuration = 2.0;
    self.graphView.dataSource = self;
    [self updateGraphWithBreakdown:overallResponse.breakdown];

    
    float height = [UILabel heightForString:self.descriptionLabel.text width:self.descriptionLabel.bounds.size.width - 40 font:self.descriptionLabel.font];
    self.descriptionHeightConstraint.constant = height;
    
    int j = 0;
    for (UIButton *qScoreButton in self.qScoreButtons) {
        [qScoreButton addTarget:self action:@selector(qScoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        qScoreButton.tag = j;
        j++;
    }
    
    [self.view setNeedsLayout];
}

- (void)updateGraphWithBreakdown:(NSArray*)breakdown {
    
    if (!breakdown.count) {
        return;
    }
    
    self.labels = breakdown;
    
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
    [self.graphView draw];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:self.contentView.frame.size];
    
    CGFloat satisfiesBottom = self.satisfiesLabel.frame.origin.y + self.satisfiesLabel.frame.size.height;
    
    CGRect newFrame = self.infoView.frame;
    newFrame.size.height = satisfiesBottom + 10;
    
    [self.infoView setFrame:newFrame];
    CGRect newQScoreFrame = self.QScoreView.frame;
    newQScoreFrame.origin.y = satisfiesBottom + 30;
    [self.QScoreView setFrame:newQScoreFrame];
    
    CGRect viewCommentsButtonFrame = self.viewCommentsButton.frame;
    viewCommentsButtonFrame.origin.y = newQScoreFrame.origin.y + newQScoreFrame.size.height + 10;
    [self.viewCommentsButton setFrame:viewCommentsButtonFrame];
    
}

- (void)qScoreButtonPressed:(UIButton*)senderButton {
    
    GraphTabIndex index = (GraphTabIndex)senderButton.tag;
    if (senderButton.selected) {
        return;
    }
    for (UIButton *button in self.qScoreButtons) {
        UILabel *buttonLabel = self.qScoreLabels[button.tag];
        if (button.tag != senderButton.tag) {
            button.selected = NO;
            buttonLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13];
        } else {
            button.selected = YES;
            buttonLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13];
        }
    }
    [self updateGraph:index];
}

- (void)updateGraph:(GraphTabIndex)index {
    
    QResponse *response = nil;
    switch (index) {
        case GraphTabOverall:
            response = self.report.responses[@"Course Overall"];
            break;
        case GraphTabWorkload:
            response = self.report.responses[@"Workload (hours per week)"];
        default:
            break;
    }
    if (response) {
        [self updateGraphWithBreakdown:response.breakdown];
    }
}

- (IBAction)viewCommentsButtonClicked:(id)sender {
    
    if (!self.report.comments.count) {
        [self.viewCommentsButton setTitle:@"No comments reported :(" forState:UIControlStateNormal];
        return;
    }
    
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentsViewController *controller = [main instantiateViewControllerWithIdentifier:@"comments"];
    controller.report = self.report;
    [self.navigationController pushViewController:controller animated:YES];
}

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

- (CFTimeInterval)animationDurationForBarAtIndex:(NSInteger)index {
    CGFloat percentage = [[self valueForBarAtIndex:index] doubleValue];
    percentage = (percentage / 100);
    return (self.graphView.animationDuration * percentage);
}

- (NSString *)titleForBarAtIndex:(NSInteger)index {
    NSNumber *value = self.labels[index];
    return value.stringValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
