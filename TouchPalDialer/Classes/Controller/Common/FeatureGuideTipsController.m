//
//  FeatureGuideTips.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeatureGuideTipsController.h"
#import "consts.h"
#import "FeatureTipsLabel.h"
#import "TPDialerResourceManager.h"
#import "AdvancedCalllog.h"
#import "FeatureGuideSelectCarrierViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "FunctionUtility.h"
#import "SelectCountryViewController.h"
#import "DeviceSim.h"
#import "CootekNotifications.h"
#import "TPItemButton.h"
#import "UserDefaultsManager.h"
#import "ScheduleTaskManager.h"
#import "PredefCountriesUtil.h"
#import "TouchPalVersionInfo.h"
#import "LoginController.h"
#import "FreeCallLoginController.h"
#import "CommonWebViewController.h"
#import "DefaultUIAlertViewHandler.h"
#import "DialerUsageRecord.h"
#import <Usage_iOS/UsageRecorder.h>
#import "CommonImageViewWithBlock.h"
#import "TPFilterRecorder.h"
#import "DialerUsageRecord.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UINavigationController+FDFullscreenPopGesture.h"



#define UILABEL_DRAW_TAG 200
#define UIIMAGEVIEW_HAND_TAG 201
#define DURATION 1.0
#define LABEL_GAP 20
#define KEY_FEATURE_QUEUE_VERSION @"KEY_FEATURE_QUEUE_VERSION"
#define FEATURE_QUEUE_VERSION 1
#define IP (TPScreenHeight() > 500 )
#define IP5DOWNDISTANCE (TPScreenHeight() > 500? 40 : 20)

#define WIDTH_ADAPT TPScreenWidth()/320
#define IPHONE4 TPScreenHeight() < 500
#define IPHONE6 TPScreenHeight() > 600

#define WIDTH_SUBTITLE 46
#define HEIGHT_SUBTITLE 55

@interface FeatureGuideTipsController(){
    BOOL privacyRead;
    CGFloat stepY;
    CGFloat iphone4Padding;
    CGFloat stepPadding;
    CGFloat stepRadius;
    
    UIButton *startButton;
    UIButton *registerButton;
    UILabel *checkBox;
    UIView *_actionLayout;
    UIView *_actionBgLayout;
    UIImageView *_fullImageView;
    UIImageView *_sloganImageView;
    UIView *_subtitleLayout;
    NSMutableArray *_subtitleArray;
    UIView *stepView;
    
    UIView *scroll_view_page;
}
@property(nonatomic,strong)AVPlayer *player;
@end

@implementation FeatureGuideTipsController

- (void)loadView
{
    iphone4Padding = IPHONE4 ? 10 : 0;
    stepY = (int)((IPHONE4 ? 0.9 : 0.93) * TPScreenHeight() - 12 + iphone4Padding);
    stepPadding = IPHONE4 ? 12 : 20;
    stepRadius = IPHONE4 ? 4 : 6;
    [UserDefaultsManager setIntValue:FEATURE_QUEUE_VERSION forKey:KEY_FEATURE_QUEUE_VERSION];
    int pageNumber = 1;
    privacyRead = YES;
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    emptyView.backgroundColor = [[TPDialerResourceManager sharedManager]getUIColorFromNumberString:@"featureGuideTips_background_color"];
    self.view = emptyView;
    
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, TPScreenWidth(), TPScreenHeight()+20)];
    scrollView.contentSize = CGSizeMake(TPScreenWidth() * pageNumber, TPScreenHeight());
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    scrollView.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    [self.view addSubview:scrollView];
    [self loadScrollViewItem];
    self.fd_interactivePopDisabled = YES;

//    stepView = [self getStepUIViewWithFrame:CGRectMake(0, stepY, TPScreenWidth() / 2 + stepPadding + 3 * stepRadius, 12) currentStep:0];
//    [self.view addSubview:stepView];
    
    //[self testUserDefaultManager_readValue];
    
    //page controller
