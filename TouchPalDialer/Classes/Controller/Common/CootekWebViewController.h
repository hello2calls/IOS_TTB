//
//  CootekWebViewController.h
//  TouchPalDialer
//
//  Refactored by Leon Lu on 12-8-6.
//  Copyright (c) 2012年 CooTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "CootekViewController.h"
#import "FLWebViewProvider.h"
#import "TLWebSetting.h"
#import "UIView+MJExtension.h"

@interface CootekWebViewController : CootekViewController <UIWebViewDelegate,
WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
{
    UIActivityIndicatorView* wait_indicator;
}

@property(nonatomic, retain) UIView <FLWebViewProvider> *web_view;
@property(nonatomic, retain) NSString* url_string;
@property(nonatomic, strong) NSString* web_title;
@property(nonatomic, strong) NSString* service_id;
@property(nonatomic, assign) BOOL hasLoaded;
@property(nonatomic, retain) NSString *funcStr;
@property(nonatomic, assign) BOOL usingWkWebview;
@property(nonatomic, assign) BOOL injectJavascript;
@property(nonatomic, assign) BOOL isRefreshButtonVisible;
@property(nonatomic, retain) UIButton *rightRefreshButton;
@property(nonatomic, assign) BOOL jumpOutsideFinish;
@property(nonatomic, assign) BOOL allowsInlineMediaPlayback;
@property(nonatomic, retain) TLWebSetting *webSetting;
@property(nonatomic, strong) UIView* containerView;

- (void)loadURL;

@end
