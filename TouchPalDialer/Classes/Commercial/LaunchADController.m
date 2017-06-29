//
//  LaunchADController.m
//  TouchPalDialer
//
//  Created by siyi on 16/2/22.
//
//

#import "LaunchADController.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "CootekWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "HangupCommercialManager.h"
#import "LaunchCommercialManager.h"
#import "Reachability.h"
#import "TouchPalVersionInfo.h"
#import "AdShowtimeManager.h"
#import "AdLandingPageManager.h"
#import "LaunchCommercialManager.h"
#import "MarketLoginController.h"
#import "HandlerWebViewController.h"
#import "DialerUsageRecord.h"
#import "NormalLaunchViewController.h"
#import "SixpackUtil.h"
#import "SkipButton.h"
#import "HangupCommercialManager.h"
#import "AdStatManager.h"
#import "VoipUtils.h"
#import "CootekNotifications.h"
#import "PrepareAdModel.h"
#import "AdStatManager.h"
#import "PrepareAdManager.h"
#import "UserDefaultsManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#define FADE_IN_TIME_SECONDS (0.5)

@implementation LaunchADController {
    UIView *_splashWhiteView;
    UIImageView *_launchImageView;
    NSString *_tickerStringFormat;
    BOOL _countDownStarted;
    LaunchADCallback _callback;
    AdShowtimeManager *_adShowTimeManager;
    AdLandingPageManager *_adLandingPageManager;
    BOOL _onlineFetched;
    BOOL _shouldDeleteCache;
    BOOL _adStarted;
    NSUInteger _remainedDisplayTime;
    HandlerWebViewController *_adWebViewController;
    NSString *requestUuid;
    BOOL _usePrepare;
    PrepareAdItem *prepare;
}

- (void) baseInit {
    _onlineFetched = NO;
    _shouldDeleteCache = NO;
    _countDownStarted = NO;
    _adStarted = NO;
    _remainedDisplayTime = 0;
}



- (instancetype) initWithADModel:(HangupCommercialModel *) model uuid:(NSString *)uuid viewDidAppearCallback:(LaunchADCallback) callback{
    self = [super init];
    if (self) {
        _callback = callback;
        _adModel = model;
        requestUuid = uuid;
        prepare = [[PrepareAdManager instance] getPrepareAdItem:kAD_TU_LAUNCH];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunchAD) name:N_LAUNCH_AD_FINISH object:nil];
        

    }
    return self;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    [LaunchADController asyncGetLaunchADWithUuid:requestUuid preUuid:prepare.uuid];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AdReadyToShowWebInMainThread:) name:N_AD_READY_FOR_SHOW object:nil];

    self.view.backgroundColor = [TPDialerResourceManager getColorForStyle:@"tp_color_white"];
    
    // logo image view
    UIImage *logoImage = [TPDialerResourceManager getImage:@"chubao_slogan@2x.png"];
    CGSize logoSize = logoImage.size;
    CGFloat logoViewWidth = TPScreenWidth();
    CGFloat logoViewHeight = (logoSize.height / logoSize.width) * logoViewWidth;
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.frame = CGRectMake(0, TPScreenHeight() - logoViewHeight, logoViewWidth, logoViewHeight);
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    logoImageView.hidden = YES;
    // splash white view
    _splashWhiteView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, TPScreenWidth(), TPScreenHeight() + 20)];
    _splashWhiteView.backgroundColor = [UIColor whiteColor];
    
    // launch image view for displaying the ad image
    _launchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight() - logoViewHeight)];
    _launchImageView.hidden = YES;
    _launchImageView.alpha = 0;
    _launchImageView.contentMode = UIViewContentModeScaleToFill;
    
    //set listener for the ad image
    UITapGestureRecognizer *tapADImageRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickAD)];
    [_launchImageView addGestureRecognizer:tapADImageRecognizer];
    _launchImageView.userInteractionEnabled = YES;

    
    // set up the view tree
    [self.view addSubview:_splashWhiteView];
    [self.view addSubview:_launchImageView];
    [self.view addSubview:logoImageView];
    
    [TimerTickerManager setDelegate:self];
    //[self applyStrategy];

    [self checkIfOnlineADReady];
    [self hideStatusBar];
    self.fd_interactivePopDisabled = YES;

}


