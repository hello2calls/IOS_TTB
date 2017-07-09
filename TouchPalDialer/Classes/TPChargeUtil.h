//
//  TPChargeUtil.h
//  VoipSDK
//
//  Created by by.huang on 2017/6/14.
//  Copyright © 2017年 by.huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPChargeUtil : NSObject

typedef void(^OnChargeCallback)(Boolean statu,NSString *errorMsg);

typedef void(^OnQueryCallback)(NSString *minute);

+(void)queryTime : (NSString *)phoneNum callback : (OnQueryCallback)callback;

+(void)charge : (NSString *)phoneNum reward : (int)reward callback : (OnChargeCallback)callback;

+(NSString *)transformBase64 : (NSString *)signStr;

+(NSString *)transformJson : (NSMutableDictionary *)dict;

@end
