//
//  FiltersViewController.h
//  Coursica
//
//  Created by Regan Bell on 11/25/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FiltersViewControllerDelegate <NSObject>

- (void)filtersDidChange:(NSPredicate*)predicate;

- (void)dismissFiltersViewController;

@end

@interface FiltersViewController : UIViewController

@property (weak, nonatomic) id<FiltersViewControllerDelegate> delegate;


@end
