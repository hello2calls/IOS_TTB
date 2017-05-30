//
//  AdDebugStatsManager.m
//  TouchPalDialer
//
//  Created by siyi on 16/7/22.
//
//

#import "AdDebugStatsManager.h"
#import "HangupCommercialManager.h"
#import "FileUtils.h"
#import "SeattleFeatureExecutor.h"

@implementation AdDebugStatsManager

+ (void) recordLastAdStats:(NSDictionary *)info {
    if (info == nil || info.count == 0) {
        return;
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSMutableDictionary *adstats = [[NSMutableDictionary alloc] initWithDictionary:info];
        NSArray *notReadyRes = [[HangupCommercialManager instance] getNotReadyAdResources];
        [adstats setObject:notReadyRes forKey:KEY_LAST_AD_NOT_READY_RESOURCE];
        NSString *tu = [info objectForKey:KEY_LAST_AD_TU];
        NSString *fileName = nil;
        if ([tu isEqualToString:kAD_TU_CALLING]
            || [tu isEqualToString:kAD_TU_BACKCALL]) {
            fileName = LAST_AD_CALLING_STATS_FILE;
        } else if ([tu isEqualToString:kAD_TU_HANGUP]
                   || [tu isEqualToString:kAD_TU_BACKCALLHANG]) {
            fileName = LAST_AD_HANGUP_STATS_FILE;
        }
        if (fileName != nil) {
            NSString *filePath = [FileUtils getAbsoluteFilePath:filePath];
            [adstats writeToFile:filePath atomically:YES];
        }
    });
}

@end
