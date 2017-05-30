//
//  HangupController.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/9.
//
//

#import "HangupController.h"
#import "HangupHeaderView.h"
#import "HangupMiddleView.h"
#import "HangupActionView.h"
#import "VoipConsts.h"
#import "CallRingUtil.h"
#import "CootekNotifications.h"
#import "TouchPalDialerAppDelegate.h"
#import "PushAndPopAnimator.h"
#import "HangupCommercialManager.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "DialerUsageRecord.h"
#import "TouchLifeShareMgr.h"
#import "DialerGuideAnimationUtil.h"
#import "TPVoipPrivilegeADView.h"
#import "InviteShareManager.h"
#import "NumberPersonMappingModel.h"
#import "ContactCacheDataManager.h"
#import "VoipUtils.h"
#import "DefaultUIAlertViewHandler.h"
#import "CommonTipsWithBolckView.h"
#import "SeattleFeatureExecutor.h"
//shareRing
#import "TurnToneTips.h"
#import "DialogUtil.h"
#import "VoipShareAllView.h"
#import "TouchPalVersionInfo.h"
#import "UserDefaultsManager.h"
#import "TPAnalyticConstants.h"
#import "AppSettingsModel.h"
#import "UILayoutUtility.h"

#import "Reachability.h"


#import "UIView+Toast.h"
#import "LocalStorage.h"

#import "VoipUtils.h"
#import "AlertViewHandle.h"
#import "AdDebugStatsManager.h"
#import "YPFeedsTask.h"
#import "FeedsRedPacketManager.h"
#import "PrepareAdManager.h"
#import "AdStatManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "TPDLib.h"
@interface HangupController () <ModelChangeDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,copy) NSString *callNumber;
@property (nonatomic,copy) NSString *error_code;
@property (nonatomic,assign) NSInteger callDuration;
@property (nonatomic,assign) BOOL hadShowWeb;
@property (nonatomic,assign)NSInteger position;
@property (nonatomic, assign) BOOL webViewCanShow;


@property (nonatomic, assign) BOOL timeAutoClose;
@property (nonatomic, strong) HangupModel *hangupModel;
@property (nonatomic, weak) UIAlertView *alert;
@end

#define TimePadding 30 //30

@implementation HangupController{
    HangupViewModelGenerator *_modelGenerator;
    HandlerWebViewController *adWebViewController;
    UIView *_actionView;
    HangupActionView *_actionAdView;
    HangupMiddleView *middleView;
    NSTimer *_timer;
    HangupHeaderView *headerView;
    BOOL _isIncomingCall;
    bool _isVoipPrivilegeADReady;
    HangupCommercialModel *_adModelData;
    UIImageView *bgView;
    UIImageView *adBgView;
    BOOL ifWebHAdShow;
    UILabel *label;
}


- (id)initWithHanupModel:(HangupModel *)model {
    self = [super init];
    if (self) {
        _modelGenerator = [[HangupViewModelGenerator alloc] initWithHangupModel:model andDelegate:self];
        _position = 1;
        _isIncomingCall = model.isIncomingCall;
        _callNumber = model.number;
        _callDuration = model.callDur;
        _hangupModel = model;
    }
    return self;
}

- (id)initWithCallNumber:(NSString *)callNumber
               startTime:(double)startTime
                 callDur:(double)callDur
               isP2PCall:(BOOL)isP2p
                    uuid:(NSString *)uuid{
    HangupModel *model = [[HangupModel alloc] init];
    model.number = callNumber;
    model.startTime = startTime;
    model.callDur = callDur;
    model.isp2pCall = isP2p;
    model.uuid = uuid;
    return [self initWithHanupModel:model];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController*)fromVC
                                                 toViewController:(UIViewController*)toVC
{
    if (operation == UINavigationControllerOperationPush)
        return [[CustomPushAnimator alloc] init];
    
    if (operation == UINavigationControllerOperationPop)
        return [[CustomPopAnimator alloc] init];
    
    return nil;
}

- (void)reomveCommericalWebController {
    if (adWebViewController) {
        [(UIWebView *)adWebViewController.commonWebView.web_view stopLoading];
        [adWebViewController.view removeFromSuperview];
        adWebViewController = nil;
    }
}

