//
//  AdInfoModelManager.m
//  TouchPalDialer
//
//  Created by tanglin on 16/2/1.
//
//

#import "AdInfoModelManager.h"
#import "FLWebViewProvider.h"
#import "CommonWebViewController.h"
#import "YellowPageWebViewController.h"
#import "SeattleFeatureExecutor.h"
#import "FunctionUtility.h"
#import "TouchPalDialerAppDelegate.h"
#import "EdurlManager.h"
#import "IndexConstant.h"
#import "TPAdControlRequestParams.h"

AdInfoModelManager *inf_instance_ = nil;


@interface AdInfoModelManager(){
    long long _tsin;
    long long _flts;
    AdInfoModel* _ad;
    UIViewController* _adWebController;
    NSString* _lastADWebRequestUrl;
}

@end
@implementation AdInfoModelManager

#pragma mark LifeCycle
+ (void)initWithAd:(AdInfoModel *)ad webController:(UIViewController *)controller
{
    inf_instance_ = [AdInfoModelManager new];
    if (inf_instance_) {
        
        if (![inf_instance_ setController:controller webViewControllerDelegate:inf_instance_ andModel:ad]) {
            return;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:inf_instance_ selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:inf_instance_ selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

- (void)dealloc
{
    _ad = nil;
    _adWebController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Private

- (BOOL)setController:(UIViewController *)controller webViewControllerDelegate:(id <WebViewControllerDelegate>)delegate andModel:(AdInfoModel *)model
{
    if ([controller isKindOfClass:CommonWebViewController.class] || [controller isKindOfClass:YellowPageWebViewController.class]) {
        if ([controller respondsToSelector:@selector(setControllerDelegate:)]) {
            [controller performSelector:@selector(setControllerDelegate:) withObject:delegate];
            _adWebController = controller;
            _ad = model;
            return YES;
        }
    }
    
    return NO;
}

- (void)transformBackWithParam:(NSDictionary *)param
{
    if (param) {
        __block AdInfoModel* model = _ad;
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            NSString* url = PREFIX_URL_AD;
            if (model.ctId) {
                url = PREFIX_URL_NEWS;
            }
            [FunctionUtility visitUrl:url param:param];
            model = nil;
        });
    }
}

#pragma mark WebViewControllerDelegate

- (BOOL)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self startLoad:webView webViewController:controller];
    return YES;
}

- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self startLoad:webView webViewController:controller];
}

- (void)startLoad:(UIView<FLWebViewProvider> *)webView webViewController:(UIViewController *)controller
{
    if (_adWebController == controller) {
        
        NSString* targetUrl = nil;
        targetUrl = [webView.request.URL absoluteString];
        if (![_lastADWebRequestUrl isEqualToString:[CTUrl encodeUrl:targetUrl]]) {
            
            long long tsout = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
            
            if (_tsin) {
                [self transformBackWithParam:[self createParams]];
            }
            _lastADWebRequestUrl = [CTUrl encodeUrl:targetUrl];
            _tsin = tsout;
        }
    }  else {
        cootek_log(@"AdInfoModelManager startLoad error: has another controller");
    }
}

- (void)webViewControllerDidGoback:(UIViewController *)controller
{
    cootek_log(@"AdLandingPageManager webViewControllerDidGoback:%@", controller);
    if (_adWebController == controller) {
        if (_tsin || _flts) {
            [self transformBackWithParam:[self createParams]];
        }
        
        _tsin = 0;
        _flts = 0;
        _lastADWebRequestUrl = nil;
    } else {
        cootek_log(@"AdInfoModelManager webViewControllerDidGoback error: has another controller");
    }
    
}

- (void)webViewControllerDidClose:(UIViewController *)controller
{
    cootek_log(@"AdLandingPageManager webViewControllerDidClose:%@", controller);
    
    if (_adWebController == controller) {
        if (_tsin || _flts) {
            [self transformBackWithParam:[self createParams]];
        }
        
        _tsin = 0;
        _flts = 0;
        _lastADWebRequestUrl = nil;
        _ad = nil;
    } else {
        cootek_log(@"AdInfoModelManager webViewControllerDidClose error: has another controller");
    }
}

