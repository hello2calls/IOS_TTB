//
//  Settings.m
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-25.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import "UsageSettings.h"
static volatile UsageSettings *sInst;
@implementation UsageSettings

- (void)removeRecords:(NSString *)strategyName {
    NSString *fileName = [strategyName stringByAppendingString:@"Records.plist"];
    NSString *plistPath = [[[UsageRecorder sAssist] storagePath] stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
    [[NSFileManager defaultManager] createFileAtPath:plistPath contents:nil attributes:nil];
}

- (void)setRecords:(NSMutableArray *)array strategyName:(NSString *)strategyName {
    NSString *fileName = [strategyName stringByAppendingString:@"Records.plist"];
    NSString *plistPath = [[[UsageRecorder sAssist] storagePath] stringByAppendingPathComponent:fileName];
    BOOL success =  [array writeToFile:plistPath atomically:YES];
    NSLog(@"%d", success);
}

- (NSMutableArray *)getRecords:(NSString *)strategyName {
    NSString *fileName = [strategyName stringByAppendingString:@"Records.plist"];
    NSString *plistPath = [[[UsageRecorder sAssist] storagePath] stringByAppendingPathComponent:fileName];
    return [NSMutableArray arrayWithContentsOfFile:plistPath];
}

- (double)getCurrentTime {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

- (double)getTimeZone {
    NSDate *date = [NSDate date];
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    return interval * 1000;
}

+ (volatile UsageSettings *)getInst {
    if (sInst == nil) {
        @synchronized (self) {
            if (sInst == nil) {
                sInst = [[UsageSettings alloc] init];
            }
        }
    }
    return sInst;
}

- (double)getQuietTime:(NSString *)strategyName {
    double lastSuccess = [self getLastSuccess:strategyName];
    double cunrrentTime = [self getCurrentTime];
    return cunrrentTime - lastSuccess;
}

- (double)getLastSuccess:(NSString *)strategyName {
    NSString *fileName = [strategyName stringByAppendingString:@"Time.plist"];
    NSString *plistPath = [[[UsageRecorder sAssist] storagePath] stringByAppendingPathComponent:fileName];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    double result;
    if (dict == nil) {
        [[NSFileManager defaultManager] createFileAtPath:plistPath contents:nil attributes:nil];
        return 0;
    } else {
        result = [[dict objectForKey:@"lastTime"] doubleValue];
    }
    return result;
}

- (void)updateLastSuccess:(NSString *)strategyName {
    NSString *fileName = [strategyName stringByAppendingString:@"Time.plist"];
    NSString *plistPath = [[[UsageRecorder sAssist] storagePath] stringByAppendingPathComponent:fileName];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    if (dict == nil) {
        dict = [[NSMutableDictionary alloc] init];
    }
    double currentTime = [self getCurrentTime];
    [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
    [[NSFileManager defaultManager] createFileAtPath:plistPath contents:nil attributes:nil];
    [dict setObject:[[NSNumber alloc] initWithDouble:currentTime] forKey:@"lastTime"];
    [dict writeToFile:plistPath atomically:YES];
}

- (double)getLastInfoSuccess:(NSString *)infoName {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"last_%@_success",infoName]] doubleValue];
}

- (void)setLastInfoSuccess:(NSString *)infoName andTime:(double)time {
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithDouble:time] forKey:[NSString stringWithFormat:@"last_%@_success",infoName]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (long long)getLastInfoSuccessId:(NSString *)infoName {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"last_%@_keyid_success",infoName]] longLongValue];
}

- (void)setLastInfoSuccessId:(NSString *)infoName andId:(long long)lastId {
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithLongLong:lastId] forKey:[NSString stringWithFormat:@"last_%@_keyid_success",infoName]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
