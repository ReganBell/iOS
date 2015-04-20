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

@interface ScrapeViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (strong, nonatomic) NSOperationQueue *requestQueue;

@end

@implementation ScrapeViewController

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
    
//    NSURL *base = [NSURL URLWithString:@"https://webapps.fas.harvard.edu"];
//    
//    NSURL *url = [NSURL URLWithString:@"/course_evaluation_reports/fas/list?yearterm=2013_2" relativeToURL:base];
    
    NSURL *stringURL = [NSURL URLWithString:@"https://webapps.fas.harvard.edu/course_evaluation_reports/fas/list?yearterm=2013_2"];
//    NSURLRequest *courseList = [NSURLRequest requestWithURL:url];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        [self createCoursesFromResultsPageData:responseObject];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//    
//    [self.requestQueue addOperation:operation];
    
//    NSURLSession *session = [NSURLSession sharedSession];
//    [[session dataTaskWithURL:[NSURL URLWithString:@"/course_evaluation_reports/fas/list?yearterm=2013_2" relativeToURL:base]
//            completionHandler:^(NSData *data,
//                                NSURLResponse *response,
//                                NSError *error) {
//                
//                
//                
//            }] resume];
    
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:stringURL]];
}

//- (void)createCoursesFromResultsPageData:(id)pageData {
//    
//    TFHpple *coursesPage = [TFHpple hppleWithHTMLData:pageData];
//    
//    NSString *courseLinkXPath = @"//span[@class='qtip-link']/a";
//    NSArray *courseLinks = [coursesPage searchWithXPathQuery:courseLinkXPath];
//    
//    for (TFHppleElement *linkElement in courseLinks) {
//        
//        NSString *linkString = linkElement.attributes[@"href"];
//        
//        NSURL *url = [NSURL URLWithString:linkString];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//        
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            NSLog(@"dl'ed %@", linkString);
//            [self createCourseFromCoursePageData:responseObject];
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
//        
//        [self.requestQueue addOperation:operation];
//    }
//}

#pragma mark - Save Cookies

- (void)scrapeUrls {
    
    NSString *js = @"var headers = document.getElementsByClassName(\"course\"); var titles = new Array(1313);for (var i = 0; i < 1313; i++) {titles[i] = new Array(5);} for (var i = 0; i < headers.length; i++) {titles[i][0] = \"*&*\"; titles[i][1] = headers[i].innerText; titles[i][2] = \"*&*\"; titles[i][3] = headers[i].firstElementChild.href; titles[i][4] = \"*&*\"}; titles.toString();";
    NSString *result = [self.webview stringByEvaluatingJavaScriptFromString:js];
    NSArray *comps = [result componentsSeparatedByString:@"*&*,"];
    NSMutableDictionary *courses = [NSMutableDictionary dictionary];
    for (int i = 1; i < comps.count; i += 3) {
        NSString * untrimmed = comps[i];
        NSString * trimmed = [untrimmed stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n,"]];
        NSString * untrimmedURL = comps[i+1];
        NSString * trimmedURL = [untrimmedURL stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n,"]];
        courses[trimmed] = trimmedURL;
        
        Course *match = [[[SearchManager sharedSearchManager] coursesForSearch:trimmed] firstObject];
        
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:@"var inputs = document.getElementsByClassName(\"course-block-head\");for (var i = 0; i < inputs.length; i++) {inputs[i].click();}"];
    
    NSTimer *scrapeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scrapeUrls) userInfo:nil repeats:NO];
    
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
