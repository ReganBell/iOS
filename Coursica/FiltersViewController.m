//
//  FiltersViewController.m
//  Coursica
//
//  Created by Regan Bell on 11/25/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "FiltersViewController.h"

@interface FiltersViewController ()

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)termSwitchedChanged:(UISwitch*)termSwitch {
    
    if (termSwitch.on) {
        self.termLabel.text = @"Spring";
        
    } else {
        self.termLabel.text = @"Fall";
    }
    
    [self updateFilter];
}

- (IBAction)graduateSwitchChanged:(UISwitch*)graduateSwitch {
    
    if (graduateSwitch.on) {
        self.graduateLabel.text = @"Graduate";
    } else {
        self.graduateLabel.text = @"Undergraduate";
    }
    
    [self updateFilter];
}

- (void)updateFilter {
    
    NSPredicate *predicate = nil;
    NSPredicate *newPredicate = [NSPredicate predicateWithFormat:@"term = %@", (self.termSwitch.on) ? @"SPRING" : @"FALL"];
    if (!predicate) {
        predicate = newPredicate;
    } else {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, newPredicate]];
    }
    
    newPredicate = [NSPredicate predicateWithFormat:@"graduate = %@", [NSNumber numberWithBool:self.graduateSwitch.on]];
    if (!predicate) {
        predicate = newPredicate;
    } else {
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, newPredicate]];
    }
    
    [self.delegate filtersDidChange:predicate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
