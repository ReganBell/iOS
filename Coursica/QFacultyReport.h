//
//  QFacultyReport.h
//  Coursica
//
//  Created by Regan Bell on 4/20/15.
//  Copyright (c) 2015 Prestige Worldwide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Faculty, QReport;

@interface QFacultyReport : NSManagedObject

@property (nonatomic, retain) NSNumber * overall;
@property (nonatomic, retain) NSNumber * overallBaseline;
@property (nonatomic, retain) NSNumber * lectures;
@property (nonatomic, retain) NSNumber * lecturesBaseline;
@property (nonatomic, retain) NSNumber * accessible;
@property (nonatomic, retain) NSNumber * accessibleBaseline;
@property (nonatomic, retain) NSNumber * enthusiasm;
@property (nonatomic, retain) NSNumber * enthusiasmBaseline;
@property (nonatomic, retain) NSNumber * discussion;
@property (nonatomic, retain) NSNumber * discussionBaseline;
@property (nonatomic, retain) NSNumber * feedback;
@property (nonatomic, retain) NSNumber * feedbackBaseline;
@property (nonatomic, retain) NSNumber * timely;
@property (nonatomic, retain) NSNumber * timelyBaseline;
@property (nonatomic, retain) Faculty *faculty;
@property (nonatomic, retain) QReport *report;

@end
