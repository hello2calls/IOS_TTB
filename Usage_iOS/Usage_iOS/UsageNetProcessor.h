//
//  NetProcessor.h
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-28.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UsageData.h"
#import "UsageRecorder.h"
#define AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES
@interface UsageNetProcessor : NSObject
- (id)initWithUsages:(NSMutableArray *)usages
                type:(NSString *)type
       andUseEncrypt:(BOOL)useEncrypt;
- (void)sendWithBlock:(void(^)(NSMutableArray *saveArray, BOOL res, NSString *type))block;
@end
