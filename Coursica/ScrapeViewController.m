//
//  ScrapeViewController.m
//  Coursica
//
//  Created by Regan Bell on 3/23/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "ScrapeViewController.h"
#import "AFNetworking.h"
#import "TFHpple.h"
#import "NSString+HTML.h"
#import "SearchManager.h"
#import "Course.h"
#import "AppDelegate.h"
#import "QReport.h"

@interface ScrapeViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) NSOperationQueue *requestQueue;
@property (assign) NSInteger currentReportIndex;
@property (strong, nonatomic) QReport *currentReport;
@property (strong, nonatomic) NSArray *reports;
@property (strong, nonatomic) NSNumberFormatter *sharedFormatter;

@end

@implementation ScrapeViewController

- (NSNumberFormatter *)sharedFormatter {
    
    if (!_sharedFormatter) {
        _sharedFormatter = [[NSNumberFormatter alloc] init];
    }
    return _sharedFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *requestDict = [defaults objectForKey:@"request"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = [NSURL URLWithString:requestDict[@"url"]];
    NSDictionary *headers = requestDict[@"headers"];
    for (NSString *header in headers) {
        [request setValue:headers[header] forHTTPHeaderField:header];
    }
    request.HTTPBody = requestDict[@"body"];
    request.HTTPMethod = requestDict[@"method"];
    
    NSDictionary *cookieDict = [defaults objectForKey:@"cookie"];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieDict];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"QReport"];
    NSError *error;
    NSArray *reports = [context executeFetchRequest:fetch error:&error];
    if (reports.count == 0 || error) {
        NSLog(@"Error fetching reports. %@", error);
        return;
    }
    
    self.reports = reports;
    self.currentReportIndex = 0;
    
    NSURL *stringURL = [NSURL URLWithString:self.currentReport.url];
                                     
// Use this basic url for getting Q Report URLs
//    NSURL *stringURL = [NSURL URLWithString:@"https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list?yearterm=2014_1"];
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:stringURL]];
}

- (QReport*)currentReport {
    
    return self.reports[self.currentReportIndex];
}

#pragma mark - Save Cookies

- (NSString*)JSStringForScoresOfCategoryAtIndex:(NSUInteger)index {
    
    return [NSString stringWithFormat:@"var headers = document.getElementsByClassName('graphReport'); var tds = headers[%lu].getElementsByTagName('td');var scores = new Array(5); var j = 0; for (var i = 3; i < tds.length; i += 5) {scores[j] = tds[i].innerText; j++;}; scores.toString();", index];
}

- (NSString*)JSStringForMedianScoresOfCategoryAtIndex:(NSUInteger)index {
    
    return [NSString stringWithFormat:@"var headers = document.getElementsByClassName('graphReport');var images = headers[%lu].getElementsByTagName('img');var histobars= []; var j = 0; for (var i = 0; i < images.length; i++) {if (images[i].alt.search('Segments') != -1) histobars[j] = images[i].alt; j++;}; histobars.toString();", index];
}

- (void)scrapeQData {
    
    // Get main five q scores
    NSString *mainScoresJS = [self JSStringForScoresOfCategoryAtIndex:0];
    NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:mainScoresJS];
    NSArray *scores = [self scoresFromJSArrayString:result];

    self.currentReport.overall = scores[0];
    self.currentReport.materials = scores[1];
    self.currentReport.assignments = scores[2];
    self.currentReport.feedback = scores[3];
    self.currentReport.section = scores[4];
    
    NSString *mainCategoryMediansJS = [self JSStringForMedianScoresOfCategoryAtIndex:0];
    result = [self.webview stringByEvaluatingJavaScriptFromString:mainCategoryMediansJS];

    NSArray *medians = [self mediansFromHistogramAltText:result];
    
    self.currentReport.overallMedian = medians[0];
    self.currentReport.materialsMedian = medians[1];
    self.currentReport.assignmentsMedian = medians[2];
    self.currentReport.feedbackMedian = medians[3];
    self.currentReport.sectionMedian = medians[4];
    
    NSString *workloadScoreJS = [self JSStringForScoresOfCategoryAtIndex:1];
    result = [self.webview stringByEvaluatingJavaScriptFromString:workloadScoreJS];
    NSArray *workloadScore = [self scoresFromJSArrayString:result];
    
    self.currentReport.workload = workloadScore[0];
    
    NSString *workloadMedianJS = [self JSStringForMedianScoresOfCategoryAtIndex:1];
    result = [self.webview stringByEvaluatingJavaScriptFromString:workloadMedianJS];
    NSArray *workloadMedian = [self mediansFromHistogramAltText:result];
    
    self.currentReport.workloadMedian = workloadMedian[0];
    
    NSString *recommendScoreJS = [self JSStringForScoresOfCategoryAtIndex:2];
    result = [self.webview stringByEvaluatingJavaScriptFromString:recommendScoreJS];
    NSArray *recommendScore = [self scoresFromJSArrayString:result];
    
    self.currentReport.recommend = recommendScore[0];
    
    NSString *recommendMedianJS = [self JSStringForMedianScoresOfCategoryAtIndex:2];
    result = [self.webview stringByEvaluatingJavaScriptFromString:recommendMedianJS];
    NSArray *recommendMedian = [self mediansFromHistogramAltText:result];
    
    self.currentReport.recommendMedian = recommendMedian[0];
    
    NSString *enrollmentJS = @"document.getElementById('summaryStats').innerText";
    result = [self.webview stringByEvaluatingJavaScriptFromString:enrollmentJS];
    
    self.currentReport.enrollment = [self enrollmentNumberFromRawString:result];
}

