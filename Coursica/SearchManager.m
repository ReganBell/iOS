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
@property (strong, nonatomic) NSArray *allCourses;
@property (strong, nonatomic) NSLinguisticTagger *sharedTagger;
@property NSUInteger disagreements;

@end

@implementation SearchManager

- (NSLinguisticTagger*)sharedTagger {
    
    if (!_sharedTagger) {
        NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation;
        _sharedTagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
    }
    return _sharedTagger;
}

- (void)setUp {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *coursesFetch = [NSFetchRequest fetchRequestWithEntityName:@"Course"];
    
    self.disagreements = 0;
    
    NSError *error = nil;
    self.allCourses = [context executeFetchRequest:coursesFetch error:&error];
    for (Course *course in self.allCourses) {

        [self addCourseToSearchIndex:course];
    }
    [self calculateIDFs];
}

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
        
        NSMutableDictionary *abbrevs = [NSMutableDictionary dictionary];
        
        int i = 0;
        for (NSString *longField in longFields) {
            NSString *shortField = shortFields[i];
            
            abbrevs[shortField.lowercaseString] = longField.lowercaseString;
            i++;
        }
        
        NSString *commonString = @"cs:computer science,ec:economics,cb:culture and belief,ai:aesthetic and interpretive understanding,aiu:aesthetic and interpretive understanding,astro:astronomy,bio:biology,lit:literature,comp:computer comparative,sci:science,em:empirical and mathematical reasoning,eps:earth and planetary sciences,es:engineering sciences,er:ethical reasoning,pol:policy politics,hum:humanities,hist:history,kor:korean,lat:latin,med:medical,sls:science of living systems,spu:science of the physical universe,syst:systems,usw:united states in the world,ls:life sciences";
        
        NSArray *pairs = [commonString componentsSeparatedByString:@","];
        for (NSString *pair in pairs) {
            NSArray *components = [pair componentsSeparatedByString:@":"];
            abbrevs[components[0]] = components[1];
        }
        _commonAbbrevs = abbrevs;
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
    
    if (!course.longField)
        course.longField = self.commonAbbrevs[course.shortField.lowercaseString];
    
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
    
    NSMutableArray *fastFieldTerms = [NSMutableArray array];
    NSMutableString *currentString = [NSMutableString string];
    const char *primitiveField = field.UTF8String;
    char primitiveBuffer[field.length];
    char *primitiveString = &primitiveBuffer;
    int tokenIndex = 0;
    for (int i = 0; i < field.length; i++) {
        char character = tolower(primitiveField[i]);
        
        if (character == ':' || character == ',' || character == '"' || character == '?' || character == '&' || character == '(' || character == ')'
            || character == '!' || character == '\'') {
            continue;
        }
        
        if (character == '.' || character == ' ') {
            if (i + 1 < field.length) {
                char next = primitiveField[i+1];
                if (next == ' ') {
                    if (currentString.length) {
                        [fastFieldTerms addObject:currentString];
                    }
                    currentString = [NSMutableString string];
                    i++;
                    continue;
                }
                if (next == '.') {
                    continue;
                }
            }
        }
        
        if (character == ' ' || character == '/' || character == '-') {
            int length = tokenIndex;
            char *token = calloc(length, 1);
            strncpy(token, primitiveString, length);
            NSString *tokenString = [NSString stringWithUTF8String:token];
            if (tokenString.length) {
                [fastFieldTerms addObject:tokenString];
            }
            free(token);
            tokenIndex = 0;
            continue;
        }
        primitiveString[tokenIndex] = character;
        tokenIndex++;
        
        if (i == field.length - 1) {
            int length = tokenIndex;
            char *token = calloc(length, 1);
            strncpy(token, primitiveString, length);
            NSString *tokenString = [NSString stringWithUTF8String:token];
            if (tokenString.length) {
                [fastFieldTerms addObject:tokenString];
            }
            free(token);
            tokenIndex = 0;
        }
    }
    int length = tokenIndex;
    if (length) {
        char *token = calloc(length, 1);
        strncpy(token, primitiveString, length);
        [fastFieldTerms addObject:[NSString stringWithUTF8String:token]];
    }

