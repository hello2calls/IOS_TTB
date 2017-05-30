//
//  TLWebSetting.m
//  TouchPalDialer
//
//  Created by lingmeixie on 16/8/15.
//
//

#import "TLWebSetting.h"

@implementation TLWebSetting

- (instancetype) init
{
    self = [super init];
    if (self) {
        
        self.allowsInlineMediaPlayback = NO;
        self.mediaPlaybackRequiresUserAction = YES;
        self.mediaPlaybackAllowsAirPlay = YES;
        self.suppressesIncrementalRendering = NO;
        self.allowsPictureInPictureMediaPlayback = YES;
        self.allowsLinkPreview = NO;
        
        self.paginationMode = UIWebPaginationModeUnpaginated;
        self.paginationBreakingMode = UIWebPaginationBreakingModePage;
        self.pageLength = 0;
        self.gapBetweenPages = 0;
        self.keyboardDisplayRequiresUserAction = YES;
        self.scalesPageToFit = YES;
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        
        self.allowsBackForwardNavigationGestures = NO;
        self.customUserAgent = nil;
        NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [dic objectForKey:@"CFBundleIdentifier"];
        self.applicationNameForUserAgent = appName;
        self.allowsAirPlayForMediaPlayback = YES;
        self.requiresUserActionForMediaPlayback = YES;
        self.selectionGranularity = WKSelectionGranularityDynamic;
        
        self.minimumFontSize = 0;
        self.javaScriptEnabled = YES;
        self.javaScriptCanOpenWindowsAutomatically = NO;
    }
    return self;
}

+ (void)applyTLWebSetting:(TLWebSetting *)setting toUIWebView:(UIWebView *)webView
{
    if (setting == nil) {
        return;
    }
    webView.allowsInlineMediaPlayback = setting.allowsInlineMediaPlayback;
    webView.mediaPlaybackRequiresUserAction = setting.mediaPlaybackRequiresUserAction;
    webView.mediaPlaybackAllowsAirPlay = setting.mediaPlaybackAllowsAirPlay;
    webView.suppressesIncrementalRendering = setting.suppressesIncrementalRendering;

    if ([webView respondsToSelector:@selector(setAllowsPictureInPictureMediaPlayback:)]) {
        webView.allowsPictureInPictureMediaPlayback = setting.allowsPictureInPictureMediaPlayback;
    }
    if ([webView respondsToSelector:@selector(setAllowsLinkPreview:)]) {
        webView.allowsLinkPreview = setting.allowsLinkPreview;
    }
    
    webView.keyboardDisplayRequiresUserAction = setting.keyboardDisplayRequiresUserAction;
    webView.scalesPageToFit = setting.scalesPageToFit;
    webView.dataDetectorTypes = setting.dataDetectorTypes;
    
    if ([webView respondsToSelector:@selector(setPaginationMode:)]) {
        webView.paginationMode = setting.paginationMode;
    }
    if ([webView respondsToSelector:@selector(setPaginationBreakingMode:)]) {
        webView.paginationBreakingMode = setting.paginationBreakingMode;
    }
    if ([webView respondsToSelector:@selector(setPageLength:)]) {
        webView.pageLength = setting.pageLength;
    }
    if ([webView respondsToSelector:@selector(setGapBetweenPages:)]) {
        webView.gapBetweenPages = setting.gapBetweenPages;
    }
}

+ (void)applyTLWebSetting:(TLWebSetting *)setting toWKWebView:(WKWebView *)webView
{
    if (setting == nil) {
        return;
    }
    webView.allowsBackForwardNavigationGestures = setting.allowsBackForwardNavigationGestures;
    if ([webView respondsToSelector:@selector(setCustomUserAgent:)]) {
        webView.customUserAgent = setting.customUserAgent;
    }
    if ([webView respondsToSelector:@selector(setAllowsLinkPreview:)]) {
        webView.allowsLinkPreview = setting.allowsLinkPreview;
    }
}

+ (WKWebViewConfiguration *)createWkWebConfiguration:(nullable TLWebSetting *)setting
{
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    if (setting == nil) {
        return webViewConfig;
    }
    webViewConfig.allowsInlineMediaPlayback = setting.allowsInlineMediaPlayback;
    webViewConfig.suppressesIncrementalRendering = setting.suppressesIncrementalRendering;
    if ([webViewConfig respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
        webViewConfig.mediaPlaybackRequiresUserAction = setting.mediaPlaybackRequiresUserAction;
    }
    if ([webViewConfig respondsToSelector:@selector(setMediaPlaybackAllowsAirPlay:)]) {
        webViewConfig.mediaPlaybackAllowsAirPlay = setting.mediaPlaybackAllowsAirPlay;
    }
    if ([webViewConfig respondsToSelector:@selector(setAllowsPictureInPictureMediaPlayback:)]) {
        webViewConfig.allowsPictureInPictureMediaPlayback = setting.allowsPictureInPictureMediaPlayback;
    }
    if ([webViewConfig respondsToSelector:@selector(setApplicationNameForUserAgent:)]) {
        webViewConfig.applicationNameForUserAgent = setting.applicationNameForUserAgent;
    }
    if ([webViewConfig respondsToSelector:@selector(setAllowsAirPlayForMediaPlayback:)]) {
        webViewConfig.allowsAirPlayForMediaPlayback = setting.allowsAirPlayForMediaPlayback;
    }
    if ([webViewConfig respondsToSelector:@selector(setRequiresUserActionForMediaPlayback:)]) {
        webViewConfig.requiresUserActionForMediaPlayback = setting.requiresUserActionForMediaPlayback;
    }

    webViewConfig.selectionGranularity = setting.selectionGranularity;
    webViewConfig.preferences.javaScriptEnabled = setting.javaScriptEnabled;
    webViewConfig.preferences.minimumFontSize = setting.minimumFontSize;
    webViewConfig.preferences.javaScriptCanOpenWindowsAutomatically = setting.javaScriptCanOpenWindowsAutomatically;

    return webViewConfig;
}

@end
