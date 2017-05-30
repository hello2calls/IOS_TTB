//
//  AdDebugStatsManager.h
//  TouchPalDialer
//
//  Created by siyi on 16/7/22.
//
//

#ifndef AdDebugStatsManager_h
#define AdDebugStatsManager_h


#define KEY_LAST_AD_TU @"tu"
#define KEY_LAST_AD_ERROR_CODE @"error_code"
#define KEY_LAST_AD_HTML_TU_EMPTY @"html_tu_empty"
#define KEY_LAST_AD_NOT_READY_RESOURCE @"not_ready_resource"

#define LAST_AD_CALLING_STATS_FILE @"last_ad_calling_stats.plist"
#define LAST_AD_HANGUP_STATS_FILE @"last_ad_hangup_stats.plist"

typedef NS_ENUM(NSInteger, AdDefaultReason) {
    kAdDefaultReasonRequestFailed,
    kAdDefaultReasonRequestResourceEmpty,
    kAdDefaultReasonRequestDownloading,
};

#import <Foundation/Foundation.h>

@interface AdDebugStatsManager : NSObject

+ (void) recordLastAdStats:(NSDictionary *)info;

@end

#endif /* AdDebugStatsManager_h */