- (void)loadView{
    [super loadView];
    ifWebHAdShow = NO;
    if ([UserDefaultsManager boolValueForKey:HANGUP_NO_AD]) {
        [VoipUtils saveNoAdReasonWithKey:@"phone" value:_hangupModel.number];
    }
    [_actionAdView removeFromSuperview];
    [HangupCommercialManager instance].adCount = 0;
    _error_code = [NSString stringWithFormat:@"%d",_hangupModel.errorCode];
    
    if (![VoipUtils ifShowADWithErrorCode:_hangupModel.errorCode ifOutging:_hangupModel.isIncomingCall]) {

        self.view.backgroundColor = [UIColor colorWithRed:COLOR_IN_256(0xEE) green:COLOR_IN_256(0xEE) blue:COLOR_IN_256(0xEE) alpha:1];
        UIImage *image = [_modelGenerator getBgImage];
        
        if (image) {
            bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
            bgView.image = image;
            bgView.userInteractionEnabled = YES;
            [self.view addSubview:bgView];
        }

        headerView = [[HangupHeaderView alloc] initWithModel:[_modelGenerator getHeaderModel]];
        headerView.center = CGPointMake(TPScreenWidth()/2, headerView.frame.size.height/2);

        
        [self.view addSubview:headerView];
        
        BOOL errorCodePageShown = NO;
        if ([_modelGenerator getErrorCode]) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(15, headerView.frame.size.height + 10, 50, 30)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor grayColor];
            label.text = [_modelGenerator getErrorCode];
            label.font = [UIFont systemFontOfSize:14];
            [self.view addSubview:label];
            errorCodePageShown = YES;
            
            [UserDefaultsManager setObject:AD_PAGE_ERROR_CDOE forKey:LAST_AD_PAGE_TYPE];
            
        }else{
            headerView.altLabel.text = @"";
            [UserDefaultsManager setObject:AD_PAGE_DEFAULT forKey:LAST_AD_PAGE_TYPE];
        }
        
        // for last ad debug stats
        NSMutableDictionary *lastCallStats = [[NSMutableDictionary alloc] initWithCapacity:1];
        [lastCallStats setObject:kAD_TU_HANGUP forKey:KEY_LAST_AD_TU];
        [lastCallStats setObject:@(NO) forKey:KEY_LAST_AD_HTML_TU_EMPTY];
        [lastCallStats setObject:[NSString nilToEmpty:[_modelGenerator getErrorCode]] forKey:KEY_LAST_AD_ERROR_CODE];
        [AdDebugStatsManager recordLastAdStats:lastCallStats];
        
        CGFloat globaly = headerView.frame.size.height;
        MiddleViewModel *middleModel = [_modelGenerator getMiddleModel];
        if (middleModel.icon) {
            [self reomveCommericalWebController];
            middleView = [[HangupMiddleView alloc] initWithMiddleModel:middleModel];
            middleView.center = CGPointMake(TPScreenWidth()/2, middleView.frame.size.height/2 + globaly+10);
            [self.view addSubview:middleView];
            globaly += middleView.frame.size.height;
        }
        CGFloat scale = TPScreenHeight()/667.0;
        UIView *actionView = [[HangupActionView alloc] getActionVieWithModel:[_modelGenerator getMainActionViewModel] frame:CGRectMake(0, TPScreenHeight()-180*scale-(20-TPHeaderBarHeightDiff()), TPScreenWidth(), 180*scale)];
        if (_position==1 && [HangupCommercialManager instance].adCount>1) {
            [_actionAdView.closeButton setTitle:@"跳过" forState:(UIControlStateNormal)];
        } else {
            [_actionAdView.closeButton setTitle:@"关闭" forState:(UIControlStateNormal)];
        }
        [self.view addSubview:actionView];
        [self.view bringSubviewToFront:actionView];
        _actionView = actionView;
        [self.view bringSubviewToFront:_actionView];
    } else {
        adBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
        adBgView.image = [TPDialerResourceManager getImage:@"outgoing_bg@2x.png"];
        [self.view addSubview:adBgView];
        
        if (![self addWebViewWithPosition:YES]){
            adBgView.hidden = NO;
            [self changeProvider];
        }
        
        if ([HangupCommercialManager instance].commercialModel) {
            [[HangupCommercialManager instance] tellShow:YES];
        }
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.delegate = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTimer) name:N_REMOVE_HANGUP_TIMER object:nil];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close) name:N_APP_DID_ENTER_BACKGROUND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voipPrivilegeADDataReady:) name:N_VOIP_PRIVILEGE_AD_DATA_READY object:nil];
    _timer = [NSTimer scheduledTimerWithTimeInterval:TimePadding target:self selector:@selector(autoClose) userInfo:nil repeats:NO];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseOut animations:^ {
        headerView.center = CGPointMake(TPScreenWidth()/2, headerView.frame.size.height/2);
    } completion:nil];
    [[AlertViewHandle sharedSingleton] showAlertErrorWithHangUpModel:_hangupModel];
    [UserDefaultsManager setBoolValue:NO forKey:if_hangupcon_closed];
    self.fd_interactivePopDisabled = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) voipPrivilegeADDataReady:(NSNotification *) notification {
    if (!notification) return;
    _adModelData = (HangupCommercialModel *)[notification object];
    if (_adModelData) {
        _isVoipPrivilegeADReady = YES;
    }
}