//    if (![[fieldTerms componentsJoinedByString:@" "].lowercaseString isEqualToString:[fastFieldTerms componentsJoinedByString:@" "]]) {
//        self.disagreements++;
//        NSLog(@"%ld", self.disagreements);
//        NSLog(@"%@", [fieldTerms componentsJoinedByString:@" "].lowercaseString);
//        NSLog(@"%@", [fastFieldTerms componentsJoinedByString:@" "]);
//    }
    
    for (NSString *unique in fastFieldTerms) {
        
        NSString *term = unique;
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

- (void)numberSearchForNumber:(NSString*)search results:(NSMutableDictionary*)results {
    
    
}

- (void)searchInIndex:(NSMutableDictionary*)index forTerms:(NSArray*)searchTerms withZoneWeight:(double)zoneWeight results:(NSMutableDictionary*)results {
    
    NSString *indexString = @"";
    if (index == self.titleInvertedIndex) {
        indexString = @"title";
    } else if (index == self.numberInvertedIndex) {
        indexString = @"number";
    } else if (index == self.fieldInvertedIndex) {
        indexString = @"field";
    } else
        indexString = @"default";
    
    for (NSString *term in searchTerms) {
        
        NSMutableDictionary *termDict = index[term.lowercaseString];
        // If term doesn't exist in the indexes, it doesn't match any course
        if (!termDict) {
            continue;
        }
        
        NSNumber *idfNum = termDict[@"idf"];
        double idf = idfNum.doubleValue;
        double maxIdf = log(self.coursesCount / 1.0);
        double normalizeFactor = 1.0 / maxIdf;
        double normalizedScore = idf * normalizeFactor;
        double zonedScore = normalizedScore * zoneWeight;
        NSArray *courses = termDict[@"courses"];
        
        for (Course *course in courses) {
            
//            NSLog(@"Course '%@' matched index '%@' on '%@'\n Adding %f", course.displayTitle, indexString, term, zonedScore);
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

- (void)clearSearchScores {
    
    for (Course *course in self.allCourses) {
        course.searchScore = @0;
    }
}

- (void)assignScoresForSearch:(NSString *)search {
    
    [self clearSearchScores];
    
    NSMutableArray *searchTerms = [NSMutableArray arrayWithArray:[search componentsSeparatedByString:@" "]];
    
    NSRegularExpression *numRegEx = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:nil];
    NSRegularExpression *wordRegEx = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]+" options:0 error:nil];
    
    NSInteger count = searchTerms.count;
    for (int i = 0; i < count; i++) {
        
        NSString *term = searchTerms[i];
        
        // Check if they've written something like "ec10" or "cs50" which our search doesn't like
        NSRegularExpression *squishRegEx = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z]+[0-9]+" options:0 error:nil];
        NSArray *matches = [squishRegEx matchesInString:term options:0 range:NSMakeRange(0, term.length)];
        
        if (matches.count > 0) {
            
            NSTextCheckingResult *match = matches.firstObject;
            NSString *matchString = [term substringWithRange:match.range];
            NSTextCheckingResult *word = [wordRegEx matchesInString:matchString options:0 range:NSMakeRange(0, matchString.length)].firstObject;
            NSString *wordString = [matchString substringWithRange:word.range];
            NSString *restString = [term stringByReplacingOccurrencesOfString:wordString withString:@""];
            [searchTerms removeObjectAtIndex:i];
            [searchTerms addObject:wordString];
            [searchTerms addObject:restString];
            count++;
            i--;
            continue;
        }
        
        NSString *expansion = self.commonAbbrevs[term.lowercaseString];
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
    
//    NSLog(@"Searching for %@", searchTerms);
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    
    NSArray *numbers = [numRegEx matchesInString:search options:0 range:NSMakeRange(0, search.length)];
    
    //TODO: do a weaker match for the stems of words, using nslinguistictagger
    
    if (numbers.count) {
        
        [self searchInIndex:self.fieldInvertedIndex forTerms:searchTerms withZoneWeight:0.6 results:results];
        [self searchInIndex:self.titleInvertedIndex forTerms:searchTerms withZoneWeight:0.3 results:results];
        [self searchInIndex:self.numberInvertedIndex forTerms:searchTerms withZoneWeight:0.6 results:results];
        
    } else {
    
        [self searchInIndex:self.fieldInvertedIndex forTerms:searchTerms withZoneWeight:0.3 results:results];
        [self searchInIndex:self.titleInvertedIndex forTerms:searchTerms withZoneWeight:0.3 results:results];
        [self searchInIndex:self.numberInvertedIndex forTerms:searchTerms withZoneWeight:0.3 results:results];
    }


    NSMutableArray *unsorted = [NSMutableArray array];
    
    for (NSString *catNum in results) {
        [unsorted addObject:[results objectForKey:catNum]];
    }
    
    for (NSDictionary *result in unsorted) {
        Course *course = result[@"course"];
        course.searchScore = result[@"score"];
    }
    
    // Uncomment to debug search
//    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO];
//    
//    NSArray *sortedResults = [unsorted sortedArrayUsingDescriptors:@[descriptor]];
    
//    for (NSDictionary *result in sortedResults) {
//        Course *course = result[@"course"];
////        NSLog(@"\n%@ %@ - %@\n%@", course.shortField, course.number, course.title, result[@"score"]);
//    }
}

+ (SearchManager *)sharedSearchManager {
    static SearchManager *sharedSearchManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSearchManager = [[self alloc] init];
        [sharedSearchManager setUp];
    });
    return sharedSearchManager;
}

@end
