//
//  WebViewJavascriptBridgeBase.m
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridgeBase.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "SeattleFeatureExecutor.h"
#import "LocalStorage.h"
#import "IndexConstant.h"
#import "WXApi.h"
#import "TouchPalVersionInfo.h"
#import "FunctionUtility.h"

@implementation WebViewJavascriptBridgeBase {
    id _webViewDelegate;
    long _uniqueId;
    NSBundle *_resourceBundle;
}

static bool logging = false;

+ (void)enableLogging { logging = true; }

-(id)initWithHandler:(WVJBHandler)messageHandler resourceBundle:(NSBundle*)bundle
{
    self = [super init];
    _resourceBundle = bundle;
    self.messageHandler = messageHandler;
    self.messageHandlers = [NSMutableDictionary dictionary];
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
    return(self);
}

- (void)dealloc {
    self.startupMessageQueue = nil;
    self.responseCallbacks = nil;
    self.messageHandlers = nil;
    self.messageHandler = nil;
}

- (void)reset {
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
}

- (void)sendData:(id)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    
    if (data) {
        message[@"data"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    [self _queueMessage:message];
}

- (void)flushMessageQueue:(NSString *)messageQueueString{
    id messages;
    if (messageQueueString) {
        messages = [self _deserializeMessageJSON:messageQueueString];
    }
    
    if (![messages isKindOfClass:[NSArray class]]) {
        NSLog(@"WebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [messages class], messages);
        return;
    }
    for (WVJBMessage* message in messages) {
        if (![message isKindOfClass:[WVJBMessage class]]) {
            NSLog(@"WebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
            continue;
        }
        [self _log:@"RCVD" json:message];
        
        NSString* responseId = message[@"responseId"];
        if (responseId) {
            WVJBResponseCallback responseCallback = _responseCallbacks[responseId];
            responseCallback(message[@"responseData"]);
            [self.responseCallbacks removeObjectForKey:responseId];
        } else {
            WVJBResponseCallback responseCallback = NULL;
            NSString* callbackId = message[@"callbackId"];
            if (callbackId) {
                responseCallback = ^(id responseData) {
                    if (responseData == nil) {
                        responseData = [NSNull null];
                    }
                    
                    WVJBMessage* msg = @{ @"responseId":callbackId, @"responseData":responseData };
                    [self _queueMessage:msg];
                };
            } else {
                responseCallback = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }
            
            WVJBHandler handler;
            if (message[@"handlerName"]) {
                handler = self.messageHandlers[message[@"handlerName"]];
            } else {
                handler = self.messageHandler;
            }
            
            if (!handler) {
//                [NSException raise:@"WVJBNoHandlerException" format:@"No handler for message from JS: %@", message];
                cootek_log(@"No handler for message from JS: %@",message);
            } else {
                handler(message[@"data"], responseCallback);
            }
        }
    }
}

- (void)injectJavascriptFile:(BOOL)shouldInject webView:(UIView<FLWebViewProvider> *)webview {
    if(shouldInject){
        NSBundle *bundle = _resourceBundle ? _resourceBundle : [NSBundle mainBundle];
        NSString *filePath = [bundle pathForResource:@"WebViewJavascriptBridge.js" ofType:@"txt"];
        NSString *jsBridge = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [self webview:webview evaluateJavaScript:jsBridge completionHandler:^(id callback, NSError *error) {
            [self injectForDispatch:webview];
        }];
    }
    
}

- (void) injectForDispatch:(UIView<FLWebViewProvider> *)webview
{
    NSString* secret =  [FunctionUtility simpleDecodeForString:[UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]];
    NSString* accountName = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    
    BOOL isWXInstalled = [WXApi isWXAppInstalled] ? YES : NO;
    BOOL isWXSupported = [WXApi isWXAppSupportApi] ? YES : NO;
    
    NSString *interfaceFilePath = [[NSBundle mainBundle] pathForResource:@"WebViewJavascriptInterface.js" ofType:@"txt"];
    NSString *jsInterface = [NSString stringWithContentsOfFile:interfaceFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary * activationJsonInfo = [[NSMutableDictionary alloc] init];
    [activationJsonInfo setValue:COOTEK_APP_NAME forKey:@"app_name"];
    [activationJsonInfo setValue:CURRENT_TOUCHPAL_VERSION forKey:@"app_version"];
    [activationJsonInfo setValue:IPHONE_CHANNEL_CODE forKey:@"channel_code"];
    
    NSString* callbackValue = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:activationJsonInfo options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString* jsStr = [NSString stringWithFormat:jsInterface,
                       WEBVIEW_JAVASCRIPT_API_LEVEL,
                       [UserDefaultsManager stringForKey:NATIVE_PARAM_LOCATION defaultValue:@""],
                       [UserDefaultsManager stringForKey:NATIVE_PARAM_ADDR defaultValue:@""],
                       [UserDefaultsManager stringForKey:NATIVE_PARAM_CITY defaultValue:@""],
                       [UserDefaultsManager stringForKey:NATIVE_PARAM_LOCATION_CACHE_TIME defaultValue:@""],
                       [UserDefaultsManager stringForKey:NATIVE_PARAM_ADDR_CACHE_TIME defaultValue:@""],
                       [UserDefaultsManager stringForKey:NATIVE_PARAM_CITY_CACHE_TIME defaultValue:@""],
                       secret == nil ? @"" : secret,
                       [SeattleFeatureExecutor getToken],
                       accountName == nil ? @"" : accountName,
                       [NSNumber numberWithInt:isWXInstalled],
                       [NSNumber numberWithInt:isWXSupported],
                       callbackValue,
                       [UserDefaultsManager stringForKey:SEATTLE_AUTH_LOGIN_ACCESS_TOKEN defaultValue:@""],
                       [UserDefaultsManager stringForKey:SEATTLE_AUTH_LOGIN_TICKET defaultValue:@""]];
    
    [self webview:webview evaluateJavaScript:jsStr completionHandler:^(id callback, NSError *error) {
        [LocalStorage nativeItemToStorage:webview];
        [self webview:webview evaluateJavaScript:@"if(CTK) {CTK.dispatchEvent}" completionHandler:^(id callback, NSError *error){
            [self dispatchStartUpMessageQueue];
        }];
        
    }];
}

- (void)dispatchStartUpMessageQueue {
    if (self.startupMessageQueue) {
        for (id queuedMessage in self.startupMessageQueue) {
            [self _dispatchMessage:queuedMessage];
        }
        self.startupMessageQueue = nil;
    }
}

-(BOOL)isCorrectProcotocolScheme:(NSURL*)url {
    if([[url scheme] isEqualToString:kCustomProtocolScheme]){
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)isCorrectHost:(NSURL*)url {
    if([[url host] isEqualToString:kQueueHasMessage]){
        return YES;
    } else {
        return NO;
    }
}

-(void)logUnkownMessage:(NSURL*)url {
    NSLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", kCustomProtocolScheme, [url path]);
}

-(NSString *)webViewJavascriptCheckCommand {
    return @"typeof WebViewJavascriptBridge == \'object\';";
}

-(NSString *)webViewJavascriptFetchQueyCommand {
    return @"WebViewJavascriptBridge._fetchQueue();";
}

// Private
// -------------------------------------------

- (void)webview:(UIView<FLWebViewProvider> *)webview evaluateJavaScript: (NSString *) javaScriptString completionHandler: (void (^)(id callback, NSError * error)) completionHandler {
    [self.delegate webview:webview evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (void)_queueMessage:(WVJBMessage*)message {
    if (self.startupMessageQueue) {
        [self.startupMessageQueue addObject:message];
    } else {
        [self _dispatchMessage:message];
    }
}

- (void)_dispatchMessage:(WVJBMessage*)message {
    NSString *messageJSON = [self _serializeMessage:message];
    [self _log:@"SEND" json:messageJSON];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString* javascriptCommand = [NSString stringWithFormat:@"WebViewJavascriptBridge._handleMessageFromObjC('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [_flWebView evaluateJavaScript:javascriptCommand completionHandler:nil];
        
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_flWebView evaluateJavaScript:javascriptCommand completionHandler:nil];
        });
    }
}

- (NSString *)_serializeMessage:(id)message {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (NSArray*)_deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)_log:(NSString *)action json:(id)json {
    if (!logging) { return; }
    if (![json isKindOfClass:[NSString class]]) {
        json = [self _serializeMessage:json];
    }
    if ([json length] > 500) {
        NSLog(@"WVJB %@: %@ [...]", action, [json substringToIndex:500]);
    } else {
        NSLog(@"WVJB %@: %@", action, json);
    }
}

@end
