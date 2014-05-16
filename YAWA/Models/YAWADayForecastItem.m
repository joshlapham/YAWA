//
//  YAWADayForecastItem.m
//  YAWA
//
//  Created by jl on 6/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "YAWADayForecastItem.h"

@implementation YAWADayForecastItem

@synthesize dayOfWeek, shortDescString, longDescString, minString, maxString, cloudsString, iconToUse;

#pragma mark - Init methods

- (id)initWithDay:(NSString *)dayName
     andShortDesc:(NSString *)shortDescToUse
      andLongDesc:(NSString *)longDescToUse
       andMinTemp:(NSString *)minTemp
       andMaxTemp:(NSString *)maxTemp
        andClouds:(NSString *)cloudAmount
{
    self = [super init];
    
    if (self) {
        dayOfWeek = dayName;
        shortDescString = shortDescToUse;
        longDescString = longDescToUse;
        minString = minTemp;
        maxString = maxTemp;
        cloudsString = cloudAmount;
        
        NSLog(@"Init forecast item: %@, %@, %@, %@, %@, clouds: %@", dayName, shortDescToUse, longDescToUse, minTemp, maxTemp, cloudAmount);
        
        // Set icon image to use
        iconToUse = [self returnIconToUseBasedOnClouds:cloudsString
                                          andShortDesc:shortDescString
                                           andLongDesc:longDescString];
        //NSLog(@"icon to use: %@", iconToUse);
    }
    return self;
}

// This method determines the right icon to use based on weather results
- (NSString *)returnIconToUseBasedOnClouds:(NSString *)cloudAmount
                              andShortDesc:(NSString *)shortDescToCheck
                               andLongDesc:(NSString *)longDescToCheck
{
    NSInteger clouds = cloudAmount.integerValue;
    
    // Clear
    if ([shortDescToCheck isEqualToString:@"Clear"]) {
        //NSLog(@"short desc: %@, clouds: %d", shortDescToCheck, clouds);
        return @"sun";
        
    // Clouds
    } else if ([shortDescToCheck isEqualToString:@"Clouds"]) {
        //NSLog(@"short desc: %@, clouds: %d", shortDescToCheck, clouds);
        
        if (clouds > 90) {
            return @"cloud-two";
        } else if (clouds > 80) {
            return @"cloud-one";
        } else {
            return @"cloud-sun";
        }
    
    // Rain
    } else if ([shortDescToCheck isEqualToString:@"Rain"]) {
        //NSLog(@"short desc: %@, clouds: %d", shortDescToCheck, clouds);
        
        if ([longDescString isEqualToString:@"heavy intensity rain"] || [longDescString isEqualToString:@"very heavy rain"]) {
            return @"cloud-rain-three";
        } else {
            return @"cloud-rain-one";
        }
    }
    
    return nil;
}

#pragma mark - NSCoding delegate methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        dayOfWeek = [aDecoder decodeObjectForKey:@"dayOfWeek"];
        shortDescString = [aDecoder decodeObjectForKey:@"shortDescString"];
        longDescString = [aDecoder decodeObjectForKey:@"longDescString"];
        minString = [aDecoder decodeObjectForKey:@"minString"];
        maxString = [aDecoder decodeObjectForKey:@"maxString"];
        cloudsString = [aDecoder decodeObjectForKey:@"cloudsString"];
        iconToUse = [aDecoder decodeObjectForKey:@"iconToUse"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:dayOfWeek forKey:@"dayOfWeek"];
    [aCoder encodeObject:shortDescString forKey:@"shortDescString"];
    [aCoder encodeObject:longDescString forKey:@"longDescString"];
    [aCoder encodeObject:minString forKey:@"minString"];
    [aCoder encodeObject:maxString forKey:@"maxString"];
    [aCoder encodeObject:cloudsString forKey:@"cloudsString"];
    [aCoder encodeObject:iconToUse forKey:@"iconToUse"];
}

@end
