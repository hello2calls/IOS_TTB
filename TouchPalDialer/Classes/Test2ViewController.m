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

@interface Test2ViewController ()<WKNavigationDelegate>
@property(nonatomic,strong) WKWebViewJavascriptBridge* bridge;
@property (nonatomic, strong)WKWebView * wkWebView;

@end

@implementation Test2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_wkWebView];
    
    _wkWebView.navigationDelegate = self;
    _wkWebView.scrollView.bounces = 0;
    _wkWebView.scrollView.showsVerticalScrollIndicator = 0;
    _wkWebView.scrollView.showsHorizontalScrollIndicator = 0;
    
    [WKWebViewJavascriptBridge enableLogging];
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView*)_wkWebView
                                         webViewDelegate:self
                                                 handler:^(id data, WVJBResponseCallback responseCallback) {
                                                     cootek_log(@"ObjC received message from JS: %@", data);
                                                     responseCallback(@"Response for message from ObjC");
                                                 }];
    
  
    [self.bridge registerHandler:@"getLoginNumber" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(@"+2348080808080");
        }
    }];
    
    [self.bridge registerHandler:@"getAuthToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            NSString *token = [SeattleFeatureExecutor getToken];
            responseCallback(token);
        }
    }];
    
    [self.bridge registerHandler:@"getApiLevel" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(@(43));
        }
    }];
    
    [self.bridge registerHandler:@"getSecret" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            NSString* secret =  [FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]];
            responseCallback(secret);
        }
    }];
    
    [self.bridge registerHandler:@"log" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(@"log");
        }
    }];
    
    [self.bridge registerHandler:@"getWXPaySupported" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(@"log");
        }
    }];
    
    [self.bridge registerHandler:@"getWeixinAppInstalled" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback) {
            responseCallback(@"log");
        }
    }];
    
 
    
    [self.bridge callHandler:@"log" data:@"by666" responseCallback:^(id responseData) {
        NSLog(@"from js0: %@", responseData);
    }];
    
    [self.bridge callHandler:@"getLoginNumber" data:@"+2348080808080" responseCallback:^(id responseData) {
        NSLog(@"from js1: %@", responseData);
    }];
    
    NSString *token = [SeattleFeatureExecutor getToken];
    [self.bridge callHandler:@"getAuthToken" data:token responseCallback:^(id responseData) {
        NSLog(@"from js2: %@", responseData);
    }];
    
    
    [self.bridge callHandler:@"getApiLevel" data:@(43) responseCallback:^(id responseData) {
        NSLog(@"from js3: %@", responseData);
    }];
    
    NSString* secret =  [FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]];
    [self.bridge callHandler:@"getSecret" data:secret responseCallback:^(id responseData) {
        NSLog(@"from js4: %@", responseData);
    }];
   
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:CHARGE_URL]]];

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
    }
    return _wkWebView;
}

@end
