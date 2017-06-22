//
//  TestViewController.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/5/27.
//
//

#import "Test2ViewController.h"
#import "WKWebViewJavascriptBridge.h"
#import "WebViewJavascriptBridge.h"
#import "IndexConstant.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import "WXApi.h"
#import "TouchPalVersionInfo.h"

@interface Test2ViewController ()<WKNavigationDelegate>
@property(nonatomic,strong) WKWebViewJavascriptBridge* bridge;
@property (nonatomic, strong)WKWebView * wkWebView;

@end

@implementation Test2ViewController

-(void)viewWillAppear:(BOOL)animated
{
    _wkWebView = [self wkWebView];
    
    [WKWebViewJavascriptBridge enableLogging];
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView*)_wkWebView
                                              webViewDelegate:self
                                                      handler:^(id data, WVJBResponseCallback responseCallback) {
                                                          cootek_log(@"ObjC received message from JS: %@", data);
                                                          responseCallback(@"Response for message from ObjC");
                                                      }];

    [self test];
    [self performSelector:@selector(openWebView) withObject:nil afterDelay:2.0f];
}


-(void)test
{
    [self.bridge registerHandler:@"getApiLevel" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(WEBVIEW_JAVASCRIPT_API_LEVEL);
        }
    }];
    
    
    [self.bridge registerHandler:@"getLoginNumber" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            NSString *accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
            if(accountName == nil){
                responseCallback(@"");
            }else{
                responseCallback(accountName);
            }
        }
    }];
    
    [self.bridge registerHandler:@"getAuthToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            NSString *token = [SeattleFeatureExecutor getToken];
            responseCallback(token);
        }
    }];
    
    
    [self.bridge registerHandler:@"getSecret" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            NSString* secret =  [FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]];
            responseCallback(secret);
        }
    }];
    //
    [self.bridge registerHandler:@"log" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(@"log");
        }
    }];
    //
    [self.bridge registerHandler:@"getWXPaySupported" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(@"true");
        }
    }];
    
    [self.bridge registerHandler:@"getWeixinAppInstalled" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(@"true");
        }
    }];
    
    [self.bridge registerHandler:@"isZh" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(@"true");
        }
    }];
}

-(void)openWebView
{
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:CHARGE_URL]]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void) injectForDispatch
{
//    NSString* secret =  [FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]];
//    NSString* accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
//    
//    BOOL isWXInstalled = [WXApi isWXAppInstalled] ? YES : NO;
//    BOOL isWXSupported = [WXApi isWXAppSupportApi] ? YES : NO;
//    
//    NSString *interfaceFilePath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptInterface.js" ofType:@"txt"];
//    NSString *jsInterface = [NSString stringWithContentsOfFile:interfaceFilePath encoding:NSUTF8StringEncoding error:nil];
//    
//    NSMutableDictionary * activationJsonInfo = [[NSMutableDictionary alloc] init];
//    [activationJsonInfo setValue:COOTEK_APP_NAME forKey:@"app_name"];
//    [activationJsonInfo setValue:CURRENT_TOUCHPAL_VERSION forKey:@"app_version"];
//    [activationJsonInfo setValue:IPHONE_CHANNEL_CODE forKey:@"channel_code"];
//    
//    NSString* callbackValue = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:activationJsonInfo options:0 error:nil] encoding:NSUTF8StringEncoding];
//    
//    NSString* jsStr = [NSString stringWithFormat:jsInterface,
//                       WEBVIEW_JAVASCRIPT_API_LEVEL,
//                       [UserDefaultsManager stringForKey:NATIVE_PARAM_LOCATION defaultValue:@""],
//                       [UserDefaultsManager stringForKey:NATIVE_PARAM_ADDR defaultValue:@""],
//                       [UserDefaultsManager stringForKey:NATIVE_PARAM_CITY defaultValue:@""],
//                       [UserDefaultsManager stringForKey:NATIVE_PARAM_LOCATION_CACHE_TIME defaultValue:@""],
//                       [UserDefaultsManager stringForKey:NATIVE_PARAM_ADDR_CACHE_TIME defaultValue:@""],
//                       [UserDefaultsManager stringForKey:NATIVE_PARAM_CITY_CACHE_TIME defaultValue:@""],
//                       secret == nil ? @"" : secret,
//                       [SeattleFeatureExecutor getToken],
//                       accountName == nil ? @"" : accountName,
//                       [NSNumber numberWithInt:isWXInstalled],
//                       [NSNumber numberWithInt:isWXSupported],
//                       callbackValue,
//                       [UserDefaultsManager stringForKey:SEATTLE_AUTH_LOGIN_ACCESS_TOKEN defaultValue:@""],
//                       [UserDefaultsManager stringForKey:SEATTLE_AUTH_LOGIN_TICKET defaultValue:@""]];
    
    
    [_wkWebView evaluateJavaScript:@"" completionHandler:^(id callback, NSError *error) {
      
        
    }];
}

- (WKWebView *)wkWebView
{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_wkWebView];
        
        _wkWebView.navigationDelegate = self;
        _wkWebView.scrollView.bounces = 0;
        _wkWebView.scrollView.showsVerticalScrollIndicator = 0;
        _wkWebView.scrollView.showsHorizontalScrollIndicator = 0;
        [self.view addSubview:_wkWebView];

    }
    return _wkWebView;
}

@end
