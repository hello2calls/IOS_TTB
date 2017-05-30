//
//  NetworkUtil.h
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-24.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsageReachability.h"

#define NON 0
#define WIFI_STATUS 1
#define MOBILE_STATUS 2

@interface UsageNetworkUtil : NSObject
+ (int)netStatus;
@end
