//
//  TLWebSetting.h
//  TouchPalDialer
//
//  Created by lingmeixie on 16/8/15.
//
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface TLWebSetting : NSObject

@property (nonatomic) BOOL allowsInlineMediaPlayback;
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;
@property (nonatomic) BOOL mediaPlaybackAllowsAirPlay;
@property (nonatomic) BOOL suppressesIncrementalRendering;
@property (nonatomic) BOOL allowsPictureInPictureMediaPlayback;
@property (nonatomic) BOOL allowsLinkPreview;

@property (nonatomic) UIWebPaginationMode paginationMode;
@property (nonatomic) UIWebPaginationBreakingMode paginationBreakingMode;
@property (nonatomic) CGFloat pageLength;
@property (nonatomic) CGFloat gapBetweenPages;
@property (nonatomic) BOOL keyboardDisplayRequiresUserAction;
@property (nonatomic) BOOL scalesPageToFit;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;

@property (nonatomic) BOOL allowsBackForwardNavigationGestures;
@property (nullable, nonatomic, copy) NSString *customUserAgent;
@property (nullable, nonatomic, copy) NSString *applicationNameForUserAgent;
@property (nonatomic) BOOL allowsAirPlayForMediaPlayback;
@property (nonatomic) BOOL requiresUserActionForMediaPlayback;
@property (nonatomic) WKSelectionGranularity selectionGranularity;

@property (nonatomic) CGFloat minimumFontSize;
@property (nonatomic) BOOL javaScriptEnabled;
@property (nonatomic) BOOL javaScriptCanOpenWindowsAutomatically;

+ (void)applyTLWebSetting:(nullable TLWebSetting *)setting toUIWebView:(nonnull UIWebView *)webView;
+ (void)applyTLWebSetting:(nullable TLWebSetting *)setting toWKWebView:(nonnull WKWebView *)webView;

+ (nonnull WKWebViewConfiguration *)createWkWebConfiguration:(nullable TLWebSetting *)setting;

@end
