//
//  NoahWebHandler.h
//  TouchPalDialer
//
//  Created by game3108 on 15/2/2.
//
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"
#import "FLWebViewProvider.h"
#import <WebKit/WebKit.h>
#import "AdMessageModel.h"

@protocol CootekWebHandlerDelegate<NSObject>
@optional
- (void) setHeaderTitle:(NSString *)name;
- (void) setWebViewScroll:(BOOL)ifScroll;
@end


@interface CootekWebHandler : NSObject
@property (nonatomic, weak) id<CootekWebHandlerDelegate>webDelegate;
- (instancetype)initWithWebView:(UIView<FLWebViewProvider> *)webView andDelegate:(UIViewController<UIWebViewDelegate> *)webViewDelegate;
- (void)registerHandler;
- (void)initPageData;
@end
