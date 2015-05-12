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
#import "SearchManager.h"
#import "DoubleSliderView.h"
#import "QReport.h"
#import "AppDelegate.h"

#define CoursicaBlue [UIColor colorWithRed:31/255.0 green:148/255.0 blue:255/255.0 alpha:1.0]
#define UnselectedGray [UIColor colorWithRed:217/255.0 green:215/255.0 blue:215/255.0 alpha:1.0]

@interface FiltersViewController () <UITextFieldDelegate, UIScrollViewDelegate>

    // References to the UI elements in the view
@property (weak, nonatomic) NMRangeSlider *overallSlider;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *genEdButtons;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *genEdLabels;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *cards;
@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *genEdImageViews;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *termBarButtons;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *termBarLabels;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *gradBarButtons;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *gradBarLabels;

@property (weak, nonatomic) IBOutlet UIView *termBarView;
@property (weak, nonatomic) IBOutlet UIView *genEdBarView;

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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign) NSInteger selectedTermIndex;
@property (assign) NSInteger selectedGradIndex;

@property (weak, nonatomic) IBOutlet UIButton *filterCoursesButton;

@end

@implementation FiltersViewController

- (IBAction)filterCoursesButtonPressed:(id)sender {
    

}

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
    
    for (UIImageView *genEdImageView in self.genEdImageViews) {
        
        genEdImageView.image = [genEdImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        genEdImageView.tintColor = UnselectedGray;
    }
    
    for (UIView *card in self.cards) {
        
        card.layer.cornerRadius = 4.0f;
        card.clipsToBounds = YES;
    }
    
    self.filterCoursesButton.layer.cornerRadius = 4.0f;
    self.filterCoursesButton.clipsToBounds = YES;
    
    int i = 0;
    for (UIButton *genEdButton in self.genEdButtons) {
        [genEdButton addTarget:self action:@selector(genEdButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        genEdButton.tag = i;
        i++;
    }
    
    int j = 0;
    for (UIButton *termButton in self.termBarButtons) {
        [termButton addTarget:self action:@selector(termButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        termButton.tag = j;
        j++;
    }
    
    int k = 0;
    for (UIButton *gradButton in self.gradBarButtons) {
        [gradButton addTarget:self action:@selector(gradButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        gradButton.tag = k;
        k++;
    }
    
    // Creates title bar with app name
    CGRect frame = CGRectMake(0, 0, 0, 0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
    label.text = @"Filters";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBg.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;

    [self.contentView addSubview:self.genEdBarView];
    [self configureSliders];
}

- (void)selectButton:(UIButton*)button inArray:(NSArray*)array {
    
    button.selected = !button.selected;
    
    UILabel *label = array[button.tag];
    
    UIColor *newColor = (button.selected) ? CoursicaBlue : UnselectedGray;
    label.textColor = newColor;
}

- (void)gradButtonPressed:(UIButton*)senderButton {
    
    self.selectedGradIndex = senderButton.tag;
    [self selectButton:senderButton inArray:self.gradBarLabels];
    for (UIButton *button in self.gradBarButtons) {
        if (button.selected && button.tag != senderButton.tag) {
            [self selectButton:button inArray:self.gradBarLabels];
        }
    }
}

- (void)termButtonPressed:(UIButton*)senderButton {
    
    self.selectedTermIndex = senderButton.tag;
    [self selectButton:senderButton inArray:self.termBarLabels];
    for (UIButton *button in self.termBarButtons) {
        if (button.selected && button.tag != senderButton.tag) {
            [self selectButton:button inArray:self.termBarLabels];
        }
    }
}

- (void)genEdButtonPressed:(UIButton*)senderButton {
    
    senderButton.selected = !senderButton.selected;
    
    UIImageView *iconView = self.genEdImageViews[senderButton.tag];
    UILabel *label = self.genEdLabels[senderButton.tag];
    
    UIColor *newColor = (senderButton.selected) ? CoursicaBlue : UnselectedGray;
    [UIView animateWithDuration:0 animations:^{
        label.textColor = newColor;
        iconView.tintColor = newColor;
    }];
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
    
//    NSMutableArray *predicates = [NSMutableArray new];
//    
//    switch (self.courseLevelControl.selectedSegmentIndex) {
//        case 1:
//            [predicates addObject:[NSPredicate predicateWithFormat:@"graduate = %@", [NSNumber numberWithBool:NO]]];
//            break;
//        case 2:
//            [predicates addObject:[NSPredicate predicateWithFormat:@"graduate = %@", [NSNumber numberWithBool:YES]]];
//        default:
//            break;
//    }
//    // Checking all of the Q score filters
////    [predicates addObject:[NSPredicate predicateWithFormat:@"qOverall >= %f", self.qOverallSlider.lowerValue]];
////    [predicates addObject:[NSPredicate predicateWithFormat:@"qOverall <= %f", self.qOverallSlider.upperValue]];
////    
////    [predicates addObject:[NSPredicate predicateWithFormat:@"qWorkload >= %f", self.qWorkloadSlider.lowerValue]];
////    [predicates addObject:[NSPredicate predicateWithFormat:@"qWorkload <= %f", self.qWorkloadSlider.upperValue]];
////    
////    [predicates addObject:[NSPredicate predicateWithFormat:@"qDifficulty >= %f", self.qDifficultySlider.lowerValue]];
////    [predicates addObject:[NSPredicate predicateWithFormat:@"qDifficulty <= %f", self.qDifficultySlider.upperValue]];
//
//    switch (self.termControl.selectedSegmentIndex) {
//        case 1:
//            [predicates addObject:[NSPredicate predicateWithFormat:@"term = %@", @"FALL"]];
//            break;
//        case 2:
//            [predicates addObject:[NSPredicate predicateWithFormat:@"term = %@", @"SPRING"]];
//        default:
//            break;
//    }
//    
//    // Checks all Gen. Ed. filters
//    for (UIButton *button in self.genEdButtons) {
//        
//        if (button.selected) {
//            NSNumber *index = [NSNumber numberWithInteger:button.tag + 1];
//            [predicates addObject:[NSPredicate predicateWithFormat:@"genEdOne = %@ OR genEdTwo = %@", index, index]];
//        }
//    }
//    
//    NSString *search = self.searchField.text;
//
//    if (search.length) {
//        
//        NSMutableArray *termPreds = [NSMutableArray array];
//        NSArray *terms = [search componentsSeparatedByString:@" "];
//        for (NSString *searchTerm in terms) {
//            
//            NSMutableArray *searchPreds = [NSMutableArray array];
//            [searchPreds addObject:[NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchTerm]];
//            [searchPreds addObject:[NSPredicate predicateWithFormat:@"shortField CONTAINS[cd] %@", searchTerm]];
//            [searchPreds addObject:[NSPredicate predicateWithFormat:@"longField CONTAINS[cd] %@", searchTerm]];
//            [searchPreds addObject:[NSPredicate predicateWithFormat:@"number like %@", searchTerm]];
//            [searchPreds addObject:[NSPredicate predicateWithFormat:@"ANY %K CONTAINS[cd] %@", @"faculty.first", searchTerm]];
//            [searchPreds addObject:[NSPredicate predicateWithFormat:@"ANY %K CONTAINS[cd] %@", @"faculty.last", searchTerm]];
//            [termPreds addObject:[NSCompoundPredicate orPredicateWithSubpredicates:searchPreds]];
//        }
//        [predicates addObject:[NSCompoundPredicate andPredicateWithSubpredicates:termPreds]];
//    }
//    
//    // Calls function in CoursesViewController to update course list
//    [self.delegate filtersDidChange:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    
    NSArray *results = [[SearchManager sharedSearchManager] coursesForSearch:@"latin america"];
    
    
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
- (DoubleSliderView*)configureSliderWithTitle:(NSString*)title font:(UIFont*)font textColor:(UIColor*)textColor {
    
    DoubleSliderView *sliderView = [[DoubleSliderView alloc] initWithTitle:title font:font textColor:textColor];
    [self.contentView addSubview:sliderView];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:sliderView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.genEdBarView attribute:NSLayoutAttributeLeft multiplier:1 constant:18]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:sliderView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.genEdBarView attribute:NSLayoutAttributeRight multiplier:1 constant:-18]];
    [sliderView addConstraint:[NSLayoutConstraint constraintWithItem:sliderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0]];
    
    return sliderView;
}

- (void) configureSliders
{
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0];
    UIColor *textColor = [UIColor colorWithWhite:155/255.0 alpha:1.0];
    
    DoubleSliderView *overall = [self configureSliderWithTitle:@"Overall Q Score" font:font textColor:textColor];
    self.qOverallSlider = overall.slider;
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overall attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.genEdBarView attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    
    DoubleSliderView *workload = [self configureSliderWithTitle:@"Workload" font:font textColor:textColor];
    self.qDifficultySlider = workload.slider;
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:workload attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:overall attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    
    DoubleSliderView *difficulty = [self configureSliderWithTitle:@"Difficulty" font:font textColor:textColor];
    self.qWorkloadSlider = overall.slider;
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:difficulty attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:workload attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
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