- (void)close:(BOOL)animate {
    _position++;
    [FunctionUtility saveLogInDebugToDocFile:@"log.txt"
                                     withLog:@{@"ad_web_count":@([HangupCommercialManager instance].adCount),@"position":@(_position)}];
    if (ifWebHAdShow && animate && !_timeAutoClose
        && [_modelGenerator getErrorCode] == 0
        && _position <= [HangupCommercialManager instance].adCount) {
        [adWebViewController.view removeFromSuperview];
        [self addWebViewWithPosition:NO];
        [_timer invalidate];
         _timer = nil;
         _timer = [NSTimer scheduledTimerWithTimeInterval:TimePadding
                                                   target:self
                                                 selector:@selector(autoClose)
                                                 userInfo:nil
                                                  repeats:NO];
    } else {
        _position = 1;
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        [self reomveCommericalWebController];
        [self stopTimer];
        _timeAutoClose = NO;
        
        [UserDefaultsManager setBoolValue:YES forKey:if_hangupcon_closed];

        [[HangupCommercialManager instance] finishPresent];
        if ( !_isIncomingCall && _isVoipPrivilegeADReady) {
            [self showVoipPrivilegeAD];
        } else {
            [FeedsRedPacketManager showRedPacketGuaji];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
        
        if ([UserDefaultsManager objectForKey:@"SHARE_RING_DATA"] != nil && appSettingsModel.dial_tone==YES
            && ![UserDefaultsManager boolValueForKey:@"NOT_SHARE_RING_BYDATA"]
            ) {
            NSDate *lastDate =(NSDate *)[UserDefaultsManager objectForKey:@"SHARE_RING_DATA"];
            NSDate *nowDate = [NSDate date];
            NSTimeInterval times = [nowDate timeIntervalSinceDate:lastDate];
            
            if(times>84600){
                [self performSelector:@selector(shareRing) withObject:nil afterDelay:1.2];
                [UserDefaultsManager setBoolValue:YES forKey:@"NOT_SHARE_RING_BYDATA"];
                
            }
        }
       
        UINavigationController *navi = [TouchPalDialerAppDelegate naviController];
        
        if ([navi topViewController] == self) {
            [self.navigationController popViewControllerAnimated:animate];
        } else {
            [FunctionUtility removeFromStackViewController:self];
        }
    }
}

- (void)requestShareContent{
    int personId = [NumberPersonMappingModel queryContactIDByNumber:self.callNumber];
    NSString *target_name = @"";
    BOOL is_general_contact = NO;
    if (personId>0){
        ContactCacheDataModel *contact = [[ContactCacheDataManager instance] contactCacheItem:personId];
        target_name = contact.displayName;
        is_general_contact = YES;
    }
    NSDictionary *dict = @{@"close_time":@([UserDefaultsManager intValueForKey:@"invite_share_close_time" defaultValue:0]),
                           @"target_phone":self.callNumber,
                           @"duration":@(self.callDuration),
                           @"is_general_contact":@(is_general_contact),
                           @"target_name":target_name};
    [[InviteShareManager instance]requestInviteShare:dict withInviteFailBlock:^{
        TouchLifeShare *touchLifeShare = [[TouchLifeShareMgr instance] newTouchLifeShare];
        NSDictionary *param = [touchLifeShare generateShareRequestParamWithCallNumber:self.callNumber callDuration:self.callDuration isVoipCall:YES];
        [touchLifeShare checkShareWithRequestParam:param];
    }];
}

- (void) showVoipPrivilegeAD {
    if (!_isVoipPrivilegeADReady) return;
    UINavigationController *naviController = [TouchPalDialerAppDelegate naviController];
    [naviController popToRootViewControllerAnimated:NO];
    TPVoipPrivilegeADView *adView = [[TPVoipPrivilegeADView alloc] initWithModelData:_adModelData];
    if (adView) {
        [adView showInAppWindow];
    }
}

-(void)shareRing{
    
    [UserDefaultsManager setIntValue:([UserDefaultsManager intValueForKey:EV_SHAREGUIDE_COUNT defaultValue:0]+1) forKey:EV_SHAREGUIDE_COUNT];
    cootek_log(@"%d",[UserDefaultsManager intValueForKey:EV_SHAREGUIDE_COUNT]);
    [DialerUsageRecord recordpath:EV_SHAREGUIDE_COUNT kvs:Pair(RING_GUIDE, @([UserDefaultsManager intValueForKey:EV_SHAREGUIDE_COUNT])), nil];
    TurnToneTips *shareRingView = [[TurnToneTips alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) titleString:@"这款拨号音是不是很好玩？快邀请朋友一起来体验吧~" leftString:@"不了，谢谢" rightString:@"分享给朋友" sureBlock:^{
        VoipShareAllView *shareAllView = [[VoipShareAllView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) title:@"超好玩的拨号音，只在触宝电话，你不要来装一个？" msg:@"才不告诉你装了还能免费打电话呢~" url:@"http://dialer.cdn.cootekservice.com/web/external/laststep/index.html?code=ops_sicong_theme_20151015" buttonArray:@[@"wechat", @"qq"]];
        [shareAllView setHeadTitle:@"分享给"];
        shareAllView.fromWhere = @"shareRing";
        [[TouchPalDialerAppDelegate naviController].topViewController.view addSubview:shareAllView];
    }];
    [DialogUtil showDialogWithContentView:shareRingView inRootView:nil];
}

- (void)closeAnimate {
    BOOL _isBackCall = ((HangupViewModelGenerator *)_modelGenerator).hangupModel.isBackCall;
    if (_position==1) {
        if (_isBackCall) {
            [DialerUsageRecord recordCustomEvent:PATH_HANGUP_BACKCALL_CUSTOM_EVENT];
        } else {
            [DialerUsageRecord recordCustomEvent:PATH_HANGUP_CUSTOM_EVENT];
        }
    }
    [self close:YES];
}

- (void)close{
    [self close:NO];
}

- (BOOL)showAd:(NSString *)filePath url_string:(NSString *)url_string tu:(NSString *)tu {
    cootek_log(@"PrepareThread hangup url= %@",url_string);
    BOOL noTu = NO;
    NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *pattern = REG_PATTERN_COOTEK_AD;
    
    if (string.length>0 && [VoipUtils stringByRegularExpressionWithstring:string pattern:pattern tu:tu]) {
        ifWebHAdShow =YES;
        //[[HangupCommercialManager instance] setAdWebViewControllerAndViewNil];
        adWebViewController = [[HandlerWebViewController alloc] init];
        adWebViewController.webViewCanNotScroll = YES;
        adWebViewController.webViewFullScreen = YES;
        adWebViewController.url_string = url_string;
        [adWebViewController.view setFrame:self.view.bounds];
        adBgView.hidden = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTimer:)];
        [adWebViewController.commonWebView.web_view addGestureRecognizer:tap];
        tap.delegate= self;
        tap.cancelsTouchesInView = NO;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resetTimer:)];
        [adWebViewController.commonWebView.web_view addGestureRecognizer:pan];
        pan.delegate= self;
        pan.cancelsTouchesInView= NO;
        
        
        [self.view addSubview:adWebViewController.view];
        headerView.hidden =NO;
        if (isIPhone5Resolution()) {
            if (_position==1) {
                [self animationWithView:adWebViewController.commonWebView];
            }
        }
        [FunctionUtility saveLogInDebugToDocFile:@"log.txt" withLog:@{@"html":url_string,@"width":@(adWebViewController.view.bounds.size.width)}];
        [_actionView removeFromSuperview];
        [_actionAdView removeFromSuperview];
        _actionAdView = [[HangupActionView alloc] initForAdWebWithModel:[_modelGenerator getMainActionViewModel] frame:CGRectMake(0, TPScreenHeight(), TPScreenWidth(), 60)];
        HangUpAdButton *closeButton = [[_actionAdView  subviews] lastObject];
        if (_position==1 && [HangupCommercialManager instance].adCount>1) {
            [_actionAdView.closeButton setTitle:@"跳过" forState:(UIControlStateNormal)];
        } else {
            [_actionAdView.closeButton setTitle:@"关闭" forState:(UIControlStateNormal)];
        }
        [self.view addSubview:_actionAdView];
        [self.view bringSubviewToFront:_actionAdView];
        [self.view bringSubviewToFront:_actionAdView];
        
        
        
        [self actionAdViewAnimation];
        
        headerView = [[HangupHeaderView alloc] initWithModel:[_modelGenerator getHeaderModel]];

        headerView.center = CGPointMake(TPScreenWidth()/2, headerView.frame.size.height/2);
        [self.view addSubview:headerView];
        [self.view bringSubviewToFront: headerView];
        [UserDefaultsManager setObject:AD_PAGE_NORMAL forKey:LAST_AD_PAGE_TYPE];
    } else {
        [VoipUtils saveNoAdReasonWithKey:@"reason" value:@"no_hangup_tu"];
        noTu = YES;
    }
    return noTu;
}

