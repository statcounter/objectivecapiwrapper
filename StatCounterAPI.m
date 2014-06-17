//
//  StatCounterAPI.m
//  StatCounterApp
//
//  Provides an Objective-C interface to the StatCounter API
//  Data is returned as a NSDictionary, and can be accessed by key same as the API JSON structure
//
//  http://api.statcounter.com
//
//  Created by Zach Graham on 6/11/14.
//  Copyright (c) 2014 StatCounter. All rights reserved.

#import "StatCounterAPI.h"
#import <CommonCrypto/CommonDigest.h>

// Interface for private methods
@interface StatCounterAPI()

- (NSString*) buildURL: (NSString*) function;
- (Boolean) validDevice: (NSString*) device;
- (Boolean) validDate: (NSString*) date;
- (Boolean) validTimezone: (NSString*) timezone;
- (NSDictionary*) fetchJSON: (NSString*) url;
- (NSString*)URLEncode:(NSString*)string;
- (NSString*)sha1:(NSString*)str;

@end

// Header method implementation
@implementation StatCounterAPI

// Constructor to initialize with SC username and password
- (id) initWithUsername: (NSString *) username password: (NSString *) password {
    
    self = [super init];
    
    if (self) {
        
        [self setScBaseURL: @"http://api.statcounter.com"];
        [self setScVersionNum: 3];
        [self setScUsername: username];
        [self setScPassword: password];
        [self setScQueryString: @""];
    }
    
    return self;
}

// Gets the user's project details
// If successful, returns a dictionary with project details, else returns nil
- (NSDictionary*) getUserProjectDetails {
    
    NSString* url = [self buildURL: @"user_projects"];
    
    return [self fetchJSON: url];
    
}

// Creates a StatCouner project with website URL, title, and timezone
- (NSDictionary*) createProject: (NSString*) websiteURL title: (NSString*) websiteTitle timeZone: (NSString *) timeZone {
        
    if ([NSTimeZone timeZoneWithName: timeZone] == nil) {
        
        [NSException raise:NSInvalidArgumentException format:@"Invalid time zone entered"];
    }
    
    _scQueryString = [NSString stringWithFormat:@"&wu=%@&wt=%@&tz=%@&ps=0",
                                [self URLEncode: websiteURL],
                                [self URLEncode: websiteTitle],
                                [self URLEncode: timeZone]];
    
    NSString* url = [self buildURL: @"add_project"];
    
    return [self fetchJSON: url];
    
}

// Gets the recent keyword activity for the given project ID
- (NSDictionary*) getRecentKeywordActivity: (NSString*)projectID numOfResults: (NSInteger)numOfResults {
    
    _scQueryString = [NSString stringWithFormat:@"&s=keyword-activity&pi=%@&n=%ld", projectID, (long)numOfResults];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
    
}

