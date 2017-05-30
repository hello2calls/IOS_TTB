//
//  NoahWebView.h
//  TouchPalDialer
//
//  Created by game3108 on 15/2/2.
//
//

#import <UIKit/UIKit.h>
#import "FLWebViewProvider.h"
@interface CommonWebView : UIView
@property(nonatomic, retain) UIView<FLWebViewProvider> *web_view;
@property(nonatomic, retain) NSString *url_string;
@property(nonatomic, assign) BOOL hasLoaded;
@property(nonatomic, assign) BOOL needLoad;
- (instancetype)initWithFrame:(CGRect)frame andIfNoah:(BOOL)boolIfNoah andUsingWkWebview:(BOOL)boolUsingWkWebview;
- (instancetype)initWithADFrame:(CGRect)frame andIfNoah:(BOOL)boolIfNoah;

- (void)loadURL;
- (void)loadFile:(NSString *)fileName;
- (void)reloadURL;
- (void)showLoading;
- (void)showPage;
- (void)showReload;
- (void)showReloadWithText:(NSString*)text;
- (void)reload;
- (void)testLoadUrl;
@end
