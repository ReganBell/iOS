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

@end

@interface FiltersViewController : UIViewController

@property (weak, nonatomic) id<FiltersViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISwitch *termSwitch;
@property (weak, nonatomic) IBOutlet UILabel *termLabel;

@property (weak, nonatomic) IBOutlet UISwitch *graduateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *graduateLabel;

@property (weak, nonatomic) IBOutlet UISwitch *testSwitch;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end
