//
//  YPAdTaskDavinci.m
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "YPAdTaskDavinci.h"
#import "FindNewsItem.h"
#import "UpdateService.h"
#import "IndexConstant.h"
#import "TouchPalVersionInfo.h"
#import "SeattleFeatureExecutor.h"
#import "DialerUsageRecord.h"
#import "LocalStorage.h"
#import "UserDefaultsManager.h"
#import "SSPStat.h"

@implementation YPAdTaskDavinci

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = ADTaskDavinci;
    }
    return self;
}

- (void) executeTask
{
    cootek_log(@" --- generate task davinci -----");
    NSString* url = nil;
    if (USE_DEBUG_SERVER) {
        url = [NSString stringWithFormat:@"%@%@",YP_DEBUG_SERVER, YP_DEBUG_AD_REQUEST_URL_PATH];
    } else {
        url = YP_AD_REQUEST_URL;
    }

    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* time = [NSString stringWithFormat:@"%.0f",interval * 1000];

    NSString* mode = self.isRefresh ? @"2" : @"1";
    
    NSArray* values = [NSArray arrayWithObjects:
                       @"3",
                       @"190",
                       @"145",
                       @"TUWEN",
                       @"EMBEDDED",
                       mode,
                       [SeattleFeatureExecutor getToken],
                       time,
                       @"3",
                       @"JSON",
                       self.queryId ? self.queryId : @"",
                       self.ftu,
                       [DialerUsageRecord getClientNetWorkType],
                       nil];
    NSArray* keys = [NSArray arrayWithObjects:
                     @"adn",
                     @"w",
                     @"h",
                     @"at",
                     @"adclass",
                     @"mode",
                     @"token",
                     @"prt",
                     @"tu",
                     @"rt",
                     @"s",
                     @"ftu",
                     @"nt",
                     nil];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]
                            initWithObjects:values
                            forKeys:keys];
    
    [params setObject:CURRENT_TOUCHPAL_VERSION forKey:@"v"];
    [params setObject:COOTEK_APP_NAME forKey:@"ch"];
    
    
    NSString* city = [LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY];
    
    if (city.length == 0) {
        city = (NSString *)[UserDefaultsManager objectForKey:INDEX_CITY_SELECTED];
    }
   
    if (city.length > 0) {
        [params setValue:city forKey:@"city"];
    }
    
    NSString* addr = (NSString *)[UserDefaultsManager objectForKey:NATIVE_PARAM_ADDR];
    
    if (addr.length > 0) {
        [params setValue:addr forKey:@"addr"];
    }
   
    
    NSString* latitude = (NSString *)[UserDefaultsManager objectForKey:QUERY_PARAM_LATITUDE];
    NSString* longitude = (NSString *)[UserDefaultsManager objectForKey:QUERY_PARAM_LONGITUDE];
    
    
    if (latitude.length> 0 && longitude.length > 0) {
        [params setValue:latitude forKey:@"latitude"];
        [params setValue:longitude forKey:@"longitude"];
    }
    
    
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
    
    NSMutableArray* remResult = [[UpdateService instance] requestForAds:url];

    [self setResults:remResult];

}
@end
