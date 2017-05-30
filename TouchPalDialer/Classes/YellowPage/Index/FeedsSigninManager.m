//
//  FeedsSiginManager.m
//  TouchPalDialer
//
//  Created by lin tang on 16/10/17.
//
//

#import "FeedsSigninManager.h"
#import "UserDefaultsManager.h"
#import "YPFeedsTask.h"
#import "UpdateService.h"
#import "IndexConstant.h"
#import "TouchPalVersionInfo.h"
#import "DialerUsageRecord.h"
#import "LocalStorage.h"
#import "FeedsSignPopupView.h"
#import "DialogUtil.h"
#import "SignBtnManager.h"

@implementation FeedsSigninManager

+ (BOOL) shouldShowSignin
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:FEEDS_DATE_FORMAT];
    NSString* current = [df stringFromDate:[NSDate date]];
    if  (![[UserDefaultsManager stringForKey:FEEDS_QEURY_SIGN_TIME defaultValue:@""]  isEqualToString:current]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void) updateSignTime
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:FEEDS_DATE_FORMAT];
    NSString* current = [df stringFromDate:[NSDate date]];
    [UserDefaultsManager setObject:current forKey:FEEDS_QEURY_SIGN_TIME];
    [[SignBtnManager instance] hideSignBtn];
}

+ (void) showSigninGuideDialog: (UIView *) rootView
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [FeedsSigninManager queryFeedsSigninReward:rootView];
     });
}


+ (void) queryFeedsSigninReward:(UIView *)rootView
{
    NSString* url = @"";
    if  (USE_DEBUG_SERVER) {
        url = [NSString stringWithFormat:@"%@%@", url, YP_DEBUG_SERVER];
    } else {
        url = [NSString stringWithFormat:@"%@%@", url, TOUCHLIFE_SITE];
    }
    url = [NSString stringWithFormat:@"%@%@", url, YP_FEEDS_SIGN_QUERY_URL_PATH];
    
    url = [NSString stringWithFormat:@"%@?%@&", url, [UpdateService createNormalParams]];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:CURRENT_TOUCHPAL_VERSION forKey:@"app_version"];
    [params setObject:COOTEK_APP_NAME forKey:@"app_name"];
    [params setObject:[DialerUsageRecord getClientNetWorkType] forKey:@"network"];
    [params setObject:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY] forKey:@"geo_city"];
    [params setObject:[UserDefaultsManager objectForKey:INDEX_CITY_SELECTED defaultValue:@""] forKey:@"city"];
    [params setObject:[UserDefaultsManager objectForKey:NATIVE_PARAM_ADDR defaultValue:@""] forKey:@"addr"];
    [params setObject:[LocalStorage getItemWithKey:QUERY_PARAM_LONGITUDE] forKey:@"longitude"];
    [params setObject:[LocalStorage getItemWithKey:QUERY_PARAM_LATITUDE] forKey:@"latitude"];
    
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
    
    
    NSDictionary* result = [[UpdateService instance] requestUrlWithDicResult:url];
    
    NSDictionary* data = [result objectForKey:@"result"];
    
    if (data) {
        NSString* timestamp = [data objectForKey:@"timestamp"];
        NSString* s = [data objectForKey:@"s"];
        NSString* adid = [data objectForKey:@"ad_id"];
        NSString* desc = [data objectForKey:@"desc"];
        if (s) {
             [FeedsSigninManager openFeedsSigninReward:timestamp andS:s andAdId:adid andDesc:desc andIn:rootView];
        }
    }

}


+ (void) openFeedsSigninReward:(NSString *)timestamp andS:(NSString *)s andAdId:(NSString *)adid andDesc:(NSString *) desc andIn:(UIView*)rootView
{
    NSString* url = @"";
    if  (USE_DEBUG_SERVER) {
        url = [NSString stringWithFormat:@"%@%@", url, YP_DEBUG_SERVER];
    } else {
        url = [NSString stringWithFormat:@"%@%@", url, TOUCHLIFE_SITE];
    }
    url = [NSString stringWithFormat:@"%@%@", url, YP_FEEDS_SIGN_URL_PATH];
    
    url = [NSString stringWithFormat:@"%@?%@&", url, [UpdateService createNormalParams]];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:CURRENT_TOUCHPAL_VERSION forKey:@"app_version"];
    [params setObject:COOTEK_APP_NAME forKey:@"app_name"];
    [params setObject:[DialerUsageRecord getClientNetWorkType] forKey:@"network"];
    [params setObject:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY] forKey:@"geo_city"];
    [params setObject:[UserDefaultsManager objectForKey:INDEX_CITY_SELECTED defaultValue:@""] forKey:@"city"];
    [params setObject:[UserDefaultsManager objectForKey:NATIVE_PARAM_ADDR defaultValue:@""] forKey:@"addr"];
    [params setObject:[LocalStorage getItemWithKey:QUERY_PARAM_LONGITUDE] forKey:@"longitude"];
    [params setObject:[LocalStorage getItemWithKey:QUERY_PARAM_LATITUDE] forKey:@"latitude"];
    [params setObject:s forKey:@"s"];
    [params setObject:timestamp forKey:@"timestamp"];
    [params setObject:adid forKey:@"ad_id"];
    
    url = [url stringByAppendingString:[UpdateService generateParamsWithDictionary:params]];
    
    NSDictionary* result = [[UpdateService instance] requestUrlWithDicResult:url];
    NSDictionary* data = [result objectForKey:@"result"];
    NSNumber* error_code = [data objectForKey:@"error_code"];
    if (error_code.intValue == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            FeedsSignPopupView* view = [[FeedsSignPopupView alloc] initWithContent:desc];
            [DialogUtil showDialogWithContentView:view inRootView:rootView];
        });
    }
}
@end
