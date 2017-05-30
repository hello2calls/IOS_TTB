//
//  TaeClient.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/2/3.
//
//

#import <Foundation/Foundation.h>
#import <TAESDK/TaeSDK.h>
#import <ALBBLoginSDK/ALBBLoginService.h>
#import <ALBBTradeSDK/ALBBItemService.h>

@interface TaeClient : NSObject

+ (TaeClient*) instance;

+ (void) setInfoBeforeInit;
- (void) initTae;
- (BOOL) handleOpenURL:(NSURL *)url;

- (BOOL) isLogin;
- (TaeUser*) getUser;
- (void) showLogin:(UIViewController*) parentController
   successCallback:(loginSuccessCallback) successCallback
    failedCallback:(loginFailedCallback) failedCallback;
- (void) logout;

- (void) showpage:(UIViewController*) parentController
       isNeedPush:(BOOL) isNeedPush
          pageUrl:(NSString*)pageUrl
webViewUISettings:(TaeWebViewUISettings*) webViewUISettings
tradeProcessSuccessCallback:(tradeProcessSuccessCallback)successCallback
tradeProcessFailedCallback:(tradeProcessFailedCallback)failedCallback;

@end

