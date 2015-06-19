//
//  MapViewController.m
//  Coursica
//
//  Created by Regan Bell on 6/14/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutNavigationBarTitle];
    [self.webView loadRequest:self.request];
}

- (void)layoutNavigationBarTitle {
    
    // Sets title bar appearance for the view
    CGRect frame = CGRectMake(0, 0, 0, 0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
    label.text = self.title;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
