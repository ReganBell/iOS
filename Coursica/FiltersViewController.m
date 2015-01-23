//
//  FiltersViewController.m
//  Coursica
//
//  Created by Regan Bell on 11/25/14.
//  Matthew Beatty
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "FiltersViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CoursicaBlue [UIColor colorWithRed:31/255.0 green:148/255.0 blue:255/255.0 alpha:1.0]

@interface FiltersViewController () <UITextFieldDelegate, UIScrollViewDelegate>

    // References to the UI elements in the view
@property (weak, nonatomic) NMRangeSlider *overallSlider;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *genEdButtons;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *genEdLabels;

@property (weak, nonatomic) IBOutlet UILabel *qOverallTitleLabel;
@property (weak, nonatomic) NMRangeSlider *qOverallSlider;
@property (weak, nonatomic) UILabel *qOverallValueLabel;

@property (weak, nonatomic) UILabel *qWorkloadTitleLabel;
@property (weak, nonatomic) NMRangeSlider *qWorkloadSlider;
@property (weak, nonatomic) UILabel *qWorkloadValueLabel;

@property (weak, nonatomic) UILabel *qDifficultyTitleLabel;
@property (weak, nonatomic) NMRangeSlider *qDifficultySlider;
@property (weak, nonatomic) UILabel *qDifficultyValueLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *termControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *courseLevelControl;

@property (weak, nonatomic) IBOutlet UITextField *searchField;

@end

@implementation FiltersViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.searchField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [self applyFiltersButtonPressed:nil];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Creates titles bar for the view
    CGRect frame = CGRectMake(0, 0, 0, 0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
    label.text = @"Filters";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBg.png"] forBarMetrics:UIBarMetricsDefault];
    
    // Creates cancel button in the title bar
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15];
    [button addTarget:self.delegate action:@selector(dismissFiltersViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = cancelButton;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.title = @"Filters";
    
    self.searchField.delegate = self;
    self.searchField.tintColor = CoursicaBlue;
    
    [self configureRangeSliders];
}
    // Checks for editting in the textfield
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)handleTap:(UITapGestureRecognizer*)recognizer {
    
    [self.searchField resignFirstResponder];
    [self.view removeGestureRecognizer:recognizer];
}
    // Called when apply filters button pressed
    // Checks all UI elements for changes in order to filter results
