//
//  UsageAssist.m
//  UsageAPP
//
//  Created by ZhangNan on 14-8-13.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#define STRATEGY_FILE_NAME (@"usage_strategy.xml")
#define SERVER_ADDRESS @"ws2.cootekservice.com"
#define HTTP_PORT 80
#define HTTPS_PORT 443
#define HTTP_RETRY_TIMES 1
#define CAN_USE_HTTPS NO
#define DEFAULT_INTERVAL -1

#import "UsageAssist.h"

static id<UsageAbsUsageAssist> sAssist;
@implementation UsageAssist
- (id)initWithAssist:(id<UsageAbsUsageAssist>)assist
{
    if (self = [super init]) {
        if (sAssist == nil) {
            sAssist = assist;
        }
    }
    return self;
}
- (NSString *)strategyFileName
{
    if ([sAssist respondsToSelector:@selector(strategyFileName)]) {
        return [sAssist strategyFileName];
    } else {
        return STRATEGY_FILE_NAME;
    }
}
- (void)tokenInvalid:(ERROR_TOKEN)errorCode {
    if ([sAssist respondsToSelector:@selector(tokenInvalid:)]) {
        [sAssist tokenInvalid:errorCode];
    }
}
- (NSString *)storagePath {
    if ([sAssist respondsToSelector:@selector(storagePath)])
    {
        return [sAssist storagePath];
    } else {
        return nil;
    }
}

- (BOOL)useHttps {
    if([sAssist respondsToSelector:@selector(canUseHttps)])
    {
        return [sAssist canUseHttps];
    } else {
        return CAN_USE_HTTPS;
    }
}

- (NSString *)getServerAddress {
    if ([sAssist respondsToSelector:@selector(serverAddress)]) {
        return [sAssist serverAddress];
    } else {
        return SERVER_ADDRESS;
    }
}

- (int)getHttpsPort {
    if ([sAssist respondsToSelector:@selector(httpsPort)]) {
        return [sAssist httpsPort];
    } else {
        return HTTPS_PORT;
    }
}

- (int)getHttpPort {
    if ([sAssist respondsToSelector:@selector(httpPort)]) {
        return [sAssist httpPort];
    } else {
        return HTTP_PORT;
    }
}

- (int)getRetryTimes {
    if ([sAssist respondsToSelector:@selector(retryTimes)]) {
        return [sAssist retryTimes];
    } else {
        return HTTP_RETRY_TIMES;
    }
}

- (NSString *)getToken
{
    return [sAssist token];
}

- (void)updateStrategyResult:(BOOL)result {
    if ([sAssist respondsToSelector:@selector(updateStrategyResult:)]) {
        [sAssist updateStrategyResult:result];
    }
}

- (int)getVersionCode {
    if ([sAssist respondsToSelector:@selector(getVersionCode)]) {
        return [sAssist getVersionCode];
    }else {
        return -1;
    }
}

- (int)getInfoInterval:(int)flag {
    if ([sAssist respondsToSelector:@selector(getInfoInterval:)]) {
        return [sAssist getInfoInterval:flag];
    } else {
        return DEFAULT_INTERVAL;
    }
}
- (BOOL)canUploadInfo:(int)flag {
    if ([sAssist respondsToSelector:@selector(canUploadInfo:)]) {
        return [sAssist canUploadInfo:flag];
    } else {
        return YES;
    }
}

- (void)invalidRecordValues:(NSDictionary *)values {
    if ([sAssist respondsToSelector:@selector(invalidRecordValues:)]) {
        [sAssist invalidRecordValues:values];
    }
}

@end
