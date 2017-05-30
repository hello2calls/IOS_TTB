//
//  WebviewControllerDelegate.h
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/23.
//
//

#import "WKWebView+FLWKWebView.h"
#import "UIWebView+FLUIWebView.h"
#ifndef WebviewControllerDelegate_h
#define WebviewControllerDelegate_h

NS_ASSUME_NONNULL_BEGIN

@protocol WebViewControllerDelegate <NSObject>
@optional
- (void)webViewControllerDidGoback:(UIViewController *)controller; // 网页返回
- (void)webViewControllerDidClose:(UIViewController *)controller;  // 关闭网页

- (BOOL)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewController:(UIViewController *)controller webViewDidStartLoad:(UIView<FLWebViewProvider> *)webView;
- (void)webViewController:(UIViewController *)controller webViewDidFinishLoad:(UIView<FLWebViewProvider> *)webView;
- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didFailLoadWithError:(nullable NSError *)error;
- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler;
- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;
- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didFailNavigation:(WKNavigation *)navigation;
- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didCommitNavigation:(WKNavigation *)navigation;
- (void)webViewController:(UIViewController *)controller webView:(UIView<FLWebViewProvider> *)webView didFinishNavigation:(WKNavigation *)navigation;
@end

NS_ASSUME_NONNULL_END
#endif /* WebviewControllerDelegate_h */
