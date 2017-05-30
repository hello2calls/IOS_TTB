//
//  StrategyController.h
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-24.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsageRecorder.h"
#import "UsageData.h"

@interface UsageStrategyController : NSObject <NSXMLParserDelegate>

- (BOOL)generate;
- (BOOL)isPathExist:(NSString *)path;
- (int)getSampling:(NSString *)path;
- (NSString *)getStrategy:(NSString *)path;
- (int)getWifi:(NSString *)name;
- (int)getMobile:(NSString *)name;
- (int)getCount:(NSString *)name;
- (BOOL)getEncrypt:(NSString *)name;
+ (UsageStrategyController *)getCurrent;
- (NSMutableDictionary *)mUploadStrategy;
- (NSMutableDictionary *)mUploadControl;

@end

@interface Strategy : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int wifi;
@property (nonatomic, assign) int mobile;
@property (nonatomic, assign) BOOL encrypt;
@property (nonatomic, assign) int count;
@end

@interface UploadControlItem : NSObject
@property (nonatomic, retain) NSString *path;
@property (nonatomic, assign) int sampling;
@property (nonatomic, retain) NSString *strategyName;
@end


