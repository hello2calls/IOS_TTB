
//
//  YellowPageWebViewController.m
//  TouchPalDialer
//
//  Created by Simeng on 14-7-16.
//
//

#import "YellowPageWebViewController.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "CootekNotifications.h"
#import "CallLogDataModel.h"
#import "CallLog.h"
#import "TPCallActionController.h"
#import "Reachability.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultsManager.h"
#import "YellowCityModel.h"
#import "CityDataDBA.h"
#import "SeattleExecutorHelper.h"
#import "WebSearchConstants.h"
#import "DialerUsageRecord.h"
#import "NoahManager.h"
#import "NotificationAlertManger.h"
#import "UIDataManager.h"
#import "ImageUtils.h"
#import "TouchPalDialerAppDelegate.h"
#import "YellowPageMainQueue.h"
#import "DialerGuideAnimationUtil.h"
#import "TouchPalVersionInfo.h"
#import "IndexConstant.h"
#import "NetworkUtility.h"
#import "TPAnalyticConstants.h"
#import <WebKit/WebKit.h>
#import "WKWebView+FLWKWebView.h"
#import "UIWebView+FLUIWebView.h"
#import "RegExCategories.h"
#import "VerticallyAlignedLabel.h"
#import "UIView+Toast.h"
#import "DefaultUIAlertViewHandler.h"
#import "AdInfoModelManager.h"
#import "FloatingLayoutView.h"
#import "YPUIView.h"
#import "FeedsRedPacketManager.h"
#import "YPFeedsTask.h"
#import "FindNewsBonusResult.h"
#import "UINavigationController+TP.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

typedef enum FeedsFontType {
    FeedsFontSmall,
    FeedsFontMedia,
    FeedsFontLarge,
} FeedsFontType;

@interface SlideView : UISlider
@end

@implementation SlideView

-(instancetype)init{
    self = [super init];
    return self;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    CGFloat startY = (self.frame.size.height - 20 ) / 2;
    if (value <=33) {
        return CGRectMake(0, startY, 20, 20);
    } else if (value <= 66) {
        return CGRectMake(self.frame.size.width / 2 - 10, startY, 20, 20);
    } else {
        return CGRectMake(self.frame.size.width - 20, startY, 20, 20);
    }
    
}
@end

@interface YellowPageWebViewController()
{
    YPUIView* redpacketView;
    NSDate *loadDate;
  
}
@property(strong)  UIButton* fullViewForFont;
@property(strong) SlideView* slider;
@property(nonatomic, strong)FindNewsBonusResult* queryResult;
@end
@implementation YellowPageWebViewController

@synthesize fullViewForFont;
@synthesize slider;
@synthesize gobackBtn;
@synthesize shutDownBtn;
@synthesize fontSettingsBtn;

@synthesize reloadView;
@synthesize loadingView;
@synthesize imageView;
@synthesize wifiView;
@synthesize reloadLabel;
@synthesize reloadBtn;
@synthesize loadingDissy;
@synthesize loadingLabel;
@synthesize webviewHandler;
@synthesize web_title;
@synthesize bottomBar;
@synthesize swipeUp;
@synthesize serviceId;
@synthesize floatingPointView;
bool delayPlay;
bool finishPlay;
BOOL requestService;
Boolean updateLocation;
BOOL backPress;

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.jumpOutsideFinish = NO;
        self.needFontSettings = NO;
    }
    
    return self;
}

