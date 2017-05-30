//
//  AdvancedCalllog.m
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdvancedCalllog.h"
#import "AppSettingsModel.h"
#import "UserDefaultsManager.h"
#import "AdvancedSyncCalllog.h"

NSInteger LATEST_TWEAK_VERSION = 4580;
NSInteger REQUIRED_MIN_TWEAK_VERSION = 4300;
NSInteger NO_TWEAK = -1;

@implementation AdvancedCalllog

+ (void)setChannelCode:(NSString*)channelCode
{
    [UserDefaultsManager setObject:channelCode forKey:ADVANCED_SOURCE_CHANNEL_KEY];
    
}

+ (BOOL)SynCalllogFromSystemDB {
    return NO;
}

+ (BOOL)synCalllog
{
    if (![self isAccessCallDB]) {
        return NO;
    }
    
    // If want to use the old bigboss plugin, uncomment the following line.
    // return [self SynCalllogFromSystemDB];
    
    // If want to directly access system callog, uncomment the following lines.
    return [AdvancedSyncCalllog copySystemCalllogToTPDialer:[self getTPDialerDBPath]];
}

+ (NSString *)getTPDialerDBPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *filepath = [documentDirectory stringByAppendingPathComponent:@"data.sqlite"];
    return filepath;
}

+ (BOOL)isAccessCallHistoryDB {
    return NO;
}

+ (BOOL)isAccessCallDB
{
    // If want to test non-jailbreak phone feature, uncomment the following line.
     return NO;
    
    // If want to use the old bigboss plugin, uncomment the following line.
    // return [self isAccessCallHistoryDB];
    
    
    // If want to direct access system callog, uncomment the following lines.
    
    // check if it's jailbroken phone. Avoid trying to access system db file for un-jailbroken phones.
    if (![self canHaveTweak]) {
        return NO;
    }
    
    return  [AdvancedSyncCalllog isAccessCallHistoryDB];
}

+ (BOOL)isShowLogsType
{
    return YES;
    //return [AdvancedCalllog isAccessCallDB];
}

+ (NSInteger)getAdvancedTweakVersion
{
    return NO_TWEAK;
}

+ (BOOL)checkVersion:(NSInteger)tweakVersion
{
    if (LATEST_TWEAK_VERSION < tweakVersion) {
        return NO;
    }
    
    if (REQUIRED_MIN_TWEAK_VERSION > tweakVersion) {
        return NO;
    }
    
    return YES;
}

+ (void)reportVersion
{
    NSInteger v = [AdvancedCalllog getAdvancedTweakVersion];
    if(v != NO_TWEAK) {
        cootek_log(@"report tweak version %d", v);
        
    }
}

+ (BOOL)canHaveTweak
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]];
}

+ (BOOL)canFreshInstallTweak
{
    if(![AdvancedCalllog canHaveTweak]) {
        return false;
    }
    
    return [AdvancedCalllog getAdvancedTweakVersion] == NO_TWEAK;
}

+ (BOOL)canUpdateTweak
{
    if(![AdvancedCalllog canHaveTweak]) {
        return false;
    }
    
    NSInteger currentVersion = [AdvancedCalllog getAdvancedTweakVersion];
    return (currentVersion != NO_TWEAK) && (currentVersion < LATEST_TWEAK_VERSION);
}

+ (void)addAdvancedSetting:(id)value forKey:(NSString *)key
{
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *settingPath = [documentDirectory stringByAppendingPathComponent:@"advancedSetting.plist"];
    NSMutableDictionary* dict;
    
    if([manager fileExistsAtPath:settingPath] && [manager isReadableFileAtPath:settingPath]) {
        cootek_log(@"load setting from %@", settingPath);
        dict = [NSMutableDictionary dictionaryWithContentsOfFile:settingPath];
    } else {
        cootek_log(@"create setting dict");
        dict = [[NSMutableDictionary alloc] init];
    }
    
    [dict setObject:value forKey:key];
    
    if([manager isWritableFileAtPath:settingPath] || (![manager fileExistsAtPath:settingPath])) {
        BOOL success = [dict writeToFile:settingPath atomically:YES];
        if(success) {
            cootek_log(@"write settings successfully");
        } else {
            cootek_log(@"failed to write settings");
        }
    } else {
        cootek_log(@"cannot write settings to %@", settingPath);
    }
    
}

+ (void)prepare
{
    // CurrentVersion
    [AdvancedCalllog addAdvancedSetting:[NSString stringWithFormat:@"%d", LATEST_TWEAK_VERSION] forKey:ADVANCED_SETTING_LATEST_TWEAK_VERSION];
    BOOL enableQueryCallerId = YES;
    // disable the query from network feature in tweak, as the old tweak cannot work with new api.
    [AdvancedCalllog addAdvancedSetting:[NSNumber numberWithBool:enableQueryCallerId] forKey:ADVANCED_SETTING_USE_NETWORK_SMART_EYE];
}

@end
