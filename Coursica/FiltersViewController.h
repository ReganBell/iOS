//
//  FiltersViewController.h
//  Coursica
//
//  Created by Regan Bell on 11/25/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NMRangeSlider.h"

@protocol FiltersViewControllerDelegate <NSObject>

- (void)filtersDidChange:(NSPredicate*)predicate;

- (void)dismissFiltersViewController;

@end

@interface FiltersViewController : UIViewController

@property (weak, nonatomic) id<FiltersViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UISwitch *termSwitch;
@property (weak, nonatomic) IBOutlet UILabel *termLabel;

@property (weak, nonatomic) IBOutlet UISwitch *gradSwitch;
@property (weak, nonatomic) IBOutlet UILabel *gradLabel;

@property (weak, nonatomic) IBOutlet UISlider *yearSlider;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;

@property (weak, nonatomic) IBOutlet UISlider *qOverallSlider;
@property (weak, nonatomic) IBOutlet UILabel *qOverallLabel;

@property (weak, nonatomic) IBOutlet UISwitch *graduateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *graduateLabel;

@property (weak, nonatomic) IBOutlet UIButton *aipButton;
@property (weak, nonatomic) IBOutlet UIButton *cbButton;
@property (weak, nonatomic) IBOutlet UIButton *emrButton;
@property (weak, nonatomic) IBOutlet UIButton *erButton;
@property (weak, nonatomic) IBOutlet UIButton *slsButton;
@property (weak, nonatomic) IBOutlet UIButton *spuButton;
@property (weak, nonatomic) IBOutlet UIButton *sowButton;
@property (weak, nonatomic) IBOutlet UIButton *sopButton;
@property (weak, nonatomic) IBOutlet UIButton *uswButton;

@property (weak, nonatomic) IBOutlet NMRangeSlider *standardSlider;

@property (weak, nonatomic) IBOutlet NMRangeSlider *labelSlider;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;


- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;

@end