- (void)loadView
{
    self.skinDisabled = YES;
    
    [super loadView];

    gobackBtn = [[TPHeaderButton alloc] init];
    [self.view addSubview:gobackBtn];
    self.backButton.hidden  = YES;
    
    [gobackBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(TPHeaderBarHeightDiff());
        make.left.equalTo(self.view);
        make.width.equalTo(50);
        make.height.equalTo(45);
    }];
    [gobackBtn setTitle:@"L" forState:UIControlStateNormal];
    UILabel *backLabel = gobackBtn.titleLabel;
    backLabel.textAlignment = NSTextAlignmentCenter;
    backLabel.font = [UIFont fontWithName:@"iPhoneIcon4" size:30];
    backLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
    [backLabel adjustSizeByFillContent];
    
    [gobackBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"] forState:UIControlStateNormal];
    [gobackBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_700"] forState:UIControlStateHighlighted];
    UITapGestureRecognizer* gobackBtnGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gobackBtnPressed)];
    [gobackBtn setUserInteractionEnabled:YES];
    [gobackBtn addGestureRecognizer:gobackBtnGesture];
    gobackBtn.autoresizingMask = UIViewAutoresizingNone;

    shutDownBtn = [[TPHeaderButton alloc] init];
    [self.view addSubview:shutDownBtn];
    [shutDownBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(TPHeaderBarHeightDiff());
        make.left.equalTo(self.gobackBtn.right).offset(5);
        make.width.equalTo(40);
        make.height.equalTo(45);
    }];
    
    [shutDownBtn setTitle:@"关闭" forState:UIControlStateNormal];
    UILabel *shutDownLabel = shutDownBtn.titleLabel;
    shutDownLabel.textAlignment = NSTextAlignmentCenter;
    shutDownLabel.font =  [UIFont systemFontOfSize:FONT_SIZE_3];
    [shutDownLabel adjustSizeByFillContent];
    shutDownBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [shutDownBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"] forState:UIControlStateNormal];
    [shutDownBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_700"] forState:UIControlStateHighlighted];
    UITapGestureRecognizer* shutDownBtnGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shutDownPressed)];
    [shutDownBtn setUserInteractionEnabled:YES];
    [shutDownBtn addGestureRecognizer:shutDownBtnGesture];
    shutDownBtn.hidden = YES;

    
    if (self.needFontSettings) {
        fontSettingsBtn = [[TPHeaderButton alloc] init];
        [self.view addSubview:fontSettingsBtn];
        [fontSettingsBtn makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(TPHeaderBarHeightDiff());
            make.right.equalTo(self.view);
            make.width.equalTo(50);
            make.height.equalTo(45);
        }];
        
        [fontSettingsBtn setTitle:@"x" forState:UIControlStateNormal];
        UILabel *fontSettingsLabel = fontSettingsBtn.titleLabel;
        fontSettingsLabel.textAlignment = NSTextAlignmentCenter;
        fontSettingsLabel.font = [UIFont fontWithName:@"iPhoneIcon5" size:30];
        [fontSettingsLabel adjustSizeByFillContent];
    
        [fontSettingsBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"] forState:UIControlStateNormal];
        [fontSettingsBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_grey_700"] forState:UIControlStateHighlighted];
        UITapGestureRecognizer* fontSettingsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingFont)];
        [fontSettingsBtn setUserInteractionEnabled:YES];
        [fontSettingsBtn addGestureRecognizer:fontSettingsGesture];
    }

    self.web_view.hidden = YES;

    wait_indicator.hidden = YES;

    [self setHeaderTitle:@""];

    self.web_view.backgroundColor = [UIColor whiteColor];

    reloadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(415))];
    [self.containerView addSubview:reloadView];
    reloadView.autoresizingMask = UIViewAutoresizingNone;
    reloadView.autoresizesSubviews = YES;
    reloadView.hidden = YES;

    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (TPScreenHeight() > 500) ? 73 : 44.5, TPScreenWidth(), 176)];
    imageView.autoresizingMask = UIViewAutoresizingNone;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [reloadView addSubview:imageView];

    wifiView = [[UIImageView alloc] initWithFrame:CGRectMake(TPScreenWidth()/2 -20, (TPScreenHeight() > 500) ? 276.5 : 236.5, 39.5, 39.5)];
    wifiView.autoresizingMask = UIViewAutoresizingNone;
    [reloadView addSubview:wifiView];

    reloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (TPScreenHeight() > 500) ? 330.5 : 280, TPScreenWidth(), 25)];
    reloadLabel.backgroundColor = [UIColor clearColor];
    reloadLabel.text = NSLocalizedString(@"reset_net_prompt", @"");
    reloadLabel.textAlignment = NSTextAlignmentCenter;
    reloadLabel.font = [UIFont systemFontOfSize:12];
    reloadLabel.autoresizingMask = UIViewAutoresizingNone;
    [reloadView addSubview:reloadLabel];

    reloadBtn = [[UIButton alloc] initWithFrame:CGRectMake((TPScreenWidth()/2 - 54.5), (TPScreenHeight() > 500) ? 368 : 317.5, 109, 35)];
    [reloadBtn addTarget:self action:@selector(loadURL) forControlEvents:UIControlEventTouchUpInside];
    reloadBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [reloadBtn setTitle:NSLocalizedString(@"reload_yellow_page", @"") forState:UIControlStateNormal];
    reloadBtn.layer.cornerRadius = 5;
    reloadBtn.layer.masksToBounds = YES;
    reloadBtn.autoresizingMask = UIViewAutoresizingNone;
    [reloadView addSubview:reloadBtn];

    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(415))];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    loadingView.autoresizesSubviews = YES;
    [self.containerView addSubview:loadingView];
    loadingView.hidden = YES;

    loadingDissy = [[UIImageView alloc] initWithFrame:CGRectMake(TPScreenWidth()/2 - 16.5, (TPScreenHeight() > 500) ? 135 : 120, 33, 33)];
    loadingDissy.autoresizingMask = UIViewAutoresizingNone;
    [loadingView addSubview:loadingDissy];

    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (TPScreenHeight() > 500) ? 180 : 165, TPScreenWidth(), 25)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.text = NSLocalizedString(@"Loading...", @"");
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.font = [UIFont systemFontOfSize:12];
    loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [loadingView addSubview:loadingLabel];

    TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
    reloadView.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_bg_color"];
    loadingView.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_bg_color"];
    imageView.image = [manager getImageByName:@"yellow_page_help@2x.png"];
    wifiView.image = [manager getImageByName:@"yellow_page_wifi@2x.png"];
    reloadLabel.textColor = [manager getUIColorFromNumberString:@"yellow_page_reload_text_color"];
    [reloadBtn setBackgroundImage:[FunctionUtility imageWithColor:[manager getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"] withFrame:CGRectMake(0, 0, reloadBtn.frame.size.width, reloadBtn.frame.size.height)] forState:UIControlStateNormal];
    reloadBtn.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"];
    [reloadBtn setTitleColor:[manager getUIColorFromNumberString:@"yellow_page_reload_btn_text_color"] forState:UIControlStateNormal];
    loadingDissy.image = [manager getImageByName:@"loading_circle@2x.png"];
    loadingLabel.textColor = [manager getUIColorFromNumberString:@"yellow_page_loading_text_color"];

    webviewHandler = [[CootekWebHandler alloc]initWithWebView:self.web_view andDelegate:self];
    [webviewHandler registerHandler];

    updateLocation = NO;

    // bottom bar
    bottomBar = [[TPBottomBar alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bottomBar.hidden = NO;
    [self.view addSubview:bottomBar];
    requestService = YES;


    //progress
    if (self.usingWkWebview && NSClassFromString(@"WKWebView")) {
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), 2)];
        self.progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.web_view addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
        [self.view addSubview:self.progressView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBackground) name:N_APP_DID_ENTER_BACKGROUND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backForeground) name:N_APPLICATION_BECOME_ACTIVE object:nil];
    backPress = NO;

    if (self.fullScreen) {
        gobackBtn.hidden = YES;
        shutDownBtn.hidden = YES;
        self.progressView.frame = CGRectMake(0, 0, TPScreenWidth(), 2);
        self.containerView.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
        loadingView.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
    }
    self.view.autoresizesSubviews = YES;
    self.hiddenStatusBar = self.fullScreen;
    if (self.showFloatingPoint) {
        floatingPointView = [[FloatingLayoutView alloc] initWithCTUrl:self.ctUrl];
        floatingPointView.autoresizesSubviews = YES;
        floatingPointView.frame = self.view.bounds;
        [self.view addSubview:floatingPointView];
        floatingPointView.gameDelegate = self;
        floatingPointView.hidden = NO;
    }
    
    
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME]) {
        redpacketView = [[YPUIView alloc] init];
        UIImageView* icon = [[UIImageView alloc] initWithFrame:redpacketView.bounds];
        icon.image= [TPDialerResourceManager getImage:@"feeds_red_packet@2x.png"];
        [redpacketView addSubview:icon];
        [self.view addSubview:redpacketView];
        
        [redpacketView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-15);
            make.bottom.equalTo(self.view).offset(-13);
        }];
        [icon makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(redpacketView);
        }];
    } else {
        redpacketView = [[YPUIView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 77, 57, 67)];
        NSString *redPacktePath = [[NSBundle mainBundle] pathForResource:FEEDS_RED_PACKET_FLOAT_ICON ofType:@"png"];
        UIImageView* icon = [[UIImageView alloc] initWithFrame:redpacketView.bounds];
        icon.image=  [UIImage imageWithContentsOfFile:redPacktePath];
        
        [redpacketView addSubview:icon];
        [self.view addSubview:redpacketView];
    }
    
    __block __weak YPUIView* weakView = redpacketView;
    __block __weak YellowPageWebViewController* wController = self;
    
    redpacketView.block = ^(){
        [DialerUsageRecord recordCustomEvent:PATH_FEEDS module:FEEDS_MODULE event:FEEDS_SHOW_RED_PACKET_DETAIL];
        [FeedsRedPacketManager showRedPacket: weakView withType:YP_RED_PACKET_FEEDS_DETAIL withQueryResult:wController.queryResult withLoginBlock:^{
            weakView.hidden = YES;
             [wController queryFeedsRedPacket];
        }];
    };
    redpacketView.hidden = YES;
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;

    [self initFontControllerViews];
}

