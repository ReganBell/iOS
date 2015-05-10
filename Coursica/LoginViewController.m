//
//  LoginViewController.m
//  Coursica
//
//  Created by Matthew Beatty on 1/21/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CoursesViewController.h"
#import <QuartzCore/QuartzCore.h>

#define coursicaBlue [UIColor colorWithRed:31/255.0 green:148/255.0 blue:255/255.0 alpha:1.0]

@interface LoginViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIWebView *secretWebView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageHUIDSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titlePasswordSpace;
@property (weak, nonatomic) IBOutlet UIView *keyboardView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign) BOOL PINSiteLoaded;
@property (assign) BOOL userDidSubmit;
@property (assign) BOOL PINSiteTried;
@property (nonatomic, assign) CGFloat titleTopSpaceInitial;
@property (nonatomic, assign) CGFloat titleTopSpaceError;
@property (assign) BOOL UIStateError;

@end

@implementation LoginViewController

/* This works by loading a UIWebView behind the main login view. When the login view loads for the first time,
 we make a request to CS50 courses for its authentication. 
 When we load this authentication page, self.PINSiteLoaded is set to YES
 When the user submits their credentials, self.userDidSubmit is set to YES
 If these are both set to YES, we try their credentials, and if the authentication website routes us back to cs50 courses,
 we know that login was successful and can dismiss the login controller
 */

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.PINSiteLoaded = NO;
    self.userDidSubmit = NO;
    self.PINSiteTried = NO;
    self.UIStateError = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://courses.cs50.net/classes/login"]];
    [self.secretWebView loadRequest:request];
    
    self.usernameField.layer.cornerRadius = 4.0f;
    self.passwordField.layer.cornerRadius = 4.0f;
    
    self.usernameField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    self.passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    self.loginButton.layer.cornerRadius = 2;
    self.loginButton.clipsToBounds = YES;
    
    self.titleTopSpaceInitial = self.titlePasswordSpace.constant;
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height < 568) {
        self.messageHUIDSpace.constant -= 8;
    }
    
    [self registerKeyboardNotifications];
    
    UIImageView *backgroundImageView =
        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jharvard_dark.jpg"]];
    backgroundImageView.frame = self.view.bounds;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack: backgroundImageView];
    
    [self.view setNeedsLayout];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (CGFloat)titleTopSpaceError {
    
    // TODO: Handle the error message animation on the 4s in a less sketchy way
    
    CGFloat shift = 25;
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height < 568) {
        shift = 5;
    }
    
    return _titleTopSpaceInitial + shift;
}

- (void)tryUserCredentials {
    
    [self removeFailureUIState];
    
    [self.secretWebView stringByEvaluatingJavaScriptFromString:@"setContent('PIN','Harvard University ID (HUID)');"];
    
    NSString *username = self.usernameField.text;
    NSString *usernameJS  = [NSString stringWithFormat:@"document.getElementById('username').value = '%@'", username];
    [self.secretWebView stringByEvaluatingJavaScriptFromString:usernameJS];
    
    NSString *password = self.passwordField.text;
    NSString *passwordJS  = [NSString stringWithFormat:@"document.getElementById('password').value = '%@'", password];
    [self.secretWebView stringByEvaluatingJavaScriptFromString:passwordJS];
    
    NSString *submitJS = @"document.getElementsByName('_eventId_submit')[0].click()";
    self.PINSiteTried = YES;
    [self.secretWebView stringByEvaluatingJavaScriptFromString:submitJS];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [self loginFailedWithMessage:@"Error connecting to the network."];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[webView.request.URL absoluteString] isEqualToString:@"https://courses.cs50.net/"]) {
        
        [self.usernameField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        
        [self.delegate userDidLogin];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    self.PINSiteLoaded = YES;
    if (self.userDidSubmit && !self.PINSiteTried) {
        [self tryUserCredentials];
    } else if (self.PINSiteTried) {
        [self loginFailedWithMessage:@"Invalid HUID or password, try again."];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)removeFailureUIState {
    
    if (!self.UIStateError) {
        return;
    }
    
    if (self.titleTopSpaceError == self.titleTopSpaceError)
        self.titlePasswordSpace.constant = self.titleTopSpaceInitial;

    [UIView animateWithDuration:0.2 animations:^{
        self.messageLabel.alpha = 0.0;
        [self.view layoutIfNeeded];
        // Change to red failure color
        self.loginButton.backgroundColor = coursicaBlue;
    } completion:^(BOOL finished) {
        self.UIStateError = !finished;
    }];
}

- (void)loginFailedWithMessage:(NSString*)message {
    
    self.UIStateError = YES;
    self.messageLabel.text = message;
    self.titlePasswordSpace.constant = self.titleTopSpaceError;
        
    [self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.2 animations:^{
        self.messageLabel.alpha = 1.0;
        [self.view layoutIfNeeded];
        // Change to red failure color
        self.loginButton.backgroundColor = [UIColor colorWithRed:1.0 green:30/255.0 blue:31/255.0 alpha:1.0];
    }];
}

- (IBAction)loginButtonPressed:(id)sender {

    if (self.usernameField.text.length == 0) {
        [self loginFailedWithMessage:@"Your HUID is required to log in."];
        return;
    }
    if (self.passwordField.text.length == 0) {
        [self loginFailedWithMessage:@"Your password is required to log in."];
        return;
    }
    
    self.userDidSubmit = YES;
    [self.loginButton setTitle:@"Logging in..." forState:UIControlStateNormal];
    if (self.PINSiteLoaded) {
        [self tryUserCredentials];
    }
}

- (void)registerKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangeFrame:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangeFrame:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

-(void)keyboardChangeFrame:(NSNotification*)notification{
    
    CGRect keyboardEndFrame;
    [[notification userInfo][UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    UIViewAnimationCurve curve =[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.keyboardHeight.constant = CGRectGetHeight(keyboardEndFrame);
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

@end
