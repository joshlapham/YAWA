//
//  YAWAWeatherStore.m
//  YAWA
//
//  Created by jl on 5/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "YAWAWeatherStore.h"
#import "YAWADayForecastItem.h"
//#import "AFNetworking.h"

@implementation YAWAWeatherStore

@synthesize storeResults, cityName, mainString, descString, sevenDayResults;

#pragma mark - Item store methods

// Returns a string of the last time data was fetched and cached
- (NSString *)returnLastForecastFetchTimeAsString
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"forecastLastFetchTime"]) {
        NSDate *lastFetchTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"forecastLastFetchTime"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        
        return [dateFormatter stringFromDate:lastFetchTime];
    } else {
        return [NSString stringWithFormat:@"never"];
    }
}

// Returns a string of the last city name that was fetched and cached
- (NSString *)returnNameOfCityLastFetched
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastCityFetched"]) {
        // Return a capitalized string just in case
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastCityFetched"] capitalizedString];
    } else {
        return nil;
    }
}

// Returns a bool based on whether or not data has been cached
- (BOOL)isThereForecastDataInCache
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"forecastCachedData"]) {
        NSTimeInterval interval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"forecastLastFetchTime"] timeIntervalSinceNow];
        NSLog(@"Cache interval: %f", interval);
        
        // 600 is 10mins in nerd talk
        if (interval < -600) {
            NSLog(@"Cache data is older than 10mins");
            return NO;
        } else {
            NSLog(@"Cache was fetched less than 10mins ago");
            return YES;
        }
    } else {
        NSLog(@"Nothing found in cache");
        return NO;
    }
}

// Returns an array containing the results of the data fetch
- (NSArray *)returnStoreResultsArray
{
    if (storeResults.count != 0) {
        return storeResults;
    } else {
        return nil;
    }
}

// Method to fetch data for a given city name
- (void)fetchSevenDayForecastDataForCity:(NSString *)cityToFetch
{
    // Init results array
    sevenDayResults = [[NSMutableArray alloc] init];
    
    // Check if there is already data cached,
    // only if cityToFetch has changed from last city cached
    if ([self isThereForecastDataInCache] && [[cityToFetch lowercaseString] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastCityFetched"]]) {
        
        sevenDayResults = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"forecastCachedData"]]];
        
        // Post notification
        NSString *notificationName = @"YAWADidFetchSevenDayData";
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
        
        NSLog(@"Using cached data");
    } else {
        NSLog(@"Fetching new data");
        
        // Show network activity monitor
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSURLSession *session = [[NSURLSession alloc] init];
        // GC
//        http://www.bom.gov.au/fwo/IDQ60801/IDQ60801.94580.json
//        [[session ]]
        
        // Get JSON file
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        
//        // Remove spaces from parameter and replace with %20 for API call
//        NSString *apiString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@,au&cnt=7&units=metric", [cityToFetch stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
//        
//        // TODO: set q and units parameters as options set by user
//        [manager GET:apiString parameters:Nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            // Set city name
//            NSString *cityNameForSevenDay = [[responseObject objectForKey:@"city"] objectForKey:@"name"];
//            NSLog(@"City name for 7 day: %@", cityNameForSevenDay);
//            
//            //NSLog(@"7 day list: %@", [[[responseObject objectForKey:@"list"] objectAtIndex:0] debugDescription]);
//            
//            // Init date formatter and NSDate for today's date
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"EEEE"];
//            NSDate *currentDate = [NSDate date];
//            
//            // Loop over each day of the week and get dicts
//            for (NSDictionary *dayDict in [responseObject objectForKey:@"list"]) {
//                // Parse date of forecast
//                NSDate *forecastDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[[dayDict objectForKey:@"dt"] doubleValue]];
//                //NSLog(@"date of thing: %@", [dateFormatter stringFromDate:forecastDate]);
//                
//                // If result is today's date, then use string 'Today'
//                // instead of the actual day name
//                NSString *dayNameToSave = [[NSString alloc] init];
//                if ([[dateFormatter stringFromDate:currentDate] isEqualToString:[dateFormatter stringFromDate:forecastDate]]) {
//                    dayNameToSave = @"Today";
//                } else {
//                    // Use actual day name
//                    dayNameToSave = [dateFormatter stringFromDate:forecastDate];
//                }
//                
//                // Init new day forecast item object
//                NSString *shortDescStringToAdd = [NSString stringWithFormat:@"%@", [[[dayDict objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"]];
//                NSString *longDescStringToAdd = [NSString stringWithFormat:@"%@", [[[dayDict objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"description"]];
//                NSString *minString = [NSString stringWithFormat:@"%@", [[dayDict objectForKey:@"temp"] objectForKey:@"min"]];
//                NSString *maxString = [NSString stringWithFormat:@"%@", [[dayDict objectForKey:@"temp"] objectForKey:@"max"]];
//                NSString *cloudsString = [NSString stringWithFormat:@"%@", [dayDict objectForKey:@"clouds"]];
//                
//                YAWADayForecastItem *itemToAdd = [[YAWADayForecastItem alloc] initWithDay:dayNameToSave
//                                                                             andShortDesc:shortDescStringToAdd
//                                                                              andLongDesc:longDescStringToAdd
//                                                                               andMinTemp:minString
//                                                                               andMaxTemp:maxString
//                                                                                andClouds:cloudsString];
//                
//                [sevenDayResults addObject:itemToAdd];
//            }
//            
//            // Hide network activity monitor
//            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//            
//            // Save the time of data fetch and results array to
//            // NSUserDefaults for caching
//            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"forecastLastFetchTime"];
//            NSData *dataToCache = [NSKeyedArchiver archivedDataWithRootObject:sevenDayResults];
//            [[NSUserDefaults standardUserDefaults] setObject:dataToCache forKey:@"forecastCachedData"];
//            // Cache name of city that we're fetching,
//            // using a lowercase string so that we can check
//            // things from the cache easier
//            [[NSUserDefaults standardUserDefaults] setObject:[cityToFetch lowercaseString] forKey:@"lastCityFetched"];
//            // Save changes to NSUserDefaults
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//            // Post notification
//            NSString *notificationName = @"YAWADidFetchSevenDayData";
//            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
//            
//            // Post error notification
//            NSString *notificationErrorName = @"YAWAErrorWhileFetching";
//            [[NSNotificationCenter defaultCenter] postNotificationName:notificationErrorName object:nil];
//        }];
    }
}

// Method to remove cached data
- (void)flushForecastCache
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"forecastCachedData"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"forecastCachedData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Flushed cache");
    }
}

@end
