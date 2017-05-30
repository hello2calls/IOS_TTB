//
//  UsageProcessor.h
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-23.
//  Copyright (c) 2014年 hello. All rights reserved.
//
#define TIME_KEY (@"timestamp")
#define TIME_ZONE (@"timezone")

#import <Foundation/Foundation.h>
#import <dispatch/queue.h>
#import "UsageData.h"
#import "UsageStrategyController.h"
#import "UsageSettings.h"
#import "UsageNetworkUtil.h"
#import "UsageNetProcessor.h"
#import "UsageRecorder.h"

@interface UsageProcessor : NSObject

//need a method to handle the asynctask.
- (void)sendData;
- (void)sendInfoData;
- (void)updateStrategy:(NSString *)newFilePath;
- (void)saveRecord:(UsageRecord *)record;
- (id)init;
@end
