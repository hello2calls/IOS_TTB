//
//  UsageAssist.h
//  UsageAPP
//
//  Created by ZhangNan on 14-8-13.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsageAbsUsageAssist.h"

@interface UsageAssist : NSObject
- (id)initWithAssist:(id<UsageAbsUsageAssist>)assist;
- (NSString *)getToken;
- (NSString *)getServerAddress;
- (int)getHttpPort;
- (int)getHttpsPort;
- (int)getRetryTimes;
- (BOOL)useHttps;
- (NSString *)strategyFileName;
- (void)tokenInvalid :(ERROR_TOKEN) errorCode;
- (NSString *)storagePath;
- (void)updateStrategyResult:(BOOL) result;
- (int)getVersionCode;
- (int)getInfoInterval:(int)flag;
- (BOOL)canUploadInfo:(int)flag;
- (void)invalidRecordValues:(NSDictionary *)values;
@end
