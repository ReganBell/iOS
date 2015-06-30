//
//  LoginViewController.h
//  Coursica
//
//  Created by Matthew Beatty on 1/21/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@class Course;

@protocol LoginViewControllerDelegate <NSObject>

- (void)userDidLoginWithHUID:(NSString*)huid;

@end

@interface LoginViewController : UIViewController

@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

@end