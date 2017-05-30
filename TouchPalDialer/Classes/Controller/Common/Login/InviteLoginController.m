//
//  InviteLoginController.m
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/4.
//
//

#import "InviteLoginController.h"
#import "HandlerWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "TouchPalVersionInfo.h"

@implementation InviteLoginController

- (void)jumpSomeWhereAfterLogin:(BOOL)animate
{
    HandlerWebViewController *webVC = [[HandlerWebViewController alloc] init];

    NSString *url = USE_DEBUG_SERVER ? TEST_INVITE_REWARDS_WEB : INVITE_REWARDS_WEB;

    if (_shareFrom.length) {
        NSString *segment = [url rangeOfString:@"?"].length > 0 ? @"&":@"?";
        url = [url stringByAppendingFormat:@"%@share_from=%@", segment , _shareFrom];
    }
    if (_shareDest.length) {
        NSString *segment = [url rangeOfString:@"?"].length > 0 ? @"&":@"?";
        url = [url stringByAppendingFormat:@"%@share_dest=%@",segment , _shareDest];
    }
    webVC.url_string = url;
    cootek_log(@"InviteLoginController:%@",url);
    webVC.header_title = _webTitle ? : NSLocalizedString(@"invite_friends", @"邀请有奖");
    [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:animate];
}

- (LoginControllerType)getIdentifyController
{
    return PERSONAL_REDBAG;
}

@end
