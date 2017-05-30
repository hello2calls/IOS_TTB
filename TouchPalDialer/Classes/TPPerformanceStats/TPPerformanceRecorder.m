//
//  TPPerformanceRecorder.m
//  TouchPalDialer
//
//  Created by siyi on 16/8/17.
//
//

#import "TPPerformanceRecorder.h"
#import "NSString+TPHandleNil.h"
#import "DialerUsageRecord.h"
#import "DateTimeUtil.h"

@implementation TPPerformanceRecorder

extern CFAbsoluteTime mainStartTime;

+ (void) recordWithTime:(double)recordTime forPath:(NSString *)path inDuration:(NSString *)durationName byAction:(NSString *)action {
    if (![NSString isNilOrEmpty:action]) {
        durationName = [NSString stringWithFormat:@"%@_%@", durationName, action];
    }
    [TPPerformanceRecorder recordWithTimeInterval:(recordTime - mainStartTime) forPath:path inDuration:durationName];
}

+ (void) recordWithTimeInterval:(double)timeInterval forPath:(NSString *)path inDuration:(NSString *)durationName {
    if ([NSString isNilOrEmpty:path]
        || [NSString isNilOrEmpty:durationName]) {
        return;
    }
    NSNumber *timestamp = @(timeInterval * 1000 * 1000);
    cootek_log(@"app_performance, path= %@, durationName= %@, timestamp= %@", path, durationName, [timestamp stringValue]);
    [DialerUsageRecord recordpath:path kvs:Pair(durationName, timestamp), nil];
}

@end
