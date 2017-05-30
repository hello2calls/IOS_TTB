//
//  DialerUsageRecord.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/1/21.
//
//

#import "DialerUsageRecord.h"
#import <Usage_iOS/UsageRecorder.h>
#import "UserDefaultsManager.h"
#import "LocalStorage.h"
#import "Reachability.h"
#import "TPUncaughtExceptionHandler.h"
#import "SeattleFeatureExecutor.h"
#import "MJExtension.h"

#define USAGE_TYPE @"dialer_iOS"
#define CRASH_TYPE @"app_crash"
#define CRASH_PATH @"path_noah_crash"
#define PV_PATH @"eden_path_pageactive_dialer_ios"


NSString * const rainbowPath = @"path_noah_crash";
@implementation DialerUsageRecord

+ (void)recordpath:(NSString *)path kvs:(UsageRecordDataKV *)kv, ... {
    if (!kv) {
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    if (kv.recordValue && kv.recordKey) {
        [dic setValue:kv.recordValue forKey:kv.recordKey];
    }
    va_list arglist;
    va_start(arglist, kv);
    UsageRecordDataKV *arg = va_arg(arglist, UsageRecordDataKV*);
    while (arg) {
        if (arg.recordKey && arg.recordValue) {
            [dic setValue:arg.recordValue forKey:arg.recordKey];
        }
        arg = va_arg(arglist, UsageRecordDataKV*);
    }
    va_end(arglist);
    
    [DialerUsageRecord record:USAGE_TYPE path:path values:dic];
}

+ (void)record:(NSString *)type path:(NSString *)path values:(NSDictionary *)values{
    NSMutableDictionary* d = [values mutableCopy];
    [d setValue:@([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) forKey:ENABLE_V6_TEST_ME];

    [UsageRecorder record:USAGE_TYPE path:path values:d];
}


+ (void)recordpath:(NSString *)path kvarray:(NSArray *)kvarray {
    if (!kvarray || kvarray.count == 0) {
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:kvarray.count];
    for (UsageRecordDataKV *kv in kvarray) {
        if (kv.recordKey && kv.recordValue) {
            [dic setValue:kv.recordValue forKey:kv.recordKey];
        }
    }
    [DialerUsageRecord record:USAGE_TYPE path:path values:dic];
}

+ (void)recordYellowPage:(NSString *)path kvs:(UsageRecordDataKV *)kv, ... {
    if (!kv) {
        return;
    }
    NSMutableDictionary* newValues = [[NSMutableDictionary alloc]init];
    NSString* user_tag = [UserDefaultsManager stringForKey:YP_USER_TAG];
    user_tag = user_tag == nil ? @"new" : @"old";
    [newValues setObject:user_tag forKey:@"user_tag"];
    NSString* version = [UserDefaultsManager stringForKey:ZIP_CURRENT_VERSION] ;
    if (version == nil) {
        version = @"0";
    }
    [newValues setObject:version forKey:@"version"];
    NSString* city = [LocalStorage getItemWithKey:QUERY_PARAM_CITY] ;
    if (city == nil) {
        city = @"全国";
    }
    [newValues setObject:city forKey:@"city"];
    if (kv.recordValue && kv.recordKey) {
        [newValues setValue:kv.recordValue forKey:kv.recordKey];
    }
    va_list arglist;
    va_start(arglist, kv);
    UsageRecordDataKV *arg = va_arg(arglist, UsageRecordDataKV*);
    while (arg) {
        if (arg.recordKey && arg.recordValue) {
            [newValues setValue:arg.recordValue forKey:arg.recordKey];
        }
        arg = va_arg(arglist, UsageRecordDataKV*);
    }
    va_end(arglist);
    if  ([PATH_FEEDS isEqualToString:path]) {
        [DialerUsageRecord recordCustomEvent:path metric:0 extraInfo:newValues];
    } else {
        [DialerUsageRecord record:USAGE_TYPE path:path values:newValues];
    }
}

+ (void)recordCustomEvent:(NSString *)path module:(NSString *)module event:(NSString *)event{
    [DialerUsageRecord recordYellowPage:path kvs:Pair(@"id", @"139"), Pair(@"name", @"custom_event"), Pair(@"event", ([NSString stringWithFormat:@"%@%@%@%@", @"ios_", module, @" ", event])), Pair(@"token", [SeattleFeatureExecutor getToken]), nil];
}

+ (NSString*)getClientNetWorkType
{
    int intType = [Reachability network];
    switch (intType) {
        case 0:
            return @"NONE";
            break;
        case 1:
            return @"2G";
            break;
        case 2:
            return @"3G";
            break;
        case 3:
            return @"4G";
            break;
        case 4:
            return @"4G";
            break;
        case 5:
            return @"WIFI";
            break;
        default:
            return @"NONE";
            break;
    }
}

+ (void)recordCrashReport{
    NSString *settingPath = [TPUncaughtExceptionHandler crashFileAbsolutePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *dict = nil;
    
    NSError *error = nil;
    if ( [fileManager fileExistsAtPath:settingPath]) {
        dict = [NSMutableDictionary dictionaryWithContentsOfFile:settingPath];
        [DialerUsageRecord record:CRASH_TYPE path:CRASH_PATH values:dict];
        BOOL success = [fileManager removeItemAtPath:settingPath error:&error];
        if(!success){
            NSLog(@"Error remove crash report fail :%@", error);
        }
    }
}

+ (void)recordPV:(NSString *)path inTime:(NSInteger)inTime outTime:(NSInteger)outTime rawOffset:(NSInteger)rawOffset{
    NSDictionary *dic = @{
                          @"inTime":[NSNumber numberWithInt:inTime],
                          @"outTime":[NSNumber numberWithInt:outTime],
                          @"path":path,
                          @"raw_offset":[NSNumber numberWithInt:rawOffset]};
    [DialerUsageRecord record:USAGE_TYPE path:PV_PATH values:dic];
    
}

/*
 * record usage data with instant uploading and pushing into data warehouse:
 * * + (void)recordCustomEvent:(NSString *)eventName;
 * * + (void)recordCustomEvent:(NSString *)eventName metric:(NSNumber *)metric;
 * * + (void)recordCustomEvent:(NSString *)eventName extraInfo:(NSDictionary *)extraInfo;
 * * + (void)recordCustomEvent:(NSString *)eventName metric:(NSNumber *)metric extraInfo:(NSDictionary *)extraInfo;
 */

+ (void)recordCustomEvent:(NSString *)eventName
{
    [DialerUsageRecord recordCustomEvent:eventName metric:nil extraInfo:nil];
}

+ (void)recordCustomEvent:(NSString *)eventName metric:(NSNumber *)metric
{
    [DialerUsageRecord recordCustomEvent:eventName metric:metric extraInfo:nil];
}

+ (void)recordCustomEvent:(NSString *)eventName extraInfo:(NSDictionary *)extraInfo
{
    [DialerUsageRecord recordCustomEvent:eventName metric:nil extraInfo:extraInfo];
}

+ (void)recordCustomEvent:(NSString *)eventName metric:(NSNumber *)metric extraInfo:(NSDictionary *)extraInfo
{
    eventName = eventName == nil ? @"" : [eventName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([eventName isEqualToString:@""]) {
        cootek_log([NSString stringWithFormat:@"ignored empty event name"]);
    }
    else if (![UserDefaultsManager boolValueForKey:[USAGE_CUSTOM_EVENT_PREFIX stringByAppendingString:eventName]
                                      defaultValue:[UserDefaultsManager boolValueForKey:USAGE_CUSTOM_EVENT_DEFAULT_ON defaultValue:YES]]) {
        cootek_log([NSString stringWithFormat:@"ignored blocked event name: %@", eventName]);
    }
    else {
        cootek_log([NSString stringWithFormat:@"packing event data: %@", eventName]);
        NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
        if (extraInfo != nil) {
            [data addEntriesFromDictionary:extraInfo];
            [data removeObjectForKey:CUSTOM_EVENT_NAME];
            [data removeObjectForKey:CUSTOM_EVENT_VALUE];
        }

        [data setValue:eventName forKey:CUSTOM_EVENT_NAME];
        if (metric != nil) {
            [data setValue:metric forKey:CUSTOM_EVENT_VALUE];
        }

        cootek_log([NSString stringWithFormat:@"sending event data %@", [extraInfo mj_JSONString]]);
        [UsageRecorder record:USAGE_TYPE path:PATH_CUSTOM_EVENT values:data];
        [UsageRecorder send];
    }
}

@end
