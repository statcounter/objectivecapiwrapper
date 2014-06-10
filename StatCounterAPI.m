//
//  StatCounterAPI.m
//  StatCounter
//
//  Created by Zach Graham on 6/10/14.
//
//

#import "StatCounterAPI.h"
#import <CommonCrypto/CommonDigest.h>

// For private methods
@interface StatCounterAPI()

- (NSString*) buildURL: (NSString*) function;
- (Boolean) validDevice: (NSString*) device;
- (Boolean) validDate: (NSString*) date;
- (Boolean) validTimezone: (NSString*) timezone;

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

- (NSDictionary*) createStatCounterProject: (NSString*) websiteURL title: (NSString*) websiteTitle timeZone: (NSString *) timeZone {
        
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

- (NSDictionary*) getRecentKeywordActivity: (NSString*)projectID numOfResults: (NSInteger)numOfResults {
    
    _scQueryString = [NSString stringWithFormat:@"&s=keyword-activity&pi=%@&n=%d", projectID, numOfResults];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
    
}

// Count type of page_views or visitors
- (NSDictionary*) getPopularPages: (NSString*)projectID numOfResults: (NSInteger)numOfResults countType: (NSString*)countType {
    
    _scQueryString = [NSString stringWithFormat: @"&s=popular&pi=%@&n=%d&ct=%@", projectID, numOfResults, countType];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

- (NSDictionary*) getEntryPages: (NSString*)projectID numOfResults: (NSInteger)numOfResults {
    
    _scQueryString = [NSString stringWithFormat: @"&s=entry&pi=%@&n=%d", projectID, numOfResults];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

- (NSDictionary*) getExitPages: (NSString*)projectID numOfResults: (NSInteger)numOfResults {
    
    _scQueryString = [NSString stringWithFormat: @"&s=exit&pi=%@&n=%d", projectID, numOfResults];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

- (NSDictionary*) getCameFrom: (NSString*)projectID numOfResults: (NSInteger)numOfResults external: (NSInteger)external {
    
    _scQueryString = [NSString stringWithFormat: @"&s=camefrom&pi=%@&n=%d&external=%d", projectID, numOfResults, external];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

- (NSDictionary*) getBrowsers: (NSString*)projectID device: (NSString*)device {
    
    _scQueryString = [NSString stringWithFormat: @"&s=browsers&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

- (NSDictionary*) getOperatingSystems: (NSString*)projectID device: (NSString*)device {
    
    _scQueryString = [NSString stringWithFormat: @"&s=os&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
    
}

- (NSDictionary*) getRecentPageloadActivity: (NSString*)projectID device: (NSString*)device {
    
    _scQueryString = [NSString stringWithFormat: @"&s=pageload&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON:url];
    
}

- (NSDictionary*) getExitLinkActivity: (NSString*)projectID device: (NSString*)device {
    
    _scQueryString = [NSString stringWithFormat: @"&s=exit-link-activity&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON:url];
}

- (NSDictionary*) getDownloadLinkActivity: (NSString*)projectID device: (NSString*)device {
    
    _scQueryString = [NSString stringWithFormat: @"&s=download-link-activity&de=%@&pi=%@", device, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

- (NSDictionary*) getRecentVisitors: (NSString*)projectID numOfResults: (NSInteger)numOfResults {
    
    _scQueryString = [NSString stringWithFormat: @"&s=visitor&g=daily&pi=%@&n=%d", projectID, numOfResults];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}

- (NSDictionary*) getSummaryStatsDate: (NSString*)projectID date: (NSString*)date {
    
    return [self getSummaryStatsDateRange: projectID startDate: date endDate: date]; // Need to return only 1 result
    
}

- (NSDictionary*) getSummaryStatsDateRange: (NSString*)projectID startDate: (NSString*)startDate endDate: (NSString*)endDate {
    
    if (![self validDate: startDate]) { [NSException raise:NSGenericException format:@"Invalid start date"]; }
    if (![self validDate: endDate]) { [NSException raise:NSGenericException format:@"Invalid end date"]; }
    
    NSArray* startDateArray = [startDate componentsSeparatedByString:@"/"];
    NSArray* endDateArray = [startDate componentsSeparatedByString:@"/"];
    
    NSInteger startMonthNum = (int)startDateArray[0];
    NSInteger startDayNum = (int)startDateArray[1];
    NSInteger startYearNum = (int)startDateArray[2];
    
    NSInteger endMonthNum = (int)endDateArray[0];
    NSInteger endDayNum = (int)endDateArray[1];
    NSInteger endYearNum = (int)endDateArray[2];
    
    _scQueryString = [NSString stringWithFormat: @"&s=summary&g=daily&sd=%d&sm=%d&sy=%d&ed=%d&em=%d&ey=%d&pi=%@",
                      startDayNum, startMonthNum, startYearNum, endDayNum, endMonthNum, endYearNum, projectID];
    
    NSString* url = [self buildURL: @"stats"];
    
    return [self fetchJSON: url];
}


/** Private Methods **/

// Builds the API url
- (NSString*)buildURL:(NSString *)function {
    
    NSString* base = [NSString stringWithFormat:@"%@/%@/", _scBaseURL, function];
    
    long timestamp = (long)[[NSDate date] timeIntervalSince1970];
    
    // Generate the query string with timestamp and version number etc
    _scQueryString = [NSString stringWithFormat:@"?vn=%d&t=%ld&u=%@%@&f=json", _scVersionNum, timestamp, _scUsername, _scQueryString];
    
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
    
    NSInteger month = (int)[dateArray objectAtIndex: 0];
    NSInteger day = (int)[dateArray objectAtIndex: 1];
    NSInteger year = (int)[dateArray objectAtIndex: 2];
    
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