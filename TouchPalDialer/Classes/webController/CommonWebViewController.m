//
//  CommonWebViewController.m
//  TouchPalDialer
//
//  Created by game3108 on 15/4/13.
//
//

#import "CommonWebViewController.h"
#import "TPDialerResourceManager.h"
#import "NoahManager.h"
#import "UserDefaultsManager.h"
#import "RootScrollViewController.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "FunctionUtility.h"
#import "MarketLoginController.h"
#import "Reachability.h"

@interface CommonWebViewController() <CommonHeaderBarProtocol>{
    void(^_webviewDidStartLoadBlock)(UIView<FLWebViewProvider> *webView);
    void(^_webviewDidFinishLoadBlock)(UIView<FLWebViewProvider> *webView);
    void(^_webviewDidFailedLoadBlock)(UIView<FLWebViewProvider> *webView, NSError *error);
    UIColor *_bgColor;
    UIButton *refreshButton;
}

@end

@implementation CommonWebViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.useWkWebView = YES;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if ( _ifLight ){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        [FunctionUtility setAppHeaderStyle];
    }
    if (_webViewCanNotScroll) {
         self.view.backgroundColor = [UIColor clearColor];
    }else{
         self.view.backgroundColor = [UIColor whiteColor];
    }
   
    _headerBar= [[CommonHeaderBar alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth() , 45+TPHeaderBarHeightDiff()) andHeaderTitle:_header_title];
    _headerBar.delegate = self;
    [self.view addSubview:_headerBar];
    [self refreshHeader];
    
    refreshButton = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 50, TPHeaderBarHeightDiff(), 50, 45)];
    [refreshButton setTitle:@"J" forState:UIControlStateNormal];
    refreshButton.titleLabel.font = [UIFont fontWithName:@"iPhoneIcon3" size:24];
    
    NSDictionary *property_dic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"defaultUILabel_style"];
    BOOL isVersionSix = [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
    [refreshButton setTitleColor:[TPDialerResourceManager getColorForStyle:isVersionSix ? @"skinHeaderBarOperationText_normal_color": [property_dic objectForKey:@"textColor_color"]] forState:UIControlStateNormal];
    if ( _ifLight ){
        [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [_headerBar addSubview:refreshButton];
    [refreshButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    refreshButton.hidden = _ifRefreshHidden;
    
    if (_headerTextColor) {
        [_headerBar.leftButton setTitleColor:_headerTextColor forState:UIControlStateNormal];
        _headerBar.headerLabel.textColor = _headerTextColor;
        [refreshButton setTitleColor:_headerTextColor forState:UIControlStateNormal];
    }
    
    float webViewY = TPHeaderBarHeight();
    float webViewHeight = TPScreenHeight() - webViewY;
    if ( _ifHideHeaderBar ){
        _headerBar.hidden = YES;
        webViewY = 0;
    }
    if ( _viewFrame.size.height != 0 ){
        webViewHeight = _viewFrame.size.height-webViewY;
    }
#ifdef DEBUG
    if (self.url_string.length>0 && [self.url_string rangeOfString:@"wk=true"].location != NSNotFound) {
        self.useWkWebView = YES;
    }
#endif
    if (_webViewFullScreen) {
        _headerBar.hidden = YES;
        webViewY = 0;
        webViewHeight = TPScreenHeight() - webViewY;
    }
    

    if (_webViewCanNotScroll) {
        _commonWebView = [[CommonWebView alloc]initWithADFrame:CGRectMake(0, webViewY, TPScreenWidth(), webViewHeight) andIfNoah:_isNoah];
        ((UIWebView *)_commonWebView.web_view).scrollView.scrollEnabled = NO;
    }else{
        _commonWebView = [[CommonWebView alloc]initWithFrame:CGRectMake(0, webViewY, TPScreenWidth(), webViewHeight) andIfNoah:_isNoah andUsingWkWebview:self.useWkWebView];
    }
    [_commonWebView.web_view setDelegateViews: self];
    _commonWebView.url_string = self.url_string;
    [self.view addSubview:_commonWebView];
    
    if ( _file_name != nil && [_file_name length] > 0 ){
        [_commonWebView loadFile:_file_name];
    }else{
        [_commonWebView loadURL];
    }

    [self onDataCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHeader) name:N_SKIN_DID_CHANGE object:nil];
}

- (void) onDataCount{
    if ([_url_string isEqualToString:[MarketLoginController getActivityCenterUrlString]])
        [DialerUsageRecord recordpath:EV_ACTIVITY_MARKET_ENTER_ALL kvs:Pair(@"count", @(1)), nil];
}

- (void)setHeaderBarBackgroundColor:(UIColor *)bgColor{
    _bgColor = bgColor;
    if ( _headerBar != nil )
        _headerBar.backgroundColor = _bgColor;
}

- (void)setHeaderTitle:(NSString *)headerTitle{
    _header_title = headerTitle;
    if (headerTitle && ![headerTitle isEqual: @""]) {
        [_headerBar setHeaderTitle:headerTitle];
    }
}

- (void) setWebViewScroll:(BOOL)ifScroll{
    if ( [_commonWebView.web_view isKindOfClass:[UIWebView class]] ){
        ((UIWebView *)_commonWebView.web_view).scrollView.scrollEnabled = ifScroll;
    }else if ( [_commonWebView.web_view isKindOfClass:[WKWebView class]] ){
        ((WKWebView *)_commonWebView.web_view).scrollView.scrollEnabled = ifScroll;
    }
}

- (void)setRefreshButton:(BOOL)ifRefreshHidden{
    _ifRefreshHidden = ifRefreshHidden;
    refreshButton.hidden = ifRefreshHidden;
}

- (void)reloadUrl:(NSString *)url{
    _url_string = url;
    _commonWebView.url_string = url;
    [_commonWebView reloadURL];
}

- (void)reload{
    [_commonWebView reload];
}

- (void)reloadFile:(NSString *)fileName;{
    _file_name = fileName;
    [_commonWebView loadFile:_file_name];
}

- (void)refreshHeader{
    [_headerBar setLight:_ifLight];
    if ( _bgColor != nil )
        _headerBar.backgroundColor = _bgColor;
    else{
        NSDictionary *property_dic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"defaultHeaderView_style"];
        NSString* imageName = [property_dic objectForKey:BACK_GROUND_IMAGE];
        if ([imageName rangeOfString:@".png"].length>0) {
            _headerBar.imageView.image = [TPDialerResourceManager getImage:imageName];
        }else{
            _headerBar.imageView.image = nil;
            _headerBar.backgroundColor =  [UIColor colorWithPatternImage:[TPDialerResourceManager getImage:imageName]];
        }
        if ( _ifLight ){
            [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            NSDictionary *dic = [[TPDialerResourceManager sharedManager] getPropertyDicByStyle:@"defaultUILabel_style"];
            [refreshButton setTitleColor:[TPDialerResourceManager getColorForStyle:[dic objectForKey:@"textColor_color"]] forState:UIControlStateNormal];
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark CommonHeaderBar delegate
- (void) leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
    if ( [self.navigationController.topViewController isKindOfClass:[RootScrollViewController class]]){
        [FunctionUtility setAppHeaderStyle];
    }
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewControllerDidClose:)]) {
        [self.controllerDelegate webViewControllerDidClose:self];
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:shouldStartLoadWithRequest:navigationType:)]) {
        if (![self.controllerDelegate webViewController:self webView:webView shouldStartLoadWithRequest:request navigationType:navigationType]) {
            return NO;
        }
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    refreshButton.enabled = NO;
    if (_commonWebView.needLoad) {
        [_commonWebView showLoading];
        _commonWebView.needLoad = NO;
    }
    if (_webviewDidStartLoadBlock) {
        _webviewDidStartLoadBlock(webView);
    }
    
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webViewDidStartLoad:)]) {
        [self.controllerDelegate webViewController:self webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    refreshButton.enabled = YES;
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (theTitle && ![theTitle isEqual: @""]) {
        [_headerBar setHeaderTitle:theTitle];
    }
    if (_commonWebView.hasLoaded) {
        return;
    }

    ClientNetworkType netType = [[Reachability shareReachability] networkStatus];
    if (netType == network_none){
        
        if ( self.webViewFullScreen == YES &&
            self.webViewCanNotScroll == YES) {
            
        }else{
        cootek_log(@"webview no net");
        _commonWebView.hasLoaded = NO;
        [_commonWebView showReload];
        return;
        }
    }
    
    if ( _isNoah )
        [[NoahManager sharedPSInstance] webPageLoadedWithUrl:self.url_string];
    _commonWebView.hasLoaded = YES;
    [_commonWebView showPage];
    if (_webviewDidFinishLoadBlock) {
        _webviewDidFinishLoadBlock(webView);
    }
    
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webViewDidFinishLoad:)]) {
        [self.controllerDelegate webViewController:self webViewDidFinishLoad:webView];
    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    refreshButton.enabled = YES;
    _commonWebView.hasLoaded = NO;
    cootek_log(@"webview error : %@",[error localizedDescription]);
    if (error.code == 102) {
        [_commonWebView showReloadWithText:@"此链接不可用"];
    } else if (error.code != NSURLErrorCancelled) {
        [_commonWebView showReload];
    }
    
    if (_webviewDidFailedLoadBlock) {
        _webviewDidFailedLoadBlock(webView, error);
    }
    
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didFailLoadWithError:)]) {
        [self.controllerDelegate webViewController:self webView:webView didFailLoadWithError:error];
    }
}