//    TPPageController *page_control = [[TPPageController alloc] initWithFrame:CGRectMake(0,TPAppFrameHeight()-31+TPHeaderBarHeightDiff(),TPScreenWidth(), 26)];
//    page_control.backgroundColor = [UIColor clearColor];
//    [page_control setSkinStyleWithHost:self forStyle:@"pageControl_style"];
//    [page_control addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
//    page_control.numberOfPages = pageNumber;
//    currentPage=0;
//    
//    //设置当前页
//    page_control.currentPage=currentPage;
//    pageController = page_control;
//    [self.view addSubview:page_control];
//    [page_control release];
    int appearCount = [UserDefaultsManager intValueForKey:FEATURE_GUIDE_TIPS_CONTROLLER_APPEAR_COUNT defaultValue:0];
    appearCount += 1;
    [UserDefaultsManager setIntValue:appearCount forKey:FEATURE_GUIDE_TIPS_CONTROLLER_APPEAR_COUNT];
    
    [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_GREETING_PAGE, @(1)), nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goonPlayVideo) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)addAndPlayMovieInView:(UIView *)view{
    AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    avLayer.backgroundColor = [UIColor blackColor].CGColor;
    avLayer.frame = view.bounds;
    avLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [view.layer addSublayer:avLayer];
    [_player play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seekToZeroTimePlay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

}

-(void)seekToZeroTimePlay{
    [_player.currentItem seekToTime:kCMTimeZero];
    [_player play];
}
-(void)goonPlayVideo{
    [_player play];
}


-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *platerItem = [self  getPlayItem:@"starting_up_feature_guide"];
        _player = [AVPlayer playerWithPlayerItem:platerItem];
    }
    return _player;
}

-(AVPlayerItem *)getPlayItem:(NSString *)fileName{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp4"];
    //视频URL
    NSURL *url = [NSURL fileURLWithPath:path];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    return playerItem;
}

-(void)loadScrollViewItem
{
    scroll_view_page =[[UIView alloc] initWithFrame:CGRectMake(0,0,TPScreenWidth(),TPScreenHeight())] ;
    CGFloat globalY = 0;
    
    [self addAndPlayMovieInView:scroll_view_page];
    
    UIImage *imageSlogan = [TPDialerResourceManager getImage:@"starting_up_animation_slogan@2x.png"];
    _sloganImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 35, imageSlogan.size.width, imageSlogan.size.height)];
    _sloganImageView.image = imageSlogan;
    _sloganImageView.alpha = 0;
    [scroll_view_page addSubview:_sloganImageView];
    
    CGFloat registerHeight = IPHONE4 ? 46 : 56;
    globalY = TPScreenHeight() *0.52;
    
    
    [scrollView addSubview:scroll_view_page];
    _actionLayout = [[UIView alloc]initWithFrame:CGRectMake(0, (int)globalY, TPScreenHeight(), TPScreenHeight() - globalY)];
    _actionLayout.alpha = 1;
    

    
