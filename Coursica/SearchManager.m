//
//  SearchManager.m
//  Coursica
//
//  Created by Regan Bell on 1/25/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import "SearchManager.h"
#import "Course.h"
#import "AppDelegate.h"

@interface SearchManager ()

@property (strong, nonatomic) NSMutableDictionary *titleInvertedIndex;
@property (strong, nonatomic) NSMutableDictionary *fieldInvertedIndex;
@property (strong, nonatomic) NSMutableDictionary *numberInvertedIndex;
@property (strong, nonatomic) NSMutableDictionary *commonAbbrevs;
@property (strong, nonatomic) NSSet *stopWords;
@property (assign) NSInteger coursesCount;

@end

@implementation SearchManager

- (NSMutableDictionary *)titleInvertedIndex {
    
    if (!_titleInvertedIndex) {
        _titleInvertedIndex = [NSMutableDictionary dictionary];
    }
    return _titleInvertedIndex;
}

- (NSMutableDictionary *)fieldInvertedIndex {
    
    if (!_fieldInvertedIndex) {
        _fieldInvertedIndex = [NSMutableDictionary dictionary];
    }
    return _fieldInvertedIndex;
}

- (NSMutableDictionary *)numberInvertedIndex {
    
    if (!_numberInvertedIndex) {
        _numberInvertedIndex = [NSMutableDictionary dictionary];
    }
    return _numberInvertedIndex;
}

- (NSMutableDictionary *)commonAbbrevs {
    
    if (!_commonAbbrevs) {
        
        NSError *error;
        
        NSString *shortString = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ShortFields"] encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        
        NSString *longString = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LongFields"] encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        
        NSArray *shortFields = [shortString componentsSeparatedByString:@",\n"];
        NSArray *longFields = [longString componentsSeparatedByString:@",\n"];
        
        _commonAbbrevs = [NSMutableDictionary dictionary];
        
        int i = 0;
        for (NSString *longField in longFields) {
            NSString *shortField = shortFields[i];
            [_commonAbbrevs setObject:[shortField lowercaseString] forKey:[longField lowercaseString]];
            i++;
        }
        
        NSString *commonString = @"cs:computer science,ec:economics,cb:culture and belief,ai:aesthetic and interpretive understanding,aiu:aesthetic and interpretive understanding,astro:astronomy,bio:biology,lit:literature,comp:computer comparative,sci:science,em:empirical and mathematical reasoning,eps:earth and planetary sciences,es:engineering sciences,er:ethical reasoning,pol:policy politics,hum:humanities,hist:history,kor:korean,lat:latin,med:medical,sls:science of living systems,spu:science of the physical universe,syst:systems,usw:united states in the world";
        
        NSArray *pairs = [commonString componentsSeparatedByString:@","];
        for (NSString *pair in pairs) {
            NSArray *components = [pair componentsSeparatedByString:@":"];
            [_commonAbbrevs setObject:components[1] forKey:components[0]];
        }
    }
    
    return _commonAbbrevs;
}

- (NSSet*)stopWords {
    
    if (!_stopWords) {
        NSString *stopString = @"I,a,about,an,are,as,at,be,by,com,for,from,how,,in,is,it,of,on,or,that,the,this,to,was,what,when,where,who,will,with,the,www";
        _stopWords = [NSSet setWithArray:[stopString componentsSeparatedByString:@","]];
    }
    return _stopWords;
}

- (void)addCourseToSearchIndex:(Course*)course {
    
    [self addField:course.longField toIndex:self.fieldInvertedIndex fromCourse:course];
    [self addField:course.title toIndex:self.titleInvertedIndex fromCourse:course];
    
    double decimalNumber = course.decimalNumber.doubleValue;
    if (decimalNumber > 0) {
        [self addField:[NSString stringWithFormat:@"%0.f", decimalNumber] toIndex:self.numberInvertedIndex fromCourse:course];
    }
    [self addField:course.number toIndex:self.numberInvertedIndex fromCourse:course ignoreStopWords:NO];
}

- (void)addField:(NSString*)field toIndex:(NSMutableDictionary*)index fromCourse:(Course*)course {
    
    [self addField:field toIndex:index fromCourse:course ignoreStopWords:YES];
}

