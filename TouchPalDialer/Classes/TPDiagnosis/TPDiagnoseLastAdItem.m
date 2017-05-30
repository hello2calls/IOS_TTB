//
//  TPDiagnoseLastAdItem.m
//  TouchPalDialer
//
//  Created by siyi on 16/7/20.
//
//

#import "TPDiagnoseLastAdItem.h"
#import "UserDefaultsManager.h"
#import "AdDebugStatsManager.h"
#import "FileUtils.h"
#import "NSString+TPHandleNil.h"
#import "TPDiagnoseManager.h"

@implementation TPDiagnoseLastAdItem

+ (NSString *) diagnoseCode {
    return @"23";
}

- (NSString *) alertTitle {
    return NSLocalizedString(@"last_ad", @"最近一次广告");
}

- (NSString *) alertMessage {
    // all about the last ad
    NSMutableDictionary *lastAdInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    NSString *callerNumber = [UserDefaultsManager stringForKey:LAST_FREE_CALL_CALLER_NUMBER defaultValue:@""];
    NSString *calleeNumber = [UserDefaultsManager stringForKey:LAST_FREE_CALL_CALLEE_NUMBER defaultValue:@""];
    NSString *lastErrorCode = [UserDefaultsManager stringForKey:LAST_FREE_CALL_ERROR_CODE defaultValue:@""];
    
    NSString *callType = [UserDefaultsManager stringForKey:LAST_FREE_CALL_TYPE defaultValue:@""];
    NSString *callTypeDescription = [TPDiagnoseManager getCallTypeDescription:callType];
    
    NSString *networkType = [UserDefaultsManager stringForKey:LAST_FREE_CALL_NETWORK_TYPE defaultValue:@""];
    
    NSString *adPageType = [UserDefaultsManager stringForKey:LAST_AD_PAGE_TYPE defaultValue:@""];
    NSString *adPageTypeDescription = [TPDiagnoseManager getAdPageTypeDescription:adPageType];
    
    AdDefaultReason adPageDetail = [UserDefaultsManager intValueForKey:LAST_AD_PAGE_DETAIL defaultValue:-1];
    NSString *adPageDetailDescription = [TPDiagnoseManager getDefaultAdReasonDescription:adPageDetail];
    NSString *lastAdId = [UserDefaultsManager stringForKey:LAST_AD_ID defaultValue:@""];
    
    //
    [lastAdInfo setObject:lastAdId forKey:NSLocalizedString(@"ad_id", @"广告ID")];
    [lastAdInfo setObject:callerNumber forKey:NSLocalizedString(@"caller_number", @"主叫号码")];
    [lastAdInfo setObject:calleeNumber forKey:NSLocalizedString(@"callee_number", @"被叫号码")];
    [lastAdInfo setObject:networkType forKey:NSLocalizedString(@"network_status", @"网络状况")];
    [lastAdInfo setObject:callTypeDescription forKey:NSLocalizedString(@"call_type", @"拨号类型")];
    [lastAdInfo setObject:lastErrorCode forKey:NSLocalizedString(@"error_code_info", @"错误码信息")];
    [lastAdInfo setObject:adPageTypeDescription forKey:NSLocalizedString(@"ad_page_info", @"广告展示信息")];
    [lastAdInfo setObject:adPageDetailDescription forKey:NSLocalizedString(@"ad_detail", @"详细信息")];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:lastAdInfo options:NSJSONWritingPrettyPrinted error:&error];
    if (data == nil
        || error != nil) {
        return @"";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *) getBody {
    NSString *callingAdFilePath = [FileUtils getAbsoluteFilePath:LAST_AD_CALLING_STATS_FILE];
    NSString *callingAdString = nil;
    if ([FileUtils fileExistAtAbsolutePath:callingAdFilePath]) {
        NSError *error = nil;
        callingAdString = [NSString stringWithContentsOfFile:callingAdFilePath encoding:NSUTF8StringEncoding error:&error];
        cootek_log(@"%s\n, calling ad, error= %@", __func__, error);
    }
    
    NSString *hangupAdFilePath = [FileUtils getAbsoluteFilePath:LAST_AD_HANGUP_STATS_FILE];
    NSString *hangupAdString = nil;
    if ([FileUtils fileExistAtAbsolutePath:hangupAdFilePath]) {
        NSError *error = nil;
        hangupAdString = [NSString stringWithContentsOfFile:hangupAdFilePath encoding:NSUTF8StringEncoding error:&error];
        cootek_log(@"%s\n, hangup ad, error= %@", __func__, error);
    }
    
    callingAdString = [NSString nilToEmpty:callingAdString];
    hangupAdString = [NSString nilToEmpty:hangupAdString];
    
    return [NSString stringWithFormat:@"%@\n%@\n%@", \
            [self alertMessage], callingAdString, hangupAdString];
}



@end
