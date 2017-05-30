//
//  SeattleEngine.m
//  TPDialerAdvanced
//
//  Created by ThomasYe on 13/5/23.
//
//

#import "SeattleEngine.h"
#import "SeattleChannel.h"
#import "SeattleSetting.h"
#import "SeattleEventHandler.h"
#import "AdvancedSettingUtility.h"
#import "feature_runner.h"
#import "define.h"
#import "CStringUtils.h"
#import "activate_feature.h"
#import "yellowpage_info_feature.h"

#define ACTIVATE_IDENTIFIER @"ACTIVATE_IDENTIFIER"
#define ACTIVATE_INTERVAL (30)

@implementation SeattleEngine

+ (void)initialize
{
    cootek_log_function;
    SeattleChannelManager* mgr = new SeattleChannelManager();
    SeattleSetting* setting = new SeattleSetting();
    SeattleEventHandler *handler = new SeattleEventHandler();
    
    TPSTRING str;
    FeatureRunner::initialize(mgr, setting, handler, str);
}

+ (FeatureExecuteResult)executeFeature:(Feature *)feature
{
    if ([[Reachability shareReachability] currentReachabilityStatus] == NotReachable) {
        return FeatureExecuteResultFailCouldRetry;
    }
    
    FeatureRunner::get_inst().execute_feature(feature);
    switch (feature->get_status()) {
        case kFeatureDone:
            return FeatureExecuteResultSuccess;
        case kFeatureNeedRetry:
            return [self executeFeature:feature];
        case kFeatureNeedRetryLater:
            [NSThread sleepForTimeInterval:300];
            return [self executeFeature:feature];
        case kFeatureFailedMaybeRetryLater:
            return FeatureExecuteResultFailCouldRetry;
        default:
            return FeatureExecuteResultFail;
    }
}

+ (BOOL) fillNumberInfo:(NumberInfoModel*) data {
    cootek_log_function;
    
    if(data.isCallerId) {
        return YES;
    }
    BOOL find = NO;
    
    NSString* number = data.normalizedNumber;
    
    YellowpageInfoFeature* feature = new YellowpageInfoFeature();
    YellowpageInfoRequestMessage* msg = (YellowpageInfoRequestMessage*) feature->get_request()->get_data();
    msg->phone.push_back(CStringUtils::nsstr2cstr(number));

    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        YellowpageInfoResponseMessage *response = (YellowpageInfoResponseMessage *)(feature->get_response()->get_data());
        if (response->res.size() > 0) {
            CallerInfoMessage *item = response->res[0];
            if (item) {
                data.isCallerId = YES;
                data.verified = (item->verify_type == "verified");
                data.classify = CStringUtils::cstr2nsstr(item->classify_type);
                data.markCount = item->mark_count;
                data.name = CStringUtils::cstr2nsstr(item->shop_name);
                data.cacheLevel = 2;
                data.versionTime = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
                find = YES;
            }
        }
    }
    [data printInfo];
    delete feature;
    return find;
}

int lastSuccessTime = 0;

+ (BOOL) activateWithType:(ActivateType) type {
    cootek_log_function;
    NSString *appName = @"cootek.contactplus.ios.public.advanced";
    NSString *version = @"4580";
    NSString *identifier = [AdvancedSettingUtility querySetting:ACTIVATE_IDENTIFIER];
    if ([identifier length] == 0) {
//        identifier = [NSString stringWithNewUUID];
//        [AdvancedSettingUtility setAdvancedSetting:ACTIVATE_IDENTIFIER
//                                             value:identifier];
//        identifier = @"thomas test";
    }
    
    @synchronized(self) {
        if (([[NSDate date] timeIntervalSince1970] - lastSuccessTime) < ACTIVATE_INTERVAL) {
            return YES;
        }
        
        __block ActivateFeature *feature = new ActivateFeature();
        ActivateRequestMessage *msg = (ActivateRequestMessage *)(feature->get_request()->get_data());
        
        NSString *t;
        switch (type) {
            case ActivateTypeNew:
                t = @"new";
                break;
            case ActivateTypeRenew:
                t = @"renew";
                break;
            case ActivateTypeUpgrade:
                t = @"upgrade";
                break;
            default:
                // not supported
                return NO;
        }
        
        msg->activate_type = CStringUtils::nsstr2cstr(t);
        msg->app_name = CStringUtils::nsstr2cstr(appName);
        msg->app_version = CStringUtils::nsstr2cstr(version);
        msg->identifier = CStringUtils::nsstr2cstr(identifier);
        
        FeatureExecuteResult result = [self executeFeature:feature];
        if (result == FeatureExecuteResultSuccess) {
            lastSuccessTime = (int) [[NSDate date] timeIntervalSince1970];
        }
        
        delete feature;
        return (result == FeatureExecuteResultSuccess);
    }

    return YES;
}

+(BOOL) uploadCallHistory {
    cootek_log_function;
    return YES;
}

@end