- (void) initFontControllerViews
{
    fullViewForFont = [[UIButton alloc] init];
    fullViewForFont.backgroundColor = RGBA2UIColor2(0, 0, 0, 128);
    [self.view addSubview:fullViewForFont];
    [fullViewForFont makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    fullViewForFont.hidden = YES;
    
    UIView* fontContainerView = [[UIView alloc] init];
    [fullViewForFont addSubview:fontContainerView];
    
    [fontContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.fullViewForFont);
        make.height.equalTo(208);
    }];
    fontContainerView.backgroundColor = [UIColor whiteColor];
    
    UIButton* emptyView = [[UIButton alloc] init];
    [fullViewForFont addSubview:emptyView];
    [emptyView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(fontContainerView.top);
        make.top.equalTo(fullViewForFont);
        make.left.right.equalTo(fullViewForFont);
    }];
    
    [emptyView addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
        fullViewForFont.hidden = YES;
    }];
    
    UILabel* l1 = [[UILabel tpd_commonLabel] tpd_withText:@"小" color:[UIColor blackColor] font:18];
    l1.textAlignment = NSTextAlignmentLeft;
    UILabel* l2 = [[UILabel tpd_commonLabel] tpd_withText:@"中" color:[UIColor blackColor] font:18];
    l2.textAlignment = NSTextAlignmentCenter;
    UILabel* l3 = [[UILabel tpd_commonLabel] tpd_withText:@"大" color:[UIColor blackColor] font:18];
    l3.textAlignment = NSTextAlignmentRight;
    NSArray* viewArr = @[l1,l2,l3];
    
    UIView* labelContainer =  [[[UIView tpd_horizontalGroupWith: viewArr horizontalPadding:0 verticalPadding:0 interPadding:0 weightArr:@[@1,@1,@1]] tpd_withHeight:25] tpd_withBackgroundColor:[UIColor whiteColor]];
    [fontContainerView addSubview:labelContainer];
    [labelContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fontContainerView.mas_top).offset(46);
        make.left.equalTo(fontContainerView.mas_left).offset(47);
        make.right.equalTo(fontContainerView.mas_right).offset(-47);
    }];
    
    slider = [[SlideView alloc] init];
    [fontContainerView addSubview:slider];
    [slider makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labelContainer.mas_bottom).offset(15);
        make.left.equalTo(fontContainerView.mas_left).offset(44);
        make.right.equalTo(fontContainerView.mas_right).offset(-44);
    }];
    
    slider.minimumValue = 0;
    slider.maximumValue = 100;
    slider.continuous = YES;
    slider.minimumTrackTintColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_450"];
    slider.maximumTrackTintColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_200"];
    [slider setThumbImage:[TPDialerResourceManager getImage:@"font_size_slide_view@2x.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[TPDialerResourceManager getImage:@"font_size_slide_view@2x.png"] forState:UIControlStateHighlighted];
    [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer* _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    _tapGesture.delegate = self;
    [slider addGestureRecognizer:_tapGesture];
    

    
    YPUIView* done = [[YPUIView alloc] init];
    [fontContainerView addSubview:done];
    [done makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(fontContainerView.mas_bottom).offset(-19);
        make.height.equalTo(22);
        make.width.mas_equalTo(fontContainerView);
        make.centerX.equalTo(fontContainerView.mas_centerX);
    }];
    UILabel* textDone = [[UILabel alloc] init];
    textDone.text = @"完成";
    textDone.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_500"];
    textDone.textAlignment = NSTextAlignmentCenter;
    [done addSubview:textDone];
    [textDone makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(done);
    }];
    done.block = ^{
        fullViewForFont.hidden = YES;
    };
//    [done addBlockEventWithEvent:UIControlEventTouchUpInside withBlock:^{
//        fullViewForFont.hidden = YES;
//    }];
    
    UIView* line = [[UIView alloc] init];
    line.backgroundColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_grey_100"];
    [fontContainerView addSubview:line];
    [line makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(1);
        make.bottom.equalTo(done.mas_top).offset(-18);
        make.left.equalTo(fontContainerView.mas_left).offset(16);
        make.right.equalTo(fontContainerView.mas_right).offset(-16);
    }];
    
    FeedsFontType type = [UserDefaultsManager intValueForKey:@"feeds_font_size" defaultValue:FeedsFontMedia];
    switch (type) {
        case FeedsFontSmall:
        {
            [slider setValue:0 animated:YES];
            break;
        }
        case FeedsFontMedia:
        {
            [slider setValue:50 animated:YES];
            break;
        }
        case FeedsFontLarge:
        {
            [slider setValue:100 animated:YES];
            break;
        }
        default:
            break;
    }


}

- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:slider];
    int value = (slider.maximumValue - slider.minimumValue) * (touchPoint.x / slider.frame.size.width );
    if (value <=33) {
        [self changeFontSmall];
    } else if (value <=66) {
        [self changeFontMiddle];
    } else {
        [self changeFontLarge];
    }
}

- (void)changeFontSmall
{
    [slider setValue:0 animated:YES];
    [UserDefaultsManager setIntValue:FeedsFontSmall forKey:@"feeds_font_size"];
    [self.web_view evaluateJavaScript:@"$('.ctm_content p').css('font-size','18px');" completionHandler:nil];
}

- (void)changeFontMiddle
{
    [slider setValue:50 animated:YES];
    [UserDefaultsManager setIntValue:FeedsFontMedia forKey:@"feeds_font_size"];
    [self.web_view evaluateJavaScript:@"$('.ctm_content p').css('font-size','21px');" completionHandler:nil];
}

- (void)changeFontLarge
{
    [slider setValue:100 animated:YES];
    [UserDefaultsManager setIntValue:FeedsFontLarge forKey:@"feeds_font_size"];
    [self.web_view evaluateJavaScript:@"$('.ctm_content p').css('font-size','24px');" completionHandler:nil];
}

- (void) sliderChange:(id) sender
{
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider * sl = sender;
        CGFloat value = sl.value;
        if (value <=33) {
             [self changeFontSmall];
        } else if (value <=66) {
            [self changeFontMiddle];
        } else {
            [self changeFontLarge];
        }
    }
}

- (void) settingFont
{
    self.fullViewForFont.hidden = NO;
}

- (void) queryFeedsRedPacket {
    
    if  (self.ctUrl.queryFeedsRedPacket) {
        
        if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
            redpacketView.hidden = NO;
            return;
        }
        [[FeedsRedPacketManager new] queryFeedsRedPacketByType:YP_RED_PACKET_FEEDS_DETAIL withBlock:^(FindNewsBonusResult * result) {
            if ([result checkBonus]) {
                redpacketView.hidden = NO;
                self.queryResult = result;
            }
        }];
    }
}

- (void) hideStatusBar:(BOOL) status
{
    self.hiddenStatusBar = status;
    if ([[UIDevice currentDevice]systemVersion].floatValue < 7.0) {
        [[UIApplication sharedApplication] setStatusBarHidden:self.hiddenStatusBar];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:self.hiddenStatusBar];
        [self setNeedsStatusBarAppearanceUpdate];
    }

}

- (BOOL)prefersStatusBarHidden {
    return self.hiddenStatusBar;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object != self.web_view) {
            return;
        }
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:((WKWebView *)self.web_view).estimatedProgress animated:YES];

        if(((WKWebView *)self.web_view).estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self goBackground];
    if (self.isNews) {
        [FunctionUtility setStatusBarStyleToDefault:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.isNews) {
        [FunctionUtility setStatusBarStyleToDefault:YES];
    } else {
        if (self.skinDisabled) {
            [FunctionUtility setStatusBarStyleToDefault:YES];
        } else {
            [FunctionUtility updateStatusBarStyle];
        }
    }

    [self queryFeedsRedPacket];
   
    [self exitEditingMode];
    [self isAtIndex];

    [self backForeground];
    
    
//    __weak typeof(self) weakSelf = self;
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }
    [self hideStatusBar:self.fullScreen];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[YellowPageMainQueue instance] removeFirstTask];
}

