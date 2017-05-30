//
//  UsageRecorder.m
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-23.
//  Copyright (c) 2014年 hello. All rights reserved.
//
#define TIME_KEY (@"timestamp")
#define APP_VERSION (@"app_version")
#import "UsageRecorder.h"

#define USAGE_TYPE (@"noah_usage_inner")
#define PATH_INVALID_USAGE (@"path_noah_usage_invalid")

typedef enum : NSInteger {
    TYPE_CHECK = 0,
    PATH_CHECK,
    SERVER_CHECK
} CheckType;

static UsageProcessor *sProcessor;
static UsageAssist *sAssist;
static NSString *storagePath;
@implementation UsageRecorder

+ (UsageAssist *)sAssist {
    return sAssist;
}

+ (void)initialize:(id<UsageAbsUsageAssist>)assist {
    if (assist == NULL) {
        #ifdef DEBUG
        NSLog(@"UsageRecorder can't initialize with a null assist.");
        #endif
    }
    sAssist = [[UsageAssist alloc] initWithAssist:assist];
}

+ (UsageProcessor *)getProcessor {
    if (sProcessor == nil) {
        @synchronized (self) {
            if (sProcessor == nil) {
                if (sAssist == nil) {
                    #ifdef DEBUG
                    NSLog(@"UsageRecorder is not initialized.");
                    #endif
                }
                sProcessor = [[UsageProcessor alloc] init];
            }
        }
    }
    return sProcessor;
}

+ (void)record:(NSString *)type path:(NSString *)path values:(NSDictionary *)values {
    if (![self checkValidName:type andType:TYPE_CHECK] || ![self checkValidName:path andType:PATH_CHECK]) {
        return;
    }
    if (![NSJSONSerialization isValidJSONObject:values]) {
        [sAssist invalidRecordValues:values];
        values = [NSDictionary dictionaryWithObjectsAndKeys:type,@"type",path,@"path",nil];
        type = USAGE_TYPE;
        path = PATH_INVALID_USAGE;
    }
    UsageRecord *record = [[UsageRecord alloc] init];
    record.type = type;
    record.path = path;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:values];
    NSNumber *time = [[NSNumber alloc] initWithDouble:floor([[UsageSettings getInst] getCurrentTime])];
    NSNumber *timezone = [[NSNumber alloc] initWithDouble:floor([[UsageSettings getInst] getTimeZone])];
    [dict setValue:time forKey:TIME_KEY];
    [dict setValue:timezone forKey:TIME_ZONE];
    if ([sAssist getVersionCode] >= 0) {
        [dict setValue:[NSNumber numberWithInt:[sAssist getVersionCode]] forKey:APP_VERSION];
    }
    record.values = dict;
    if (record.type != nil && record.path != nil) {
        [[UsageRecorder getProcessor] saveRecord:record];
    }
}

+ (void)updateStrategyFile:(NSString *)path {
    [[UsageRecorder getProcessor] updateStrategy:path];
}

+ (void)send {
    [[UsageRecorder getProcessor] sendData];
    [[UsageRecorder getProcessor] sendInfoData];
}

+ (BOOL)checkValidName:(NSString *)name andType:(CheckType)type {
    if (name == nil) {
        return NO;
    }
    NSString *regex = [[NSString alloc] init];
    switch (type) {
        case TYPE_CHECK:
            regex = @"[a-zA-Z0-9_]*";
            break;
        case PATH_CHECK:
            regex = @"[a-zA-Z0-9_/.]*";
            break;
        case SERVER_CHECK:
            regex = @"[a-zA-Z0-9./-]*";
            break;
        default:
            return NO;
            break;
    }
    NSError *error = NULL;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regExp firstMatchInString:name options:0 range:NSMakeRange(0, [name length])];
    return (BOOL)result;
}

@end















