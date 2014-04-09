//
//  YAWADayForecastItem.h
//  YAWA
//
//  Created by jl on 6/04/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAWADayForecastItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *dayOfWeek;
@property (nonatomic, strong) NSString *shortDescString;
@property (nonatomic, strong) NSString *longDescString;
@property (nonatomic, strong) NSString *minString;
@property (nonatomic, strong) NSString *maxString;
@property (nonatomic, strong) NSString *cloudsString;
@property (nonatomic, strong) NSString *iconToUse;

- (id)initWithDay:(NSString *)dayName
     andShortDesc:(NSString *)shortDescToUse
      andLongDesc:(NSString *)longDescToUse
       andMinTemp:(NSString *)minTemp
       andMaxTemp:(NSString *)maxTemp
        andClouds:(NSString *)cloudAmount;

@end