+ (void) asyncGetLaunchADWithUuid:(NSString *)uuid preUuid:(NSString *)preUuid{
    [UserDefaultsManager removeObjectForKey:ad_now_resource_arr];
    NSDictionary *sizeInfo = [FunctionUtility getADViewSizeWithTu:kAD_TU_LAUNCH];
    NSDictionary *dic = @{@"at": @"IMG",
                  @"tu": kAD_TU_LAUNCH,
                  @"w": sizeInfo[@"w"],
                  @"h": sizeInfo[@"h"],
                  @"other_phone":AD_DEBUG_TU_LAUNCH_OTHERPHONE,
                  @"vt":@"",
                  @"ck":uuid};
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *adInfo = [[HangupCommercialManager instance] asyncCommercialAd:kAD_TU_LAUNCH param:dic];
        NSDictionary *dic = adInfo[@"conf"];
        [LaunchADController saveToPlistWithDic:dic];
    });
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


+ (void)saveToPlistWithDic:(NSDictionary *)dic {
    if (dic.allKeys.count == 0) {
        return;
    }
    NSString *filePath = [LaunchADController getAbsoluteCachedFilePath];
    if (filePath) {
        [dic writeToFile:filePath atomically:YES];
    }
}



- (void)finishLaunchAD {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showStatusBar];
        cootek_log(@"finishLaunchAD luanchVC");
        CATransition* transition = [CATransition animation];
        transition.duration = 0.8;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
        //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [FunctionUtility removeFromStackViewController:self];
    });
    
}


- (void) checkIfOnlineADReady {
    if (!_countDownStarted) {
        // counting down for 500ms
        _countDownStarted = YES;
        // defaultly, post delayed in 500ms
        long long waitTime = DEFAULT_FETCH_TIMEOUT_MSEC;
        if (_adModel) {
            waitTime = _adModel.wtime;
        }
        
        dispatch_time_t fireTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) waitTime * NSEC_PER_MSEC);
        dispatch_after(fireTime, dispatch_get_main_queue(), ^(){
            NSString * filePath;
            NSString *url_string;
                if (!_adStarted) {
                    prepare = [[PrepareAdManager instance] getPrepareAdItem:kAD_TU_LAUNCH];
                    if (prepare) {
                            _usePrepare = YES;
                            filePath = prepare.fullHtmlPath;
                            url_string = [filePath stringByAppendingFormat:@"?tu=%@&pst=%@",
                                          kAD_TU_LAUNCH,prepare.uuid];
                        
                            BOOL  isHtmlTuEmpty = [self showAd:filePath url_string:url_string tu:kAD_TU_LAUNCH];
                            [[PrepareAdManager instance] didShowPrepareAd:kAD_TU_LAUNCH];
                           if (isHtmlTuEmpty) {
                               [self finishLaunchAD];
                           }
                           cootek_log(@"use prepare ad");
                           return ;
                        
                        }
                    if (![TouchPalDialerLaunch getInstance].isVoipCallInitialized) {
                        [self pushNormalLaunchViewController];
                    }
                    
                    [self finishLaunchAD];
                }
        });
        
    }
}


- (BOOL) shouldShowAD {
    if (_adStarted) {
        return NO;
    }
    return  _adModel && _adModel.idws;
}



