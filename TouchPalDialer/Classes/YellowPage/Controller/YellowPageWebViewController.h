//
//  YellowPageWebViewController.h
//  TouchPalDialer
//
//  Created by Simeng on 14-7-16.
//
//

#import "CootekWebViewController.h"
#import "PullDownSheet.h"
#import "CootekWebHandler.h"
#import "EntranceIcon.h"
#import "TPBottomBar.h"
#import "WebViewControllerDelegate.h"
#import "FloatingLayoutView.h"
#import "CTUrl.h"

@interface YellowPageWebViewController : CootekWebViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate, GameMenusDelegate>
@property(nonatomic, retain) TPHeaderButton *gobackBtn;
@property(nonatomic, retain) TPHeaderButton *shutDownBtn;
@property(nonatomic, retain) TPHeaderButton *fontSettingsBtn;

@property(nonatomic, retain) UIView *reloadView;
@property(nonatomic, retain) UIView *loadingView;
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UIImageView *wifiView;
@property(nonatomic, retain) UILabel *reloadLabel;
@property(nonatomic, retain) UIButton *reloadBtn;
@property(nonatomic, retain) UIImageView *loadingDissy;
@property(nonatomic, retain) UILabel *loadingLabel;
@property(nonatomic, strong) CootekWebHandler* webviewHandler;
@property(nonatomic, strong) TPBottomBar* bottomBar;
@property(nonatomic, strong) UIPanGestureRecognizer* swipeUp;
@property(nonatomic, strong) NSString* serviceId;
@property(nonatomic, weak)   id<WebViewControllerDelegate> controllerDelegate;
@property(nonatomic, assign) BOOL backConfirm;
@property(nonatomic, strong) NSString* backConfirmTitle;
@property(nonatomic, assign) BOOL fullScreen;
@property(nonatomic, assign) BOOL landscape;
@property(nonatomic, assign) BOOL hiddenStatusBar;
@property(nonatomic, assign) BOOL showFloatingPoint;
@property(nonatomic, retain) CTUrl* ctUrl;
@property(nonatomic, retain) UIProgressView* progressView;
@property(nonatomic, retain) FloatingLayoutView *floatingPointView;
@property(nonatomic, assign) BOOL needTitle;
@property(nonatomic, assign) BOOL needFontSettings;
@property(nonatomic, assign) BOOL isNews;


@property(nonatomic, strong) NSMutableArray* newsInfo;

- (void)exitEditingMode;
- (void)finishLoad;
- (void)showReload;
@end