- (NSDictionary *) createParams
{
    long long tsout = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    if (_ad.ctId && _ad.ctId.length > 0) {
        NSDictionary    *param = @{kADTransformParamSid:_ad.s ? : @"",
                                   kADTransformParamType:kADTransformLandingPage,
                                   kADTransformParamUrl:_lastADWebRequestUrl ? : @"",
                                   kADTransformParamBlts:@(_tsin),
                                   kADTransformParamFlts:@(_flts),
                                   kADTransformParamTsout:@(tsout),
                                   kADTransformParamCtid:_ad.ctId,
                                   kADTransformParamAdid:_ad.adId ? : @"",
                                   kADTransformParamTU:_ad.tu ? : @""};
        return param;
    } else if (_ad.adId && _ad.adId.length > 0) {
        NSDictionary    *param = @{kADTransformParamSid:_ad.s ? : @"",
                                   kADTransformParamType:kADTransformLandingPage,
                                   kADTransformParamUrl:_lastADWebRequestUrl ? : @"",
                                   kADTransformParamTsin:@(_tsin),
                                   kADTransformParamFlts:@(_flts),
                                   kADTransformParamTsout:@(tsout),
                                   kADTransformParamAdid:_ad.adId,
                                   kADTransformParamTU:_ad.tu ? : @""};
        return param;
    }
    return nil;
}
- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self finishLoad:webView webViewController:controller];
}

- (void)webViewController:(UIViewController *)controller webViewDidFinishLoad:(UIView<FLWebViewProvider>*)webView
{
    [self finishLoad:webView webViewController:controller];
}

- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    [self finishLoad:webView webViewController:controller];
}

- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didFailNavigation:(WKNavigation *)navigation
{
    [self finishLoad:webView webViewController:controller];
}


- (void)finishLoad:(UIView<FLWebViewProvider> *)webView webViewController:(UIViewController *)controller
{
    cootek_log(@"AdInfoModelManager webViewDidFinishLoad %@  request:%@  HTTPBody:%@  HTTPMethod:%@", webView, webView.request, webView.request.HTTPBody, webView.request.HTTPMethod);
    
    if (_adWebController == controller) {
        long long tsout = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
        _flts = tsout;
    } else {
        cootek_log(@"AdInfoModelManager webViewDidFinishLoad error: has another controller");
    }
}
#pragma mark UIApplicationDelegate

- (void)applicationDidBecomeActive
{
    UIViewController    *topController = [TouchPalDialerAppDelegate naviController].topViewController;
    long long           tsin = (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    
    if (topController == _adWebController) {
        _flts = tsin;
        _tsin = 0;
    }
}

- (void)applicationDidEnterBackground
{
    UIViewController *topController = [TouchPalDialerAppDelegate naviController].topViewController;
    
    if (topController == _adWebController) {
        
        if (_tsin && _lastADWebRequestUrl) {
            [self transformBackWithParam:[self createParams]];
        }
        
        _flts = 0;
        _tsin = 0;
    }
    
}
@end

@implementation AdInfoModel

- (instancetype) initWithS:(NSString *)s andTu:(NSString *)tu andAdid:(NSString *)adid
{
    self = [self init];
    if (self) {
        self.s = s;
        self.tu = tu;
        
        if (![adid isKindOfClass:[NSString class]] ) {
            self.adId = [((NSArray*)adid) objectAtIndex:0] ;
        }else{
            self.adId = adid;
        }
    }
    return self;
}

- (instancetype) initWithS:(NSString *)s andTu:(NSString *)tu andCtid:(NSString *)ctid
{
    self = [self init];
    if (self) {
        self.s = s;
        self.tu = tu;
        self.ctId = ctid;
    }
    return self;
}

@end