// Count type of page_views or visitors
- (NSDictionary*) getPopularPages: (NSString*)projectID numOfResults: (NSInteger)numOfResults countType: (NSString*)countType {
    
    _scQueryString = [NSString stringWithFormat: @"&s=popular&pi=%@&n=%ld&ct=%@", projectID, (long)numOfResults, countType];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

// Gets the X number of entry page results for the given project ID
- (NSDictionary*) getEntryPages: (NSString*)projectID numOfResults: (NSInteger)numOfResults {
    
    _scQueryString = [NSString stringWithFormat: @"&s=entry&pi=%@&n=%ld", projectID, (long)numOfResults];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

// Gets the X number of exit page results for the given project ID
- (NSDictionary*) getExitPages: (NSString*)projectID numOfResults: (NSInteger)numOfResults {
    
    _scQueryString = [NSString stringWithFormat: @"&s=exit&pi=%@&n=%ld", projectID, (long)numOfResults];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

// Gets the came from visitor data for the given project ID
- (NSDictionary*) getCameFrom: (NSString*)projectID numOfResults: (NSInteger)numOfResults external: (NSInteger)external {
    
    _scQueryString = [NSString stringWithFormat: @"&s=camefrom&pi=%@&n=%ld&external=%ld", projectID, (long)numOfResults, (long)external];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

// Gets the browser usage ratio for the given project ID and device
- (NSDictionary*) getBrowsers: (NSString*)projectID device: (NSString*)device {
    
    if (![self validDevice: device]) { [NSException raise:NSGenericException format:@"Invalid device entered"]; }
    
    _scQueryString = [NSString stringWithFormat: @"&s=browsers&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

// Gets the operating system usage for the given project ID and device
- (NSDictionary*) getOperatingSystems: (NSString*)projectID device: (NSString*)device {
    
    if (![self validDevice: device]) { [NSException raise:NSGenericException format:@"Invalid device entered"]; }
    
    _scQueryString = [NSString stringWithFormat: @"&s=os&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
    
}

// Gets the recent pageload activity for the given project ID and device
- (NSDictionary*) getRecentPageloadActivity: (NSString*)projectID device: (NSString*)device {
    
    if (![self validDevice: device]) { [NSException raise:NSGenericException format:@"Invalid device entered"]; }
    
    _scQueryString = [NSString stringWithFormat: @"&s=pageload&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON:url];
    
}

// Gets the exit link activity for the given project ID and device
- (NSDictionary*) getExitLinkActivity: (NSString*)projectID device: (NSString*)device {
    
    if (![self validDevice: device]) { [NSException raise:NSGenericException format:@"Invalid device entered"]; }
    
    _scQueryString = [NSString stringWithFormat: @"&s=exit-link-activity&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON:url];
}

// Gets the download link activity for the given project ID and device
- (NSDictionary*) getDownloadLinkActivity: (NSString*)projectID device: (NSString*)device {
    
    if (![self validDevice: device]) { [NSException raise:NSGenericException format:@"Invalid device entered"]; }
    
    _scQueryString = [NSString stringWithFormat: @"&s=download-link-activity&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

// Gets the recent visitors data for the latest X number of visitors, for the given project ID
- (NSDictionary*) getRecentVisitors: (NSString*)projectID numOfResults: (NSInteger)numOfResults {
    
    _scQueryString = [NSString stringWithFormat: @"&s=visitor&g=daily&pi=%@&n=%ld", projectID, (long)numOfResults];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

// Gets the daily summary stats for the given project ID and date
- (NSDictionary*) getSummaryStatsDate: (NSString*)projectID date: (NSString*)date {
    
    NSDictionary* data = [self getSummaryStatsDateRange: projectID startDate: date endDate: date];
    
    return data;
    
}

// Gets the summary stats for a project ID for multiple days between start date and end date
- (NSDictionary*) getSummaryStatsDateRange: (NSString*)projectID startDate: (NSString*)startDate endDate: (NSString*)endDate {
    
    if (![self validDate: startDate]) { [NSException raise:NSGenericException format:@"Invalid start date"]; }
    if (![self validDate: endDate]) { [NSException raise:NSGenericException format:@"Invalid end date"]; }
    
    NSArray* startDateArray = [startDate componentsSeparatedByString:@"/"];
    NSArray* endDateArray = [endDate componentsSeparatedByString:@"/"];
    
    NSInteger startMonthNum = [startDateArray[0] intValue];
    NSInteger startDayNum = [startDateArray[1] intValue];
    NSInteger startYearNum = [startDateArray[2] intValue];
    
    NSInteger endMonthNum = [endDateArray[0] intValue];
    NSInteger endDayNum = [endDateArray[1] intValue];
    NSInteger endYearNum = [endDateArray[2] intValue];
    
    _scQueryString = [NSString stringWithFormat: @"&s=summary&g=daily&sd=%ld&sm=%ld&sy=%ld&ed=%ld&em=%ld&ey=%ld&pi=%@",
                      (long)startDayNum, (long)startMonthNum, (long)startYearNum, (long)endDayNum, (long)endMonthNum, (long)endYearNum, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

// Checks if the given login is valid
- (Boolean) loginIsValid:(NSString *)userID password:(NSString *)userPass {
    
    NSString* url = [self buildURL: @"user_projects"];
    
    NSData* responseData = nil;
    
    responseData = [NSData dataWithContentsOfURL: [NSURL URLWithString: url]];
    
    NSError* error = nil;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    NSDictionary* status = [json objectForKey:@"@attributes"];
    
    if ([status[@"status"] isEqualToString: @"ok"]) {
        
        return true;
    }
    
    return false;
}


/** Private Methods **/

// Builds the API url
- (NSString*)buildURL:(NSString *)function {
    
    NSString* base = [NSString stringWithFormat:@"%@/%@/", _scBaseURL, function];
    
    long timestamp = (long)[[NSDate date] timeIntervalSince1970];
    
    // Generate the query string with timestamp and version number etc
    _scQueryString = [NSString stringWithFormat:@"?vn=%ld&t=%ld&u=%@%@&f=json", (long)_scVersionNum, timestamp, _scUsername, _scQueryString];
    
    // Generate the SHA1
    NSString* queryPass = [NSString stringWithFormat: @"%@%@", _scQueryString, _scPassword];
    
    NSString* sha1 = [self sha1: queryPass];
    
    NSString* url = [NSString stringWithFormat: @"%@%@&sha1=%@", base, _scQueryString, sha1];
    
    return url;
    
}

// Returns an NSDictionary form of the JSON fetched from the API
- (NSDictionary*) fetchJSON: (NSString*) url {
    
    NSData* responseData = nil;
    
    responseData = [NSData dataWithContentsOfURL: [NSURL URLWithString: url]];
    
    NSError* error = nil;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    NSDictionary* status = [json objectForKey:@"@attributes"];
        
    if (error == nil && [status[@"status"] isEqualToString: @"ok"]) {
        
        NSDictionary* data = [json objectForKey:@"sc_data"]; //2
        return data;
    }
    
    [NSException raise:NSGenericException format:@"Could not fetch SC data"];
    
    return nil;
}

// Returns true if the given device is valid
- (Boolean) validDevice: (NSString*) device {
    
    return ([device isEqualToString: @"all"] ||
           [device isEqualToString: @"desktop"] ||
           [device isEqualToString: @"mobile"]);
}

// Returns true if the given date is valid
// Must be of the format MM/DD/YYYY
- (Boolean) validDate: (NSString*) date {
    
    NSArray *dateArray = [date componentsSeparatedByString:@"/"];
    if ([dateArray count] != 3) { return false; }
    
    NSInteger month = [[dateArray objectAtIndex: 0] intValue];
    NSInteger day = [[dateArray objectAtIndex: 1] intValue];
    NSInteger year = [[dateArray objectAtIndex: 2] intValue];
    
    if (month <= 0 || month > 12) { return false; }

    // number of days in month
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    // Get the current year
    NSInteger currentYear = [[cal components:NSYearCalendarUnit fromDate:[NSDate date]] year];
    
    [comps setMonth: month];
    NSInteger daysInMonth = [cal rangeOfUnit:NSDayCalendarUnit
                                      inUnit:NSMonthCalendarUnit
                                     forDate:[cal dateFromComponents:comps]].length;
    if (day < 1 || day > daysInMonth) { return false; }

    if (year > currentYear) { return false; }
    
    return true;
}

// Returns true if the given timezone is valid, else returns false
- (Boolean) validTimezone: (NSString*) timezone {
    
    return ([NSTimeZone timeZoneWithName: timezone] != nil);
    
}

// Encodes the URL properly for fetching
- (NSString*)URLEncode:(NSString*)string {
    
    NSString *encodedString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return encodedString;
}

// Returns the SHA1 of the given string
- (NSString *)sha1:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2], result[3], result[4],
                   result[5], result[6], result[7],
                   result[8], result[9], result[10], result[11], result[12],
                   result[13], result[14], result[15],
                   result[16], result[17], result[18], result[19]
                   ];
    
    return s;
}

@end
