//
//  YAWAWeatherStore.h
//  YAWA
//
//  Created by jl on 5/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAWAWeatherStore : NSObject

@property (nonatomic) NSArray *storeResults;
@property (nonatomic) NSString *cityName;
@property (nonatomic) NSString *mainString;
@property (nonatomic) NSString *descString;
@property (nonatomic) NSMutableArray *sevenDayResults;

// Init method
+ (YAWAWeatherStore *)sharedStore;

// Class methods
- (void)fetchSevenDayForecastDataForCity:(NSString *)cityToFetch;
- (void)flushForecastCache;
- (BOOL)isThereForecastDataInCache;
- (NSArray *)returnStoreResultsArray;
- (NSString *)returnNameOfCityLastFetched;
- (NSString *)returnLastForecastFetchTimeAsString;

@end