- (void)setStartLoadAction:(void (^)(UIView<FLWebViewProvider> *webView))webviewDidStartLoadAction {
    _webviewDidStartLoadBlock = webviewDidStartLoadAction;
}

- (void)setFinishLoadAction:(void (^)(UIView<FLWebViewProvider> *webView))webviewDidFinishLoadAction {
    _webviewDidFinishLoadBlock = webviewDidFinishLoadAction;
}

- (void)setFailedLoadAction:(void (^)(UIView<FLWebViewProvider> *webView, NSError *))webviewDidFailedLoadAction {
    _webviewDidFailedLoadBlock = webviewDidFailedLoadAction;
}



#pragma mark - WKWebView Delegate Methods

/*
 * Called on iOS devices that have WKWebView when the web view wants to start navigation.
 * Note that it calls shouldStartDecidePolicy, which is a shared delegate method,
 * but it's essentially passing the result of that method into decisionHandler, which is a block.
 */
- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    decisionHandler([self shouldStartDecidePolicy: [navigationAction request]]);
    
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
    if (_commonWebView.needLoad) {
        [_commonWebView showLoading];
        _commonWebView.needLoad = NO;
    }
    if (_webviewDidStartLoadBlock) {
        _webviewDidStartLoadBlock(webView);
    }
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

    [self finishLoadOrNavigation:webView withRequest:[webView request]];
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didFinishNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didFinishNavigation:navigation];
    }
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
    
}