// Prints an error message with the context of the current Q report being scraped for debugging
- (void)logErrorMessageWithMessage:(NSString*)message {
    
    Course *failingCourse = self.currentReport.course;
    NSLog(@"\n%@\n%@\nTerm: %@ Year: %@\n%@", message, failingCourse.displayTitle, self.currentReport.term, self.currentReport.year, self.currentReport.url);
}

- (NSNumber*)enrollmentNumberFromRawString:(NSString*)string {
    
    // String comes in looking like 'Enrollment: 34    Evaluations: 32    Response Rate: 94.12%'
    // The spaces between are all non-breaking spaces, so &nbsp; in HTML or option-space in Xcode
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    // Consume 'Enrollment: ' aka everything that comes before the first number
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    
    NSString *enrollmentString;
    // Scan the number until we hit a non-breaking space, this gives us the enrollment number as a string
    [scanner scanUpToString:@" " intoString:&enrollmentString];
    
    NSNumber *enrollmentNumber = [self.sharedFormatter numberFromString:enrollmentString];
    if (!enrollmentNumber) {
        [self logErrorMessageWithMessage:[NSString stringWithFormat:@"Could not turn enrollment string '%@' into a number!", enrollmentString]];
    }
    return enrollmentNumber;
}

- (NSArray*)scoresFromJSArrayString:(NSString*)arrayString {
    
    NSArray *unfiltered = [arrayString componentsSeparatedByString:@","];
    NSArray *scores = [self arrayByFilteringEmptyStringsFromArray:unfiltered];
    if (!arrayString || !scores) {
        [self logErrorMessageWithMessage:@"Error getting scores!"];
    }
    NSMutableArray *numScores = [NSMutableArray array];
    for (NSString *score in scores) {
        NSNumber *numScore = [self.sharedFormatter numberFromString:score];
        if (!numScore) {
            [self logErrorMessageWithMessage:[NSString stringWithFormat:@"Formatter failed to convert string '%@' into a number!", score]];
        }
        [numScores addObject:numScore];
    }
    return numScores;
}

// Must provide array full of strings only
- (NSArray*)arrayByFilteringEmptyStringsFromArray:(NSArray*)array {
    
    return [array filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *string = evaluatedObject;
        return string.length != 0;
    }]];
}

- (NSArray*)mediansFromHistogramAltText:(NSString*)altText {
    
    NSArray *breakdowns = [altText componentsSeparatedByString:@","];
    if (!altText || !breakdowns) {
        [self logErrorMessageWithMessage:@"Error getting median Q Data!"];
    }
    NSArray *filteredBreakdowns = [self arrayByFilteringEmptyStringsFromArray:breakdowns];
    NSMutableArray *medians = [NSMutableArray array];
    for (NSString *breakdown in filteredBreakdowns) {
        //Raw breakdown text looks like 'Segments 0 0 5 5 21 totalling a 100%'
        NSScanner *scanner = [NSScanner scannerWithString:breakdown];
        
        //Consume the 'Segments ' by discarding every char until we hit a number
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
        
        NSString *numbers;
        [scanner scanUpToString:@" totalling" intoString:&numbers];
        
        NSArray *numStringsArray = [numbers componentsSeparatedByString:@" "];
        double sum = 0;
        NSMutableArray *numbersArray = [NSMutableArray array];
        for (NSString *numString in numStringsArray) {
            NSNumber *number = [self.sharedFormatter numberFromString:numString];
            sum += number.doubleValue;
            [numbersArray addObject:number];
        }
        
        double median = 1;
        int total = 0;
        for (NSNumber *number in numbersArray) {
            total += number.intValue;
            if (total > (sum / 2))
                break;
            else if (total == (sum / 2)) {
                median += 0.5;
                break;
            }
            else
                median++;
        }
        [medians addObject:@(median)];
    }
    return [NSArray arrayWithArray:medians];
}

