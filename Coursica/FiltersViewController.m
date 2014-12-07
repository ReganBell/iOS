//
//  FiltersViewController.m
//  Coursica
//
//  Created by Regan Bell on 11/25/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "FiltersViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface FiltersViewController ()

@property (weak, nonatomic) NMRangeSlider *rangeSlider;

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"Filters";
    
    [self configureLabelSlider];
    
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:self.aipButton,self.erButton,self.cbButton,self.emrButton, self.slsButton, self.spuButton, self.sowButton, self.sopButton, self.uswButton, self.fallButton, self.springButton, self.undergradButton, self.gradButton, nil];
    
    for (UIButton *button in buttonArray)
    {
        button.layer.cornerRadius = 2;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blueColor].CGColor;
    }
    
    [self configureRangeSlider];
}

- (IBAction)applyFiltersButtonPressed:(id)sender {
    
    NSMutableArray *predicates = [NSMutableArray new];
    
    NSPredicate *newPredicate;// = [NSPredicate predicateWithFormat:@"term = %@", (self.termSwitch.on) ? @"SPRING" : @"FALL"];
    [predicates addObject:newPredicate];
    
    newPredicate = [NSPredicate predicateWithFormat:@""];

    [self.delegate filtersDidChange:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
}


// unnecessary
- (IBAction)buttonClicked:(UIButton*)genEdButton {
    if (genEdButton.backgroundColor == [UIColor grayColor])
    {
        genEdButton.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        genEdButton.backgroundColor = [UIColor grayColor];
    }
}

- (IBAction)yearSliderChanged:(UISlider*)yearSlider {
    
    float sliderVal = roundf(yearSlider.value);
    
    switch ((int)sliderVal) {
        case 2014:
            self.yearLabel.text = @"2014-2015";
            yearSlider.value = 2014;
            break;
        case 2015:
            self.yearLabel.text = @"2015-2016";
            yearSlider.value = 2015;
            break;
        case 2016:
            self.yearLabel.text = @"2016-2017";
            yearSlider.value = 2016;
            break;
        case 2017:
            self.yearLabel.text = @"2017-2018";
            yearSlider.value = 2017;
            break;
        case 2018:
            self.yearLabel.text = @"2018-2019";
            yearSlider.value = 2018;
            break;
            
        default:
            self.yearLabel.text = @"All Years";
            yearSlider.value = 2014;
            break;
    }
    
    [self updateFilter];
}


- (IBAction)qOverallSliderChanged:(UISlider*)qOverallSlider {
    
    float rounded = roundf(qOverallSlider.value*10)/10;
    self.qOverallLabel.text = [NSString stringWithFormat:@"%0.1f", rounded];;
    
    [self updateFilter];
}

    // TODO: update with year slider value
- (void)updateFilter {
    
//        NSPredicate *predicate = nil;
//        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"term = %@", (self.termSwitch.on) ? @"SPRING" : @"FALL"];
//        if (!predicate) {
//                predicate = newPredicate;
//            } else {
//                    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, newPredicate]];
//                }
//
//        newPredicate = [NSPredicate predicateWithFormat:@"graduate = %@", [NSNumber numberWithBool:self.graduateSwitch.on]];
//        if (!predicate) {
//                predicate = newPredicate;
//            } else {
//                    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, newPredicate]];
//                }
//    
        //[self.delegate filtersDidChange:predicate];
    }

- (IBAction)showCourses {
    
    
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
    [self updateSliderLabels];
}


#pragma mark -
#pragma mark - Programic Sliders

- (void) configureRangeSlider
{
    NMRangeSlider* rangeSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(16, 6, 275, 34)];
    rangeSlider.lowerValue = 0;
    rangeSlider.upperValue = 5;
    [rangeSlider addConstraint:[NSLayoutConstraint constraintWithItem:rangeSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:34]];
    [rangeSlider addConstraint:[NSLayoutConstraint constraintWithItem:rangeSlider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:275]];
    [self.contentView addSubview:rangeSlider];
    self.rangeSlider = rangeSlider;
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
