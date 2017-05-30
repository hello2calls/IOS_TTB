//
//  UsageRecorder.h
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-23.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

#import "UsageAbsUsageAssist.h"
#import "UsageProcessor.h"
#import "UsageAssist.h"

@interface UsageRecorder : NSObject

+ (void)initialize:(id<UsageAbsUsageAssist>)assist;
+ (void)record:(NSString *)type path:(NSString *)path values:(NSDictionary *)values;
+ (void)send;
+ (void)updateStrategyFile:(NSString *)path;
+ (UsageAssist *)sAssist;

@end