-(BOOL)addWebViewWithPosition:(BOOL)hangup {
    NSString *callType = _hangupModel.isp2pCall?P2P:C2C;
    NSString *tu = nil;
    BOOL _isBackCall = NO;
    BOOL noTu = NO;
    if ([_modelGenerator isKindOfClass:NSClassFromString(@"HangupViewModelGenerator")]){
        _isBackCall = ((HangupViewModelGenerator *)_modelGenerator).hangupModel.isBackCall;
    }
    NSString *filePath;
    NSString *url_string;
    if (_isBackCall) {
        tu = kAD_TU_BACKCALLHANG;
        filePath = [FileUtils getAbsoluteFilePath:[[Commercial stringByAppendingPathComponent:ADResource] stringByAppendingPathComponent:ADBackCallHTML]];
    } else {
        tu = kAD_TU_HANGUP;
        filePath = [FileUtils getAbsoluteFilePath:[[Commercial stringByAppendingPathComponent:ADResource] stringByAppendingPathComponent:ADDirectCallHTML]];
    }
    
    BOOL extisResouce = NO;
    if (!_hangupModel.prepare && [[HangupCommercialManager instance] checkIfResourceReady]){
        extisResouce = YES;
        url_string = [filePath stringByAppendingFormat:@"?tu=%@&position=%d&call_type=%@&st=%@",
                      tu,_position,callType,_hangupModel.uuid];
    }
    PrepareAdItem *item = [[PrepareAdManager instance] getPrepareAdItem:tu];
    if(hangup) {
        [[AdStatManager instance] commitCommericalStat:tu pst:item.uuid st:_hangupModel.uuid];
    }
    if (!extisResouce) {
        if (item) {
            extisResouce = YES;
            filePath = item.fullHtmlPath;
            url_string = [filePath stringByAppendingFormat:@"?tu=%@&position=%d&call_type=%@&pst=%@",
                          tu,_position,callType,item.uuid];
            [[PrepareAdManager instance] didShowPrepareAd:tu];
        }
    }

    if (extisResouce) {
        noTu = [self showAd:filePath url_string:url_string tu:tu];
        if(!noTu)  {
            return YES;
        }
    }
    
    // for last ad debug stats
    [UserDefaultsManager setObject:@"" forKey:LAST_AD_ID];
    
    NSMutableDictionary *lastCallStats = [[NSMutableDictionary alloc] initWithCapacity:1];
    [lastCallStats setObject:tu forKey:KEY_LAST_AD_TU];
    [lastCallStats setObject:@(noTu) forKey:KEY_LAST_AD_HTML_TU_EMPTY];
    [lastCallStats setObject:@"" forKey:KEY_LAST_AD_ERROR_CODE];
    [AdDebugStatsManager recordLastAdStats:lastCallStats];
    
    [VoipUtils saveNoAdReasonWithKey:@"phone" value:_hangupModel.number];
    ifWebHAdShow = NO;
    return NO;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


-(void)animationWithView:(UIView *)view{
    view.alpha = 0;
    cootek_log(@"animationStart");
        [UIView animateWithDuration:1 delay:0.5 options:(UIViewAnimationOptionLayoutSubviews) animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            cootek_log(@"animationEnd");
        }];
    
}
-(void)actionAdViewAnimation{
    if (_actionAdView.frame.origin.y<TPScreenHeight()) {
        return;
    }
    
    if (_position==1) {
        [UIView animateWithDuration:0.5 delay:0.5 options:(UIViewAnimationOptionLayoutSubviews) animations:^{
            _actionAdView.frame = CGRectMake(0, TPScreenHeight()-60-(20-TPHeaderBarHeightDiff()), TPScreenWidth(), 60);
        } completion:^(BOOL finished) {
            
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONG(_actionAdView);
            if (_position==1 && [HangupCommercialManager instance].adCount>1) {
                [_actionAdView.closeButton setTitle:@"跳过" forState:(UIControlStateNormal)];
            } else {
                [_actionAdView.closeButton setTitle:@"关闭" forState:(UIControlStateNormal)];
            }
        });
    } else{
        _actionAdView.frame = CGRectMake(0, TPScreenHeight()-60-(20-TPHeaderBarHeightDiff()), TPScreenWidth(), 60);
    }
}

