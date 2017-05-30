//
//  BiBiPairManager.m
//  TouchPalDialer
//
//  Created by lingmeixie on 17/1/10.
//
//

#import "BiBiPairManager.h"
#import "Reachability.h"
#import "SeattleFeatureExecutor.h"
#import "NetworkUtility.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "ScheduleInternetVisit.h"
#import "TouchPalVersionInfo.h"
#import "CooTekServerDef.h"
#import "YellowPageWebViewController.h"
#import "TPDialerResourceManager.h"

#define BIBI_PAIR_URL @"http://%@:%d/yellowpage_v3/friends_in_BB"
#define BIBI_PAIR_FILE @"bibi_pair.plist"
#define BIBI_SCHEMA @"bibi://"
#define BIBI_TALK_TARGET_INDEX @"http://dialer.cdn.cootekservice.com/web/internal/activities/light_phone/index.html"

@interface BiBiPairManager () {
    BOOL _registered;
    NSDictionary *_bibiMap;
    NSString *_number;
}

+ (BiBiPairManager *)manager;

@end

BiBiPairManager *_instance = nil;

@implementation BiBiPairManager

+ (void)initialize {
    _instance = [[BiBiPairManager alloc] init];
}

+ (BiBiPairManager *)manager {
    return _instance;
}


- (BOOL)canBibiCall:(NSString *)number {
    if (_bibiMap == nil) {
        return NO;
    }
    BOOL numberRegisteredBibi = [[_bibiMap valueForKey:number] intValue] > 0;
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:BIBI_SCHEMA]]
            && numberRegisteredBibi && _registered;
}

- (NSString *)recommendNumber {
    if (_bibiMap != nil) {
        if (_number) {
            return _number;
        }
        _number = [[_bibiMap allKeys] firstObject];
        return _number;
    }
    return nil;
}


- (UIImage *)defualtBibiPhoto {
    return [[TPDialerResourceManager sharedManager] getImageByName:@"light_dial_photo_default@3x.png"];
}

- (id)init {
    if (self = [super init]) {
        _registered = [UserDefaultsManager boolValueForKey:BIBI_LOCAL_ACCOUNT_REGISTED];
        NSString *filePath = [FunctionUtility documentFile:BIBI_PAIR_FILE];
        _bibiMap = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    return self;
}

- (void)asycBiBiPair {
    if ([[Reachability shareReachability] networkStatus] <= network_2g ||
        [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN] == NO) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSString *host = [NSString stringWithFormat:BIBI_PAIR_URL,COOTEK_DYNAMIC_LIFE_SERVICE,COOTEK_DYNAMIC_SERVICE_PORT];
        if (ENABLE_YP_DEBUG) {
           host = [NSString stringWithFormat:BIBI_PAIR_URL,YP_DEBUG_SERVER_HOST,YP_DEBUG_HTTP_PORT];
        }
      
        NSString *url = [NSString stringWithFormat:@"%@?_token=%@",host,[SeattleFeatureExecutor getToken]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] init];
        NSError *error = [[NSError alloc] init];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if ([response statusCode] == 200) {
            [self saveResult:data];
        }
    });
}

- (void)saveResult:(NSData *)result {
    if (result == nil) {
        return;
    }
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:nil];
    if (response != nil) {
        response = [response objectForKey:@"result"];
        if (response != nil && [[response objectForKey:@"error_code"] intValue] == 2000) {
            _registered = [[response objectForKey:@"local_registration"] intValue] > 0;
            [UserDefaultsManager setBoolValue:_registered forKey:BIBI_LOCAL_ACCOUNT_REGISTED];
            NSArray *paired = [response objectForKey:@"friends_pairs"];
            if ([paired count] > 0) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[paired count]];
                for (NSDictionary *item in paired) {
                    [dic setObject:[item objectForKey:@"registration"] forKey: [item objectForKey:@"phone"]];
                }
                @synchronized (self) {
                    _number = nil;
                    _bibiMap = dic;
                }
                NSString *filePath = [FunctionUtility documentFile:BIBI_PAIR_FILE];
                [_bibiMap writeToFile:[FunctionUtility documentFile:filePath] atomically:YES];
            } else {
                @synchronized (self) {
                    _number = nil;
                    _bibiMap = nil;
                }
                NSString *filePath = [FunctionUtility documentFile:BIBI_PAIR_FILE];
                [_bibiMap writeToFile:[FunctionUtility documentFile:filePath] atomically:YES];
            }
    
        }
    }
}

- (void)pushBibiWebController:(UINavigationController *)nav {
    NSString *key = [NSString stringWithFormat:BIBI_GUIDE_SHOW_INAPP,[UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME]];
    [UserDefaultsManager setBoolValue:YES forKey:key];
    BOOL install = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:BIBI_SCHEMA]];
    YellowPageWebViewController *controller = [[YellowPageWebViewController alloc] init];
    controller.url_string = [NSString stringWithFormat:@"%@?number=%@&install=%d",BIBI_TALK_TARGET_INDEX,_number,install];
    controller.web_title = @"认领唠嗑对象";
    controller.needTitle = YES;
    [nav pushViewController:controller animated:YES];
}

- (BOOL)canShowBibiGuide {
    NSString *key = [NSString stringWithFormat:BIBI_GUIDE_SHOW_INAPP,[UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME]];
    return  [self recommendNumber] != nil &&
    ![UserDefaultsManager boolValueForKey:key];
}
@end
