//
//  MarketLoginController.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/7.
//
//

#import "MarketLoginController.h"
#import "HandlerWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "TouchPalVersionInfo.h"
#import "CTUrl.h"
#import "DialerViewController.h"
#import "UserDefaultsManager.h"
#import "YellowPageWebViewController.h"
#import "SeattleFeatureExecutor.h"
#import "FunctionUtility.h"

@implementation MarketLoginController

@synthesize url;

- (void)jumpSomeWhereAfterLogin:(BOOL)animate {
    if (url && url.length > 0){
        CTUrl *ctUrl = [[CTUrl alloc] initWithUrl:url];
        if ([url rangeOfString:INVITATION_URL_STRING].length>0) {
            HandlerWebViewController *controller = [[HandlerWebViewController alloc] init];
            controller.url_string = url;
            [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:animate];
        }else{
        [ctUrl startWebView];
        }
    }else{
        YellowPageWebViewController *webVC = [[YellowPageWebViewController alloc] init];
        webVC.headerBackgroundImage = [[TPDialerResourceManager sharedManager] getImageInDefaultPackageByName:@"common_header_bg@2x.png"];
        webVC.isRefreshButtonVisible = YES;
        webVC.needTitle = YES;
        webVC.url_string = [MarketLoginController getActivityCenterUrlString];
        [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:animate];
    }
    [UserDefaultsManager setBoolValue:YES forKey:ASK_LIKE_VIEW_COULD_SHOW];
}


- (LoginControllerType)getIdentifyController {
    if ([url rangeOfString:INVITATION_URL_STRING].length>0) {
    return INVITE_VIEW;
    }else{
        return 0;
    }
}

+ (NSString *) getActivityCenterUrlString {
    NSString *path = MARKET_WEB_URL;
    if (USE_DEBUG_SERVER) {
        path = TEST_MARKET_WEB_URL;
    }
    NSString *token = [SeattleFeatureExecutor getToken];
    if (!token) {
        token = @"";
    }
    NSDictionary *info = @{
        @"_v":@"1",
        @"_token": token,
        @"platform":@(0),
        @"version":CURRENT_TOUCHPAL_VERSION,
        @"channel":IPHONE_CHANNEL_CODE,
    };
    NSMutableString *targetUrl = [[NSMutableString alloc] initWithString:path];
    [targetUrl appendString:@"?"];
    
    NSInteger infoCount = info.count;
    NSInteger counter = 0;
    for (NSString *key in info.allKeys) {
        NSString *value = [info objectForKey:key];
        counter += 1;
        NSString *format = @"%@=%@&";
        if (counter == infoCount) {
            format = @"%@=%@";
        }
        [targetUrl appendString:[NSString stringWithFormat:format, key, value]];
    }
    return [targetUrl copy];
}

@end
