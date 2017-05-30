//
//  HandlerWebViewControllerForV6.m
//  TouchPalDialer
//
//  Created by weyl on 16/10/11.
//
//

#import "HandlerWebViewControllerForV6.h"
#import "YellowPageWebViewController.h"
#import "UIScrollView+MJRefresh.h"
#import "MJRefreshNormalHeader.h"
#import "UIView+TPDExtension.h"

@interface HandlerWebViewControllerForV6 ()
@property (nonatomic) BOOL isFirstTimeLoad;
@end

@implementation HandlerWebViewControllerForV6

- (void)viewDidLoad {
    self.isFirstTimeLoad = true;
    [super viewDidLoad];
    if ([self.web_view isKindOfClass:[UIWebView class]]) {
        ((UIWebView *)self.web_view).scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshLoad)];
        self.mj_header = ((UIWebView *)self.web_view).scrollView.mj_header ;
    } else {
         ((WKWebView *)self.web_view).scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshLoad)];
        self.mj_header = ((WKWebView *)self.web_view).scrollView.mj_header ;
    }
//    self.web_view.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshLoad)];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if (!self.isFirstTimeLoad) {
        YellowPageWebViewController *controller = [[YellowPageWebViewController alloc] init];
//        controller.jumpOutsideFinish = jumpOutsideFinish;
        controller.url_string = request.URL.absoluteString;
        controller.usingWkWebview = YES;
        controller.needTitle = YES;

        [self.navigationController pushViewController:controller animated:NO];
        return NO;
    }else{
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }

    
}

- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    
    if (!self.isFirstTimeLoad) {
        
        if ([navigationAction.request.URL.absoluteString rangeOfString:@"#cootek_popup"].location != NSNotFound
            || [navigationAction.request.URL.absoluteString rangeOfString:@"about:blank"].location != NSNotFound) {
            [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        }else{
            YellowPageWebViewController *controller = [[YellowPageWebViewController alloc] init];
            //        controller.jumpOutsideFinish = jumpOutsideFinish;
            controller.url_string = navigationAction.request.URL.absoluteString;
            controller.usingWkWebview = YES;
            controller.needTitle = YES;
            
            [self.navigationController pushViewController:controller animated:NO];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        
    }else{
        [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }

}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [super webViewDidFinishLoad:webView];
    self.isFirstTimeLoad = false;
}

- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    [super webView:webView didFinishNavigation:navigation];
    self.isFirstTimeLoad = false;
}

- (void) refreshLoad
{
    self.hasLoaded = NO;
    self.isFirstTimeLoad = YES;
    [self.mj_header beginRefreshing];
    [self loadURL];
}

- (void) finishLoad
{
    [super finishLoad];
    [self.mj_header endRefreshing];
}

- (void) showReload
{
    [super showReload];
    [self.mj_header endRefreshing];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
