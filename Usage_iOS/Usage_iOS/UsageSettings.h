//
//  Settings.h
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-25.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsageStrategyController.h"
#import "UsageRecorder.h"

@interface UsageSettings : NSObject
+ (UsageSettings *)getInst;
- (double)getLastSuccess:(NSString *)strategyName;
- (void)updateLastSuccess:(NSString *)strategyName;
- (double)getLastInfoSuccess:(NSString *)infoName;
- (void)setLastInfoSuccess:(NSString *)infoName andTime:(double)time;
- (long long)getLastInfoSuccessId:(NSString *)infoName;
- (void)setLastInfoSuccessId:(NSString *)infoName andId:(long long)lastId;
- (double)getQuietTime:(NSString *)strategyName;
- (double)getCurrentTime;
- (double)getTimeZone;
- (NSMutableArray *)getRecords:(NSString *)strategyName;
- (void)setRecords:(NSMutableArray *)array strategyName:(NSString *)strategyName;
- (void)removeRecords:(NSString *)strategyName;
@end