/*
 * This is called when navigation failed.
 */
- (void) failLoadOrNavigation: (NSURLRequest *) request withError: (NSError *) error
{
    // Notify the user that navigation failed, provide information on the error, and so on.
    cootek_log(@"webview error : %@",[error localizedDescription]);
    if (error.code == 102) {
        [_commonWebView showReloadWithText:@"此链接不可用"];
    } else if (error.code != NSURLErrorCancelled) {
        [_commonWebView showReload];
    }
}

/*
 * This is called when navigation succeeds and is complete.
 */
- (void) finishLoadOrNavigation:(UIView<FLWebViewProvider>*)webview withRequest:(NSURLRequest *) request
{
    if (_commonWebView.hasLoaded) {
        return;
    }
    if ( _isNoah )
        [[NoahManager sharedPSInstance] webPageLoadedWithUrl:self.url_string];
    _commonWebView.hasLoaded = YES;
    [webview evaluateJavaScript:@"document.title"  completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        NSString* theTitle = ret;
        if (theTitle && ![theTitle isEqual: @""]) {
            [_headerBar setHeaderTitle:theTitle];
        }
#ifdef DEBUG
        if ([self.url_string rangeOfString:@"wk=true"].location != NSNotFound) {
            NSMutableString *mutableTitle = [[NSMutableString alloc] init];
            NSString *title = theTitle.length > 0 ? theTitle : self.title;
            [mutableTitle appendString:@"(WKWebView)"];
            [mutableTitle appendString:[NSString nilToEmpty:title]];
            [_headerBar setHeaderTitle:[mutableTitle copy]];
        }
#endif
        [_commonWebView showPage];
    }];
    
    if (_webviewDidFinishLoadBlock) {
        _webviewDidFinishLoadBlock(webview);
    }
}

@end
