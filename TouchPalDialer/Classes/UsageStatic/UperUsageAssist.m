//
//  UsageAssit.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14/12/17.
//
//

#import "UperUsageAssist.h"
#import "SeattleFeatureExecutor.h"
#import <Usage_iOS/UsageInfoProvider.h>

@implementation UperUsageAssit
- (NSString *)token
{
    return [SeattleFeatureExecutor getToken];
}

- (NSString*)strategyFileName {
    return @"usage_upload_strategy.xml";
}

- (NSString *)storagePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

- (int)getInfoInterval:(int)flag {
    if(flag == kUsageInfoCallVOIPHistory) {
        return 7;
    } else {
        return -1;
    }
}

@end
