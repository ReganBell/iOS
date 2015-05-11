//
//  ViewController.m
//  Coursica
//
//  Created by Regan Bell on 11/9/14.
//  Matthew Beatty
//  Copyright (c) 2014 Prestige Worldwide. All rights reserved.
//

#import "CoursesViewController.h"
#import "AFNetworking.h"
#import "Course.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "FiltersViewController.h"
#import "NavigationController.h"
#import "SearchManager.h"

#define CoursicaBlue [UIColor colorWithRed:31/255.0 green:148/255.0 blue:255/255.0 alpha:1.0]

@interface CoursesViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSPredicate *filterPredicate;

@property (strong, nonatomic) FiltersViewController *filterController;
@property (strong, nonatomic) UIView *navBarView;
@property (strong, nonatomic) UIView *navBarRightButtonView;

@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) NSLayoutConstraint *cancelButtonCenterY;

@property (strong, nonatomic) UIButton *searchButton;
@property (strong, nonatomic) NSLayoutConstraint *searchButtonCenterY;

@property (strong, nonatomic) UILabel *coursicaTitleLabel;
@property (strong, nonatomic) NSLayoutConstraint *coursicaTitleCenterY;

@property (strong, nonatomic) UITextField *searchBar;
@property (strong, nonatomic) NSLayoutConstraint *searchBarCenterY;

@end

@implementation CoursesViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Creates objects used retrieving data from CS50 API
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSUInteger count = [delegate.managedObjectContext countForFetchRequest:fetchRequest error:nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.opaque = YES;

    self.tableView.tableFooterView = [UIView new];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBg.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.titleView = self.navBarView;
    
    CGRect frame = self.navBarView.superview.superview.frame;
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:window attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.coursicaTitleLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [window addConstraint:centerX];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navBarRightButtonView];
    
    // checks for a database, and if not requests courses data from CS50 API
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

- (UIView*)navBarRightButtonView {
    
    if (_navBarRightButtonView) {
        return _navBarRightButtonView;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    [view addSubview:self.cancelButton];
    [view addSubview:self.searchButton];
    NSLayoutConstraint *centerXCancel = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.cancelButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *centerXSearch = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.searchButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *centerYCancel = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.cancelButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    self.cancelButtonCenterY = centerYCancel;
    NSLayoutConstraint *centerYSearch = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.searchButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    self.searchButtonCenterY = centerYSearch;
    NSLayoutConstraint *searchHeight = [NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:24.0];
    NSLayoutConstraint *searchWidth = [NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:24.0];
    
    [view addConstraints:@[centerXCancel, centerXSearch, centerYCancel, centerYSearch, searchHeight, searchWidth]];
    self.cancelButton.hidden = YES;
    _navBarRightButtonView = view;
    
    return _navBarRightButtonView;
}

- (UITextField*)searchBar {
    
    if (_searchBar) {
        return _searchBar;
    }
    
    UITextField *searchBar = [[UITextField alloc] initWithFrame:CGRectZero];
    
    searchBar.backgroundColor = [UIColor colorWithRed:31/255.0 green:117/255.0 blue:1 alpha:1.0];
    searchBar.layer.cornerRadius = 4.0f;
    searchBar.layer.masksToBounds = YES;
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIFont *searchBarFont = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0];
    
    searchBar.font = searchBarFont;
    searchBar.textColor = [UIColor whiteColor];
    
    UIView *leftSpacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [searchBar setLeftViewMode:UITextFieldViewModeAlways];
    [searchBar setLeftView:leftSpacerView];
    
    UIColor *placeholderColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    
    NSMutableParagraphStyle *style = [searchBar.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = searchBar.font.lineHeight - (searchBar.font.lineHeight - searchBarFont.lineHeight) / 2.0;
    
    NSString *placeholder = @"Search for courses";
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                                attributes: @{NSForegroundColorAttributeName:placeholderColor,
                                                                                              NSFontAttributeName:searchBarFont,
                                                                                              NSParagraphStyleAttributeName:style}];
    searchBar.attributedPlaceholder = attributedPlaceholder;
    _searchBar = searchBar;
    return searchBar;
}

