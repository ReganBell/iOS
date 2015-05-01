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
#import "Faculty.h"
#import "QFacultyReport.h"

typedef enum {

    ScrapeStateAuth,
    ScrapeStateMain,
    ScrapeStateInstructorComplete,
    ScrapeStateInstructorIncomplete,
    ScrapeStateCommentLoad, //You have to load the comments page, and then grab a specific url from it to load actual comments
    ScrapeStateComment,
    ScrapeStateURLs

} ScrapeState;

@interface ScrapeViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) NSOperationQueue *requestQueue;
@property (assign) NSInteger currentReportIndex;
@property (strong, nonatomic) QReport *currentReport;
@property (strong, nonatomic) NSArray *reports;
@property (strong, nonatomic) NSNumberFormatter *sharedFormatter;
@property (assign) ScrapeState state;
@property (strong, nonatomic) NSMutableDictionary *facultyDict;

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
//    fetch.predicate = [NSPredicate predicateWithFormat:@"year = 2013 AND overall = 0.0"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"comments != nil AND year = 2014"];
    NSError *error;
    NSArray *reports = [context executeFetchRequest:fetch error:&error];
    if (reports.count == 0 || error) {
        NSLog(@"Error fetching reports! %@", error);
        return;
    }
    [self writeQReportsToFile:reports];
    
    NSFetchRequest *faculty = [NSFetchRequest fetchRequestWithEntityName:@"Faculty"];
    NSArray *facultyArray = [context executeFetchRequest:faculty error:&error];
    
    NSMutableDictionary *facultyDict = [NSMutableDictionary dictionary];
    for (Faculty *faculty in facultyArray) {
        NSString *key = [NSString stringWithFormat:@"%@ %@", faculty.first, faculty.last];
        if ([faculty.middle isEqualToString:@" "]) {
            faculty.middle = @"";
        }
        Faculty *existing = facultyDict[key];
        if (existing) {
            [existing addCourses:faculty.courses];
            [context deleteObject:faculty];
        }
        facultyDict[key] = faculty;
    }
    
    [context save:nil];
    self.facultyDict = facultyDict;
    
    if (facultyArray.count == 0 || error) {
        NSLog(@"Error fetching faculty! %@", error);
        return;
    }
    
    self.reports = reports;
    self.currentReportIndex = 0;
    
    NSURL *stringURL = [NSURL URLWithString:self.currentReport.url];
                                     
// Use this basic url for getting Q Report URLs
//    NSURL *stringURL = [NSURL URLWithString:@"https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list?yearterm=2014_1"];
    
    self.state = ScrapeStateMain;
    [self.webview loadRequest:[NSURLRequest requestWithURL:stringURL]];
}

