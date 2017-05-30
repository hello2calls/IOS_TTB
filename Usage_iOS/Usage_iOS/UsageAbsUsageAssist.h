//
//  UsageAbsUsageAssist.h
//  UsageAPP
//
//  Created by ZhangNan on 14-8-7.
//  Copyright (c) 2014年 hello. All rights reserved.
//

typedef enum {
    TOKEN_NOWORKING,
    TOKEN_NEED_UPDATE,
} ERROR_TOKEN;

@protocol UsageAbsUsageAssist <NSObject>

@required
- (NSString *)token;
- (NSString *)storagePath;

@optional
- (NSString *)serverAddress;
- (BOOL)canUseHttps;
- (int)httpPort;
- (int)httpsPort;
- (int)retryTimes;
- (NSString *)strategyFileName;
- (void)tokenInvalid:(ERROR_TOKEN)errorCode;
- (void)updateStrategyResult:(BOOL)result;
- (int)getVersionCode;
- (int)getInfoInterval:(int)flag;
- (BOOL)canUploadInfo:(int)flag;
- (void)invalidRecordValues:(NSDictionary *)values;
@end