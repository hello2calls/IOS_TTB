//
//  CootekWebViewController.m
//  TouchPalDialer
//
//  Refactored by Leon Lu on 12-8-6.
//  Copyright (c) 2012年 CooTek. All rights reserved.

#import "CootekWebViewController.h"
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "EditVoipViewController.h"
#import "CootekViewController.h"
#import "SeattleFeatureExecutor.h"
#import "TPShareController.h"
#import "DialerUsageRecord.h"
#import "Reachability.h"
#import "AliPayTask.h"
#import "WePayDelegate.h"
#import "Order.h"
#import "TPDialerResourceManager.h"
#import "CootekNotifications.h"
#import "WKWebView+FLWKWebView.h"
#import "UIWebView+FLUIWebView.h"
#import "RegExCategories.h"
#import "CallLogDataModel.h"
#import "TPCallActionController.h"
#import "DialerGuideAnimationUtil.h"
#import "IndexConstant.h"
#import "TPDialerResourceManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "UIView+TPDExtension.h"

@implementation CootekWebViewController

@synthesize url_string;
@synthesize web_view;
@synthesize web_title;
@synthesize service_id;
@synthesize funcStr;
@synthesize injectJavascript;
@synthesize rightRefreshButton;

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.usingWkWebview = YES;;
    }
    return self;
}

#pragma mark - View lifecycle
- (void)loadView
{
    [super loadView];
    self.containerView = [[UIWebView alloc] initWithFrame: CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), self.view.frame.size.height - TPHeaderBarHeight()) ];
    if (self.usingWkWebview && NSClassFromString(@"WKWebView")) {
        
        NSString* script = @";";
        if (self.injectJavascript) {
            
            NSString* filePath = [[DOCUMENTS_DIR stringByAppendingString:@"/"] stringByAppendingString:WORKING_SPACE];
            NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]enumeratorAtPath:filePath];
            
            for (NSString *fileName in enumerator)
            {
                if ([fileName hasSuffix:@".js"]) {
                    if ([fileName hasPrefix:@"ctk"] && ![fileName hasSuffix:@"ios.v1.js"]) {
                        continue;
                    }
                    script = [script stringByAppendingString:@";"];
                    NSString *jsInjecting = [NSString stringWithContentsOfFile:[[filePath stringByAppendingString:@"/"]  stringByAppendingString:fileName] encoding:NSUTF8StringEncoding error:nil];
                    script = [script stringByAppendingString:jsInjecting];
                }
                
                
            }
        }
        
        
        NSString *getUserAgent
        = @";window.webkit.messageHandlers.didGetUserAgent.postMessage(window.navigator.userAgent);";
        script = [script stringByAppendingString:getUserAgent];
        WKUserScript *getUserAgentScript
        = [[WKUserScript alloc] initWithSource:script
                                 injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                              forMainFrameOnly:YES];
        
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        [userContentController addUserScript:getUserAgentScript];
        [userContentController addScriptMessageHandler:self name:@"didGetUserAgent"];
        
        WKWebViewConfiguration *webViewConfig = [TLWebSetting createWkWebConfiguration:self.webSetting];
        webViewConfig.userContentController = userContentController;
        webViewConfig.allowsInlineMediaPlayback = self.allowsInlineMediaPlayback;
        
        web_view= [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), self.view.frame.size.height - TPHeaderBarHeight()) configuration:webViewConfig];
        [((WKWebView *)web_view) setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [TLWebSetting applyTLWebSetting:self.webSetting toWKWebView:(WKWebView *)web_view];
    } else {
        web_view = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, TPScreenWidth(), self.view.frame.size.height - TPHeaderBarHeight()) ];
        ((UIWebView *)web_view).scalesPageToFit = YES;
        [((UIWebView *)web_view) setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [TLWebSetting applyTLWebSetting:self.webSetting toUIWebView:(UIWebView *)web_view];
        ((UIWebView*)web_view).allowsInlineMediaPlayback = self.allowsInlineMediaPlayback;
    }
    web_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [web_view setDelegateViews: self];
    
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:web_view];
    
    wait_indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(TPScreenWidth()-100, 10 + TPHeaderBarHeightDiff(), 25, 25)];
    wait_indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    wait_indicator.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:wait_indicator];
    
    rightRefreshButton = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 50, TPHeaderBarHeightDiff(), 50, 45)];
    [rightRefreshButton setTitle:@"J" forState:UIControlStateNormal];
    rightRefreshButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    if (self.headerTextColor != nil) {
        [rightRefreshButton setTitleColor:self.headerTextColor forState:UIControlStateNormal];
    } else {
        NSDictionary *property_dic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"defaultUILabel_style"];
        [rightRefreshButton setTitleColor:[TPDialerResourceManager getColorForStyle:[property_dic objectForKey:@"textColor_color"]] forState:UIControlStateNormal];
    }
    
    rightRefreshButton.hidden = YES;
    [rightRefreshButton addTarget:self action:@selector(reloadURL) forControlEvents:UIControlEventTouchUpInside];
    if (self.isRefreshButtonVisible) {
        rightRefreshButton.hidden = NO;
    }
    [self.view addSubview:rightRefreshButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadURL];
}

