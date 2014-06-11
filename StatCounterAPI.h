//
//  StatCounterAPI.h
//  StatCounterApp
//
//  Provides an Objective-C interface to the StatCounter API
//  Data is returned as a NSDictionary, and can be accessed by key same as the API JSON structure
//
//  http://api.statcounter.com
//
//  Created by Zach Graham on 6/11/14.
//  Copyright (c) 2014 StatCounter. All rights reserved.

#import <Foundation/Foundation.h>

@interface StatCounterAPI : NSObject
    
@property NSString* scBaseURL;
@property NSInteger scVersionNum;
@property NSString* scUsername;
@property NSString* scPassword;
@property NSString* scTimezone;
@property NSString* scQueryString;

- (id) initWithUsername: (NSString*)username password: (NSString*)password;

- (NSDictionary*) getUserProjectDetails;
- (NSDictionary*) createProject: (NSString*) websiteURL title: (NSString*) websiteTitle timeZone: (NSString*) timeZone;
- (NSDictionary*) getRecentKeywordActivity: (NSString*) projectID numOfResults: (NSInteger) numOfResults;
- (NSDictionary*) getPopularPages: (NSString*) projectID numOfResults: (NSInteger) numOfResults countType: (NSString*) countType;
- (NSDictionary*) getEntryPages: (NSString*) projectID numOfResults: (NSInteger) numOfResults;
- (NSDictionary*) getExitPages: (NSString*) projectID numOfResults: (NSInteger) numOfResults;
- (NSDictionary*) getCameFrom: (NSString*) projectID numOfResults: (NSInteger) numOfResults external: (NSInteger) external;
- (NSDictionary*) getBrowsers: (NSString*) projectID device: (NSString*) device;
- (NSDictionary*) getOperatingSystems: (NSString*) projectID device: (NSString*) device;
- (NSDictionary*) getRecentPageloadActivity: (NSString*) projectID device: (NSString*) device;
- (NSDictionary*) getExitLinkActivity: (NSString*) projectID device: (NSString*) device;
- (NSDictionary*) getDownloadLinkActivity: (NSString*) projectID device: (NSString*) device;
- (NSDictionary*) getSummaryStatsDate: (NSString*) projectID date: (NSString*) date;
- (NSDictionary*) getSummaryStatsDateRange: (NSString*) projectID startDate: (NSString*) startDate endDate: (NSString*) endDate;
- (NSDictionary*) getRecentVisitors: (NSString*) projectID numOfResults: (NSInteger) numOfResults;

@end
