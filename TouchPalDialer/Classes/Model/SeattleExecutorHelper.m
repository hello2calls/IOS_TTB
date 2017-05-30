//
//  SeattleExecutorHelper.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-31.
//
//

#import "SeattleExecutorHelper.h"
#import "SeattleFeatureExecutor.h"
#import "TouchPalVersionInfo.h"
#import "CallerIDInfoModel.h"
#import "OpenUDID.h"
#import "DeviceSim.h"
#import <sys/utsname.h>
#import "UserDefaultsManager.h"
#import "CallLogDBA.h"
#import "CallLogDataModel.h"
#import "NSString+UUID.h"
#import "FunctionUtility.h"
#import "DialerUsageRecord.h"
#import <Usage_iOS/UsageRecorder.h>

@implementation RequiredSeattleExecutorHelper
static dispatch_queue_t squeue;
+ (void)initialize {
    squeue = dispatch_queue_create("com.cootek.smartdialer.seattle_excutor", NULL);
}

+ (BOOL)activateWithType:(ActivateType)type
{
    BOOL result = [self activateTouchPal:COOTEK_APP_NAME withVersion:CURRENT_TOUCHPAL_VERSION activeType:type];
    if (result &&
        (type == ActivateTypeNew || type == ActivateTypeUpgrade)) {
        [UserDefaultsManager setObject:CURRENT_TOUCHPAL_VERSION forKey:KEY_ACTIVATED_PRODUCT_VERSION];
    }
    
    return result;
}

+ (BOOL)activateTouchPal:(NSString *)appName
             withVersion:(NSString *)version
              activeType:(ActivateType)activetype{
	if ([appName length]==0||[version length]==0) {
		return NO;
	}
	UIDevice *device=[UIDevice currentDevice];
    NSString *osName = [device systemName];
    NSString *osVersion = [device systemVersion];
    NSString *deviceInfo = [self deviceInfo];
    NSString *UUID = [FunctionUtility GetUUID];
    NSString *chanelCode = IPHONE_CHANNEL_CODE;
    DeviceSim *infoSim = [[DeviceSim alloc] init];
    NSString *mnc = [infoSim mccMnc];
    
    NSArray* languages = [NSLocale preferredLanguages];
    NSString *local  = [languages objectAtIndex:0];
    NSString *identifier = [UserDefaultsManager stringForKey:ACTIVATE_IDENTIFIER];
    
    NSString *appleToken = [UserDefaultsManager stringForKey:APPLE_PUSH_TOKEN];
    
    if ([identifier length] == 0) {
        identifier = UUID;
        [UserDefaultsManager setObject:identifier forKey:ACTIVATE_IDENTIFIER];
        [UserDefaultsManager synchronize];
    }
    
    return [SeattleFeatureExecutor activateWithName:appName
                                            version:version
                                       activateType:activetype
                                             osName:osName
                                          osVersion:osVersion
                                         deviceInfo:deviceInfo
                                        channelCode:chanelCode
                                               imei:nil
                                               uuid:UUID
                                              simid:@""
                                             locale:local
                                                mnc:mnc
                                         identifier:identifier
                                         appleToken:appleToken];
    
}


+(NSString*)deviceInfo{
    struct utsname u;
	uname(&u);
    return [NSString stringWithCString:u.machine encoding:NSUTF8StringEncoding];
}

+ (void) handleQueryCallerIdResult:(CloudCallerIdInfo *)callerInfo
{
    // Do nothing. the caller will handle it.
}

+ (NSArray *)calllogsSinceDate:(NSDate *)date{
    NSArray *callLogs = [CallLogDBA querycallogsStart:[date timeIntervalSince1970] endTime:[[NSDate date] timeIntervalSince1970]];
    return [self cloudCallLogsFromOriginalCallLogs:callLogs];
}

+ (NSArray *)recentlyCalllogsWithCount:(int)count{
    NSArray *callLogs = [CallLogDBA queryRecentlyCallLogsWithCount:count];
    return [self cloudCallLogsFromOriginalCallLogs:callLogs];
}

+ (NSArray *)cloudCallLogsFromOriginalCallLogs:(NSArray *)callLogs{
    if(callLogs.count > 0){
        NSMutableArray *cloudCallLogs = [[NSMutableArray alloc] initWithCapacity:callLogs.count];
        for(CallLogDataModel *callLog in callLogs){
            [cloudCallLogs addObject:[callLog cloudCallLogItem]];
        }
        return cloudCallLogs;
    }
    return nil;
}

+ (CLLocationCoordinate2D)currentLocation{
    CLLocationCoordinate2D location2D;
    NSDictionary *location = [UserDefaultsManager dictionaryForKey:LOCATION_2D];
    // Now we do not have a proper way to update location, so return inEfective location info.
    BOOL isInEfective = YES;
    if(isInEfective || location == nil || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        location2D.latitude = INVALID_LOCATION_VALUE;
        location2D.longitude = INVALID_LOCATION_VALUE;
    }else{
        location2D.latitude = [[location objectForKey:@"latitude"] doubleValue];
        location2D.longitude = [[location objectForKey:@"longitude"] doubleValue];
    }
    return location2D;
}
@end


@implementation SeattleExecutorHelper

+ (NSArray *)queryCallerIdInfo:(NSArray *)numbers
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[numbers count]];
    CLLocationCoordinate2D location = [RequiredSeattleExecutorHelper currentLocation];
    NSArray *infos = [SeattleFeatureExecutor queryCallerInfoWithSurvey:NO phones:numbers networkMnc:nil hasLocation:location.latitude != INVALID_LOCATION_VALUE location:location];
    NSMutableArray *remaining = [NSMutableArray arrayWithArray:numbers];
    
    for (CloudCallerIdInfo *info in infos) {
        CallerIDInfoModel *model = [[CallerIDInfoModel alloc] initWithCloudData:info];
        [result addObject:model];
        [remaining removeObject:info.phone];
    }
    
    for (NSString *number in remaining) {
        CallerIDInfoModel *callerId = [[CallerIDInfoModel alloc] init];
        callerId.number = number;
        if (infos) {
            callerId.callerIDCacheLevel = CallerIDQueryNotFindLevel;
        } else {
            callerId.callerIDCacheLevel = CallerIDQueryFailedLevel;
        }
        [result addObject:callerId];
    }
    
    return result;
}

+ (BOOL)activateTouchPalForInstallation
{
    NSString*  oldVersion = [UserDefaultsManager stringForKey:KEY_ACTIVATED_PRODUCT_VERSION];
    if ([oldVersion length]>0) {
        NSInteger old = [oldVersion intValue];
        NSInteger new = [CURRENT_TOUCHPAL_VERSION intValue];
        if (new > old) {
            return [RequiredSeattleExecutorHelper activateWithType:ActivateTypeUpgrade];
        }
    } else {
        [DialerUsageRecord recordpath:PATH_ACTIVATE kvs:Pair(ACTIVATE_TYPE, @"new"), nil];
        //real-time sending the activating info
        NSMutableDictionary *activateInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
        [activateInfo setObject:@"request_activate_new" forKey:REAL_TIME_ACTIVATE_TYPE];
        NSString *registeredNumber = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
        if (registeredNumber.length > 0) {
            [activateInfo setObject:registeredNumber forKey:VOIP_REGISTER_ACCOUNT_NAME];
        }

        [DialerUsageRecord record:USAGE_TYPE_DIALER_IOS path:PATH_REAL_TIME_ACTIVATE values:[activateInfo copy]];
        [UsageRecorder send];
        
        return [RequiredSeattleExecutorHelper activateWithType:ActivateTypeNew];
    }
    return NO;
}
@end

