//
//  FlowExchangeView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/2/12.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface FlowExchangeView : UIView<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url delegate:(UIViewController<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate> *)webViewDelegate;
- (void)unableToInteract;
- (void)enableToInteract;
- (void)removeView;
@end
