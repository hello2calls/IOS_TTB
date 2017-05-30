//
//  TPFilterRecorder.m
//  TouchPalDialer
//
//  Created by siyi on 16/11/3.
//
//

#import "TPFilterRecorder.h"
#import "DialerUsageRecord.h"
#import <Usage_iOS/UsageRecorder.h>

static NSMutableDictionary<NSString *, NSMutableDictionary *> *sFilteredData;
@implementation TPFilterRecorder {
    
}

+ (void) initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sFilteredData = [[NSMutableDictionary alloc] init];
    });
}

+ (void) recordpath:(NSString *)path kvarray:(NSArray*)kvarray {
    if (!kvarray || kvarray.count == 0) {
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:kvarray.count];
    for (UsageRecordDataKV *kv in kvarray) {
        if (kv.recordKey && kv.recordValue) {
            [dic setValue:kv.recordValue forKey:kv.recordKey];
        }
    }
    if (dic.count == 0) {
        return;
    }
    NSMutableDictionary *data = [sFilteredData objectForKey:path];
    if (data == nil) {
        data = [[NSMutableDictionary alloc] init];
        [sFilteredData setObject:data forKey:path];
    }
    [data addEntriesFromDictionary:dic];
}

+ (void) recordpath:(NSString *)path kvs:(UsageRecordDataKV *)kv,... NS_REQUIRES_NIL_TERMINATION {
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
    if (dic.count == 0) {
        return;
    }
    NSMutableDictionary *data = [sFilteredData objectForKey:path];
    if (data == nil) {
        data = [[NSMutableDictionary alloc] init];
        [sFilteredData setObject:data forKey:path];
    }
    [data addEntriesFromDictionary:dic];
}

+ (void) sendFilterPath:(NSString *)path {
    NSDictionary *data = [sFilteredData objectForKey:path];
    if (data != nil) {
        if ([path isEqualToString:PATH_LOGIN]) {
            [DialerUsageRecord recordCustomEvent:PATH_LOGIN extraInfo:data];
        } else {
            [DialerUsageRecord record:USAGE_TYPE_DIALER_IOS path:path values:data];
        }
        [TPFilterRecorder clearFilterPath:path];
    }
}

+ (void) clearFilterPath:(NSString *)path {
    [sFilteredData removeObjectForKey:path];
}

@end
