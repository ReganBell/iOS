//
//  FiltersViewController.h
//  Coursica
//
//  Created by Regan Bell on 11/25/14.
//  Matthew Beatty
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NMRangeSlider.h"

@protocol FiltersViewControllerDelegate <NSObject>

- (void)filtersDidChange;
- (void)keyboardShouldDismiss;

@end

@interface FiltersViewController : UIViewController

@property (weak, nonatomic) id<FiltersViewControllerDelegate> delegate;

@end