- (void) hideStatusBar {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        //WARNING: this selector is deprecated from 9.0
        [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (void) showStatusBar {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}



- (void) dealloc {
    _adModel = nil;
    _adShowTimeManager = nil;
    _adLandingPageManager = nil;
    _adWebViewController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pushNormalLaunchViewController{
    NormalLaunchViewController *normalLaunchController =[[NormalLaunchViewController alloc] init];
    [[TouchPalDialerAppDelegate naviController] pushViewController:normalLaunchController animated:NO];
}

- (void)AdReadyToShowWebInMainThread:(NSNotification *)noti {
    NSString *tu = noti.userInfo[@"tu"];
    if (![tu isEqualToString:kAD_TU_LAUNCH] ) {
        return;
    }
    
    if ([[NSThread currentThread] isMainThread]) {
        [self showWebView];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{//hasLoaded
            [self showWebView];
        });
    }
}

- (void)showWebView {
    cootek_log(@"PrepareThread, show calling webview...");
    NSString *tu = nil;
    tu = kAD_TU_LAUNCH;
    NSString *filePath = nil;
    _usePrepare = NO;
    BOOL isHtmlTuEmpty = YES;
    BOOL canLoadAd = NO;
    NSString *url_string;
    
    if([self shouldShowAD] && [[HangupCommercialManager instance] checkIfResourceReady]){
        canLoadAd = YES;
        filePath = [FileUtils getAbsoluteFilePath:[[Commercial stringByAppendingPathComponent:ADResource] stringByAppendingPathComponent:ADLaunchHTML]];
        url_string = [filePath stringByAppendingFormat:@"?tu=%@&st=%@",
                      tu,requestUuid];
    }
    if (canLoadAd) {
        isHtmlTuEmpty = [self showAd:filePath url_string:url_string tu:tu];
    }
    
    if(!isHtmlTuEmpty) {
        return;
    }

    
}

- (BOOL)showAd:(NSString *)filePath url_string:(NSString *)url_string tu:(NSString *)tu {
    cootek_log(@"PrepareThread hangup url= %@",url_string);
    BOOL noTu = NO;
    NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *pattern = REG_PATTERN_COOTEK_AD;
    
    if (string.length>0 && [VoipUtils stringByRegularExpressionWithstring:string pattern:pattern tu:tu]) {
        _adStarted = YES;
        _adWebViewController = nil;
        _adWebViewController = [[HandlerWebViewController alloc] init];
        _adWebViewController.webViewCanNotScroll = YES;
        _adWebViewController.webViewFullScreen = YES;
        _adWebViewController.url_string = url_string;
        _adWebViewController.view.alpha = 0;
        _adWebViewController.viewFrame = self.view.bounds;
        [self.view addSubview:_adWebViewController.view];
        [UIView animateWithDuration:1 animations:^{
            _adWebViewController.view.alpha = 1;
        }];
        cootek_log(@"showAd launch");

    } else {
        [VoipUtils saveNoAdReasonWithKey:@"reason" value:@"no_hangup_tu"];
        noTu = YES;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_AD_READY_FOR_SHOW object:nil];

    return noTu;
}


+ (HangupCommercialModel *)getPlistModel{
    NSString *cachedADPath = [self getAbsoluteCachedFilePath];
    if ([NSString isNilOrEmpty:cachedADPath]) {
        return nil;
    }
    // either img or plist is gone, return nil
    if (![FileUtils fileExistAtAbsolutePath:cachedADPath]) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *adinfo = [[NSDictionary alloc] initWithContentsOfFile:cachedADPath];
    if (!adinfo || adinfo.count == 0 || error) {
        return nil;
    }
    
    HangupCommercialModel *model = [[HangupCommercialModel alloc] init];
    
        
        @try {
            model.wtime = [[adinfo objectForKey:@"wtime"] longLongValue];
            model.idws = [[adinfo objectForKey:@"idws"] boolValue];
            
        } @catch(NSException *e) {
            model = nil;
            
        } @finally {
            return model;
        }
    
    return nil;
}

+ (NSString *) getAbsoluteCachedFilePath {
    NSString *adDir = [self getADCacheDir];
    if (adDir) {
        return [adDir stringByAppendingPathComponent:FILE_LAUNCH_AD];
    }
    return nil;
}

+ (NSString *) getADCacheDir {
    NSString *documentPath = [FileUtils absolutePathOfDocument];
    if (!documentPath) {
        return nil;
    }
    NSString *adDirPath = [documentPath stringByAppendingPathComponent:DIR_ADS];
    if (![FileUtils fileExistAtAbsolutePath:adDirPath]) {
        [FileUtils createDir:adDirPath];
    }
    return adDirPath;
}

@end