//    CAGradientLayer *grandlayout = [CAGradientLayer layer];
//    grandlayout.frame = CGRectMake(0, 0, _actionLayout.bounds.size.width,_actionLayout.bounds.size.height);
//    UIColor *topColor = [TPDialerResourceManager getColorForStyle:@"0xffececed"];
//    UIColor *buttonColor = [TPDialerResourceManager getColorForStyle:@"0x80ececed"];
//    grandlayout.colors = @[(id)topColor.CGColor,
//                           (id)buttonColor.CGColor];
//    grandlayout.startPoint = CGPointMake(0, 0);
//    grandlayout.endPoint = CGPointMake(0, 1);
//    [_actionLayout.layer addSublayer:grandlayout];
    [scroll_view_page addSubview:_actionLayout];
    

    _actionBgLayout =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, TPScreenHeight(), TPScreenHeight() - globalY)];
    _actionBgLayout.alpha = 0 ;
    [_actionLayout addSubview:_actionBgLayout];

    startButton = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() - 130-12,_actionLayout.bounds.size.height-38-10, 130, 14+10)];
    startButton.backgroundColor = [UIColor clearColor];
    [startButton setTitle:@"仅使用普通电话>>" forState:UIControlStateNormal];
    startButton.titleLabel.textAlignment = NSTextAlignmentRight;
    startButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_4_5];
    [startButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_500"] forState:UIControlStateNormal];
    [startButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_300"] forState:UIControlStateHighlighted];
    [_actionBgLayout addSubview:startButton];
    [startButton addTarget:self action:@selector(startExperience) forControlEvents:UIControlEventTouchUpInside];

    
    NSString *hintStr = @"      已阅读并同意用户协议及隐私政策";
    NSString *firstHintStr = @"      已阅读并同意";
    CGSize allTextSize = [hintStr sizeWithFont:[ UIFont systemFontOfSize:FONT_SIZE_5] constrainedToSize:CGSizeMake(TPScreenWidth(), FONT_SIZE_2)];
    CGSize firstTextSize = [firstHintStr sizeWithFont:[ UIFont systemFontOfSize:FONT_SIZE_5] constrainedToSize:CGSizeMake(TPScreenWidth(), FONT_SIZE_2)];
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(TPScreenWidth() / 2 - allTextSize.width / 2,_actionLayout.bounds.size.height-76, firstTextSize.width, FONT_SIZE_2)];
    hintLabel.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    hintLabel.text = @"      已阅读并同意";
    hintLabel.textAlignment = NSTextAlignmentCenter;

    hintLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5];
    hintLabel.backgroundColor = [UIColor clearColor];
    [_actionBgLayout addSubview: hintLabel];
    
    UIButton *privacy = [[UIButton alloc]initWithFrame:CGRectMake(TPScreenWidth() / 2 - allTextSize.width / 2 + firstTextSize.width, CGRectGetMinY(hintLabel.frame), allTextSize.width - firstTextSize.width, FONT_SIZE_2)];
    [privacy setTitle:@"用户协议及隐私政策" forState:UIControlStateNormal];
    [privacy setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] forState:UIControlStateNormal];
    [privacy setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_700"] forState:UIControlStateHighlighted];
    privacy.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_5];
    [privacy setBackgroundColor:[UIColor clearColor]];
    privacy.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_actionBgLayout addSubview:privacy];
    [privacy addTarget:self action:@selector(visitPirvacy) forControlEvents:UIControlEventTouchUpInside];
    if (!isIPhone5Resolution()) {
        privacy.center = CGPointMake(privacy.center.x, hintLabel.center.y+1);
    }
    
    checkBox = [[UILabel alloc]initWithFrame:CGRectMake((TPScreenWidth() - allTextSize.width)/2-3, CGRectGetMinY(hintLabel.frame), 30, FONT_SIZE_2_5)];
    checkBox.font = [UIFont fontWithName:@"iPhoneIcon2" size:FONT_SIZE_2_5];
    checkBox.textAlignment = NSTextAlignmentCenter;
    checkBox.backgroundColor = [UIColor clearColor];
    [self setPrivacyButtonChecked:privacyRead];
    [_actionBgLayout addSubview:checkBox];
    if (!isIPhone5Resolution()) {
        checkBox.center = CGPointMake(checkBox.center.x, hintLabel.center.y+2);
    }

    UIButton *checkBtn = [[UIButton alloc]initWithFrame:CGRectMake((TPScreenWidth() - allTextSize.width)/2 - 30, CGRectGetMinY(checkBox.frame) - 5, allTextSize.width / 2 + 20, FONT_SIZE_2 + 40)];
    [checkBtn setBackgroundColor:[UIColor clearColor]];
    [_actionLayout addSubview:checkBtn];
    [checkBtn addTarget:self action:@selector(checkBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    registerButton = [[UIButton alloc]initWithFrame:CGRectMake(0.17 * TPScreenWidth(), CGRectGetMinY(checkBox.frame)-20-registerHeight, 0.66 * TPScreenWidth(), registerHeight)];
    [registerButton setTitle:@"立即开启" forState:UIControlStateNormal];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [registerButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"] forState:UIControlStateNormal];
    [registerButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_900"]] forState:UIControlStateNormal];
    [registerButton setBackgroundImage:[FunctionUtility imageWithColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"]] forState:UIControlStateHighlighted];
    registerButton.layer.masksToBounds = YES;
    registerButton.layer.cornerRadius = 4.0f;
    [_actionBgLayout addSubview:registerButton];
    [registerButton addTarget:self action:@selector(startRegisterNow) forControlEvents:UIControlEventTouchUpInside];
    [self showAnimaTion];
    [self scaleAnimation];
}

-(void)showAnimaTion{
    [UIView animateWithDuration:1 delay:0.5 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
        _actionBgLayout.alpha = 1;
        _sloganImageView.alpha = 1;

    } completion:nil];
}

-(void)scaleAnimation{
    [UIView animateWithDuration:2.4 delay:1 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
        _fullImageView.transform = CGAffineTransformScale(_fullImageView.transform, 1.1, 1.1);
    } completion:nil];
}




- (void) addSubtitle {
    NSArray *array = [[NSArray alloc]initWithObjects:@"M", @"M", @"N", @"N", @"O", @"O", @"P", @"P", @"Q", @"Q", nil];
    CGFloat startX = 0;
    for (int i = 0; i < array.count ; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(startX, 0, WIDTH_SUBTITLE, HEIGHT_SUBTITLE)];
        label.text = [array objectAtIndex:i];
        label.font = [UIFont fontWithName:@"iPhoneIcon3" size:HEIGHT_SUBTITLE];
        label.layer.anchorPoint = CGPointMake(0.5, 1);
        label.contentMode = UIViewContentModeRedraw;
        if (i % 2 == 0) {
            label.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_600"];
        } else if (i == 5 || i == 7) {
            label.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_green_500"];
        } else if (i == 1 || i == 3 || i == 9){
            label.textColor = [TPDialerResourceManager getColorForStyle:@"tp_color_grey_400"];
        }
        label.backgroundColor = [UIColor clearColor];
        label.alpha = (i % 2 == 1) ? 0 : 1;
        
        startX += (i % 2 == 0) ? 0 : WIDTH_SUBTITLE;
        [_subtitleLayout addSubview:label];
        [_subtitleArray addObject:label];
    }
}

- (void) visitPirvacy {
    CommonWebViewController* webVC = [[CommonWebViewController alloc] init];
    webVC.url_string = NSLocalizedString(@"http://www.touchpal.com/privacypolicy_contacts.html", @"");
    webVC.header_title = @"";
    [[TouchPalDialerAppDelegate naviController] pushViewController:webVC animated:YES];
    [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_VISIT_PRIVACY, @(1)), nil];
}

- (void) checkBtnClick {
    [self setPrivacyButtonChecked:!privacyRead];
}

- (void) setPrivacyButtonChecked:(BOOL)checked {
    privacyRead = checked;
    NSString *iconString = nil;
    UIColor *iconColor = nil;
    if (checked) {
        iconString = @"x";
        iconColor = [TPDialerResourceManager getColorForStyle:@"tp_color_light_blue_500"];
        [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_CONFIRM_PRIVACY, @(1)), nil];
    } else {
        iconString = @"q";
        iconColor = [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_300"];
    }
    checkBox.text = iconString;
    checkBox.textColor = iconColor;
}

- (UIView*) getStepUIViewWithFrame:(CGRect)frame currentStep:(NSInteger)currentStep {
    UIView *view = [[UIView alloc]initWithFrame:frame];
    CGFloat startX = TPScreenWidth() / 2 - stepPadding - 3 * stepRadius;
    for (int i = 0; i < 3; i++) {
        CGRect frame = CGRectMake(startX, 0, stepRadius * 2, stepRadius * 2);
        UIView *step = [self getStepUICellWithFrame:frame];
        if (i == currentStep) {
            step.alpha = 1;
        }
        [view addSubview:step];
        startX += 2 * stepRadius + stepPadding;
    }
    return view;
}

- (void) setCurrentStep:(NSInteger)index {
    [stepView removeFromSuperview];
    stepView = [self getStepUIViewWithFrame:CGRectMake(0, stepY , TPScreenWidth() / 2 + stepPadding + 3 * stepRadius, 2 * stepRadius) currentStep:index];
    [self.view addSubview:stepView];
}

- (UIView*) getStepUICellWithFrame:(CGRect)frame {
    UIView *view = [[UIView alloc]initWithFrame:frame];
    view.layer.masksToBounds = YES;
    view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    view.layer.cornerRadius = stepRadius;
    view.alpha = 0.5;
    return view;
}

- (void)tabEventOnImage:(UITapGestureRecognizer *)gesture {
    [self startExperience];
}

- (void)startExperience {
    if (!privacyRead) {
        NSString *message = @"请阅读并同意用户协议及隐私政策";
        [DefaultUIAlertViewHandler showAlertViewWithTitle:message message:nil];
    } else{
        [DialerUsageRecord recordpath:PATH_REGISTER_GUIDE_VIEW kvs:Pair(KEY_ACTION , CLICK_COIN_NORMAL), nil];
        __block FeatureGuideTipsController *wkSelf = self;
        UIView *guideVSView = [[CommonImageViewWithBlock alloc] initWithImage:[TPDialerResourceManager getImage:@"FeatureGuideViewVS@2x.png"] leftTitle:@"不用免费电话" leftBlock:^{
            [UserDefaultsManager setBoolValue:YES forKey: next_active_show_guide];
            [UserDefaultsManager setBoolValue:YES forKey:have_click_vs_no_free];
            
            [wkSelf.navigationController popViewControllerAnimated:YES];
            
            // 第二次询问，点击“使用普通电话”
            [TPFilterRecorder recordpath:PATH_LOGIN
                                      kvs:Pair(LOGIN_CLICK_SECOND_CHANCE_NORMAL_CALL, @(1)), nil];
            [TPFilterRecorder sendFilterPath:PATH_LOGIN];
            
        } rightTitle:@"开启免费电话" rightBlock:^{
            [DialerUsageRecord recordpath:PATH_REGISTER_GUIDE_VIEW kvs:Pair(KEY_ACTION , CLICK_VS_REGISTER), nil];
            [UserDefaultsManager setObject:CURRENT_TOUCHPAL_VERSION forKey:FIRST_LAUNCH_VERSION];
            [UserDefaultsManager setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:KEY_CURRENT_PRODUCT_VERSION_DATE];
            [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:CLICK_VS_REGISTER]];
            [FunctionUtility removeFromStackViewController:wkSelf];
            
            // 第二次询问，点击“开启免费电话”
            [TPFilterRecorder recordpath:PATH_LOGIN
                                      kvs:Pair(LOGIN_FROM, LOGIN_FROM_SECOND_CHANCE),
                                        Pair(LOGIN_CLICK_SECOND_CHANCE_FREE_CALL, @(1)),
                                        nil];
        }];
        
        [DialogUtil showDialogWithContentView:guideVSView inRootView:nil notSeeBgView:YES];
        [UserDefaultsManager setObject:CURRENT_TOUCHPAL_VERSION forKey:FIRST_LAUNCH_VERSION];
        [UserDefaultsManager setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:KEY_CURRENT_PRODUCT_VERSION_DATE];
        NSDictionary *activateInfo = @{
            REAL_TIME_ACTIVATE_TYPE : @"landing_page_register_later_new"
        };
        
        [DialerUsageRecord record:USAGE_TYPE_DIALER_IOS path:PATH_REAL_TIME_ACTIVATE values:activateInfo];
        [UsageRecorder send];
    }
}

