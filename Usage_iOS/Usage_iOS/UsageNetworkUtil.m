//
//  NetworkUtil.m
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-24.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import "UsageNetworkUtil.h"
#import "UsageRecorder.h"
@implementation UsageNetworkUtil
+ (int)netStatus {
    int result;
    NSString *server = [[UsageRecorder sAssist] getServerAddress];
    NSRange range = [server rangeOfString:@"/"];
    if (range.location != -1 && range.length != 0) {
        server = [server substringToIndex:range.location];
    }
    UsageReachability *r = [UsageReachability reachabilityWithHostName:server];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            result = NON;
            NSLog(@"net info: none");
            break;
        case ReachableViaWiFi:
            result = WIFI_STATUS;
            NSLog(@"net info: wifi");
            break;
        case ReachableViaWWAN:
            result = MOBILE_STATUS;
            NSLog(@"net info: mobi");
            break;
    }
    return result;
}
@end