- (void)loadURL
{
    loadDate = [NSDate date];
    [super loadURL];
}

- (void)showPage
{
    self.web_view.hidden = NO;
    reloadView.hidden = YES;
    loadingView.hidden = YES;
    [loadingDissy.layer removeAllAnimations];
    if ([UIDataManager instance].startRecordTime > 0) {
        NSNumber* intervalTime = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000 - [UIDataManager instance].startRecordTime)];
        NSString* strInterval = [NSString stringWithFormat:@"%f", intervalTime.doubleValue];
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_PAGE_LOAD kvs:Pair(@"action", @"loadpage"), Pair(@"cost", strInterval), Pair(@"url", [self.web_view.request.URL absoluteString]), Pair(@"result", @"success"), Pair(@"network",[DialerUsageRecord getClientNetWorkType]),nil];
        [UIDataManager instance].startRecordTime = -1;
    }
}

- (void)showReload
{
    self.web_view.hidden = YES;
    reloadView.hidden = NO;
    loadingView.hidden = YES;
    [loadingDissy.layer removeAllAnimations];
    if ([UIDataManager instance].startRecordTime > 0) {
        NSNumber* intervalTime = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000 - [UIDataManager instance].startRecordTime)];
        NSString* strInterval = [NSString stringWithFormat:@"%f", intervalTime.doubleValue];
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_PAGE_LOAD kvs:Pair(@"action", @"loadpage"), Pair(@"cost", strInterval), Pair(@"url", [self.web_view.request.URL absoluteString]), Pair(@"result", @"failed"), Pair(@"network",[DialerUsageRecord getClientNetWorkType]),nil];
        [UIDataManager instance].startRecordTime = -1;
    }
}

- (void)showLoading
{
    [self.newsInfo setValue:[self.web_view.request.URL absoluteString]forKey:@"url"];
    if (self.usingWkWebview && NSClassFromString(@"WKWebView")) {
        self.web_view.hidden = NO;
        reloadView.hidden = YES;
        loadingView.hidden = YES;
    } else {
        self.web_view.hidden = YES;
        reloadView.hidden = YES;
        loadingView.hidden = NO;
        [self beginLoadingAnimation];
    }
}

- (void)beginLoadingAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = HUGE_VALF;
    [loadingDissy.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)changeSkin{
    TPDialerResourceManager *manager = [TPDialerResourceManager sharedManager];
    reloadView.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_bg_color"];
    loadingView.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_bg_color"];
    imageView.image = [manager getImageByName:@"yellow_page_help@2x.png"];
    wifiView.image = [manager getImageByName:@"yellow_page_wifi@2x.png"];
    reloadLabel.textColor = [manager getUIColorFromNumberString:@"yellow_page_reload_text_color"];
    [reloadBtn setBackgroundImage:[FunctionUtility imageWithColor:[manager getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"] withFrame:CGRectMake(0, 0, reloadBtn.frame.size.width, reloadBtn.frame.size.height)] forState:UIControlStateNormal];
    reloadBtn.backgroundColor = [manager getUIColorFromNumberString:@"yellow_page_reload_btn_bg_color"];
    [reloadBtn setTitleColor:[manager getUIColorFromNumberString:@"yellow_page_reload_btn_text_color"] forState:UIControlStateNormal];
    loadingDissy.image = [manager getImageByName:@"loading_circle@2x.png"];
    loadingLabel.textColor = [manager getUIColorFromNumberString:@"yellow_page_loading_text_color"];
}

- (BOOL)isAtIndex
{
    NSString *url = [self.web_view.request.URL absoluteString];
    if (url == nil || [url isEqualToString: @""] || [url isEqualToString:[NSString stringWithFormat: @"%@index.html" , WebSearch_page_url_Prefix]]) {
        return YES;
    } else {
        return NO;
    }
}
- (void)webViewDidFinishLoadDelay
{
    if (finishPlay) {
        [self showPage];
    }
    delayPlay = YES;
}

#pragma mark UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self startLoading];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    BOOL ret = [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:shouldStartLoadWithRequest:navigationType:)]) {
        if (![self.controllerDelegate webViewController:self webView:webView shouldStartLoadWithRequest:request navigationType:navigationType])
        {
            return NO;
        }
    }
    return ret;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.hasLoaded = NO;

    if ((error.code == 102 || error.code == 101) && [error.domain isEqual:@"WebKitErrorDomain"]) {
        return;
    }

    if (error.code != NSURLErrorCancelled) {
        [self showReload];
    }

    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didFailLoadWithError:)]) {
        [self.controllerDelegate webViewController:self webView:webView didFailLoadWithError:error];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self finishLoad];

    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webViewDidFinishLoad:)]) {
        [self.controllerDelegate webViewController:self webViewDidFinishLoad:webView];
    }
    if (loadDate) {
        int interval = [[NSDate date] timeIntervalSinceDate:loadDate] * 1000;
        loadDate = nil;
        cootek_log(@"webViewDidFinishLoad load minus seconds= %d",interval);
    }
}

- (BOOL)canAutoRotate
{
    return self.landscape;
}

- (void)gobackBtnPressed
{

    NSString* url = [self.web_view.URL absoluteString];
    if (self.backConfirm) {
        if (self.web_view.canGoBack) {
            NSRange range = [url rangeOfString:@"#cootek_"];
            if (range.length == 0) {
                [self showAlert];
                return;
            }
        } else {
            [self showAlert];
            return;
        }
    }

    if ([[self.web_view.request.URL absoluteString] isEqualToString:[NSString stringWithFormat: @"%@indexCity.html" , WebSearch_page_url_Prefix]] || !self.web_view.canGoBack) {
        [self quit];
    } else {

    [self.web_view stopLoading];
        [self.web_view goBack];
        if (!self.fullScreen) {
            self.shutDownBtn.hidden = NO;
        }

        if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewControllerDidGoback:)]) {
            [self.controllerDelegate webViewControllerDidGoback:self];
        }
    }
}

