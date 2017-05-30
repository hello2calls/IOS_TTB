//
//  AdvancedCalllog.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvancedSettingKeys.h"

extern NSInteger NO_TWEAK;

@interface AdvancedCalllog : NSObject
+(void)setChannelCode:(NSString*) channelCode;
+(BOOL)synCalllog;
+(NSString *)getTPDialerDBPath;
+(BOOL)isAccessCallDB;
+(NSInteger) getAdvancedTweakVersion;
+(BOOL)checkVersion:(NSInteger)tweakVersion;
+(BOOL) canHaveTweak;
+(BOOL) canFreshInstallTweak;
+(BOOL) canUpdateTweak;
+(void) addAdvancedSetting:(id)value forKey:(NSString*) key;
+(void) reportVersion;
+(void) prepare;
+(BOOL) isShowLogsType;

+ (BOOL)isAccessCallHistoryDB;
+ (BOOL)SynCalllogFromSystemDB;
@end