- (void)addField:(NSString*)field toIndex:(NSMutableDictionary*)index fromCourse:(Course*)course ignoreStopWords:(BOOL)ignoreStopWords {
    
    NSArray *fieldTerms = [field componentsSeparatedByString:@" "];
    for (NSString *unique in fieldTerms) {
        
        NSString *term = [unique lowercaseString];
        // If term is a common word like "and", "the" we don't count it
        if ([self.stopWords containsObject:term] && ignoreStopWords) {
            continue;
        }
        NSMutableDictionary *termDict = index[term];
        if (termDict) {
            NSNumber *occurences = termDict[@"n"];
            termDict[@"n"] = @(occurences.intValue + 1);
        } else {
            termDict = [NSMutableDictionary dictionary];
            termDict[@"n"] = @1;
        }
        
        NSMutableArray *termCourses = termDict[@"courses"];
        if (termCourses.count == 0) {
            termCourses = [NSMutableArray array];
            [termCourses addObject:course];
        } else {
            [termCourses addObject:course];
        }
        termDict[@"courses"] = termCourses;
        index[term] = termDict;
    }
}

- (void)calculateIDFs {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *coursesFetch = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    
    NSError *error;
    NSInteger count = [context countForFetchRequest:coursesFetch error:&error];
    
    if (count == 0 || error) {
        NSLog(@"Error calculating IDFs: 0 articles found or %@", error);
    }
    
    self.coursesCount = count;
    
    [self calculateIDFsForIndex:self.titleInvertedIndex];
    [self calculateIDFsForIndex:self.fieldInvertedIndex];
    [self calculateIDFsForIndex:self.numberInvertedIndex];
}

- (void)calculateIDFsForIndex:(NSMutableDictionary*)index {
    
    for (NSString *term in index) {
        
        NSMutableDictionary *termDict = index[term];
        NSNumber *occurences = termDict[@"n"];
        double idf = log(self.coursesCount / occurences.doubleValue);
        termDict[@"idf"] = @(idf);
    }
}

- (void)searchInIndex:(NSMutableDictionary*)index forTerms:(NSArray*)searchTerms withZoneWeight:(double)zoneWeight results:(NSMutableDictionary*)results {
    
    for (NSString *term in searchTerms) {
        
        NSString *lowercase = [term lowercaseString];
        NSMutableDictionary *termDict = index[lowercase];
        if (!termDict) {
            continue;
        }
        
        NSNumber *idfNum = termDict[@"idf"];
        double idf = idfNum.doubleValue;
        double maxIdf = log(self.coursesCount / 1.0);
        double normalizeFactor = 1.0 / maxIdf;
        double normalizedScore = idf * normalizeFactor;
        double zonedScore = normalizedScore * zoneWeight;
        
        for (Course *course in termDict[@"courses"]) {
            
            NSDictionary *result = results[course.objectID];
            NSNumber *newScore;
            if (result) {
                NSNumber *oldScore = result[@"score"];
                newScore = @(oldScore.doubleValue + zonedScore);
            } else {
                newScore = @(zonedScore);
            }
            
            results[course.objectID] = @{@"score":newScore, @"course":course};
        }
    }
}

- (NSArray *)coursesForSearch:(NSString *)search {
    
    NSMutableArray *searchTerms = [NSMutableArray arrayWithArray:[search componentsSeparatedByString:@" "]];
    NSInteger count = searchTerms.count;
    for (int i = 0; i < count; i++) {
        
        NSString *expansion = self.commonAbbrevs[searchTerms[i]];
        if (expansion.length != 0) {
            NSArray *newTerms = [expansion componentsSeparatedByString:@" "];
            [searchTerms removeObjectAtIndex:i];
            count--;
            for (NSString *newTerm in newTerms) {
                [searchTerms insertObject:newTerm atIndex:0];
                i++;
                count++;
            }
        }
    }
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    [self searchInIndex:self.fieldInvertedIndex forTerms:searchTerms withZoneWeight:0.3 results:results];
    [self searchInIndex:self.titleInvertedIndex forTerms:searchTerms withZoneWeight:0.3 results:results];
    [self searchInIndex:self.numberInvertedIndex forTerms:searchTerms withZoneWeight:0.3 results:results];
    
    NSMutableArray *unsorted = [NSMutableArray array];
    
    for (NSString *catNum in results) {
        [unsorted addObject:[results objectForKey:catNum]];
    }
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO];
    
    NSArray *sortedResults = [unsorted sortedArrayUsingDescriptors:@[descriptor]];
    for (NSDictionary *result in sortedResults) {
        Course *course = result[@"course"];
        NSLog(@"\n%@ %@ - %@\n%@", course.shortField, course.number, course.title, result[@"score"]);
    }
    return sortedResults;
}

+ (SearchManager *)sharedSearchManager {
    static SearchManager *sharedSearchManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSearchManager = [[self alloc] init];
        [sharedSearchManager]
    });
    return sharedSearchManager;
}

@end