- (void) showAlert
{
    NSString *title = @"温馨提示";
    NSString *message = (self.backConfirmTitle && self.backConfirmTitle.length > 0) ? self.backConfirmTitle :@"是否退出当前页面？";
    NSString *cancelTitle = @"返回页面";
    NSString *okTitle = @"继续退出";
    if (NSClassFromString(@"UIAlertController") != Nil) // Yes, Nil
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self quit];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {

        [DefaultUIAlertViewHandler showAlertViewWithTitle:title
                                                  message:message
                                              cancelTitle:cancelTitle
                                                  okTitle:okTitle
                                      okButtonActionBlock:^(){
                                          [self quit];
                                        }
                                        cancelActionBlock:^(){
                                        }];
    }
}


- (void) quit
{
    backPress = YES;
    [[UIDataManager instance] popWebView];
    UIViewController *c = [[UIViewController alloc]init];
    [c.view setBackgroundColor:[UIColor clearColor]];
    if (self.landscape && ([[UIApplication sharedApplication] isStatusBarHidden] || [[UIDevice currentDevice]systemVersion].floatValue < 8.0)) {
        [[TouchPalDialerAppDelegate naviController] presentViewController:c animated:NO completion:^{
            dispatch_after(0, dispatch_get_main_queue(), ^{
                [self.navigationController dismissViewControllerAnimated:NO completion:^{
                    [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
                }];
            });
        }];
        
        
    } else {
        [TouchPalDialerAppDelegate popViewControllerWithAnimated:YES];
    }

    if ([UIDataManager instance].startRecordTime > 0) {
        NSNumber* intervalTime = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] * 1000 - [UIDataManager instance].startRecordTime)];
        NSString* strInterval = [NSString stringWithFormat:@"%f", intervalTime.doubleValue];
        [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_PAGE_LOAD kvs:Pair(@"action", @"loadpage"), Pair(@"cost", strInterval), Pair(@"url", [self.web_view.request.URL absoluteString]), Pair(@"result", @"cancel"), Pair(@"network",[DialerUsageRecord getClientNetWorkType]),nil];
        [UIDataManager instance].startRecordTime = -1;
    }

    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewControllerDidClose:)]) {
        [self.controllerDelegate webViewControllerDidClose:self];
    }
}

- (void)shutDownPressed
{
    [self quit];
}

- (void)exitEditingMode
{
    [self isAtIndex];
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[YellowPageMainQueue instance] removeFirstTask];
    if (backPress) {
        self.web_view = nil;
        self.webviewHandler = nil;
    }
}

- (void)swipeIn:(UIPanGestureRecognizer *)gestureRecognizer {

}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [pan velocityInView:gestureRecognizer.view];
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            return NO;
        }else{
            if (velocity.y > 0)
            {
                self.containerView.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), self.view.frame.size.height - self.bottomBar.frame.size.height - TPHeaderBarHeight());
                self.bottomBar.hidden = NO;
            } else {
                self.bottomBar.hidden = YES;
                self.containerView.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), self.view.frame.size.height - TPHeaderBarHeight());
            }
            return YES;
        }
    }
    return YES;
}
- (void) initServiceBottom:(NSString*)url
{
    if (serviceId && serviceId.length > 0) {
        if (requestService) {
            [UIDataManager instance].serviceBottomData = nil;
            [self.bottomBar removeFromSuperview];
            bottomBar = [[TPBottomBar alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            bottomBar.hidden = NO;
            [self.view addSubview:bottomBar];
            self.containerView.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), self.view.frame.size.height - TPHeaderBarHeight());

            requestService = NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (USE_DEBUG_SERVER) {
                    [self requestServiceBottomData:[NSString stringWithFormat:@"%@%@", YP_DEBUG_SERVER, SERVICE_BOTTOM_PATH] andTargetUrl:url];
                } else {
                    [self requestServiceBottomData:[NSString stringWithFormat:@"%@%@", TOUCHLIFE_SITE, SERVICE_BOTTOM_PATH] andTargetUrl:url];
                }
            });
        }
    }

}

-(void) requestServiceBottomData:(NSString*) url andTargetUrl:(NSString*)targetUrl
{
    NSArray *strarray = [targetUrl componentsSeparatedByString:@"?"];
    NSString* parseUrl = [NSString stringWithFormat:@"%@?service_id=%@&_token=%@&url=%@",url, serviceId, [SeattleFeatureExecutor getToken], strarray[0]];

    parseUrl = [CTUrl encodeRequestUrl:parseUrl];

    NSURL *urlRequest=[NSURL URLWithString:parseUrl];
    NSMutableURLRequest *httpIndexRequest= [[NSMutableURLRequest alloc] initWithURL:urlRequest cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    [httpIndexRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response_url=[[NSHTTPURLResponse alloc] init];
    NSData *indexResult = [NetworkUtility sendSafeSynchronousRequest:httpIndexRequest returningResponse:&response_url error:nil];
    NSInteger status=[response_url statusCode];
    NSString *responseString=[[NSString alloc] initWithData:indexResult encoding:NSUTF8StringEncoding];
    if (status != 404 && [responseString length]>0) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error =nil;
        NSMutableDictionary *returnData= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
        [UIDataManager instance].serviceBottomData = [returnData objectForKey:@"result"];
        [UserDefaultsManager setObject:[UIDataManager instance].serviceBottomData forKey:[NSString stringWithFormat:@"%@%@",[UserDefaultsManager stringForKey:INDEX_SERVICE_BOTTOM_PREFIX],serviceId]];
    } else {
        [UIDataManager instance].serviceBottomData = (NSDictionary *)[UserDefaultsManager objectForKey:[NSString stringWithFormat:@"%@%@",[UserDefaultsManager stringForKey:INDEX_SERVICE_BOTTOM_PREFIX],serviceId]];
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self loadServiceBottomData];
    });
}

