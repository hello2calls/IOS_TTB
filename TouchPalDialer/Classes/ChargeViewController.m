//
//  ChargeViewController.m
//  TouchPalDialer
//
//  Created by by.huang on 2017/5/26.
//
//

#import "ChargeViewController.h"
#import "CommonWebView.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "TPDialerResourceManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "SeattleFeatureExecutor.h"
#import "IndexConstant.h"
@interface ChargeViewController ()

@end

@implementation ChargeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView
{
    [self.view setBackgroundColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_50"]];
    [self initHeader];
    [self initWebView];
}

-(void)initHeader
{
    HeaderBar *headerBar = [[HeaderBar alloc] initHeaderBar];
    [headerBar setSkinStyleWithHost:self forStyle:@"defaultHeaderView_style"];
    [self.view addSubview:headerBar];
    
    TPHeaderButton *gobackBtn = [[TPHeaderButton alloc] initLeftBtnWithFrame:CGRectMake(0, 0, 50, 45)];
    [gobackBtn setSkinStyleWithHost:self forStyle:@"default_backButton_style"];
    [gobackBtn addTarget:self action:@selector(gobackBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobackBtn];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-120)/2, TPHeaderBarHeightDiff(), 120, 45)];
    [titleLabel setSkinStyleWithHost:self forStyle:@"defaultUILabel_style"];
    titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_2_5];
    titleLabel.text = @"充值";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [headerBar addSubview:titleLabel];
}

-(void)initWebView
{
    _webviewHandler = [[CootekWebHandler alloc]initWithWebView:self.web_view andDelegate:self];
    [_webviewHandler registerHandler];
    [self loadURL];

}

- (void) reloadURL {
    self.hasLoaded = NO;
    [self loadURL];
}

- (void)loadURL
{
    if (!self.hasLoaded) {
        NSURL* url = [NSURL URLWithString:CHARGE_URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        [self.web_view loadRequest:request];
    }
}

//[webviewHandler initPageData];


#pragma mark - WKWebView Delegate Methods
- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.controllerDelegate webViewController:self webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
}

/*
 * Called on iOS devices that have WKWebView when the web view starts loading a URL request.
 * Note that it just calls didStartNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (WKNavigation *) navigation
{
//    [self startLoading];
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didStartProvisionalNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didStartProvisionalNavigation:navigation];
    }
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method,
 * but it has to retrieve the active request from the web view as WKNavigation doesn't contain a reference to it.
 */
- (void) webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didFailProvisionalNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didFailProvisionalNavigation:navigation];
    }
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFailNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didFailNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didFailNavigation:navigation];
    }
}

/*
 * Called on iOS devices that have WKWebView when the web view begins loading a URL request.
 * This could call some sort of shared delegate method, but is unused currently.
 */
- (void) webView: (WKWebView *) webView didCommitNavigation: (WKNavigation *) navigation
{
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didCommitNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didCommitNavigation:navigation];
    }
}


/*
 * Called on iOS devices that have WKWebView when the web view finishes loading a URL request.
 * Note that it just calls finishLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    [self finishLoadOrNavigation: [webView request]];
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didFinishNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didFinishNavigation:navigation];
    }
//    if (loadDate) {
//        int interval = [[NSDate date] timeIntervalSinceDate:loadDate] * 1000;
//        loadDate = nil;
//        cootek_log(@"webViewDidFinishLoad load minus seconds= %d",interval);
//    }
}


/*
 * This is called when navigation failed.
 */
- (void) failLoadOrNavigation: (NSURLRequest *) request withError: (NSError *) error
{
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) {
        return;
    }
    
    // Notify the user that navigation failed, provide information on the error, and so on.
    self.hasLoaded = NO;
    if (error.code != NSURLErrorCancelled) {
//        [self showReload];
    } else {
        [self finishLoadOrNavigation:request];
    }
}


- (void) finishLoadOrNavigation: (NSURLRequest *) request
{
    
    [self finishLoad];
}

- (void) finishLoad
{
    [_webviewHandler initPageData];

}
-(void)gobackBtnPressed
{
    [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
}


@end
