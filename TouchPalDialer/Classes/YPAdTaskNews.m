//
//  YPAdTaskNews.m
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "YPAdTaskNews.h"
#import "FindNewsItem.h"
#import "UpdateService.h"
#import "IndexConstant.h"
#import "TouchPalVersionInfo.h"
#import "SeattleFeatureExecutor.h"
#import "DialerUsageRecord.h"
#import "UserDefaultsManager.h"
#import "LocalStorage.h"
#import "AdRequestManager.h"
#import "NSString+TPHandleNil.h"
#import "TPDVideoPlayController.h"


@implementation YPAdTaskNews



- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = ADTaskNews;
    }
    return self;
}

- (void) executeTask
{
    NSDictionary *extra = @{
                @"mode": self.isRefresh ? @"2": @"1",
                @"tu" : [@(self.tu) stringValue],
                @"layout": [@(self.layout) stringValue],
                @"s": [NSString nilToEmpty:self.queryId],
                @"ctn": @"12",
                            };
    NSString *url = [YPAdTaskNews requestURLStringWithExtra:extra];
    NSLog(@"%s, tu=%ld, url: %@", __func__, (long)self.tu, url);
    NSMutableArray* remResult = [[UpdateService instance] requestForNews:url];
    [self setResults:remResult];
}

+ (NSString *) requestURLStringWithExtra:(NSDictionary *)extra {
    cootek_log(@" --- generate task news -----");
    NSString* url = nil;
    if (USE_DEBUG_SERVER) {
        url = [NSString stringWithFormat:@"%@%@",YP_DEBUG_SERVER, YP_DEBUG_NEWS_FEEDS_PATH];
    } else {
        url = YP_NEWS_FEEDS;
    }
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* time = [NSString stringWithFormat:@"%.0f",interval * 1000];
    
    NSString *token = [NSString nilToEmpty:[SeattleFeatureExecutor getToken]];
    
#ifdef DEBUG_FEEDS_VIDEO_TOKEN
    token = DEBUG_FEEDS_VIDEO_TOKEN;
#endif
    
    NSMutableArray* values = [NSMutableArray arrayWithObjects:
                              @"1",
                              @"MULTI",
                              @"EMBEDDED",
                              token,
                              time,
                              @"JSON",
                              [DialerUsageRecord getClientNetWorkType],
                              nil];
    
    // 这里，服务器只能识别nt：
    // 不要写成network
    //
    NSArray* keys = [NSArray arrayWithObjects:
                     @"noad",
                     @"ct",
                     @"ctclass",
                     @"token",
                     @"prt",
                     @"rt",
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
    
    for(NSString *key in extra.allKeys) {
        NSString *value = [extra objectForKey:key];
        if (![NSString isNilOrEmpty:value]) {
            [params setObject:value forKey:key];
        }
    }
    url = [url stringByAppendingString:
                [UpdateService generateParamsWithDictionary:params]];
    return url;
}

@end