- (void)writeQReportsToFile:(NSArray*)reports {
    
    NSMutableString *fileString = [NSMutableString string];
    
    for (QReport *report in reports) {
        
        [fileString appendFormat:@"%@</title>", report.course.displayTitle];
        
        NSArray *untrimmed = [self arrayByFilteringEmptyStringsFromArray:[report.comments componentsSeparatedByString:@"#c#"]];
        
        NSMutableCharacterSet *trimChars = [NSMutableCharacterSet characterSetWithCharactersInString:@","];
        [trimChars formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        for (NSString *comment in untrimmed) {
            NSString *tidyString = [comment stringByTrimmingCharactersInSet:trimChars];
            [fileString appendFormat:@"%@</comment>", tidyString];
        }
        
        [fileString appendString:@"</course>"];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = paths[0];
    
    NSString *emptyString = @"";
    NSError *error;
    [emptyString writeToFile:[documents stringByAppendingString:@"QData"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    // get a handle to the file
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:[documents stringByAppendingString:@"QData"]];
    
    // convert the string to an NSData object
    NSData *textData = [fileString dataUsingEncoding:NSUTF8StringEncoding];
    
    // write the data to the end of the file
    [fileHandle writeData:textData];
    
    // clean up
    [fileHandle closeFile];
    
    NSLog(@"Wrote to %@", [documents stringByAppendingString:@"/QData"]);
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

- (id)safeObjectAtIndex:(NSUInteger)index inArray:(NSArray*)array fallback:(id)fallback {
    
    if (index >= array.count) {
        [self logErrorMessageWithMessage:[NSString stringWithFormat:@"Index %lu out of bounds of array size %lu!", index, array.count]];
        return fallback;
    } else
        return array[index];
}

- (void)scrapeQData {
    
    // Get main five q scores
    NSString *mainScoresJS = [self JSStringForScoresOfCategoryAtIndex:0];
    NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:mainScoresJS];
    NSArray *scores = [self scoresFromJSArrayString:result];

    self.currentReport.overall = [self safeObjectAtIndex:0 inArray:scores fallback:@(-1)];
    self.currentReport.materials = [self safeObjectAtIndex:1 inArray:scores fallback:@(-1)];
    self.currentReport.assignments = [self safeObjectAtIndex:2 inArray:scores fallback:@(-1)];
    self.currentReport.feedback = [self safeObjectAtIndex:3 inArray:scores fallback:@(-1)];
    self.currentReport.section = [self safeObjectAtIndex:4 inArray:scores fallback:@(-1)];
    
    NSString *mainCategoryMediansJS = [self JSStringForMedianScoresOfCategoryAtIndex:0];
    result = [self.webview stringByEvaluatingJavaScriptFromString:mainCategoryMediansJS];

    NSArray *medians = [self mediansFromHistogramAltText:result];
    
    self.currentReport.overallMedian = [self safeObjectAtIndex:0 inArray:scores fallback:@(-1)];
    self.currentReport.materialsMedian = [self safeObjectAtIndex:1 inArray:scores fallback:@(-1)];
    self.currentReport.assignmentsMedian = [self safeObjectAtIndex:2 inArray:scores fallback:@(-1)];
    self.currentReport.feedbackMedian = [self safeObjectAtIndex:3 inArray:scores fallback:@(-1)];
    self.currentReport.sectionMedian = [self safeObjectAtIndex:4 inArray:scores fallback:@(-1)];
    
    NSString *workloadScoreJS = [self JSStringForScoresOfCategoryAtIndex:1];
    result = [self.webview stringByEvaluatingJavaScriptFromString:workloadScoreJS];
    NSArray *workloadScore = [self scoresFromJSArrayString:result];
    
    self.currentReport.workload = [self safeObjectAtIndex:0 inArray:workloadScore fallback:@(-1)];
    
    NSString *workloadMedianJS = [self JSStringForMedianScoresOfCategoryAtIndex:1];
    result = [self.webview stringByEvaluatingJavaScriptFromString:workloadMedianJS];
    NSArray *workloadMedian = [self mediansFromHistogramAltText:result];
    
    self.currentReport.workloadMedian = [self safeObjectAtIndex:0 inArray:workloadMedian fallback:@(-1)];
    
    NSString *recommendScoreJS = [self JSStringForScoresOfCategoryAtIndex:2];
    result = [self.webview stringByEvaluatingJavaScriptFromString:recommendScoreJS];
    NSArray *recommendScore = [self scoresFromJSArrayString:result];
    
    self.currentReport.recommend = [self safeObjectAtIndex:0 inArray:recommendScore fallback:@(-1)];
    
    NSString *recommendMedianJS = [self JSStringForMedianScoresOfCategoryAtIndex:2];
    result = [self.webview stringByEvaluatingJavaScriptFromString:recommendMedianJS];
    NSArray *recommendMedian = [self mediansFromHistogramAltText:result];
    
    self.currentReport.recommendMedian = [self safeObjectAtIndex:0 inArray:recommendMedian fallback:@(-1)];
    
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

- (void)scrapeInstructors {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSEntityDescription *facultyReportEntity = [NSEntityDescription entityForName:@"QFacultyReport" inManagedObjectContext:context];
    QFacultyReport *facultyReport = [[QFacultyReport alloc] initWithEntity:facultyReportEntity insertIntoManagedObjectContext:context];
    
    NSEntityDescription *facultyEntity = [NSEntityDescription entityForName:@"Faculty" inManagedObjectContext:context];
    
    NSString *nameJS = @"document.getElementsByClassName('instructor')[0].innerText";
    NSString *rawName = [self.webview stringByEvaluatingJavaScriptFromString:nameJS];
    NSDictionary *names = [self namesFromRawNameString:rawName];
    if (!names) {
        
        // Some courses do not have an instructor, e.g. tutorials
        self.state = ScrapeStateInstructorComplete;
        return;
    }
    Faculty *faculty = self.facultyDict[names[@"key"]];
    if (!faculty) {
        faculty = [[Faculty alloc] initWithEntity:facultyEntity insertIntoManagedObjectContext:context];
        faculty.first = names[@"first"];
        faculty.middle = names[@"middle"];
        faculty.last = names[@"last"];
    }
    facultyReport.faculty = faculty;
    
    NSString *scoresJS = [self JSStringForScoresOfCategoryAtIndex:0];
    NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:scoresJS];
    NSArray *scores = [self scoresFromJSArrayString:result];
    
    facultyReport.overall = [self safeObjectAtIndex:0 inArray:scores fallback:@(-1)];
    facultyReport.lectures = [self safeObjectAtIndex:1 inArray:scores fallback:@(-1)];
    facultyReport.accessible = [self safeObjectAtIndex:2 inArray:scores fallback:@(-1)];
    facultyReport.enthusiasm = [self safeObjectAtIndex:3 inArray:scores fallback:@(-1)];
    facultyReport.discussion = [self safeObjectAtIndex:4 inArray:scores fallback:@(-1)];
    facultyReport.feedback = [self safeObjectAtIndex:5 inArray:scores fallback:@(-1)];
    facultyReport.timely = [self safeObjectAtIndex:6 inArray:scores fallback:@(-1)];
    
    [self.currentReport addFacultyReportsObject:facultyReport];
    
    NSString *instructorsJS = @"var elements = document.getElementById('subHeader').getElementsByTagName('option'); var names = []; var j = 0; for (var i = 0; i < elements.length; i++) {names[i+j] = elements[i].innerText; names[i+j+1] = '###'; j++} names.toString();";
    NSString *instructorsRaw = [self.webview stringByEvaluatingJavaScriptFromString:instructorsJS];
    NSArray *unfiltered = [instructorsRaw componentsSeparatedByString:@"###"];
    NSArray *instructors = [self arrayByFilteringEmptyStringsFromArray:unfiltered];
    if ([rawName isEqualToString:[instructors lastObject]] || self.currentReport.facultyReports.count == instructors.count) {
        self.state = ScrapeStateInstructorComplete;
    } else {
        [self selectInstructorAtIndex:self.currentReport.facultyReports.count];
    }
}
         
- (void)selectInstructorAtIndex:(NSUInteger)index {
    
    NSString *selectString = [NSString stringWithFormat:@"var option = document.getElementById('subHeader').getElementsByTagName('option')[%lu]; option.selected = true;", index];
    NSString *js = [NSString stringWithFormat:@"%@ var inputs = document.getElementsByTagName('input');for (var i = 0; i < inputs.length; i++) {if(inputs[i].type.toLowerCase() == 'submit') {inputs[i].click()}}", selectString];
    [self.webview stringByEvaluatingJavaScriptFromString:js];
}

- (NSDictionary*)namesFromRawNameString:(NSString*)rawString {
    
    NSArray *unfiltered = [rawString componentsSeparatedByString:@","];
    NSArray *components = [self arrayByFilteringEmptyStringsFromArray:unfiltered];
    if (components.count != 2) {
        [self logErrorMessageWithMessage:@"Couldn't get name from raw string '%@'!"];
        return nil;
    }
    
    NSMutableDictionary *namesDict = [NSMutableDictionary dictionary];
    namesDict[@"last"] = components[0];
    NSString *remainder = components[1];
    unfiltered = [remainder componentsSeparatedByString:@" "];
    NSArray *firstMiddle = [self arrayByFilteringEmptyStringsFromArray:unfiltered];
    
    if (firstMiddle.count == 0 || firstMiddle.count > 2) {
        [self logErrorMessageWithMessage:@"Couldn't get name from first-middle '%@'!"];
        return nil;
    }
    
    namesDict[@"first"] = firstMiddle[0];
    
    if (firstMiddle.count == 2)
        namesDict[@"middle"] = firstMiddle[1];
    
    namesDict[@"key"] = [NSString stringWithFormat:@"%@ %@", namesDict[@"first"], namesDict[@"last"]];
    
    return [NSDictionary dictionaryWithDictionary:namesDict];
}

- (void)scrapeComments {
    
    NSString *commentsJS = @"var elements = document.getElementsByClassName('response');var comments = []; var j = 0; for (var i = 0; i < elements.length; i++) {comments[j] = '#c#'; comments[j+1] = elements[i].innerText; j += 2}; comments.toString();";
    NSString *rawComments = [self.webview stringByEvaluatingJavaScriptFromString:commentsJS];
    if (rawComments.length == 0) {
        [self logErrorMessageWithMessage:@"Could not extract any comments!"];
    } else
        self.currentReport.comments = rawComments;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    //Flow: ScrapeStateMain -> ScrapeStateCommenLoad -> ScrapeStateComment -> ScrapeStateInstructor -> next
    
    switch (self.state) {
        case ScrapeStateComment: {
            [self scrapeComments];
            NSString *instructorURLJS = @"document.getElementById('tabNav').getElementsByTagName('a')[1].href";
            NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:instructorURLJS];
            NSURL *instructorURL = [NSURL URLWithString:result];
            self.state = ScrapeStateInstructorIncomplete;
            self.currentReport.facultyReports = nil;
            [self.webview loadRequest:[NSURLRequest requestWithURL:instructorURL]];
            break;
        }
        case ScrapeStateCommentLoad: {
            NSString *commentURLString = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('reportContent').getElementsByTagName('a')[0].href"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:commentURLString]];
            self.state = ScrapeStateComment;
            [self.webview loadRequest:request];
            break;
        }
        case ScrapeStateMain: {
            [self scrapeQData];
            NSString *commentURLJS = @"document.getElementById('tabNav').getElementsByTagName('a')[2].href";
            NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:commentURLJS];
            NSURL *commentURL = [NSURL URLWithString:result];
            self.state = ScrapeStateCommentLoad;
            [self.webview loadRequest:[NSURLRequest requestWithURL:commentURL]];
            break;
        }
        case ScrapeStateURLs: {
            // Running this javascript clicks on every department header to expose all of the course links
            [webView stringByEvaluatingJavaScriptFromString:@"var inputs = document.getElementsByClassName('course-block-head');for (var i = 0; i < inputs.length; i++) {inputs[i].click();}"];
            // We wait a few seconds for all of the links to load
            [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(scrapeUrls) userInfo:nil repeats:NO];
            break;
        }
        case ScrapeStateInstructorIncomplete: {
            
            [self scrapeInstructors];
            
            if (self.state == ScrapeStateInstructorComplete) {
                self.currentReportIndex++;
                if (self.currentReportIndex < self.reports.count) {
                    self.state = ScrapeStateMain;
                    
                    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
                    NSManagedObjectContext *context = delegate.managedObjectContext;
                    NSError *error = nil;
                    [context save:&error];
                    if (error) {
                        [self logErrorMessageWithMessage:@"Error saving context!"];
                    } else {
                        NSLog(@"Report #%lu scraped", self.currentReportIndex);
                    }
                    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.currentReport.url]]];
                }
            }
            break;
        }
        default:
            break;
    }
    
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
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:webView selector:@selector(reload) userInfo:nil repeats:NO];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieJar cookiesForURL:request.URL];
    if (cookies.count == 0) {
        NSLog(@"No cookies, must auth");
        self.state = ScrapeStateAuth;
    }
    if (self.state == ScrapeStateAuth && cookies.count > 0) {
        self.state = ScrapeStateMain;
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
