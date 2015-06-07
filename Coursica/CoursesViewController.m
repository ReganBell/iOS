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

@interface CoursesViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate>

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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    [self updateCoursesData];
    [self layoutNavigationBar];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.opaque = YES;
    
    self.tableView.tableFooterView = [UIView new];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBarBg.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)updateCoursesData {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSUInteger count = [delegate.managedObjectContext countForFetchRequest:fetchRequest error:nil];
    
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

#pragma mark - Navigation Bar Layout

- (void)layoutNavigationBar {
    
    self.navigationItem.titleView = self.navBarView;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat constant = screenWidth / 2 - 8;
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.coursicaTitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.navBarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:constant];
    [self.navBarView addConstraint:centerX];
    [self.navBarView layoutIfNeeded];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navBarRightButtonView];
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
    self.cancelButton.alpha = 0.0;
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
    searchBar.returnKeyType = UIReturnKeySearch;
    searchBar.delegate = self;
    
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
    searchBar.alpha = 0.0;
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
    [button setTitle:@"Clear" forState:UIControlStateNormal];
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

#pragma mark - Filters View Transition

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self setFiltersShowing:YES searchActive:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self filtersDidChange];
    return YES;
}

- (void)filtersDidChange {
    
    NSString *search = self.searchBar.text;
    
    if (!search.length) {
        [self.searchBar resignFirstResponder];
        
    }
    
    [[SearchManager sharedSearchManager] assignScoresForSearch:search];
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"searchScore > %f", 0.05];
    NSPredicate *masterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[searchPredicate]];
    
    [self updateFetchWithPredicate:masterPredicate];
    
    [self setFiltersShowing:NO searchActive:YES];
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

- (void)setFiltersShowing:(BOOL)showing searchActive:(BOOL)searchActive {
    
    NSArray *unhideViews, *hideViews, *moveInConstraints, *moveOutConstraints;
    
    if (showing) {
        unhideViews = @[self.searchBar, self.cancelButton];
        moveInConstraints = @[self.searchBarCenterY, self.cancelButtonCenterY];
        //Order for moveOut matters, the first moves +20.0, the last -20.0
        moveOutConstraints = @[self.searchButtonCenterY, self.coursicaTitleCenterY];
        hideViews = @[self.coursicaTitleLabel, self.searchButton];
    } else {
        unhideViews = @[self.coursicaTitleLabel, self.searchButton];
        moveInConstraints = @[self.coursicaTitleCenterY, self.searchButtonCenterY];
        //Order for moveOut matters, the first moves +20.0, the last -20.0
        moveOutConstraints = @[self.searchBarCenterY, self.cancelButtonCenterY];
        hideViews = @[self.searchBar, self.cancelButton];
    }
    
    if (!searchActive) {
        for (NSLayoutConstraint *moveIn in moveInConstraints)
            moveIn.constant = 0.0;
        
        NSLayoutConstraint *firstOut = moveOutConstraints.firstObject;
        firstOut.constant = 20.0;
        NSLayoutConstraint *lastOut = moveOutConstraints.lastObject;
        lastOut.constant = -20.0;
    }
    
    if (!showing)
        [self.searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        if (!searchActive) {
            for (UIView *hide in hideViews)
                hide.alpha = 0.0;
            for (UIView *unhide in unhideViews)
                unhide.alpha = 1.0;
            [self.navigationController.navigationBar layoutIfNeeded];
        }
        self.filterController.view.alpha = (showing) ? 1.0 : 0.0;
    }];
}

- (void)cancelFiltersButtonPressed:(UIButton*)sender {
    
    [self setFiltersShowing:NO searchActive:NO];
    self.searchBar.text = @"";
    [[SearchManager sharedSearchManager] clearSearchScores];
    [self updateFetchWithPredicate:nil];
}

- (IBAction)showFilters{
    
    [self setFiltersShowing:YES searchActive:NO];
}

- (void)keyboardShouldDismiss {
    
    [self.searchBar resignFirstResponder];
}

#pragma mark - NSFetchedResultsController Delegate

- (void)updateFetchWithPredicate:(NSPredicate*)predicate {
    
    NSMutableArray *predicates = [NSMutableArray array];
    
    NSPredicate *bracketPred = [NSPredicate predicateWithFormat:@"bracketed = %@", @NO];
    [predicates addObject:bracketPred];
    
    if (predicate) {
        [predicates addObject:predicate];
    }
    
    NSPredicate *fetchPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    self.fetchedResultsController.fetchRequest.predicate = fetchPredicate;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Error updating fetch: %@", error);
    }
    
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
    
    NSMutableArray *predicates = [NSMutableArray array];
    if (self.filterPredicate) {
        [predicates addObject:self.filterPredicate];
    }
    
    NSPredicate *bracketPred = [NSPredicate predicateWithFormat:@"bracketed = %@", @NO];
    [predicates addObject:bracketPred];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *searchDescriptor = [[NSSortDescriptor alloc] initWithKey:@"searchScore" ascending:NO];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shortField"
                                                                   ascending:YES];
    // Sort by decimal number first so 10, 100, 1000 would be in the right order
    NSSortDescriptor *decimalNumberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decimalNumber" ascending:YES];
    
    // Fall back to number string when decimalNumber is the same, e.g. Math Ma and Mb both have decimal number -1, so sorting will fall back to this string comparison descriptor and sort them correctly
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];

    [fetchRequest setSortDescriptors:@[searchDescriptor, sortDescriptor, decimalNumberDescriptor, numberDescriptor]];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
                                          
    _fetchedResultsController = controller;
    
    NSError *error;
    [controller performFetch:&error];
    
    controller.delegate = self;
    
    return controller;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}
    // changes table view sections with changes in core data
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
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
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
