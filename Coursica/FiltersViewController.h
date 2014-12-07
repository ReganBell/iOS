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

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *applyFiltersButton;

@property (weak, nonatomic) IBOutlet NMRangeSlider *standardSlider;

@property (weak, nonatomic) IBOutlet NMRangeSlider *labelSlider;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;


- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;

@end
