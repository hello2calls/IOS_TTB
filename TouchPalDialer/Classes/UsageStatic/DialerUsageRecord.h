//
//  DialerUsageRecord.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/1/21.
//
//
#import "UsageConst.h"
#import "UsageRecordDataKV.h"

#define USAGE_TYPE_DIALER_IOS @"dialer_iOS"

#define Pair(x,y) [[UsageRecordDataKV alloc]initWithKey:x withValue:y]


@interface DialerUsageRecord : NSObject

/**
    Record usage for params like Pair(x,y)
 **/
+ (void)record:(NSString *)type path:(NSString *)path values:(NSDictionary *)values;
+ (void)recordpath:(NSString *)path kvarray:(NSArray*)kvarray;
+ (void)recordpath:(NSString *)path kvs:(UsageRecordDataKV *)kv,... NS_REQUIRES_NIL_TERMINATION;
+ (void)recordYellowPage:(NSString *)path kvs:(UsageRecordDataKV *)kv,... NS_REQUIRES_NIL_TERMINATION;
+ (void)recordCustomEvent:(NSString *)path module:(NSString *)module event:(NSString *)event;
+ (void)recordCrashReport;
+ (void)recordPV:(NSString *)path inTime:(NSInteger)intime outTime:(NSInteger)outTime rawOffset:(NSInteger)rawOffset;

+ (NSString*)getClientNetWorkType;

//
+ (void)recordCustomEvent:(NSString *)eventName;
+ (void)recordCustomEvent:(NSString *)eventName metric:(NSNumber *)metric;
+ (void)recordCustomEvent:(NSString *)eventName extraInfo:(NSDictionary *)extraInfo;
+ (void)recordCustomEvent:(NSString *)eventName metric:(NSNumber *)metric extraInfo:(NSDictionary *)extraInfo;

@end