- (UIView*)navBarView {
    
    if (_navBarView) {
        return _navBarView;
    }
    
    CGRect frame = CGRectZero;
    frame.size = self.navigationController.navigationBar.frame.size;
    UIView *navBarView = [[UIView alloc] initWithFrame:frame];
    UITextField *searchBar = self.searchBar;
    searchBar.hidden = YES;
    navBarView.clipsToBounds = YES;
    
    [navBarView addSubview:searchBar];
    UIView *coursicaTitleLabel =  self.coursicaTitleLabel;
    [navBarView addSubview:coursicaTitleLabel];
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:coursicaTitleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:navBarView attribute:NSLayoutAttributeCenterYWithinMargins multiplier:1.0 constant:0.0];
    self.coursicaTitleCenterY = centerY;
    [navBarView addConstraint:centerY];
    
    NSLayoutConstraint *rightSpacing = [NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeRightMargin relatedBy:NSLayoutRelationEqual toItem:navBarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
    NSLayoutConstraint *leftSpacing = [NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeLeftMargin relatedBy:NSLayoutRelationEqual toItem:navBarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:29.0];
    NSLayoutConstraint *center = [NSLayoutConstraint constraintWithItem:searchBar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:navBarView attribute:NSLayoutAttributeCenterYWithinMargins multiplier:1.0 constant:0.0];
    self.searchBarCenterY = center;
    [navBarView addConstraints:@[rightSpacing, leftSpacing, height, center]];
    _navBarView = navBarView;

    return _navBarView;
}

- (UIButton*)cancelButton {
    
    if (_cancelButton) {
        return _cancelButton;
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0];
    [button addTarget:self action:@selector(cancelFiltersButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    _cancelButton = button;
    return _cancelButton;
}

- (UIButton*)searchButton {
    
    if (_searchButton) {
        return _searchButton;
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [button setImage:[UIImage imageNamed:@"SmallSearch.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showFilters) forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    _searchButton = button;
    return _searchButton;
}

- (UILabel*)coursicaTitleLabel {
    
    if (_coursicaTitleLabel) {
        return _coursicaTitleLabel;
    }
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:17];
    label.text = @"Coursica";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    _coursicaTitleLabel = label;
    return _coursicaTitleLabel;
}

- (FiltersViewController*)filterController {
    
    if (!_filterController) {
        
        UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _filterController = [main instantiateViewControllerWithIdentifier:@"filtersController"];
        _filterController.delegate = self;
        _filterController.view.alpha = 0.0;
        [self.view addSubview:_filterController.view];
    }
    
    return _filterController;
}

- (void)cancelFiltersButtonPressed:(UIButton*)sender {
    
    self.coursicaTitleLabel.hidden = NO;
    self.searchButton.hidden = NO;
    self.coursicaTitleLabel.alpha = 0.0;
    self.searchButton.alpha = 0.0;
    self.coursicaTitleCenterY.constant = 0.0;
    self.searchButtonCenterY.constant = 0.0;
    self.searchBarCenterY.constant = 20.0;
    self.cancelButtonCenterY.constant = -20.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBar.alpha = 0.0;
        self.cancelButton.alpha = 0.0;
        self.coursicaTitleLabel.alpha = 1.0;
        self.searchButton.alpha = 1.0;
        self.filterController.view.alpha = 0.0;
        [self.navigationController.navigationBar layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        self.searchBar.hidden = YES;
        self.cancelButton.hidden = YES;
        self.filterController.view.hidden = YES;
    }];
}

    // Action called on switching to the filters screen
- (IBAction)showFilters{
    
    self.searchBar.hidden = NO;
    self.cancelButton.hidden = NO;
    self.searchBar.alpha = 0.0;
    self.cancelButton.alpha = 0.0;
    self.coursicaTitleCenterY.constant = -20.0;
    self.searchButtonCenterY.constant = 20.0;
    self.searchBarCenterY.constant = 0.0;
    self.cancelButtonCenterY.constant = 0.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.searchBar.alpha = 1.0;
        self.cancelButton.alpha = 1.0;
        self.coursicaTitleLabel.alpha = 0.0;
        self.searchButton.alpha = 0.0;
        [self.navigationController.navigationBar layoutIfNeeded];
        
    } completion:^(BOOL finished) {

        self.searchButton.hidden = YES;
        self.coursicaTitleLabel.hidden = YES;
    }];
    
    self.filterController.view.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.filterController.view.alpha = 1.0;
    }];
}

