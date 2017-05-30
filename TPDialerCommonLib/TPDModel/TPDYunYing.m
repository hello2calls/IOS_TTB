//
//  TPDYunYing.m
//  TouchPalDialer
//
//  Created by weyl on 16/12/22.
//
//

#import "TPDYunYing.h"
#import "TouchPalVersionInfo.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "LocalStorage.h"
#import "SeattleFeatureExecutor.h"
#import "ASIWrapper.h"
#import "IndexConstant.h"
#import <MJExtension.h>
#import "TPDLib.h"

@implementation TPDYunYing
+(TPDYunYingRequestParam*)defaultParam{
    TPDYunYingRequestParam* ret = [[TPDYunYingRequestParam alloc] init];
    ret.adclass = @"EMBEDDED";
    ret.rt = @"JSON";
    ret.ch = COOTEK_APP_NAME;
    ret.adn = 2;
    ret.v = CURRENT_TOUCHPAL_VERSION;
    ret.nt = [FunctionUtility networkType].uppercaseString;
    ret.at = @"IMG|TXT";
    ret.open_free_call = [UserDefaultsManager boolValueForKey:IS_VOIP_ON defaultValue:NO];
    
    ret.city = [LocalStorage getItemWithKey:NATIVE_PARAM_CITY];
    ret.addr = [LocalStorage getItemWithKey:NATIVE_PARAM_ADDR];
    
    NSString *cacheTimeString = [LocalStorage getItemWithKey:NATIVE_PARAM_LOCATION_CACHE_TIME];
    long cacheTime = [cacheTimeString longLongValue];
    if (cacheTime > 0 && [[NSDate date] timeIntervalSince1970] * 1000 - cacheTime <= 3600000) {
        NSString *cacheLoc = [LocalStorage getItemWithKey:NATIVE_PARAM_LOCATION];
        cacheLoc = [cacheLoc stringByReplacingOccurrencesOfString:@"[" withString:@""];
        cacheLoc = [cacheLoc stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *locAttr = [cacheLoc componentsSeparatedByString:@","];
        if (locAttr.count == 2 && ((NSString *)locAttr[0]).length > 0) {
            double latitude = [locAttr[0] doubleValue];
            double longitude = [locAttr[1] doubleValue];
            ret.latitude = latitude;
            ret.longtitude = longitude;
        }
    }
    ret.token = [SeattleFeatureExecutor getToken] ? [SeattleFeatureExecutor getToken] : @"";
    ret.ip = [ASIWrapper getIPAddress:YES];
    
    return ret;
}

+(TPDYunYingItem*)getYunYingByPosition:(YunYinPosition)position{
    TPDYunYingRequestParam* p = [TPDYunYing defaultParam];
    p.tu = [NSString stringWithFormat:@"%d",position];
    
    NSString* url = YP_AD_REQUEST_URL;
    //    NSString* url = [NSString stringWithFormat:@"%@/yellowpage_v3/experiment_query",@"http://121.52.235.231:40013"];
    
    ASIWrapper* wrapper = [ASIWrapper defaultWrapperObject];
    wrapper.pathStr = url;
    wrapper.params = [p mj_keyValues];
    //    wrapper.responseStructKey = @"result";
    
    [ASIWrapper getRequest:wrapper];
    
    
    //    NSDictionary* d = wrapper.responseStruct;
    if (wrapper.success) {
        NSLog(@"%@",wrapper.cache);
        NSDictionary* yunyin = [wrapper.cache tpd_JSONValue][@"ad"][0][@"ads"][0];
        TPDYunYingItem* ret = [TPDYunYingItem mj_objectWithKeyValues:yunyin];
        return ret;
    }else
        return nil;
    
}

+(void)load{
//    [TPDYunYing getYunYingByPosition:YunYinPositionCallLog];
}
@end


@implementation TPDYunYingItem

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"ed_monitor_url":[NSString class],
             };
}

@end

@implementation TPDYunYingRequestParam

@end

@implementation TPDYunYingReserve

@end