- (void)scrapeUrls {
    
    NSString *js = @"var headers = document.getElementsByClassName(\"course\"); var titles = new Array(headers.length);for (var i = 0; i < headers.length; i++) {titles[i] = new Array(5);} for (var i = 0; i < headers.length; i++) {titles[i][0] = \"*&*\"; titles[i][1] = headers[i].innerText; titles[i][2] = \"*&*\"; titles[i][3] = headers[i].firstElementChild.href; titles[i][4] = \"*&*\"}; titles.toString();";
    NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:js];
    NSArray *comps = [result componentsSeparatedByString:@"*&*,"];
    NSMutableDictionary *courses = [NSMutableDictionary dictionary];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *coursesFetch = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    
    NSError *error = nil;
    NSArray *allCourses = [context executeFetchRequest:coursesFetch error:&error];
    NSMutableDictionary *savedCourses = [NSMutableDictionary dictionary];

    for (Course *course in allCourses) {
        NSString *original = [NSString stringWithFormat:@"%@ %@: %@", course.shortField, course.number, course.title];
        savedCourses[original] = course;
    }
    
    for (int i = 1; i < comps.count; i += 3) {
        NSString * untrimmed = comps[i];
        NSString * trimmed = [untrimmed stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n,"]];
        NSString * untrimmedURL = comps[i+1];
        NSString * trimmedURL = [untrimmedURL stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n,"]];
        courses[trimmed] = trimmedURL;
        
        if (!savedCourses[trimmed]) {
            // TODO: Deal with Not Offered courses
        } else {
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"QReport" inManagedObjectContext:context];
            QReport *report = [[QReport alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
            report.url = trimmedURL;
            Course *course = savedCourses[trimmed];
            [course addqReportsObject:report];
            report.course = course;
            report.term = @(1);
            report.year = @"2014";
        }
        
    }
    [context save:nil];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //
//    NSString *result = [webView stringByEvaluatingJavaScriptFromString:@"var inputs = document.getElementsByClassName(\"course-block-head\");for (var i = 0; i < inputs.length; i++) {inputs[i].click();}"];
//    
    NSTimer *scrapeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(scrapeQData) userInfo:nil repeats:NO];
    
    /*
     
     
     
     
     
     var headers = document.getElementsByClassName("course-block-head");for (var i = 0; i < headers.length; i++) {headers[i].click();}
     var titles = new Array(1313);
     for (var i = 0; i < 1313; i++) {
     titles[i] = new Array(2);
     }
     var headers = document.getElementsByClassName("course");
     for (var i = 0; i < headers.length; i++) {titles[i][0] = headers[i].innerText; titles[i][1] = headers[i].firstElementChild.href}
     titles.toString()
     
     var inputs = document.getElementsByClassName(\"course-block-head\");for (var i = 0; i < inputs.length; i++) {inputs[i].click();}
     
     var titles = new Array(1313);
     for (var i = 0; i < 1313; i++) {
     titles[i] = new Array(2);
     }
     
     for (var i = 0; i < inputs.length; i++) {titles[i][0] = inputs[i].innerText; titles[i][1] = inputs[i].firstElementChild.href}
     
     */
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:webView.request.allHTTPHeaderFields forKey:@"headers"];
    [requestDict setObject:webView.request.URL.description forKey:@"url"];
    if (webView.request.HTTPBody) {
        [requestDict setObject:webView.request.HTTPBody forKey:@"body"];
    }
    [requestDict setObject:webView.request.HTTPMethod forKey:@"method"];
    
    [defaults setValue:requestDict forKey:@"request"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    NSLog(@"%@", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"%@", request.URL);
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieJar cookiesForURL:request.URL];
    if (cookies.count == 0) {
        NSLog(@"No cookies, must auth");
    }
    for (cookie in cookies) {
        NSDictionary *cookieDict = cookie.properties;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:cookieDict forKey:@"cookie"];
    }
    
    return YES;
}

#pragma mark - Misc

- (NSOperationQueue*)requestQueue {
    
    if (!_requestQueue) {
        _requestQueue = [[NSOperationQueue alloc] init];
        [_requestQueue setMaxConcurrentOperationCount:20];
    }
    return _requestQueue;
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
