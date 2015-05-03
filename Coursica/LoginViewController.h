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

- (void)userDidLogin;

@end

@interface LoginViewController : UIViewController

@property (weak, nonatomic) id<LoginViewControllerDelegate> delegate;

- (IBAction)onButtonFill:(id)sender;

- (IBAction)onButtonChange:(id)sender;

- (IBAction)onButtonReset:(id)sender;

@end