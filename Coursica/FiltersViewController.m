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
#import "DoubleSliderView.h"
#import "QReport.h"

#define CoursicaBlue [UIColor colorWithRed:31/255.0 green:148/255.0 blue:255/255.0 alpha:1.0]
#define UnselectedGray [UIColor colorWithRed:217/255.0 green:215/255.0 blue:215/255.0 alpha:1.0]

@interface FiltersViewController ()

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

@property (weak, nonatomic) NMRangeSlider *qOverallSlider;
@property (weak, nonatomic) NMRangeSlider *qWorkloadSlider;
@property (weak, nonatomic) NMRangeSlider *enrollmentSlider;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign) NSInteger selectedTermIndex;
@property (assign) NSInteger selectedGradIndex;

@property (weak, nonatomic) IBOutlet UIButton *filterCoursesButton;

@end

@implementation FiltersViewController

- (NSPredicate *)filters {
    
    NSMutableArray *predicates = [NSMutableArray new];

    switch (self.selectedGradIndex) {
        case 0:
            [predicates addObject:[NSPredicate predicateWithFormat:@"graduate = %@", [NSNumber numberWithBool:NO]]];
            break;
        case 1:
            [predicates addObject:[NSPredicate predicateWithFormat:@"graduate = %@", [NSNumber numberWithBool:YES]]];
        default:
            break;
    }
    
    [predicates addObject:[NSPredicate predicateWithFormat:@"overall >= %f", self.qOverallSlider.lowerValue]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"overall <= %f", self.qOverallSlider.upperValue]];

    [predicates addObject:[NSPredicate predicateWithFormat:@"workload >= %f", self.qWorkloadSlider.lowerValue]];
    [predicates addObject:[NSPredicate predicateWithFormat:@"workload <= %f", self.qWorkloadSlider.upperValue]];

    [predicates addObject:[NSPredicate predicateWithFormat:@"enrollment >= %d", (int)self.enrollmentSlider.lowerValue]];
    
    int upperEnrollment = (int)self.enrollmentSlider.upperValue;
    if (upperEnrollment < 250) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"enrollment <= %d", (int)self.enrollmentSlider.upperValue]];
    }
    
    switch (self.selectedTermIndex) {
        case 0:
            [predicates addObject:[NSPredicate predicateWithFormat:@"term = %@", @"FALL"]];
            break;
        case 1:
            [predicates addObject:[NSPredicate predicateWithFormat:@"term = %@", @"SPRING"]];
        default:
            break;
    }

//    for (UIButton *button in self.genEdButtons) {
//
//        if (button.selected) {
//            NSNumber *index = [NSNumber numberWithInteger:button.tag + 1];
//            [predicates addObject:[NSPredicate predicateWithFormat:@"genEdOne = %@ OR genEdTwo = %@", index, index]];
//        }
//    }

    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

- (IBAction)filterCoursesButtonPressed:(id)sender {
    
    [self.delegate filtersDidChange];
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
    
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.scrollView addGestureRecognizer:recognizer];
    
    [self selectButton:self.termBarButtons.lastObject inArray:self.termBarLabels];
    [self selectButton:self.gradBarButtons.lastObject inArray:self.gradBarLabels];

    [self.scrollView addSubview:self.genEdBarView];
    [self configureSliders];
}

- (void)handleTap:(UITapGestureRecognizer*)recognizer {
    
    [self.delegate keyboardShouldDismiss];
}

#pragma mark - Button Press Methods

- (void)selectButton:(UIButton*)button inArray:(NSArray*)array {
    
    button.selected = !button.selected;
    UILabel *label = array[button.tag];
    UIColor *newColor = (button.selected) ? CoursicaBlue : UnselectedGray;
    label.textColor = newColor;
}

- (void)gradButtonPressed:(UIButton*)senderButton {
    
    [self.delegate keyboardShouldDismiss];
    self.selectedGradIndex = senderButton.tag;
    [self selectButton:senderButton inArray:self.gradBarLabels];
    for (UIButton *button in self.gradBarButtons) {
        if (button.selected && button.tag != senderButton.tag) {
            [self selectButton:button inArray:self.gradBarLabels];
        }
    }
}

- (void)termButtonPressed:(UIButton*)senderButton {
    
    [self.delegate keyboardShouldDismiss];
    self.selectedTermIndex = senderButton.tag;
    [self selectButton:senderButton inArray:self.termBarLabels];
    for (UIButton *button in self.termBarButtons) {
        if (button.selected && button.tag != senderButton.tag) {
            [self selectButton:button inArray:self.termBarLabels];
        }
    }
}

- (void)genEdButtonPressed:(UIButton*)senderButton {
    
    [self.delegate keyboardShouldDismiss];
    senderButton.selected = !senderButton.selected;
    
    UIImageView *iconView = self.genEdImageViews[senderButton.tag];
    UILabel *label = self.genEdLabels[senderButton.tag];
    
    UIColor *newColor = (senderButton.selected) ? CoursicaBlue : UnselectedGray;
    [UIView animateWithDuration:0 animations:^{
        label.textColor = newColor;
        iconView.tintColor = newColor;
    }];
}
//
//- (IBAction)applyFiltersButtonPressed:(id)sender {
//    
//    [self.delegate dismissFiltersViewController];
//}
//
//- (IBAction)cancelButtonPressed:(id)sender {
//    
//    [self.delegate dismissFiltersViewController];
//}

#pragma mark - Programmatic Sliders

- (DoubleSliderView*)configureSliderWithTitle:(NSString*)title font:(UIFont*)font textColor:(UIColor*)textColor {
    
    DoubleSliderView *sliderView = [[DoubleSliderView alloc] initWithTitle:title font:font textColor:textColor];
    [self.scrollView addSubview:sliderView];
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:sliderView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.genEdBarView attribute:NSLayoutAttributeLeft multiplier:1 constant:18]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:sliderView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.genEdBarView attribute:NSLayoutAttributeRight multiplier:1 constant:-18]];
    [sliderView addConstraint:[NSLayoutConstraint constraintWithItem:sliderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:52.0]];
    
    return sliderView;
}

- (void) configureSliders
{
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0];
    UIColor *textColor = [UIColor colorWithWhite:155/255.0 alpha:1.0];
    
    DoubleSliderView *overall = [self configureSliderWithTitle:@"Overall Q Score" font:font textColor:textColor];
    overall.shouldFormatForFloatValue = YES;
    [overall valueChanged:overall.slider];
    self.qOverallSlider = overall.slider;
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:overall attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.genEdBarView attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    
    DoubleSliderView *workload = [self configureSliderWithTitle:@"Workload" font:font textColor:textColor];
    workload.shouldFormatForFloatValue = YES;
    [workload valueChanged:workload.slider];
    self.qWorkloadSlider = workload.slider;
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:workload attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:overall attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
    
    DoubleSliderView *enrollment = [self configureSliderWithTitle:@"Enrollment" font:font textColor:textColor];
    self.enrollmentSlider = enrollment.slider;
    enrollment.shouldFormatForFloatValue = NO;
    self.enrollmentSlider.minimumValue = 1;
    self.enrollmentSlider.maximumValue = 250;
    self.enrollmentSlider.upperValue = 250;
    [enrollment valueChanged:self.enrollmentSlider];
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:enrollment attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:workload attribute:NSLayoutAttributeBottom multiplier:1 constant:16]];
}

@end