- (void) loadServiceBottomData
{
    NSDictionary* data = [[UIDataManager instance].serviceBottomData objectForKey:@"service_info"];

    if ([[data allKeys] containsObject:@"status"]) {
        NSString *status = [data objectForKey:@"status"];
        if (![status isEqualToString:@"available"]) {
            return;
        }
    }

    if ([[data allKeys] containsObject:@"os"]) {
        NSString *status = [data objectForKey:@"os"];
        if (![status isEqualToString:@"all"] && ![status isEqualToString:@"ios"]) {
            return;
        }
    }

    if ([[data allKeys] containsObject:@"menus"]) {
        NSArray* menus = [NSJSONSerialization JSONObjectWithData:[[data objectForKey:@"menus"] dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingAllowFragments error:nil];

        self.bottomBar.frame = CGRectMake(0, self.view.frame.size.height - 54, TPScreenWidth(), 54);
        self.containerView.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), self.view.frame.size.height - self.bottomBar.frame.size.height - TPHeaderBarHeight());
        self.bottomBar.hidden = NO;
        
        if (!swipeUp) {
            swipeUp = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeIn:)];
            swipeUp.delegate = self;
            [self.web_view addGestureRecognizer:swipeUp];
        }
       
        [self.bottomBar drawMenus:menus];
    }

}


#pragma mark - WKWebView Delegate Methods
- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];

    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.controllerDelegate webViewController:self webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
}

/*
 * Called on iOS devices that have WKWebView when the web view starts loading a URL request.
 * Note that it just calls didStartNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didStartProvisionalNavigation: (WKNavigation *) navigation
{
    [self startLoading];
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didStartProvisionalNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didStartProvisionalNavigation:navigation];
    }
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method,
 * but it has to retrieve the active request from the web view as WKNavigation doesn't contain a reference to it.
 */
- (void) webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];

    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didFailProvisionalNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didFailProvisionalNavigation:navigation];
    }
}

/*
 * Called on iOS devices that have WKWebView when the web view fails to load a URL request.
 * Note that it just calls failLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFailNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self failLoadOrNavigation: [webView request] withError: error];

    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didFailNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didFailNavigation:navigation];
    }
}

/*
 * Called on iOS devices that have WKWebView when the web view begins loading a URL request.
 * This could call some sort of shared delegate method, but is unused currently.
 */
- (void) webView: (WKWebView *) webView didCommitNavigation: (WKNavigation *) navigation
{
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didCommitNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didCommitNavigation:navigation];
    }
}


/*
 * Called on iOS devices that have WKWebView when the web view finishes loading a URL request.
 * Note that it just calls finishLoadOrNavigation, which is a shared delegate method.
 */
- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    [self finishLoadOrNavigation: [webView request]];
    if (self.controllerDelegate && [self.controllerDelegate respondsToSelector:@selector(webViewController:webView:didFinishNavigation:)]) {
        [self.controllerDelegate webViewController:self webView:webView didFinishNavigation:navigation];
    }
    if (loadDate) {
        int interval = [[NSDate date] timeIntervalSinceDate:loadDate] * 1000;
        loadDate = nil;
        cootek_log(@"webViewDidFinishLoad load minus seconds= %d",interval);
    }
}

#pragma mark - Shared Delegate Methods

/*
 * This is called whenever the web view wants to navigate.
 */
- (BOOL) shouldStartDecidePolicy: (NSURLRequest *) request
{
    // Determine whether or not navigation should be allowed.
    // Return YES if it should, NO if not.

    return YES;
}

/*
 * This is called whenever the web view has started navigating.
 */
- (void) didStartNavigation
{

}

/*
 * This is called whenever the web view has started navigating.
 */
- (void) startLoading
{
    [self showLoading];
    delayPlay = NO;
    finishPlay = NO;
    requestService = YES;
    [self performSelector:@selector(webViewDidFinishLoadDelay) withObject:nil afterDelay:0.5f];
}
/*
 * This is called when navigation failed.
 */
- (void) failLoadOrNavigation: (NSURLRequest *) request withError: (NSError *) error
{
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) {
        return;
    }

    // Notify the user that navigation failed, provide information on the error, and so on.
    self.hasLoaded = NO;
    if (error.code != NSURLErrorCancelled) {
//        [self showReload];
    } else {
        [self finishLoadOrNavigation:request];
    }
}

/*
 * This is called when navigation succeeds and is complete.
 */
- (void) finishLoadOrNavigation: (NSURLRequest *) request
{
    
    [self finishLoad];
}

