//
//  QReport.h
//  Coursica
//
//  Created by Regan Bell on 4/20/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface QReport : NSManagedObject

@property (nonatomic, retain) NSNumber * term;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSNumber * enrollment;
@property (nonatomic, retain) NSNumber * overall;
@property (nonatomic, retain) NSNumber * overallBaseline;
@property (nonatomic, retain) NSString * overallBreakdown;
@property (nonatomic, retain) NSNumber * overallMedian;
@property (nonatomic, retain) NSNumber * materials;
@property (nonatomic, retain) NSNumber * materialsBaseline;
@property (nonatomic, retain) NSString * materialsBreakdown;
@property (nonatomic, retain) NSNumber * materialsMedian;
@property (nonatomic, retain) NSNumber * assignments;
@property (nonatomic, retain) NSNumber * assignmentsBaseline;
@property (nonatomic, retain) NSString * assignmentsBreakdown;
@property (nonatomic, retain) NSNumber * assignmentsMedian;
@property (nonatomic, retain) NSNumber * feedback;
@property (nonatomic, retain) NSNumber * feedbackBaseline;
@property (nonatomic, retain) NSString * feedbackBreakdown;
@property (nonatomic, retain) NSNumber * feedbackMedian;
@property (nonatomic, retain) NSNumber * section;
@property (nonatomic, retain) NSNumber * sectionBaseline;
@property (nonatomic, retain) NSString * sectionBreakdown;
@property (nonatomic, retain) NSNumber * sectionMedian;
@property (nonatomic, retain) NSNumber * workload;
@property (nonatomic, retain) NSNumber * workloadBaseline;
@property (nonatomic, retain) NSString * workloadBreakdown;
@property (nonatomic, retain) NSNumber * workloadMedian;
@property (nonatomic, retain) NSNumber * recommend;
@property (nonatomic, retain) NSNumber * recommendBaseline;
@property (nonatomic, retain) NSString * recommendBreakdown;
@property (nonatomic, retain) NSNumber * recommendMedian;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) Course *course;
@property (nonatomic, retain) NSSet *facultyReports;

@end

@interface QReport (CoreDataGeneratedAccessors)

- (void)addFacultyReportsObject:(NSManagedObject *)value;
- (void)removeFacultyReportsObject:(NSManagedObject *)value;
- (void)addFacultyReports:(NSSet *)values;
- (void)removeFacultyReports:(NSSet *)values;

@end