- (IBAction)applyFiltersButtonPressed:(id)sender {
    
    NSMutableArray *predicates = [NSMutableArray new];
    
    switch (self.courseLevelControl.selectedSegmentIndex) {
        case 1:
            [predicates addObject:[NSPredicate predicateWithFormat:@"graduate = %@", [NSNumber numberWithBool:NO]]];
            break;
        case 2:
            [predicates addObject:[NSPredicate predicateWithFormat:@"graduate = %@", [NSNumber numberWithBool:YES]]];
        default:
            break;
    }
    // Checking all of the Q score filters
//    [predicates addObject:[NSPredicate predicateWithFormat:@"qOverall >= %f", self.qOverallSlider.lowerValue]];
//    [predicates addObject:[NSPredicate predicateWithFormat:@"qOverall <= %f", self.qOverallSlider.upperValue]];
//    
//    [predicates addObject:[NSPredicate predicateWithFormat:@"qWorkload >= %f", self.qWorkloadSlider.lowerValue]];
//    [predicates addObject:[NSPredicate predicateWithFormat:@"qWorkload <= %f", self.qWorkloadSlider.upperValue]];
//    
//    [predicates addObject:[NSPredicate predicateWithFormat:@"qDifficulty >= %f", self.qDifficultySlider.lowerValue]];
//    [predicates addObject:[NSPredicate predicateWithFormat:@"qDifficulty <= %f", self.qDifficultySlider.upperValue]];

    switch (self.termControl.selectedSegmentIndex) {
        case 1:
            [predicates addObject:[NSPredicate predicateWithFormat:@"term = %@", @"FALL"]];
            break;
        case 2:
            [predicates addObject:[NSPredicate predicateWithFormat:@"term = %@", @"SPRING"]];
        default:
            break;
    }
    
    // Checks all Gen. Ed. filters
    for (UIButton *button in self.genEdButtons) {
        
        if (button.selected) {
            NSNumber *index = [NSNumber numberWithInteger:button.tag + 1];
            [predicates addObject:[NSPredicate predicateWithFormat:@"genEdOne = %@ OR genEdTwo = %@", index, index]];
        }
    }
    
    NSString *search = self.searchField.text;

    if (search.length) {
        
        NSMutableArray *termPreds = [NSMutableArray array];
        NSArray *terms = [search componentsSeparatedByString:@" "];
        for (NSString *searchTerm in terms) {
            
            NSMutableArray *searchPreds = [NSMutableArray array];
            [searchPreds addObject:[NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchTerm]];
            [searchPreds addObject:[NSPredicate predicateWithFormat:@"shortField CONTAINS[cd] %@", searchTerm]];
            [searchPreds addObject:[NSPredicate predicateWithFormat:@"longField CONTAINS[cd] %@", searchTerm]];
            [searchPreds addObject:[NSPredicate predicateWithFormat:@"number like %@", searchTerm]];
            [searchPreds addObject:[NSPredicate predicateWithFormat:@"ANY %K CONTAINS[cd] %@", @"faculty.first", searchTerm]];
            [searchPreds addObject:[NSPredicate predicateWithFormat:@"ANY %K CONTAINS[cd] %@", @"faculty.last", searchTerm]];
            [termPreds addObject:[NSCompoundPredicate orPredicateWithSubpredicates:searchPreds]];
        }
        [predicates addObject:[NSCompoundPredicate andPredicateWithSubpredicates:termPreds]];
    }
    
    // Calls function in CoursesViewController to update course list
    [self.delegate filtersDidChange:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    
    [self.delegate dismissFiltersViewController];
}

- (IBAction)buttonClicked:(UIButton*)genEdButton {
    
    genEdButton.selected = !genEdButton.selected;
    
    for (UILabel *label in self.genEdLabels) {
        if (label.tag == genEdButton.tag) {
            
            [UIView animateWithDuration:0.2 animations:^{
                
                if (genEdButton.selected) {
                    label.textColor = [UIColor whiteColor];
                    label.layer.backgroundColor = CoursicaBlue.CGColor;
                } else {
                    label.textColor = [UIColor grayColor];
                    label.layer.backgroundColor = [UIColor whiteColor].CGColor;
                }
            }];
        }
    }
}


- (IBAction)qOverallSliderChanged:(UISlider*)qOverallSlider {
    
    float rounded = roundf(qOverallSlider.value*10)/10;
    self.qOverallTitleLabel.text = [NSString stringWithFormat:@"%0.1f", rounded];
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.delegate dismissFiltersViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateSliderLabels];
    //[self updateSetValuesSlider];
    
    if([self.view respondsToSelector:@selector(setTintColor:)])
    {
        self.view.tintColor = [UIColor orangeColor];
    }
    
}

// From third-party range slider repository (NMRangeSlider on Github, also in our pod file)
// functions handling the creation and changes of the range sliders
#pragma mark -
#pragma mark - Label  Slider

- (void) configureLabelSlider
{
    self.labelSlider.minimumValue = 0;
    self.labelSlider.maximumValue = 100;
    
    self.labelSlider.lowerValue = 0;
    self.labelSlider.upperValue = 100;
    
    self.labelSlider.minimumRange = 10;
    
    [self.contentView addSubview:self.labelSlider];
}

- (void) updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    
    CGPoint lowerCenter;
    lowerCenter.x = (self.labelSlider.lowerCenter.x + self.labelSlider.frame.origin.x);
    lowerCenter.y = (self.labelSlider.center.y - 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.lowerValue];
    
    CGPoint upperCenter;
    upperCenter.x = (self.labelSlider.upperCenter.x + self.labelSlider.frame.origin.x);
    upperCenter.y = (self.labelSlider.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.upperValue];
}

// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender
{
    self.qOverallValueLabel.text = [NSString stringWithFormat:@"%.1f to %.1f", self.qOverallSlider.lowerValue, self.qOverallSlider.upperValue];
    self.qWorkloadValueLabel.text = [NSString stringWithFormat:@"%.1f to %.1f", self.qWorkloadSlider.lowerValue, self.qWorkloadSlider.upperValue];
    self.qDifficultyValueLabel.text = [NSString stringWithFormat:@"%.1f to %.1f", self.qDifficultySlider.lowerValue, self.qDifficultySlider.upperValue];
}

#pragma mark - Programmatic Sliders

    //Set up sliders (written by us, not third-party)
- (void)configureOverallSlider {
    
    NMRangeSlider *overallSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(16, 6, 300, 34)];
    overallSlider.minimumValue = 0;
    overallSlider.maximumValue = 5;
    overallSlider.lowerValue = 3;
    overallSlider.upperValue = 5;
    overallSlider.stepValue = 0.1;
    overallSlider.tintColor = CoursicaBlue;
    
    [self.contentView addSubview:overallSlider];
    
    // Add programatic constraints to the slider
    [overallSlider addConstraint:[NSLayoutConstraint constraintWithItem:overallSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:40]];
    [overallSlider addConstraint:[NSLayoutConstraint constraintWithItem:overallSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:300]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overallSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.qOverallTitleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overallSlider attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.qOverallTitleLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    overallSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [overallSlider addTarget:self action:@selector(labelSliderChanged:) forControlEvents:UIControlEventValueChanged];

    self.qOverallSlider = overallSlider;
    
    UILabel *overallValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    overallValueLabel.font = self.qOverallTitleLabel.font;
    overallValueLabel.text = [NSString stringWithFormat:@"%.1f to %.1f", overallSlider.lowerValue, overallSlider.upperValue];
    overallValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    overallValueLabel.textAlignment = NSTextAlignmentCenter;
    self.qOverallValueLabel = overallValueLabel;
    [self.contentView addSubview:overallValueLabel];
    
    [overallValueLabel addConstraint:[NSLayoutConstraint constraintWithItem:overallValueLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.qOverallTitleLabel.frame.size.height]];
    [overallValueLabel addConstraint:[NSLayoutConstraint constraintWithItem:overallValueLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:150]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overallValueLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.qOverallSlider attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overallValueLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.qOverallTitleLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}
    //Set up sliders (written by us, not third-party)
- (void) configureWorkloadSlider {
    
    UILabel *workloadTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    workloadTitleLabel.font = self.qOverallTitleLabel.font;
    workloadTitleLabel.text = @"Workload Q Score";
    workloadTitleLabel.textAlignment = NSTextAlignmentCenter;
    workloadTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.qWorkloadTitleLabel = workloadTitleLabel;
    [self.contentView addSubview:workloadTitleLabel];
    
    [workloadTitleLabel addConstraint:[NSLayoutConstraint constraintWithItem:workloadTitleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.qOverallTitleLabel.frame.size.height]];
    [workloadTitleLabel addConstraint:[NSLayoutConstraint constraintWithItem:workloadTitleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:200]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:workloadTitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.qOverallValueLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:workloadTitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.qOverallTitleLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    NMRangeSlider *workloadSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(16, 6, 300, 34)];
    workloadSlider.minimumValue = 0;
    workloadSlider.maximumValue = 5;
    workloadSlider.lowerValue = 3;
    workloadSlider.upperValue = 5;
    workloadSlider.stepValue = 0.1;
    workloadSlider.tintColor = CoursicaBlue;
    self.qWorkloadSlider = workloadSlider;
    
    [self.contentView addSubview:workloadSlider];
    
    [workloadSlider addConstraint:[NSLayoutConstraint constraintWithItem:workloadSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:40]];
    [workloadSlider addConstraint:[NSLayoutConstraint constraintWithItem:workloadSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:300]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:workloadSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:workloadTitleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:workloadSlider attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.qOverallTitleLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    workloadSlider.translatesAutoresizingMaskIntoConstraints = NO;
    
    [workloadSlider addTarget:self action:@selector(labelSliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *workloadValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    workloadValueLabel.font = self.qOverallTitleLabel.font;
    workloadValueLabel.text = [NSString stringWithFormat:@"%.1f to %.1f", workloadSlider.lowerValue, workloadSlider.upperValue];
    self.qWorkloadValueLabel = workloadValueLabel;
    self.qWorkloadValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.qWorkloadValueLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:workloadValueLabel];
    
    [workloadValueLabel addConstraint:[NSLayoutConstraint constraintWithItem:workloadValueLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.qOverallTitleLabel.frame.size.height]];
    [workloadValueLabel addConstraint:[NSLayoutConstraint constraintWithItem:workloadValueLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:150]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:workloadValueLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:workloadSlider attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:workloadValueLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.qOverallTitleLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}
    //Set up sliders (written by us, not third-party)
- (void) configureDifficultySlider {
    
    UILabel *difficultyTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    difficultyTitleLabel.font = self.qOverallTitleLabel.font;
    difficultyTitleLabel.text = @"Difficulty Q Score";
    difficultyTitleLabel.textAlignment = NSTextAlignmentCenter;
    difficultyTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.qDifficultyTitleLabel = difficultyTitleLabel;
    [self.contentView addSubview:difficultyTitleLabel];
    
    [difficultyTitleLabel addConstraint:[NSLayoutConstraint constraintWithItem:difficultyTitleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.qOverallTitleLabel.frame.size.height]];
    [difficultyTitleLabel addConstraint:[NSLayoutConstraint constraintWithItem:difficultyTitleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:150]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:difficultyTitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.qWorkloadValueLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:difficultyTitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.qOverallTitleLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    NMRangeSlider *difficultySlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(16, 6, 300, 34)];
    difficultySlider.minimumValue = 0;
    difficultySlider.maximumValue = 5;
    difficultySlider.lowerValue = 3;
    difficultySlider.upperValue = 5;
    difficultySlider.stepValue = 0.1;
    difficultySlider.tintColor = CoursicaBlue;
    self.qDifficultySlider = difficultySlider;
    
    [self.contentView addSubview:difficultySlider];
    
    [difficultySlider addConstraint:[NSLayoutConstraint constraintWithItem:difficultySlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:40]];
    [difficultySlider addConstraint:[NSLayoutConstraint constraintWithItem:difficultySlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:300]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:difficultySlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:difficultyTitleLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:difficultySlider attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.qOverallTitleLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    difficultySlider.translatesAutoresizingMaskIntoConstraints = NO;
    
    [difficultySlider addTarget:self action:@selector(labelSliderChanged:) forControlEvents:UIControlEventValueChanged];
    self.qDifficultySlider = difficultySlider;
    
    UILabel *difficultyValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    difficultyValueLabel.font = self.qOverallTitleLabel.font;
    difficultyValueLabel.text = [NSString stringWithFormat:@"%.1f to %.1f", difficultySlider.lowerValue, difficultySlider.upperValue];
    difficultyValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    difficultyValueLabel.textAlignment = NSTextAlignmentCenter;
    self.qDifficultyValueLabel = difficultyValueLabel;
    [self.contentView addSubview:difficultyValueLabel];
    
    [difficultyValueLabel addConstraint:[NSLayoutConstraint constraintWithItem:difficultyValueLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.qOverallTitleLabel.frame.size.height]];
    [difficultyValueLabel addConstraint:[NSLayoutConstraint constraintWithItem:difficultyValueLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:150]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:difficultyValueLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:difficultySlider attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:difficultyValueLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.qOverallTitleLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

- (void) configureRangeSliders
{
    [self configureOverallSlider];
    [self configureWorkloadSlider];
    [self configureDifficultySlider];
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
