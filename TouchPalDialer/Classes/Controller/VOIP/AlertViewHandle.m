//
//  COAlertViewHandle.m
//  TouchPalDialer
//
//  Created by ALEX on 16/7/4.
//
//

#import "AlertViewHandle.h"
#import "VoipUtils.h"
#import "LocalStorage.h"
#import "HandlerWebViewController.h"
#import "SeattleFeatureExecutor.h"
#import "TouchPalDialerAppDelegate.h"
#import "AppSettingsModel.h"
#import "UserDefaultKeys.h"
#import "UIView+Toast.h"
#import "TouchPalVersionInfo.h"
#import "DialerUsageRecord.h"
#import "YellowPageLocationManager.h"

@interface AlertViewHandle ()<UIAlertViewDelegate>
@property (nonatomic,strong) HangupModel *hangupModel;
@end

@implementation AlertViewHandle


#define VIP_URL @"http://search.cootekservice.com/page_v3/profit_center.html?_city=全国&_token=auth_token"
#define TOUCHPAL_DIALER_APP_STORE_REVIEW_URL @"http://itunes.apple.com/us/app/chu-bao-zhi-neng-bo-hao/id503130474?ls=1&mt=8"

static  AlertViewHandle  *shareSingleton = nil;

+ (instancetype) sharedSingleton  {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         shareSingleton  =  [[super allocWithZone:NULL] init] ;
    });

    return shareSingleton;
    
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    
    return [self sharedSingleton] ;
    
}

- (id)copy
{
    return self;
}


- (void)showAlertErrorWithHangUpModel:(HangupModel *)hangUpModel
{
        if (![VoipUtils ifShowADWithErrorCode:hangUpModel.errorCode ifOutging:!hangUpModel.isIncomingCall]) {
            return;
        }
            
        NSDictionary *dic = [VoipUtils translateJSONWithErrorCode:hangUpModel.errorCode];
            if (dic == nil) {
                return ;
        }
        self.hangupModel = hangUpModel;
        NSString *cancelStr;
        NSString *confirmStr;
      
        if ((dic[@"dialog_solution_action"] == nil) || ([dic[@"dialog_solution_action"] isEqualToString:@"close"])) {
                    cancelStr = @"确定";
                    confirmStr = nil;
                    
        }else{
            
            if ((dic[@"dialog_solution_action_alt"] != nil) && dic[@"dialog_solution_btn_alt"] != nil) {
                cancelStr = dic[@"dialog_solution_btn_alt"] ;
                confirmStr = dic[@"dialog_solution_btn"];
            }else{
                cancelStr = @"取消";
                confirmStr = dic[@"dialog_solution_btn"];
            }
        }
                
        if (dic[@"dialog_solution_main"] != nil && ![dic[@"dialog_solution_main"] isEqualToString:@""]) {
                    UIAlertView *alert = [[UIAlertView alloc ]initWithTitle:dic[@"dialog_solution_main"] message:nil delegate:self cancelButtonTitle:cancelStr otherButtonTitles:confirmStr,nil];
                    alert.tag = hangUpModel.errorCode;

                    [alert show];
        }
    
}

#pragma mark - EventHandle

- (void)fix
{
    [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:NO] forKey:IS_VOIP_ON];
    [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:YES] forKey:IS_VOIP_ON];
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow makeToast:@"问题已修复，重拨一下试试吧！" duration:1.0f position:CSToastPositionBottom];
}

- (void)upgrade
{
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TOUCHPAL_DIALER_APP_STORE_REVIEW_URL]];
}

- (void)launch_earn_money
{
    NSString *string = [VIP_URL stringByReplacingOccurrencesOfString:@"auth_token" withString:[SeattleFeatureExecutor getToken]];
    if ([LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]!=nil&&![[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]isEqualToString:@""]) {
        string = [string stringByReplacingOccurrencesOfString:@"全国" withString:[LocalStorage getItemWithKey:QUERY_PARAM_LOC_CITY]];
    }
    
    HandlerWebViewController  *vipWebViewVC = [[HandlerWebViewController alloc]init];
    vipWebViewVC.url_string =[string  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    vipWebViewVC.header_title = @"赚钱中心";
    [[TouchPalDialerAppDelegate naviController] pushViewController:vipWebViewVC animated:YES];
}

- (void)wifi
{
    NSURL*url=[NSURL URLWithString:@"prefs:root=INTERNET_TETHERING"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)normalCall
{
    NSString *numberString = [NSString stringWithFormat:@"tel://%@",_hangupModel.number];
    numberString = [numberString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *phoneNumberUrl = [NSURL URLWithString:numberString];
    [[UIApplication sharedApplication] openURL:phoneNumberUrl];
}

- (void)invite
{
    HandlerWebViewController *webVC = [[HandlerWebViewController alloc] init];
    NSString *url = USE_DEBUG_SERVER ? TEST_INVITE_REWARDS_WEB : INVITE_REWARDS_WEB;
    webVC.url_string = [url stringByAppendingString:@"?share_from=ErrorCode"];
    webVC.header_title = NSLocalizedString(@"invite_friends", @"邀请有奖");
    [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:YES];
    [DialerUsageRecord recordpath:PATH_INVITE_PAGE kvs:Pair(@"invite_page_from", @(5)), nil];
    
}

- (void)gps {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)close
{
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSDictionary *dic = [VoipUtils translateJSONWithErrorCode:alertView.tag];

    if (buttonIndex != 0) {
        NSString *dialog_solution_action = dic[@"dialog_solution_action"];
        if (dialog_solution_action != nil && ![dialog_solution_action isEqualToString:@""]){
            if ([self respondsToSelector:NSSelectorFromString(dialog_solution_action)]){
                [self performSelector:NSSelectorFromString(dialog_solution_action)];
            }
        }
    }else{
        NSString *dialog_solution_action = dic[@"dialog_solution_action_alt"];
        if (dialog_solution_action != nil && ![dialog_solution_action isEqualToString:@""]){
            if ([self respondsToSelector:NSSelectorFromString(dialog_solution_action)]){
                [self performSelector:NSSelectorFromString(dialog_solution_action)];
            }
        }

    }

}

@end