- (void) reloadURL {
    self.hasLoaded = NO;
    url_string = [self.web_view.URL absoluteString];
    [self loadURL];
}

- (void)loadURL
{
    
    if (url_string) {
        if (!self.hasLoaded) {
            cootek_log(@"load url : %@", url_string);
            NSURL* url = [NSURL URLWithString:url_string];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
            [self.web_view loadRequest:request];
        }
    }
}

#pragma UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [wait_indicator startAnimating];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    
    NSURL *url = [request URL];
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"tel"]) {
        NSString *phoneNumber = [url resourceSpecifier];
        CallLogDataModel *item = [[CallLogDataModel alloc]
                                  initWithPersonId:-1
                                  phoneNumber:phoneNumber
                                  loadExtraInfo:YES];
        [TPCallActionController logCallFromSource:@"YellowPage"];
        [[TPCallActionController controller] makeCall:item];
        [DialerGuideAnimationUtil waitGuideAnimation];
        if (self.jumpOutsideFinish) {
            [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
        }
        return NO;
    }
    if ([scheme isEqualToString:@"http"]) {
        if ([[url resourceSpecifier] hasPrefix:@"//maps.apple.com"]) {
            return ![[UIApplication sharedApplication] openURL:url];
        }
    }
    if ([scheme isEqualToString:@"pic"]) {
        NSArray *ary1 = [[url resourceSpecifier] componentsSeparatedByString: @"url="];
        if ([ary1 count] == 2) {
            NSString *str = ary1[1];
            NSArray *ary2 = [str componentsSeparatedByString:@"&callback="];
            if ([ary2 count] == 2) {
                funcStr = ary2[1];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:(NSString *)ary2[0]]]];
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                if (self.jumpOutsideFinish) {
                    [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
                }
                return NO;
            }
        }
    }
    
    NSString *urlString = (url) ? url.absoluteString : @"";
    // iTunes: App Store link
    if ([urlString isMatch:RX(@"\\/\\/itunes\\.apple\\.com\\/")]) {
        [[UIApplication sharedApplication] openURL:url];
        if (self.jumpOutsideFinish) {
            [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
        }
        return NO;
    }
    
    // Protocol/URL-Scheme without http(s)
    else if (![urlString isMatch:[@"^https?:\\/\\/." toRxIgnoreCase:YES]]&& ![[urlString lowercaseString] isEqualToString:@"about:blank"]) {
        [[UIApplication sharedApplication] openURL:url];
        if (self.jumpOutsideFinish) {
            [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
        }
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.hasLoaded = NO;
    [wait_indicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.hasLoaded = YES;
    [wait_indicator stopAnimating];
    if (!web_title || web_title.length == 0) {
        NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (![theTitle isEqual: @""]) {
            self.headerTitle = theTitle;
            
        }
    }
}


#pragma mark - WKWebView Delegate Methods

/*
 * Called on iOS devices that have WKWebView when the web view wants to start navigation.
 * Note that it calls shouldStartDecidePolicy, which is a shared delegate method,
 * but it's essentially passing the result of that method into decisionHandler, which is a block.
 */
- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    
    
    
    if ([scheme isEqualToString:@"tel"]) {
        NSString *phoneNumber = [url resourceSpecifier];
        CallLogDataModel *item = [[CallLogDataModel alloc]
                                  initWithPersonId:-1
                                  phoneNumber:phoneNumber
                                  loadExtraInfo:YES];
        [TPCallActionController logCallFromSource:@"YellowPage"];
        [[TPCallActionController controller] makeCall:item];
        [DialerGuideAnimationUtil waitGuideAnimation];
        decisionHandler(WKNavigationActionPolicyCancel);
        if (self.jumpOutsideFinish) {
            [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
        }
        return;
    }
    if ([scheme isEqualToString:@"http"]) {
        if ([[url resourceSpecifier] hasPrefix:@"//maps.apple.com"]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    if ([scheme isEqualToString:@"pic"]) {
        NSArray *ary1 = [[url resourceSpecifier] componentsSeparatedByString: @"url="];
        if ([ary1 count] == 2) {
            NSString *str = ary1[1];
            NSArray *ary2 = [str componentsSeparatedByString:@"&callback="];
            if ([ary2 count] == 2) {
                funcStr = ary2[1];
                UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:(NSString *)ary2[0]]]];
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                decisionHandler(WKNavigationActionPolicyCancel);
                if (self.jumpOutsideFinish) {
                    [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
                }
                return;
            }
        }
    }
    
    NSString *urlString = (url) ? url.absoluteString : @"";
    // iTunes: App Store link
    if ([urlString isMatch:RX(@"\\/\\/itunes\\.apple\\.com\\/")]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        if (self.jumpOutsideFinish) {
            [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
        }
        return;
    }
    
    // Protocol/URL-Scheme without http(s)
    else if (![urlString isMatch:[@"^https?:\\/\\/." toRxIgnoreCase:YES]]
             && ![[urlString lowercaseString] isEqualToString:@"about:blank"]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        if (self.jumpOutsideFinish) {
            [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
        }
        return;
    }
    decisionHandler([self shouldStartDecidePolicy: [navigationAction request]]);
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo

{
    NSString *msg = nil;
    NSString *func = nil;
    if(error != NULL) {
        msg = NSLocalizedString(@"save_image_failed", @"保存失败");
        func = [NSString stringWithFormat:@"%@(false)", funcStr];
    } else {
        msg = NSLocalizedString(@"save_image_succeed", @"保存成功");
        func = [NSString stringWithFormat:@"%@(true)", funcStr];
    }
    [self.web_view evaluateJavaScript:func completionHandler:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                          otherButtonTitles:nil];
    [alert show];
}


/*
 * Called on iOS devices that have WKWebView when the web view starts loading a URL request.
 * Note that it just calls didStartNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (WKNavigation *) navigation
{
    [self didStartNavigation];
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method,
 * but it has to retrieve the active request from the web view as WKNavigation doesn't contain a reference to it.
 */
- (void) webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
}

/*
 * Called on iOS devices that have WKWebView when the web view begins loading a URL request.
 * This could call some sort of shared delegate method, but is unused currently.
 */
- (void) webView: (WKWebView *) webView didCommitNavigation: (WKNavigation *) navigation
{
    [wait_indicator startAnimating];
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFailNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
}

/*
 * Called on iOS devices that have WKWebView when the web view finishes loading a URL request.
 * Note that it just calls finishLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    [self finishLoadOrNavigation: [webView request]];
}

#pragma mark - Shared Delegate Methods

/*
 * This is called whenever the web view wants to navigate.
 */
- (BOOL) shouldStartDecidePolicy: (NSURLRequest *) request
{
    // Determine whether or not navigation should be allowed.
    // Return YES if it should, NO if not.
    
    return YES;
}

/*
 * This is called whenever the web view has started navigating.
 */
- (void) didStartNavigation
{
    // Update things like loading indicators here.
}

/*
 * This is called when navigation failed.
 */
- (void) failLoadOrNavigation: (NSURLRequest *) request withError: (NSError *) error
{
    // Notify the user that navigation failed, provide information on the error, and so on.
}

/*
 * This is called when navigation succeeds and is complete.
 */
- (void) finishLoadOrNavigation: (NSURLRequest *) request
{
    // Remove the loading indicator, maybe update the navigation bar's title if you have one.
}

///Generates script to create given cookies
- (NSString*) getJSCookiesString:(NSArray* )cookies {
    NSString* result = @"";
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    
    [dateFormatter setDateFormat: @"EEE, d MMM yyyy HH:mm:ss zzz"];
    
    for (NSHTTPCookie* cookie in cookies) {
        result = [NSString stringWithFormat:@"%@document.cookie='\(%@)=\(%@); domain=\(%@); path=\(%@); ", cookie.name, cookie.value, cookie.domain, cookie.path, result ];
        NSDate* date = cookie.expiresDate;
        NSString* d = [dateFormatter stringFromDate:date];
        result = [NSString stringWithFormat:@"%@expires=(%@);",result, d];
        result = [NSString stringWithFormat:@"%@secure; '; ",result];
    }
    return result;
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    id body = message.body;
    NSString *keyPath = message.name;
    
    if ([body isKindOfClass:[NSString class]]) {
        if ([keyPath isEqualToString:@"didGetUserAgent"]) {
            NSLog(@"UserAgent: %@", body);
        }
        
    }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler
{
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    CFDataRef exceptions = SecTrustCopyExceptions(serverTrust);
    SecTrustSetExceptions(serverTrust, exceptions);
    CFRelease(exceptions);
    
    completionHandler(NSURLSessionAuthChallengeUseCredential,
                      [NSURLCredential credentialForTrust:serverTrust]);
}

@end
