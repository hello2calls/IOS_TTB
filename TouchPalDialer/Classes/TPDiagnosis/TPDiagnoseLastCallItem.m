//
//  TPDiagnoseLastCallItem.m
//  TouchPalDialer
//
//  Created by siyi on 16/7/21.
//
//


#import "TPDiagnoseLastCallItem.h"
#import "UserDefaultsManager.h"
#import "TPDiagnoseManager.h"

@implementation TPDiagnoseLastCallItem

+ (NSString *) diagnoseCode {
    return @"8647";
}

- (NSString *) alertTitle {
    return NSLocalizedString(@"last_free_call", @"最近一次免费电话");
}

- (NSString *) getBody {
    // all about the last call
    NSMutableDictionary *lastCallInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSString *callerNumber = [UserDefaultsManager stringForKey:LAST_FREE_CALL_CALLER_NUMBER defaultValue:@""];
    NSString *calleeNumber = [UserDefaultsManager stringForKey:LAST_FREE_CALL_CALLEE_NUMBER defaultValue:@""];
    BOOL isVipInLastCall = [UserDefaultsManager boolValueForKey:LAST_FREE_CALL_IS_VIP defaultValue:NO];
    BOOL isForcedOffline = [UserDefaultsManager boolValueForKey:LAST_FREE_CALL_IS_FORCED_OFFLINE defaultValue:NO];
    NSString *lastErrorCode = [UserDefaultsManager stringForKey:LAST_FREE_CALL_ERROR_CODE defaultValue:@""];
    NSString *callType = [UserDefaultsManager stringForKey:LAST_FREE_CALL_TYPE defaultValue:@""];
    NSString *networkType = [UserDefaultsManager stringForKey:LAST_FREE_CALL_NETWORK_TYPE defaultValue:@""];
    //
    [lastCallInfo setObject:callerNumber forKey:NSLocalizedString(@"caller_number", @"主叫号码")];
    [lastCallInfo setObject:calleeNumber forKey:NSLocalizedString(@"callee_number", @"被叫号码")];
    [lastCallInfo setObject:[TPDiagnoseManager getVoipPriviledgeDescription:isVipInLastCall] forKey:NSLocalizedString(@"vip_info", @"VIP信息")];
    [lastCallInfo setObject:[TPDiagnoseManager getForcedOfflineDescription:isForcedOffline] forKey:NSLocalizedString(@"voip_priviledge_info", @"掐断信息")];
    [lastCallInfo setObject:lastErrorCode forKey:NSLocalizedString(@"error_code_info", @"错误码信息")];
    [lastCallInfo setObject:networkType forKey:NSLocalizedString(@"network_status", @"网络状况")];
    [lastCallInfo setObject:callType forKey:NSLocalizedString(@"call_type", @"拨号类型")];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:lastCallInfo options:NSJSONWritingPrettyPrinted error:&error];
    if (data == nil
        || error != nil) {
        return @"";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end