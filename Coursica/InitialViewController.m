//
//  InitialViewController.m
//  Coursica
//
//  Created by Regan Bell on 11/24/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "InitialViewController.h"
#import "CoursesViewController.h"
#import "MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIViewController * leftDrawer = [[UIViewController alloc] init];
    UIViewController * center = [[CoursesViewController alloc] init];
    
    MMDrawerController * drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:center
                                             leftDrawerViewController:leftDrawer
                                             rightDrawerViewController:nil];
    
    [self.view addSubview:drawerController.view];
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