-(void)changeProvider {
    [UserDefaultsManager setObject:AD_PAGE_ERROR_CDOE forKey:LAST_AD_PAGE_TYPE];
    [VoipUtils saveNoAdReasonWithKey:@"phone" value:_hangupModel.number];
    ifWebHAdShow = NO;
    [self reomveCommericalWebController];
    _modelGenerator = [[HangupViewModelGenerator alloc]
                       initWithshowBackCallOrFeatureProviderHangupModel:((HangupViewModelGenerator *)_modelGenerator).hangupModel  andDelegate:self];
    
    if (bgView) {
        [self.view bringSubviewToFront:bgView];
    } else {
        UIImage *image = [_modelGenerator getBgImage];

        [bgView removeFromSuperview];
        if (image) {
            bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
            bgView.image = image;
            bgView.userInteractionEnabled = YES;
            [self.view addSubview:bgView];
        } else {
            self.view.backgroundColor = [UIColor colorWithRed:COLOR_IN_256(0xEE) green:COLOR_IN_256(0xEE) blue:COLOR_IN_256(0xEE) alpha:1];
        }
    }
    [headerView removeFromSuperview];
    headerView = [[HangupHeaderView alloc] initWithModel:[_modelGenerator getHeaderModel]];
    
    headerView.center = CGPointMake(TPScreenWidth()/2, headerView.frame.size.height/2);
    [self.view addSubview:headerView];
   
    
    BOOL hasErrorCode = NO;
    if ([_modelGenerator getErrorCode]) {
        
            label = [[UILabel alloc] initWithFrame:CGRectMake(15, headerView.frame.size.height + 10, 50, 30)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor grayColor];
            label.text = [_modelGenerator getErrorCode];
            label.font = [UIFont systemFontOfSize:14];
            [self.view addSubview:label];
            hasErrorCode = YES;
    }else{
        headerView.altLabel.text  = @"";
    }
    
    CGFloat globaly = headerView.frame.size.height;
    [middleView removeFromSuperview];
    MiddleViewModel *middleModel = [_modelGenerator getMiddleModel];
    middleView = [[HangupMiddleView alloc] initWithMiddleModel:middleModel];
    middleView.center = CGPointMake(TPScreenWidth()/2, middleView.frame.size.height/2 + globaly+10);
    [self.view addSubview:middleView];
    globaly += middleView.frame.size.height;
    
    _actionView = nil;
    [_actionView removeFromSuperview];
    CGFloat scale = TPScreenHeight()/667.0;
    UIView *actionView = [[HangupActionView alloc] getActionVieWithModel:[_modelGenerator getMainActionViewModel] frame:CGRectMake(0, TPScreenHeight()-180*scale-(20-TPHeaderBarHeightDiff()), TPScreenWidth(), 180*scale)];
    if (_position==1 && [HangupCommercialManager instance].adCount>1) {
        [_actionAdView.closeButton setTitle:@"跳过" forState:(UIControlStateNormal)];
    } else {
        [_actionAdView.closeButton setTitle:@"关闭" forState:(UIControlStateNormal)];
    }
    [self.view addSubview:actionView];
    [self.view bringSubviewToFront:actionView];
    _actionView = actionView;
    [self.view bringSubviewToFront:headerView];
    _position = 1;
    
    // ad debugging stats
    if (!hasErrorCode) {
        [self statsDefaultAdReason];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:N_WEB_NO_AD object:nil];
}