- (void) finishLoad
{
    [webviewHandler initPageData];
    self.hasLoaded = YES;

    if (self.needTitle) {
        if (!web_title || web_title.length == 0) {
            [self.web_view evaluateJavaScript:@"document.title" completionHandler:^(id ret, NSError *error) {
                if (![ret isEqual: @""]) {
                    self.headerTitle = ret;
                }
            }];

        } else {
            self.headerTitle = web_title;
        }
    }

    [self.web_view evaluateJavaScript:@"window.location.href" completionHandler:^(id ret, NSError *error) {

        if([((NSString *)ret) hasPrefix:@"http://search.cootekservice.com/page/search.html"]){
            [self.web_view evaluateJavaScript:@"Search.init_city();" completionHandler:^(id ret, NSError *error) {
            }];
        }

        [self initServiceBottom:ret];
    }];

    if (delayPlay) {
        [self showPage];
    }
    finishPlay = YES;
//    
//    FeedsFontType type = [UserDefaultsManager intValueForKey:@"feeds_font_size" defaultValue:FeedsFontMedia];
//    switch (type) {
//        case FeedsFontSmall:
//        {
//            [self changeFontSmall];
//            break;
//        }
//        case FeedsFontMedia:
//        {
//            [self changeFontMiddle];
//            break;
//        }
//        case FeedsFontLarge:
//        {
//            [self changeFontLarge];
//            break;
//        }
//        default:
//            break;
//    }
    
}

- (void) goBackground
{
    NSString *script = @"var videos = document.querySelectorAll(\"video\"); for (var i = videos.length - 1; i >= 0; i--) { videos[i].pause(); };var audios = document.querySelectorAll(\"audio\"); for (var i = audios.length - 1; i >= 0; i--) { audios[i].pause(); };";
    if (self.web_view) {
        [self.web_view evaluateJavaScript:script completionHandler:nil];
    }}

- (void) backForeground
{
    NSString *script = @"var videos = document.querySelectorAll(\"video\"); for (var i = videos.length - 1; i >= 0; i--) { videos[i].play(); };var audios = document.querySelectorAll(\"audio\"); for (var i = audios.length - 1; i >= 0; i--) { audios[i].play(); };";
    if (self.web_view) {
        [self.web_view evaluateJavaScript:script completionHandler:nil];
    }

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    if (self.fullScreen) {
        self.containerView.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
        reloadView.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());

        loadingView.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
        self.progressView.frame = CGRectMake(0, TPHeaderBarHeightDiff(), TPScreenWidth(), 2);
        loadingDissy.frame = CGRectMake(TPScreenWidth()/2 - 16.5, (TPScreenHeight() > 500) ? 135 : 120, 33, 33);
    } else {
        if (self.landscape) {

            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if ((orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight))
            {
                [self hideStatusBar:YES];
            } else {
                [self hideStatusBar:NO];
            }
            self.view.frame = CGRectMake(0, 0, TPScreenWidth(), TPAppFrameHeight()+TPHeaderBarHeightDiff());
            self.containerView.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), self.view.frame.size.height - TPHeaderBarHeight());
            reloadView.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), self.view.frame.size.height - TPHeaderBarHeight());
            loadingView.frame = CGRectMake(0, TPHeaderBarHeight(), TPScreenWidth(), self.view.frame.size.height - TPHeaderBarHeight());
            self.progressView.frame = CGRectMake(0, TPHeaderBarHeightDiff(), TPScreenWidth(), 2);
            loadingDissy.frame = CGRectMake(TPScreenWidth()/2 - 16.5, (TPScreenHeight() > 500) ? 135 : 120, 33, 33);

            self.headerBar.frame = CGRectMake(0, 0, TPScreenWidth(),TPHeaderBarHeight());
            [self resetHeaderFrame];
            gobackBtn.frame = CGRectMake(0, TPHeaderBarHeightDiff(), 50, 45);
            shutDownBtn.frame = CGRectMake(40, TPHeaderBarHeightDiff(), 40, 45);
        }
    }


    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ((orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight))
    {
        imageView.frame = CGRectMake((TPScreenWidth() - TPScreenHeight()) / 2, 0, TPScreenHeight() , 176);
        wifiView.frame = CGRectMake(TPScreenWidth()/2 -20, 181.5, 39.5, 39.5);
        reloadLabel.frame = CGRectMake(0, 225, TPScreenWidth(), 25);
        reloadBtn.frame = CGRectMake((TPScreenWidth()/2 - 54.5), 262.5, 109, 35);
    } else {
        imageView.frame = CGRectMake(0, (TPScreenHeight() > 500) ? 73 : 44.5, TPScreenWidth(), 176);
        wifiView.frame = CGRectMake(TPScreenWidth()/2 -20, (TPScreenHeight() > 500) ? 276.5 : 236.5, 39.5, 39.5);
        reloadLabel.frame = CGRectMake(0, (TPScreenHeight() > 500) ? 330.5 : 280, TPScreenWidth(), 25);
        reloadBtn.frame = CGRectMake((TPScreenWidth()/2 - 54.5), (TPScreenHeight() > 500) ? 368 : 317.5, 109, 35);
    }


    if (self.showFloatingPoint) {
        [floatingPointView resetCoordinate];
        floatingPointView.frame = self.view.bounds;
    }
}

- (void) dealloc
{
    if  ([self isViewLoaded]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        if (self.usingWkWebview && NSClassFromString(@"WKWebView")) {
            [self removeObserver:self forKeyPath:@"estimatedProgress" context:NULL];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return self.landscape;
}

- (BOOL)shouldAutorotate
{
    return self.landscape;
}

- (void)exitGame
{
    [self gobackBtnPressed];
}
@end


