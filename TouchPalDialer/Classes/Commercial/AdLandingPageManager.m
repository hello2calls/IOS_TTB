//
//  AdLandingPageManager.m
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/24.
//
//

#import "AdLandingPageManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "CommonWebViewController.h"
#import "YellowPageWebViewController.h"
#import "AdMessageModel.h"
#import "CTUrl.h"
#import "SeattleFeatureExecutor.h"
#import "FunctionUtility.h"
#import "UIWebView+FLUIWebView.h"

@interface AdLandingPageManager () <WebViewControllerDelegate>
@property (nonatomic, strong) AdMessageModel    *ad;
@property (nonatomic, strong) UIViewController  *adWebController;
@property (nonatomic, assign) long long         lastTsin;
@property (nonatomic, copy)   NSString          *lastADWebRequestUrl;
@end

@implementation AdLandingPageManager
#pragma mark LifeCycle
- (instancetype)initWithAd:(AdMessageModel *)ad webController:(UIViewController *)controller
{
    self = [self init];

    if (self) {
        _ad = ad;

        if (![self setController:controller webViewControllerDelegate:self]) {
            return nil;
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }

    return self;
}

- (void)dealloc
{
    _ad = nil;
    _adWebController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Private

- (BOOL)setController:(UIViewController *)controller webViewControllerDelegate:(id <WebViewControllerDelegate>)delegate
{
    if ([controller isKindOfClass:CommonWebViewController.class] || [controller isKindOfClass:YellowPageWebViewController.class]) {
        if ([controller respondsToSelector:@selector(setControllerDelegate:)]) {
            [controller performSelector:@selector(setControllerDelegate:) withObject:delegate];
            _adWebController = controller;
            return YES;
        }
    }

    return NO;
}

- (void)transformBackWithParam:(NSDictionary *)param
{
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [FunctionUtility visitUrl:kADTransformUrl param:param];
    });
}

#pragma mark WebViewControllerDelegate

- (void)webViewControllerDidClose:(UIViewController *)controller
{
    cootek_log(@"AdLandingPageManager webViewControllerDidClose:%@", controller);

    if (_adWebController == controller) {
        if (_lastTsin) {
            long long       tsout = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
            NSDictionary    *param = @{kADTransformParamSid:_ad.s ? : @"",
                                       kADTransformParamType:kADTransformLandingPage,
                                       kADTransformParamUrl:_lastADWebRequestUrl ? : @"",
                                       kADTransformParamTsin:@(_lastTsin),
                                       kADTransformParamTsout:@(tsout),
                                       kADTransformParamAdid:_ad.adId ? : @"",
                                       kADTransformParamTU:_ad.tu ? : @""};
            [self transformBackWithParam:param];
        }

        _lastTsin = 0;
        _lastADWebRequestUrl = nil;
        _adWebController = nil;
        _ad = nil;
    } else {
        cootek_log(@"AdLandingPageManager webViewControllerDidClose error: has another controller");
    }
}

- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self finishLoad:webView webViewController:controller];
}

- (void)webViewController:(UIViewController *)controller webViewDidFinishLoad:(UIView<FLWebViewProvider>*)webView
{
    [self finishLoad:webView webViewController:controller];
}


- (void)finishLoad:(UIView<FLWebViewProvider> *)webView webViewController:(UIViewController *)controller
{
    cootek_log(@"AdLandingPageManager webViewDidFinishLoad %@  request:%@  HTTPBody:%@  HTTPMethod:%@", webView, webView.request, webView.request.HTTPBody, webView.request.HTTPMethod);
    
    if (_adWebController == controller) {
        long long tsout = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
        
        if (_lastTsin) {
            NSDictionary *param = @{kADTransformParamSid:_ad.s ? : @"",
                                    kADTransformParamType:kADTransformLandingPage,
                                    kADTransformParamUrl:_lastADWebRequestUrl ? : @"",
                                    kADTransformParamTsin:@(_lastTsin),
                                    kADTransformParamTsout:@(tsout),
                                    kADTransformParamAdid:_ad.adId ? : @"",
                                    kADTransformParamTU:_ad.tu ? : @""};
            [self transformBackWithParam:param];
        }
        
        _lastADWebRequestUrl = [CTUrl encodeUrl:[webView.request.URL absoluteString]];
        _lastTsin = tsout;
    } else {
        cootek_log(@"AdLandingPageManager webViewDidFinishLoad error: has another controller");
    }
}
#pragma mark UIApplicationDelegate

- (void)applicationDidBecomeActive
{
    UIViewController    *topController = [TouchPalDialerAppDelegate naviController].topViewController;
    long long           tsin = (long long)([[NSDate date] timeIntervalSince1970] * 1000);

    if (topController == _adWebController) {
        _lastTsin = tsin;
    }
}

- (void)applicationDidEnterBackground
{
    UIViewController *topController = [TouchPalDialerAppDelegate naviController].topViewController;

    if (topController == _adWebController) {
        long long tsout = (long long)([[NSDate date] timeIntervalSince1970] * 1000);

        if (_lastTsin && _lastADWebRequestUrl) {
            NSDictionary *param = @{kADTransformParamSid:_ad.s ? : @"",
                                    kADTransformParamType:kADTransformLandingPage,
                                    kADTransformParamUrl:_lastADWebRequestUrl ? : @"",
                                    kADTransformParamTsin:@(_lastTsin),
                                    kADTransformParamTsout:@(tsout),
                                    kADTransformParamAdid:_ad.adId ? : @"",
                                    kADTransformParamTU:_ad.tu ? : @""};
            [self transformBackWithParam:param];
        }

        _lastTsin = tsout;
    }
}

@end
