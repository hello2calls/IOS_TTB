//
//  TaeClient.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/2/3.
//
//

#import "TaeClient.h"
#import "TouchPalVersionInfo.h"

@implementation TaeClient
static TaeClient *_sharedSingleInstance = nil;

+ (TaeClient*) instance {
    if (_sharedSingleInstance == nil) {
        _sharedSingleInstance = [[TaeClient alloc] init];
    }
    return _sharedSingleInstance;
}

- (void)initTae {
    [[TaeSDK sharedInstance] asyncInit:^{
        _sharedSingleInstance = [[TaeClient alloc] init];
        cootek_log(@"tae success to initialize");
    }failedCallback:^(NSError *error) {
        cootek_log(@"tae failed to initialize:%@", error);
    }];
}

+ (void)setInfoBeforeInit {
    [[TaeSDK sharedInstance] setAppVersion:CURRENT_TOUCHPAL_VERSION];
//    if (DEBUG) {
//        [[TaeSDK sharedInstance] setDebugLogOpen:YES];
//    }
}

- (BOOL) handleOpenURL:(NSURL *)url{
    return [[TaeSDK sharedInstance]handleOpenURL:url];
}

- (BOOL) isLogin {
    return [[TaeSession sharedInstance] isLogin];
}

- (TaeUser*) getUser {
    return [[TaeSession sharedInstance] getUser];
}

- (void) logout {
    id<ALBBLoginService>  loginService=[[TaeSDK sharedInstance]getService:@protocol(ALBBLoginService)];
    [loginService logout];
}

- (void)showLogin:(UIViewController *)parentController successCallback:(loginSuccessCallback)successCallback failedCallback:(loginFailedCallback)failedCallback{
    id<ALBBLoginService> loginService=[[TaeSDK sharedInstance]getService:@protocol(ALBBLoginService)];
    [loginService showLogin:parentController successCallback:successCallback failedCallback:failedCallback];
}

- (void) showpage:(UIViewController *)parentController
       isNeedPush:(BOOL)isNeedPush
          pageUrl:(NSString *)pageUrl
webViewUISettings:(TaeWebViewUISettings *)webViewUISettings
tradeProcessSuccessCallback:(tradeProcessSuccessCallback)successCallback
tradeProcessFailedCallback:(tradeProcessFailedCallback)failedCallback {
    id<ALBBItemService> _itemService=[[TaeSDK sharedInstance] getService:@protocol(ALBBItemService)];
    [_itemService showPage:parentController
                isNeedPush:isNeedPush
                   pageUrl:pageUrl
         webViewUISettings:webViewUISettings
tradeProcessSuccessCallback:successCallback
tradeProcessFailedCallback:failedCallback];
}
@end