- (void)dismissFiltersViewController {

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSFetchedResultsController Delegate

    // Response to filter changes in the filters view
- (void)filtersDidChange:(NSPredicate *)predicate {
    self.fetchedResultsController.fetchRequest.predicate = predicate;
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    [self.tableView reloadData];
}

    // returners controller for results from API calls
- (NSFetchedResultsController*)fetchedResultsController {
    
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *predicates = [NSMutableArray array];
    if (self.filterPredicate) {
        [predicates addObject:self.filterPredicate];
    }
    
    NSPredicate *bracketPred = [NSPredicate predicateWithFormat:@"bracketed = %@", @NO];
    [predicates addObject:bracketPred];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [fetchRequest setPredicate:predicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shortField"
                                                                   ascending:YES];
    // Sort by decimal number first so 10, 100, 1000 would be in the right order
    NSSortDescriptor *decimalNumberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decimalNumber" ascending:YES];
    
    // Fall back to number string when decimalNumber is the same, e.g. Math Ma and Mb both have decimal number -1, so sorting will fall back to this string comparison descriptor and sort them correctly
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];

    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, decimalNumberDescriptor, numberDescriptor, nil]];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
                                          
    _fetchedResultsController = controller;
    
    NSError *error;
    [controller performFetch:&error];
    
//    NSMutableSet *fieldAbbreviations = [[NSMutableSet alloc] init];
//    NSMutableString *abbreviations = [[NSMutableString alloc] init];
//    
//    for (Course *course in controller.fetchedObjects) {
//        
//        [fieldAbbreviations addObject:course.shortField];
//    }
//    
//    NSArray *array = [fieldAbbreviations allObjects];
//    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
//        return [obj1 caseInsensitiveCompare:obj2];
//    }];
//    NSArray *sortedArary = [array sortedArrayUsingDescriptors:@[descriptor]];
//    
//    for (NSString *abbreviation in sortedArary) {
//        [abbreviations appendFormat:@"%@\n", abbreviation];
//    }
//    
//    NSLog(@"%@", abbreviations);
    
    controller.delegate = self;
    
    return controller;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
    // changes table view sections with changes in core data
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
    // Changes table view objects with change to the object in core data
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
    
    if (course.title.length == 0) {
        return cell;
    }
    
    NSString *original = [NSString stringWithFormat:@"%@ %@ - %@", course.shortField, course.number, course.title];
    NSRange boldRange = [original rangeOfString:course.title];

    NSMutableAttributedString *fancy = [[NSMutableAttributedString alloc] initWithString:original];
    [fancy addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:14] range:NSMakeRange(0, original.length)];
    [fancy addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:150/255.0 alpha:1.0] range:NSMakeRange(0, original.length)];
    [fancy addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-DemiBold" size:17] range:boldRange];
    [fancy addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:boldRange];
    
    cell.textLabel.attributedText = fancy;
    
    return cell;
}
    // Called after a selection of the table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailViewController *detailController = [main instantiateViewControllerWithIdentifier:@"detailController"];
    detailController.course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.fetchedResultsController.sections.count == 0 && self.filterPredicate) {
        return 1;
    } else
        return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    return sectionInfo.numberOfObjects;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
