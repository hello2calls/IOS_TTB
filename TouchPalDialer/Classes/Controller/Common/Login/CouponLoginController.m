//
//  CouponLoginController.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/18.
//
//

#import "CouponLoginController.h"
#import "YellowPageWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "SeattleFeatureExecutor.h"

@implementation CouponLoginController

- (void)jumpSomeWhereAfterLogin:(BOOL)animate {
    YellowPageWebViewController *controller = [[YellowPageWebViewController alloc] init];
    NSString *token = [SeattleFeatureExecutor getToken];
    NSString *url = [NSString stringWithFormat:@"http://search.cootekservice.com/page_v3/activity_recharge_price.html?_token=%@", token];
    controller.url_string = url;
    controller.web_title = NSLocalizedString(@"personal_center_setting_coupon", @"");
    controller.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()-TAB_BAR_HEIGHT+TPHeaderBarHeightDiff());
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:animate];
}

- (LoginControllerType)getIdentifyController {
    return COUPON;
}

@end
