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


@interface LoginViewController ()


@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ios7_3.jpg"]];
//    [self.view addSubview:backgroundView];
    
    self.usernameField.layer.cornerRadius=4.0f;
    self.passwordField.layer.cornerRadius=4.0f;
    
    
    self.usernameField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    self.passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    //self.usernameField.layer.masksToBounds=YES;
    //self.usernameField.layer.borderColor=[[UIColor redColor]CGColor];
    //self.usernameField.layer.borderWidth= 1.0f;
    
    self.loginButton.layer.cornerRadius = 2; // this value vary as per your desire
    self.loginButton.clipsToBounds = YES;
    
    UIImageView *backgroundImageView =
        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jharvard_dark.jpg"]];
    backgroundImageView.frame = self.view.bounds;
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack: backgroundImageView];
    
    [self.view setNeedsLayout];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//- (BOOL)checkAuthentication:(NSString *)username password:(NSString *)password)
//{
//}

- (IBAction)loginButtonPressed:(id)sender {
    //usernameField.text and passwordField.text
    
    // Check authentication
    // If authentication fails, display failure
    // If authentication succeeds
    // (Maybe save user info in keychain) else save that they authenticated in nsuserdefaults, send to courseview
    
    //if (checkAuthentication(self.usernameField.text, self.passwordField.text))
    if (false)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"logged_in"];
        [defaults synchronize];
        NSLog(@"data saved");
        
        UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CoursesViewController *coursesController = [main instantiateViewControllerWithIdentifier:@"coursesController"];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                        message:@"Invalid HUID number or password. Please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}


/*
 #pragma mark - Navigation
 */

@end
