//
//  TouchLifeTabBarAdManager.m
//  TouchPalDialer
//
//  Created by tanglin on 16/6/3.
//
//

#import "TouchLifeTabBarAdManager.h"
#import "UserDefaultsManager.h"
#import "UserDefaultKeys.h"
#import "UpdateService.h"
#import "IndexConstant.h"
#import "SeattleFeatureExecutor.h"
#import "TouchPalVersionInfo.h"
#import "DialerUsageRecord.h"
#import "LocalStorage.h"
#import "FindNewsItem.h"
#import "EdurlManager.h"

TouchLifeTabBarAdManager *_instance_ = nil;

@interface TouchLifeTabBarAdManager()
{
    FindNewsItem* _item;
}
@end
@implementation TouchLifeTabBarAdManager

+ (void)initialize
{
    _instance_ = [[TouchLifeTabBarAdManager alloc] init];
}

+ (TouchLifeTabBarAdManager *)instance
{
    return _instance_;
}

- (void) remoteReqAd
{
    return;
    long current = [[NSDate date] timeIntervalSince1970];
    long last = [UserDefaultsManager doubleValueForKey:TAB_AD_REQ_TIMESTAMP defaultValue:0];
    if ((current - last) < [UserDefaultsManager doubleValueForKey:TAB_AD_REQ_INTERVAL defaultValue:6 * 60 * 60]) {
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSString* url = YP_AD_REQUEST_URL;

        NSString* _token = [SeattleFeatureExecutor getToken] ? [SeattleFeatureExecutor getToken] : @"";
        if (USE_DEBUG_SERVER) {
            url = [NSString stringWithFormat:@"%@%@", YP_DEBUG_SERVER, YP_DEBUG_AD_REQUEST_URL_PATH];
            url = [url stringByAppendingString:@"?debug=1&"];
            _token = @"c52f9618-4069-4e33-bfd7-7cae0219d329";
        } else {
            url = [url stringByAppendingString:@"?"];
        }

        double current = [[NSDate date] timeIntervalSince1970] * 1000;
        NSArray* values = [NSArray arrayWithObjects:
                           @"1",
                           @"190",
                           @"190",
                           @"IMG",
                           @"EMBEDDED",
                           _token,
                           [NSString stringWithFormat: @"%.0f", current],
                           @"304",
                           @"JSON",
                           [DialerUsageRecord getClientNetWorkType],
                           nil];

        NSArray* keys = [NSArray arrayWithObjects:
                         @"adn",
                         @"w",
                         @"h",
                         @"at",
                         @"adclass",
                         @"token",
                         @"prt",
                         @"tu",
                         @"rt",
                         @"nt",
                         nil];
        NSMutableDictionary* paramDic = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];


        [paramDic setObject:CURRENT_TOUCHPAL_VERSION forKey:@"v"];
        [paramDic setObject:COOTEK_APP_NAME forKey:@"ch"];


        NSString* city = [LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY];

        if (city.length == 0) {
            city = (NSString *)[UserDefaultsManager objectForKey:INDEX_CITY_SELECTED];
        }

        if (city.length > 0) {
            [paramDic setValue:city forKey:@"city"];
        }

        NSString* addr = (NSString *)[UserDefaultsManager objectForKey:NATIVE_PARAM_ADDR];

        if (addr.length > 0) {
            [paramDic setValue:addr forKey:@"addr"];
        }


        NSString* latitude = (NSString *)[UserDefaultsManager objectForKey:QUERY_PARAM_LATITUDE];
        NSString* longitude = (NSString *)[UserDefaultsManager objectForKey:QUERY_PARAM_LONGITUDE];


        if (latitude.length> 0 && longitude.length > 0) {
            [paramDic setValue:latitude forKey:@"latitude"];
            [paramDic setValue:longitude forKey:@"longitude"];
        }


        url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:paramDic]];

        NSDictionary* retDic = [[UpdateService instance]requestUrlWithDicResult:url];
        [UserDefaultsManager setDoubleValue:[[NSDate date] timeIntervalSince1970] forKey:TAB_AD_REQ_TIMESTAMP];
        if (retDic.count > 0) {
            NSArray* adArray = [retDic objectForKey:@"ad"];
            if (adArray.count > 0) {
                NSDictionary* adDic = [adArray objectAtIndex:0];
                NSArray* adArr = [adDic objectForKey:@"ads"];

                if (adArr.count > 0) {
                    @synchronized(self) {
                        _item = [[FindNewsItem alloc] initWithJson:[adArr objectAtIndex:0]];
                    }

                    NSData *data = [_item.reserved dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *error =nil;
                    NSMutableDictionary *reserved = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
                    NSNumber* interval = [reserved objectForKey:@"request_interval"];

                    if (interval) {
                        [UserDefaultsManager setDoubleValue:[interval floatValue] forKey:TAB_AD_REQ_INTERVAL];
                    }
                    cootek_log(@"tl->tabbar : ed url");
                    [[EdurlManager instance] requestEdurl:_item.edMonitorUrl];

                }
            }
        }
    });
}

-(void) sendCMonitorUrl
{
    if (!_item) {
        return;
    }

    cootek_log(@"tl->tabbar :clk url");
    [[EdurlManager instance] sendCMonitorUrl:_item];
    _item = nil;

}
@end