- (void)startRegisterNow{
    if (!privacyRead) {
        NSString *message = @"请阅读并同意用户协议及隐私政策";
        [DefaultUIAlertViewHandler showAlertViewWithTitle:message message:nil];
    } else {
        [DialerUsageRecord recordpath:PATH_REGISTER_GUIDE_VIEW kvs:Pair(KEY_ACTION , CLICK_COIN_REGISTER), nil];

        [UserDefaultsManager setObject:CURRENT_TOUCHPAL_VERSION forKey:FIRST_LAUNCH_VERSION];
        [UserDefaultsManager setObject:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKey:KEY_CURRENT_PRODUCT_VERSION_DATE];
        [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:CLICK_COIN_REGISTER]];
        [FunctionUtility removeFromStackViewController:self];
        
        NSDictionary *activateInfo = @{
            REAL_TIME_ACTIVATE_TYPE : @"landing_page_register_now_new"
        };
        
        [DialerUsageRecord record:USAGE_TYPE_DIALER_IOS path:PATH_REAL_TIME_ACTIVATE values:activateInfo];
        [UsageRecorder send];
        
        // 第一次询问，直接选择“免费电话”
        [TPFilterRecorder recordpath:PATH_LOGIN
                                  kvs:Pair(LOGIN_FROM, LOGIN_FROM_FIRST_CHANCE),
                                    Pair(LOGIN_CLICK_FIRST_CHANCE_FREE_CALL, @(1)),
                                    nil];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
     CGFloat pageWidth = scrollView.frame.size.width;
     int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	if (page!=currentPage) {
		currentPage=page;
		pageController.currentPage = page;
        [self setCurrentStep:page];
	}
}

-(void)changePage:(id)sender
{
	NSInteger currentpage=pageController.currentPage;
     CGRect frame = scrollView.frame;
     frame.origin.x = frame.size.width*currentpage;
     frame.origin.y = 0;
     [scrollView scrollRectToVisible:frame animated:YES];
}




@end
