//
//  CommonWebViewController.h
//  TouchPalDialer
//
//  Created by game3108 on 15/4/13.
//
//

#import <UIKit/UIKit.h>
#import "CommonHeaderBar.h"
#import "CommonWebView.h"
#import <WebKit/WebKit.h>
#import "WebviewControllerDelegate.h"
#import "NSString+TPHandleNil.h"

#define MARKET_WEB_URL @"http://dialer-voip.cootekservice.com/voip/reward_center"
#define TEST_MARKET_WEB_URL @"http://121.52.235.231:40718/voip/reward_center"

#define URL_NEWER_WIZARD @"http://dialer-cdn.cootekservice.com/voip/inapp/voipwizard/ios/voip_guide.html"
#define FLOW_WALLET_URL @"http://search.cootekservice.com/page/mobiledata.html"
#define TEST_FLOW_WALLET_URL @"http://search.cootekservice.com/page/mobiledata.html"
#define TEST_WEB_URL @"http://dialer.cdn.cootekservice.com/voip/inapp/index.html"
#define INVITE_REWARDS_WEB @"http://dialer.cdn.cootekservice.com/web/internal/activities/invite_rewards_visualization/index.html"
#define TEST_INVITE_REWARDS_WEB @"http://noahtest01.cootekservice.com:8032/push/dialer_web/activities/invite_rewards_visualization/index.html"


@interface CommonWebViewController : UIViewController <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>
@property(nonatomic, strong) CommonWebView *commonWebView;
@property(nonatomic, strong) NSString *url_string;
@property(nonatomic, strong) NSString *header_title;
@property(nonatomic, assign) BOOL isNoah;
@property(nonatomic, assign) BOOL ifHideHeaderBar;
@property(nonatomic, assign) CGRect viewFrame;
@property(nonatomic, strong) NSString *file_name;
@property(nonatomic, strong) id relatedObject;
@property(nonatomic, assign) BOOL ifRefreshHidden;
@property(nonatomic, assign) BOOL ifLight;
@property(nonatomic, assign) BOOL webViewFullScreen;
@property(nonatomic, assign) BOOL webViewCanNotScroll;
@property(nonatomic, weak)   id<WebViewControllerDelegate> controllerDelegate;
@property(nonatomic, assign) BOOL useWkWebView;
@property (nonatomic) CommonHeaderBar *headerBar;
@property (nonatomic) UIColor *headerTextColor;

- (void)setHeaderBarBackgroundColor:(UIColor *)bgColor;
- (void)setHeaderTitle:(NSString *)headerTitle;
- (void)setRefreshButton:(BOOL)ifRefreshHidden;
- (void)reloadUrl:(NSString *)url;
- (void)reloadFile:(NSString *)fileName;
- (void)reload;
- (void)setStartLoadAction:(void(^)(UIView<FLWebViewProvider> *webView)) webviewDidStartLoadAction;
- (void)setFinishLoadAction:(void(^)(UIView<FLWebViewProvider> *webView))webviewDidFinishLoadAction;
- (void)setFailedLoadAction:(void(^)(UIView<FLWebViewProvider> *webView, NSError *error))webviewDidFailedLoadAction;
@end