- (void)autoClose {
    _timeAutoClose = YES;
    [self close:YES];
    [[HangupCommercialManager instance] hangupADDisappearWithCloseType:ADCLOSE_TIMEOUT];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (void)resetTimer:(UIGestureRecognizer *)ges{
    if(([ges isKindOfClass:[UITapGestureRecognizer class]]
       || [ges isKindOfClass:[UIPanGestureRecognizer class]])
        && ges.state == UIGestureRecognizerStateEnded){
        @synchronized (self) {
            [_timer invalidate];
            _timer = nil;
            _timer = [NSTimer scheduledTimerWithTimeInterval:TimePadding target:self selector:@selector(autoClose) userInfo:nil repeats:NO];
        }
        

    }
    
}

- (void)addLinearGradientToView:(UIView *)theView withColor:(UIColor *)theColor
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    //the gradient layer must be positioned at the origin of the view
    CGRect gradientFrame = theView.frame;
    gradientFrame.origin.x = 0;
    gradientFrame.origin.y = 0;
    gradient.frame = gradientFrame;
    
    //build the colors array for the gradient
    NSArray *colors = [NSArray arrayWithObjects:
                       (id)[[theColor colorWithAlphaComponent:0.0f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.3f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.5f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.7f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:0.9f] CGColor],
                       (id)[[theColor colorWithAlphaComponent:1.0f] CGColor],
                       nil];
    //apply the colors and the gradient to the view
    gradient.colors = colors;
    [theView.layer insertSublayer:gradient atIndex:0];
}

- (void)dealloc {
    _position = 1;
    [self reomveCommericalWebController];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_timer invalidate];
    _timer = nil;
}

#pragma mark --- Stats --- 
- (void) statsDefaultAdReason {
    AdDefaultReason reason = -1;
    int adHtmlDownloadStatus = [UserDefaultsManager intValueForKey:AD_WEB_HTML_DOWNLOAD_STATUS defaultValue:-1];
    switch (adHtmlDownloadStatus) {
        case -1: {
            reason = kAdDefaultReasonRequestDownloading;
            break;
        }
        case 0: {
            reason = kAdDefaultReasonRequestFailed;
            break;
        }
        case 1: {
            NSArray *notReadyResource = [[HangupCommercialManager instance] getNotReadyAdResources];
            if (notReadyResource.count == 0) {
                reason = kAdDefaultReasonRequestResourceEmpty;
            }
            break;
        }
        default:
            break;
    }
    [UserDefaultsManager setIntValue:reason forKey:LAST_AD_PAGE_DETAIL];
    [UserDefaultsManager setObject:@"" forKey:LAST_AD_ID];
}

@end
