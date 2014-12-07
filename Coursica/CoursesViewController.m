//
//  ViewController.m
//  Coursica
//
//  Created by Regan Bell on 11/9/14.
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "CoursesViewController.h"
#import "AFNetworking.h"
#import "Course.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "FiltersViewController.h"
#import "NavigationController.h"

@interface CoursesViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSPredicate *filterPredicate;

@end

@implementation CoursesViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSUInteger count = [delegate.managedObjectContext countForFetchRequest:fetchRequest error:nil];
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
    label.text = @"Coursica";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    self.navigationItem.titleView = label;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBg.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [button setImage:[UIImage imageNamed:@"SmallSearch.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showFilters) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = searchButton;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.opaque = YES;

    self.tableView.tableFooterView = [UIView new];
    
    if (count == 0) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", nil];
        [manager GET:@"http://api.cs50.net/courses/3/courses?key=bb344e1e4724ebdcfe53cc61f0cb2649&output=json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //matt's key : 7f9c3089fc20f15bd6c4b460b5ff328d
            //regan's key : bb344e1e4724ebdcfe53cc61f0cb2649
            
            [Course updateCourses: responseObject];
            [self.tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error fetching lists: %@", error);
        }];
    }
}

- (IBAction)showFilters{
    
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FiltersViewController *filterController = [main instantiateViewControllerWithIdentifier:@"filtersController"];
    filterController.delegate = self;
    
    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:filterController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)dismissFiltersViewController {

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSFetchedResultsController Delegate

- (void)filtersDidChange:(NSPredicate *)predicate {
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

- (NSFetchedResultsController*)fetchedResultsController {
    
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    // Search to-dos:
    // - year
    // - faculty
    // - course level: grad/undergrad
    // - search by gen ed:
    // - general search:
    // - fields of study
    // - q-score filters:
    // - scheduling, doesn't conflict with
    [fetchRequest setPredicate:self.filterPredicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field"
                                                                   ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, numberDescriptor, nil]];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
                                          
    _fetchedResultsController = controller;
    
    NSError *error;
    [controller performFetch:&error];
    
    controller.delegate = self;
    
    return controller;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //[self fetchedResultsController:controller configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            return;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Table View Data Source and Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *original = [NSString stringWithFormat:@"%@ %@ - %@", course.field, course.number, course.title];
    NSRange boldRange = [original rangeOfString:course.title];

    NSMutableAttributedString *fancy = [[NSMutableAttributedString alloc] initWithString:original];
    [fancy addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:14] range:NSMakeRange(0, original.length)];
    [fancy addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:150/255.0 alpha:1.0] range:NSMakeRange(0, original.length)];
    [fancy addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-DemiBold" size:17] range:boldRange];
    [fancy addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:boldRange];
    
    cell.textLabel.attributedText = fancy;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detailController = [main instantiateViewControllerWithIdentifier:@"detailController"];
    detailController.course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    return sectionInfo.numberOfObjects;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
