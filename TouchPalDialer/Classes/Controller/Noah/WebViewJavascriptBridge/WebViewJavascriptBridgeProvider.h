//
//  WebViewJavascriptBridgeProvider.h
//  TouchPalDialer
//
//  Created by tanglin on 15/11/25.
//
//

#ifndef WebViewJavascriptBridgeProvider_h
#define WebViewJavascriptBridgeProvider_h
#import "WebViewJavascriptBridgeBase.h"

#endif /* WebViewJavascriptBridgeProvider_h */
@protocol WebViewJavascriptBridgeProvider <NSObject>

- (void)send:(id)message;
- (void)send:(id)message responseCallback:(WVJBResponseCallback)responseCallback;
- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;

@end