//
//  CallViewController.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-12.
//
//

#import "CallViewController.h"
#import "TPCallActionController.h"
#import "TimerTickerManager.h"
#import "UserDefaultsManager.h"
#import "VoipTopSectionMiddleView.h"
#import "CallingStateTextView.h"
#import "Reachability.h"
#import "SeattleFeatureExecutor.h"
#import "ContactCacheDataManager.h"
#import "NumberPersonMappingModel.h"
#import "CallerIDModel.h"
#import "TPDialerResourceManager.h"
#import "VoipSimpleButton.h"
#import "FunctionUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "VoipConsts.h"
#import "UIImageCutUtils.h"
#import "TouchpalMembersManager.h"
#import "CootekSystemService.h"
#import "CallingAnimateTextView.h"
#import "TouchpalDialerAppDelegate.h"
#import "CallFeeReminderView.h"
#import "TPShareController.h"
#import "TouchPalVersionInfo.h"
#import "VOIPCall.h"
#import "DialerUsageRecord.h"
#import "NoahManager.h"
#import "CommonWebViewController.h"
#import "VoipCallbackRemindView.h"
#import "DefaultLoginController.h"
#import "LoginController.h"
#import "FunctionUtility.h"
#import "VoipBackCall.h"
#import "VoipSystemCallInteract.h"
#import "CallbackWizardViewController.h"
#import "MagicUltis.h"
#import "DefaultUIAlertViewHandler.h"
#import "TaskBonusManager.h"
#import "NSString+PhoneNumber.h"
#import "VoipUtils.h"
#import "HandlerWebViewController.h"
#import "VoipFeedbackInfo.h"
#import "CallFunctionButtons.h"
#import "SnowGenerator.h"
#import "CallStateDisplay.h"
#import "CallHeaderView.h"
#import "CallProceedingDisplay.h"
#import "VoipShareView.h"
#import "CallKeyboardDisplay.h"
#import "AppSettingsModel.h"
#import "HangupController.h"
#import "TaskBonusManager.h"
#import "CallRingUtil.h"
#import "HangupCommercialManager.h"
#import "CallADViewDisplay.h"
#import "SIPConst.h"
#import <AVFoundation/AVAudioSession.h>
#import "CallInternationalWizardViewController.h"
#import "VoipCallPopUpView.h"
#import "CootekNotifications.h"
#import "ErrorHangupModelGenerator.h"
#import <AVFoundation/AVFoundation.h>
#import "TPAnalyticConstants.h"
#import "UserDefaultKeys.h"
#import "CommonTipsWithBolckView.h"
#import "CommonWebViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "DialerGuideAnimationUtil.h"
#import "HangupViewModelGenerator.h"
#import "HangupHeaderView.h"
#import "NSString+TPHandleNil.h"
#import "TPCallActionController.h"
#import "AdDebugStatsManager.h"
#import "FeedsRedPacketManager.h"
#import "PrepareAdManager.h"
#import "AdStatManager.h"
#import "TPDLib.h"
#import <Masonry.h>

#import "UINavigationController+FDFullscreenPopGesture.h"
#define CLOSE_DELAY (dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)))
#define CLOSE_DELAY_1 (dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)))
#define CLOSE_DELAY_2 (dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)))
#define TIME_OUT_MAX 6

@interface CallViewController () <TimerTickerDelegate,
                                    SystemCallDelegate,
                                    UIGestureRecognizerDelegate,
                                    CallFunctionButtonDelegate,
                                    CallKeyboardDelegate,
                                    HangupCommercialManagerDelegate,
                                    AVAudioPlayerDelegate
                                    >
//@property (copy, nonatomic) NSString *number;
@property (nonatomic,strong) NSArray* numberArr;
@property (nonatomic, retain) ContactCacheDataModel *contact;
@property (nonatomic, retain) CallerIDInfoModel *callerId;
@property (nonatomic, retain) NSString *promotion;
@property (nonatomic, retain) NSDictionary *noahBgDic;
@property (nonatomic, assign) CallMode callMode;
@property (nonatomic, retain) AdMessageModel *ad;
@property (nonatomic, assign) BOOL webViewShow;
@property (nonatomic, assign) BOOL obserAD;
@property (nonatomic, retain) UIView *kebordCoverView;
@property (nonatomic, assign) BOOL backCallHangup;
@property (nonatomic, copy) NSString *requestUuid;
@property (nonatomic, retain) PrepareAdItem *prepare;
@end

@implementation CallViewController {
    OnCallHeaderVeiw *_callHeaderView;
    __strong CallProceedingDisplay *_callProceedingDisplay;
    __strong CallKeyboardDisplay *_callKeyboardDisplay;
    __strong CallADViewDisplay *_callADViewDisplay;
    HandlerWebViewController *adWebViewController;
    
    BOOL _isPal;
    BOOL _enableSpeaker;
    BOOL _mute;
    BOOL _usePrepare;
    BOOL _serverConnected;
    BOOL _isBackCall;
    BOOL _hasLoadCallBackAd;
    BOOL _isCallModeSet;
    BOOL _alreadyGetDefaultCallInfo;
    BOOL _decidedPal;
    BOOL _ringingAccpet;
    BOOL _hasHangup;
    BOOL _userHangup;

    BOOL _isConnected;
    BOOL _isTest;
    BOOL _isSystemCallComing;
    int _errorCode;
    int _errorCompansate;
    BOOL _keyboardShown;
    int _remainingMinutes;
    int _originalMinutes;
    float _scaleRatio;
    int _tick;
    float _ratio;
    int _minuteMinus;
    int _errorHangupStamp;
    NSTimeInterval _startTime;
    __strong CallFunctionButtons *_functionButtonView;
    __strong SnowGenerator *_snowGenerator;
    UIStatusBarStyle _statusStyle;
    BOOL _pressBackCall;
}

static BOOL sIsMakingCall;
static BOOL sIsClosed;
static BOOL sIsNewCall;
static BOOL sIsFunctionButtonPressed;

+ (id)instanceWithNumberArr:(NSArray *)number andCallMode:(CallMode)callMode{
    return [self instanceWithNumberArr:number
                        andCallMode:callMode
                      requestAdUUId:nil];
}

+ (id)instanceWithNumber:(NSString *)number andCallMode:(CallMode)callMode{
   return [self instanceWithNumberArr:@[number]
                       andCallMode:callMode
                     requestAdUUId:nil];
}
 
+ (id)instanceWithNumberArr:(NSArray *)number andCallMode:(CallMode)callMode requestAdUUId:(NSString *)uuid {
    if ([uuid length] == 0) {
        uuid = [[AdStatManager instance] genenrateUUID];
    }
    CallViewController *controller = [[CallViewController alloc] init];
    controller.callMode = callMode;
    NSMutableArray* tmp = [NSMutableArray array];
    for (NSString* num in number) {
        NSString *result = num;
        if(num.length > 0)
        {
            NSRange range = NSMakeRange(0, 2);
            NSString *temp = [num substringWithRange:range];
            Boolean isNigeriaTelPhone = ([temp isEqualToString:@"47"] || [temp isEqualToString:@"48"] || [temp isEqualToString:@"49"]) && (num.length == 11);
            Boolean isNigeriaPhone = [temp isEqualToString:@"41"] && (num.length == 9);
            if(isNigeriaTelPhone || isNigeriaPhone)
            {
                result = [NSString stringWithFormat:@"+23%@",num];
            }
        }
        [tmp addObject:[result mutableCopy]];
    }
    controller.numberArr = tmp;
    controller.requestUuid = uuid;
    [[HangupCommercialManager instance] addADObserver:controller];
    return controller;
}

+ (BOOL)isMakingCall {
    return sIsMakingCall;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.fd_interactivePopDisabled = YES;
    UIImageView *bgView = [[UIImageView alloc] init];
    _snowGenerator = [[SnowGenerator alloc] initWithHolderView:self.view];
    if (_snowGenerator.noahPushBg) {
        bgView.image = _snowGenerator.noahPushBg;
    } else {
        bgView.image = [TPDialerResourceManager getImage:@"outgoing_bg@2x.png"];
    }
    [self.view addSubview:bgView];
    [bgView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // ad view
    _callADViewDisplay = [[CallADViewDisplay alloc] initWithHostView:self.view andDisplayArea:self.view.frame];
    float scaleRatio = WIDTH_ADAPT;
    _scaleRatio = scaleRatio;
    
    CGFloat bottomGap = TPScreenHeight() > 500 ? 20 : (25 - TPHeaderBarHeightDiff());
    _functionButtonView = [[CallFunctionButtons alloc] initWithHostView:self.view andDelegate:self];
    CGSize viewSize = _functionButtonView.size;
    _functionButtonView.frame = CGRectMake(0, TPScreenHeight() - viewSize.height - bottomGap, viewSize.width, viewSize.height);
    
    _statusStyle = [[UIApplication sharedApplication] statusBarStyle];
    
    self.kebordCoverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.kebordCoverView.backgroundColor = [[UIColor alloc] initWithWhite:0.0 alpha:0.85];
    self.kebordCoverView.hidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // header status view
    _callHeaderView = [[OnCallHeaderVeiw alloc] initWithNumberArr:self.numberArr callMode:self.callMode];
    [self.view addSubview:_callHeaderView];
    
    // callProceedingDisplay in the middle
    CGFloat infoHeight = 90 + 15; // you should refer these sizes by CallProceedingDisplay
    if (isIPhone5Resolution()) {
        infoHeight += STATUS_INFO_BOX_HEIGHT;
    } else {
        infoHeight += STATUS_INFO_BOX_HEIGHT_SMALL;
    }
    CGFloat infoContainerHeight = TPScreenHeight() - _functionButtonView.frame.size.height - _callHeaderView.frame.size.height;
    CGRect proceedingFrame = CGRectMake(0, CGRectGetMaxY(_callHeaderView.frame) + (infoContainerHeight - infoHeight ) /2, TPScreenWidth(), infoHeight);
    _callProceedingDisplay = [self getProceedingDisplayByFrame:proceedingFrame callMode:self.callMode];
    
    // for collecting info
    [self recordLastCallInfo];
    
    //
    [self startCall];
    
    //检查是否有feeds挂断后红包
    [FeedsRedPacketManager checkRedPacket];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [[HangupCommercialManager instance] removeADObserver:self];
    [[HangupCommercialManager instance] callingADDisappearWithCloseType:ADCLOSE_SWITCH_WINDOW];
}

-(void)viewWillAppear:(BOOL)animated{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewWillAppear:animated];
    if (_ad) {
        [_callProceedingDisplay hideDisplay];
        [[HangupCommercialManager instance] didShowAD:_ad show:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if(![[HangupCommercialManager instance].observerList containsObject:self]){
        [[HangupCommercialManager instance] addADObserver:self];
    }
    [super viewDidAppear:animated];
}

- (void)hideOtherButKeyboardElement {
    [_callProceedingDisplay hideDisplay];
    [_functionButtonView hideFirstLineFunctionButtons];
}

- (void)showKeyboard {
    [self hideOtherButKeyboardElement];
    if (!_callKeyboardDisplay) {
        _callKeyboardDisplay = [[CallKeyboardDisplay alloc] initWithHolderView:self.view andDelegate:self];
    }
    [_callKeyboardDisplay showDisplay];
}

- (void)hideKeyboard {
    [self showOtherButKeyboardElement];
    [_callKeyboardDisplay hideDisplay];
}

- (void)showOtherButKeyboardElement {
    if(!_webViewShow){
        [_callProceedingDisplay showDisplay];
    }
    [_functionButtonView showFirstLineFunctionButtons];
}

- (void)startCall {
    //data initial
    _enableSpeaker = NO;
    _backCallHangup =NO;
    _mute = NO;
    _remainingMinutes = -1;
    _originalMinutes = -1;
    _isConnected = NO;
    _tick = [PJSIPManager callDuration];
    sIsNewCall = YES;
    sIsClosed = NO;
    _isPal = NO;
    _ratio = 0;
    _decidedPal = NO;
    _ringingAccpet = NO;
    _serverConnected = NO;
    _minuteMinus = 10;
    _isBackCall = NO;
    _alreadyGetDefaultCallInfo = NO;
    _isCallModeSet = NO;
    _hasHangup = NO;
    _userHangup = NO;

    _isSystemCallComing = NO;
    sIsFunctionButtonPressed = NO;
    _errorCode = 0;
    _keyboardShown = NO;
    _errorHangupStamp = 0;
    _startTime = [[NSDate date] timeIntervalSince1970];
   
    
    _isPal = [TouchpalMembersManager isNumberRegistered:self.numberArr[0]];

    self.promotion = nil;
    
    NSString *typeString = [FunctionUtility stringifyReachabilityNetworkType:[Reachability network]];
    [UserDefaultsManager setObject:typeString forKey:LAST_FREE_CALL_NETWORK_TYPE];
    
    [_callProceedingDisplay proceedingWithCallMode:_callMode];
    _functionButtonView.alpha = 0;
    
    [DialerUsageRecord recordpath:EV_VOIP_CALL kvs:Pair(@"count", @(1)), nil];
    //logic runs
    [VoipSystemCallInteract setSystemCallDelegate:self];
    
    if (_callMode == CallModeBackCall) {
        [DialerGuideAnimationUtil shouldReFreshLocalNoah];
        
        
        if (self.numberArr.count > 1) {
            [PJSIPManager confercenceCall:self.numberArr withDelegate:self];
        }else{
            [PJSIPManager call:self.numberArr[0] callback:YES withDelegate:self];
        }
        [self displayCallBackMode];
        [CallRingUtil playBackCallConnectingTone];
        _pressBackCall = NO;
    } else if (_callMode == CallModeOutgoingCall) {
        [DialerGuideAnimationUtil shouldReFreshLocalNoah];
        if (self.numberArr.count > 1) {
            [PJSIPManager confercenceCall:self.numberArr withDelegate:self];
        }else{
            [PJSIPManager call:self.numberArr[0] callback:NO withDelegate:self];
        }
        
        [_functionButtonView setType:Calling];
        [self animateShowFunctionButtons];

        if (!_hasLoadCallBackAd) {
            [self asyncGetAD];
        }
    } else if(_callMode == CallModeTestType) {
        _isTest = YES;
        _isPal = YES;
        [_functionButtonView setType:Test];
        [self animateShowFunctionButtons];
        [self onCallStateInfo:@{ @"balance" :@"100",
                                 @"ratio" : @"0",
                                 @"registered" : @"1",
                                 @"type":@"free"}];
        [self setRinging];
        [self performSelector:@selector(onConnected) withObject:nil afterDelay:6];
        
    } else if (_callMode == CallModeIncomingCall) {
        _isPal = YES;
        _decidedPal = YES;
        _isCallModeSet = YES;
        if ([PJSIPManager isAnswerIncomingCall] > 0) {
            _isConnected = YES;
            [_callProceedingDisplay stopMovingArrow];
            [_functionButtonView setType:Calling];
            [self animateShowFunctionButtons];
        } else {
            [CallRingUtil playIncomingRingTone];
            [_functionButtonView setType:Incoming];
            _functionButtonView.alpha = 1;
        }
        [self asyncGetAD];
    }
    sIsMakingCall = YES;
    [TimerTickerManager startTimerTickerUp:self withTicker:_tick];
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    if (!_obserAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(AdReadyToShowWebInMainThread:)
                                                     name:N_AD_READY_FOR_SHOW
                                                   object:nil];
        _obserAD = YES;
    }
}

- (void)animateShowFunctionButtons{
    [UIView animateWithDuration:1 animations:^{
        _functionButtonView.alpha = 1;
    }];
}

- (void)setRinging {
    if (_isConnected) {
        return;
    }
    [_callProceedingDisplay showRinging];
}

- (void)displayCallBackMode {
    [_functionButtonView setType:BackCalling];
    [UIView animateWithDuration:1 animations:^{
        _functionButtonView.alpha = 1;
    }];
}

- (void)inviteThePerson {
    VoipShareView *voipShareView = [[VoipShareView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    if ([self ifMobileNumber:self.numberArr[0]] )
        voipShareView.msgPhone = self.numberArr[0];
    voipShareView.fromWhere = @"call_view";
    [self.view addSubview:voipShareView];
}

- (BOOL) ifMobileNumber:(NSString *)number{
    NSString *cnNormalNumber = [PhoneNumber getCNnormalNumber:number];
    if ( ([cnNormalNumber length] == 14) &&[cnNormalNumber hasPrefix:@"+861"]){
        return YES;
    }
    return NO;
}

- (void)closeView {
    if (sIsClosed) {
        return;
    }
    if ([self.navigationController topViewController] != self) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
    sIsClosed = YES;
    _obserAD =NO;

}


- (void)dealloc {
    BOOL back = (_callMode == CallModeBackCall) || _isBackCall;
    if (_userHangup && !back) {
       [CallRingUtil audioEnd];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:_statusStyle];
    if (_hasHangup == NO) {
        [self hangupEngine];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    sIsMakingCall = NO;
    [_callProceedingDisplay stop];
}

- (void)doBackCall {
    [self hangupEngine:@"switchcallback"];
    _callMode = CallModeBackCall;
    _pressBackCall = YES;
    _webViewShow = NO;
    _hasLoadCallBackAd = YES;
    [self asyncGetAD];
    [UserDefaultsManager setObject:CALL_TYPE_BACK_CALL forKey:LAST_FREE_CALL_TYPE];

}

#pragma mark Hangups

- (void)hangupPrepare{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_backCallHangup) {
        _backCallHangup =NO;
        [FunctionUtility saveLogInDebugToDocFile:@"log.txt" withLog:@{PATH_CALLBACK_HANGUP_CHECK:@{CALLBACK_HANGU_STATUS:@(3)}}];
        [DialerUsageRecord recordpath:PATH_CALLBACK_HANGUP_CHECK kvs:Pair(CALLBACK_HANGU_STATUS,@(3)), nil];
    }
    _obserAD = NO;
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    [_callProceedingDisplay stop];
    [_snowGenerator stopSnow];
    [self hangupPrepareOnData];
    if (![UserDefaultsManager boolValueForKey:VOIP_CELL_DATA_ACCEPTING_REMIND] && [Reachability network] < network_wifi && _callMode == CallModeIncomingCall) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"是否允许通通宝使用手机流量接听电话，以获得高清免费体验？（可在免费电话设置中更改选项）" message:nil cancelTitle:@"不允许" okTitle:@"允许" okButtonActionBlock:^{
        
        } cancelActionBlock:^{
            [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:NO] forKey:VOIP_ENABLE_CELL_DATA];
        }];
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_CELL_DATA_ACCEPTING_REMIND];
    }
    [DialerUsageRecord recordpath:EV_VOIP_CALL_ERROR kvs:Pair(@"errorCode", @(_errorCode)), nil];
    
    [UserDefaultsManager setObject:@(_tick) forKey:HANGUP_MODEL_TIME];
    [UserDefaultsManager setObject:self.numberArr[0]              forKey:HANGUP_MODEL_NUMBER];
    
    HangupModel *model = [[HangupModel alloc] init];
    model.isPal = _isPal || !_decidedPal;
    model.callDur = _tick;
    model.uuid = self.requestUuid;
    model.prepare = _usePrepare;
    model.errorCode = _errorCode;
    model.isIncomingCall = _callMode == CallModeIncomingCall;
    model.remainMinute = _remainingMinutes;
    model.number = self.numberArr[0];
    model.startTime = _startTime;
    model.errorCompansate = _errorCompansate;
    model.userType = _callProceedingDisplay.userType;
    model.isBackCall = (_callMode == CallModeBackCall) || _isBackCall;
    model.usingNewBackCallMode = (_callMode == CallModeBackCall);
    if (_ad) {
        _ad = nil;
    }
    // when no voip error, try to show the ad directly (without user click)
//    if (![self hasVoipError:model]) {
//        // check whether the last hangup-ad is direct
//        if ([[HangupCommercialManager instance] isDirectAD]) {
//            [[HangupCommercialManager instance] showDirectAD];
//            [FunctionUtility removeFromStackViewController:self];
//            return;
//        }
//    }
//    
//    HangupController *newController = [[HangupController alloc] initWithHanupModel:model];
//    cootek_log(@"CallViewController, errCode: %d", _errorCode);
//    if (_errorCode == 6001) {
//        [DialerUsageRecord recordpath:PATH_VIP kvs:Pair(VIP_DIRECTLY_CALL, @(_errorCode)), nil];
//        [UserDefaultsManager setBoolValue:YES forKey:LAST_FREE_CALL_IS_FORCED_OFFLINE];
//        [self getVoipPrivilegeADDataForController:newController];
//    }
//    
//    [TouchPalDialerAppDelegate naviController].delegate = newController;

    [FunctionUtility removeFromStackViewController:self];
    
//    [[TouchPalDialerAppDelegate naviController] pushViewController:newController animated:NO];
}

- (void) getVoipPrivilegeADDataForController:(UIViewController *) controller {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        NSDictionary *data = [SeattleFeatureExecutor getVoipPrivilegeAdInfoWithOtherNumber:self.numberArr[0] andCallType:CALL_TYPE_C2C];
        HangupCommercialModel *adData = data[kAD_TU_VOIP_PRIVILEGE];
        if (adData) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [[NSNotificationCenter defaultCenter] addObserver:controller selector:@selector(voipPrivilegeADDataReady:) name:N_VOIP_PRIVILEGE_AD_DATA_READY object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:controller selector:@selector(showVoipPrivilegeAD) name:N_VOIP_PRIVILEGE_AD_TO_SHOW object:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:N_VOIP_PRIVILEGE_AD_DATA_READY object:adData];
            });
        }
    });
}

- (void)hangupPrepareOnData {
    if (_remainingMinutes >= 0 && !_isPal) {
        [UserDefaultsManager setIntValue:_remainingMinutes forKey:VOIP_BALANCE];
    }
    sIsNewCall = NO;
    sIsMakingCall = NO;
    [self hangupEngine];
}

- (void)clear {
    _hasHangup = YES;
    [TimerTickerManager setTimerTickerUpStop:self];
    [TimerTickerManager removeDelegate:self];
    [VoipSystemCallInteract setSystemCallDelegate:nil];
}

- (void)hangupEngine {
    [self hangupEngine:HANGUP_TOUCHPAL];
}

- (void)hangupEngine:(NSString *)info {
    [self clear];
    [PJSIPManager hangup:info];

}

- (void)meHangupBeforeAccept {
    NSLog(@"meHangupBeforeAccept");
    [self hangupPrepare];
}

- (void)heHangupBeforeAccept {
    NSLog(@"heHangupBeforeAccept");
    [self hangupPrepare];
}

- (void)hangupAfterAccept {
    NSLog(@"hangupAfterAccept");
    [self hangupPrepare];
}

- (void)errorHangup {
    [self hangupPrepare];
}



#pragma mark CallFunctionButtons Delegate
- (void)onMuteButtonPressed{
    _mute = !_mute;
    [PJSIPManager mute:_mute];
}

- (void)onSpeakerButtonPressed{
    _enableSpeaker = !_enableSpeaker;
    if(_callMode == CallModeTestType){
        if (_enableSpeaker) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        } else {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }
        return;
    }
    
    [PJSIPManager setSpeakerEnabled:_enableSpeaker];
}

- (void)onBackCallButtonPressed {
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [SeattleFeatureExecutor getVoipDealStrategyWithCaller:[UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] callee:self.numberArr[0]];
    });
    NSString *alertInfo= nil;
    NSString *left= nil;
    NSString *right= nil;
    int  deal_strategy_code = [UserDefaultsManager intValueForKey:deal_strategy_number defaultValue:0];
    [_callProceedingDisplay setInfoWhenBackcall];
    
    [_callHeaderView removeFromSuperview];
    _callHeaderView = [[OnCallHeaderVeiw alloc] initWithNumberArr:self.numberArr callMode:CallModeBackCall];
    [self.view addSubview:_callHeaderView];
    
    __block CallViewController *wkSelf = self;
    if (deal_strategy_code>0) {
        switch (deal_strategy_code) {
            case 1:
                if (![TouchpalMembersManager isNumberRegistered:self.numberArr[0]]) {
                    alertInfo = @"对方非触宝好友，使用回拨模式将扣除双倍时长，是否继续？";
                    left = @"取消";
                    right = @"继续";
                }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([MagicUltis instance].getRoaming || ![FunctionUtility isInChina]) {
                        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"当前处于漫游状态。因手机套餐不同，运营商可能会收取漫游费用。继续回拨么？"
                                                                  message:nil
                                                              cancelTitle:@"取消"
                                                                  okTitle:@"继续"
                                                      okButtonActionBlock:^(){
                                                          if (![UserDefaultsManager boolValueForKey:VOIP_CALLBACK_WIZARD_SHOWN]) {
                                                              sIsClosed = YES;
                                                              [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:NO];
                                                              [[TouchPalDialerAppDelegate naviController] pushViewController: [CallbackWizardViewController instanceWithNumberArr:self.numberArr aduuid:self.requestUuid]animated:YES];
                                                              [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLBACK_WIZARD_SHOWN];
                                                              [self hangupEngine:@"switchcallback"];
                                                              return;
                                                          }
                                                          [self doBackCall];
                                                      }];
                        return;
                    }
                    if (![UserDefaultsManager boolValueForKey:VOIP_CALLBACK_WIZARD_SHOWN]) {
                        sIsClosed = YES;
                        [[TouchPalDialerAppDelegate naviController] pushViewController: [CallbackWizardViewController instanceWithNumberArr:self.numberArr aduuid:self.requestUuid] animated:YES];
                        [FunctionUtility removeFromStackViewController:self];
                        [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLBACK_WIZARD_SHOWN];
                        [self hangupEngine:@"switchcallback"];
                    } else {
                        [self doBackCall];
                    }
                    });

                }
                break;
            case 2:
                alertInfo = @"使用回拨模式时，会双倍消耗免费通话时长，是否继续？";
                left = @"取消";
                right = @"继续";
                break;
            case 3:
                alertInfo = @"您当前的网络不适合使用回拨模式，推荐直接使用免费通话";
                left =nil;
                right = @"我知道了";
                break;
            default:
                break;
        }

        if (alertInfo.length>0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CommonTipsWithBolckView *alertView =[[CommonTipsWithBolckView alloc] initWithtitleString:@"触宝提示" lable1String:alertInfo lable1textAlignment:NSTextAlignmentCenter lable2String:nil lable2textAlignment:0 leftString:left rightString:right rightBlock:^{
                    if (left!=nil) {
                        if ([MagicUltis instance].getRoaming || ![FunctionUtility isInChina]) {
                            [DefaultUIAlertViewHandler showAlertViewWithTitle:@"当前处于漫游状态。因手机套餐不同，运营商可能会收取漫游费用。继续回拨么？"
                                                                      message:nil
                                                                  cancelTitle:@"取消"
                                                                      okTitle:@"继续"
                                                          okButtonActionBlock:^(){
                                                              if (![UserDefaultsManager boolValueForKey:VOIP_CALLBACK_WIZARD_SHOWN]) {
                                                                  sIsClosed = YES;
                                                                  [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:NO];
                                                                  [[TouchPalDialerAppDelegate naviController] pushViewController: [CallbackWizardViewController instanceWithNumberArr:self.numberArr aduuid:self.requestUuid]animated:YES];
                                                                  [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLBACK_WIZARD_SHOWN];
                                                                  [wkSelf hangupEngine:@"switchcallback"];
                                                                  return;
                                                              }
                                                              [wkSelf doBackCall];
                                                          }];
                            return;
                        }
                        if (![UserDefaultsManager boolValueForKey:VOIP_CALLBACK_WIZARD_SHOWN]) {
                            sIsClosed = YES;
                            [[TouchPalDialerAppDelegate naviController] pushViewController: [CallbackWizardViewController instanceWithNumberArr:self.numberArr aduuid:self.requestUuid] animated:YES];
                            [FunctionUtility removeFromStackViewController:wkSelf];
                            [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLBACK_WIZARD_SHOWN];
                            [wkSelf hangupEngine:@"switchcallback"];
                        } else {
                            [wkSelf doBackCall];
                        }
                    }
                } leftBlock:^{
                    
                }];
                [DialogUtil showDialogWithContentView:alertView inRootView:nil];
            });
        }
        return;
    }
    if ([MagicUltis instance].getRoaming || ![FunctionUtility isInChina]) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"当前处于漫游状态。因手机套餐不同，运营商可能会收取漫游费用。继续回拨么？"
                                                  message:nil
                                              cancelTitle:@"取消"
                                                  okTitle:@"继续"
                                      okButtonActionBlock:^(){
                                          if (![UserDefaultsManager boolValueForKey:VOIP_CALLBACK_WIZARD_SHOWN]) {
                                              sIsClosed = YES;
                                              [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:NO];
                                              [[TouchPalDialerAppDelegate naviController] pushViewController: [CallbackWizardViewController instanceWithNumberArr:self.numberArr aduuid:self.requestUuid]animated:YES];
                                              [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLBACK_WIZARD_SHOWN];
                                              [self hangupEngine:@"switchcallback"];
                                              return;
                                          }
                                          [self doBackCall];
                                      }];
        return;
    }
    if (![UserDefaultsManager boolValueForKey:VOIP_CALLBACK_WIZARD_SHOWN]) {
        sIsClosed = YES;
        [[TouchPalDialerAppDelegate naviController] pushViewController: [CallbackWizardViewController instanceWithNumberArr:self.numberArr aduuid:self.requestUuid]animated:YES];
        [FunctionUtility removeFromStackViewController:self];
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLBACK_WIZARD_SHOWN];
        [self hangupEngine:@"switchcallback"];
    } else {
        [self doBackCall];
    }
}


- (void)onHangupButtonPressed {
    if (_callMode == CallModeTestType) {
        [CallRingUtil stop];
        [self.navigationController popViewControllerAnimated:YES];
        [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_WAIT];
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:N_JUMP_TO_REGISTER_INDEX_PAGE object:@"1" userInfo:@{@"show":@"testFreeCall_View"}];
        _isTest = NO;
        return;
    }
    if (_hasHangup) {
        return;
    }
    _userHangup = YES;
    if (_isConnected) {
        [self hangupAfterAccept];
    } else {
        [self meHangupBeforeAccept];
    }
   
    [[HangupCommercialManager instance] callingADDisappearWithCloseType:ADCLOSE_BUTTEN_CLOSE];

}

- (void)onShareButtonPressed {
    sIsFunctionButtonPressed = YES;
}

- (void)onCloseButtonPressed {
    NSLog(@"onCloseButtonPressed ...");
    [_callProceedingDisplay stop]; // stop the animation if possible
    [self closeView];
    [PJSIPManager setCallStateDelegate:nil];
    [self clear];
    [[HangupCommercialManager instance] callingADDisappearWithCloseType:ADCLOSE_BUTTEN_CLOSE];
    [self performSelector:@selector(notifyOtherAudioDevice) withObject:nil afterDelay:20];    

    
}

- (void)notifyOtherAudioDevice {
    [CallRingUtil audioEnd];
}

- (void)onAccpetButtonPressed {
    [CallRingUtil stop];
    [PJSIPManager acceptIncomingCall];
    [self onConnected];
    [_functionButtonView setType:Calling];
    [self animateShowFunctionButtons];
}

- (void)onKeyButtonPressed {
    _keyboardShown = !_keyboardShown;
    if (_keyboardShown) {
        [self showKeyboard];
        _kebordCoverView.hidden = NO;
        [self.view insertSubview:_kebordCoverView belowSubview:_functionButtonView];
    } else {
        [self hideKeyboard];
        _kebordCoverView.hidden = YES;
    }
}

#pragma mark CallStateChangeDelegate
- (void)notifyEdgeNotStable {
}

- (void)onServerConnected {
    if (_callMode == CallModeIncomingCall) {
        return;
    }
    if (_serverConnected) {
        [_callProceedingDisplay showQueryTouchPal];
        return;
    }
    _serverConnected = YES;
    [_callProceedingDisplay showQueryTouchPal];
}

- (void)onCallStateInfo:(NSDictionary *)dic {
    if (_callMode == CallModeIncomingCall ) {
        if (dic == nil) {
            return;
        }
        NSString *registered = [dic objectForKey:@"registered"];
        if ([registered length] > 0) {
            _decidedPal = YES;
        }
        _isPal = [registered boolValue];
        BOOL isActive = [@"1" isEqualToString:[dic objectForKey:@"isActive"]];
        NSInteger callType = [[TPCallActionController controller] getCallNumberTypeCustion:self.numberArr[0]];
        [_callProceedingDisplay showQueryResultIsPalOrNot:_isPal isActive:isActive callType:callType];
        return;
    }
    [self onServerConnected];
    if (dic == nil) {
        return;
    }
    if (_alreadyGetDefaultCallInfo) {
        return;
    }
    NSString *ratio = [dic objectForKey:@"ratio"];
    if ([ratio length] > 0) {
        _ratio = [ratio floatValue];
        _alreadyGetDefaultCallInfo = YES;
    }
    NSString *balanceString = [dic objectForKey:@"balance"];
    _originalMinutes = [balanceString longLongValue]/60;
    if ([balanceString length] == 0) {
        _originalMinutes = -1;
    }
    if (_originalMinutes > 0) {
        _remainingMinutes = _originalMinutes;
    }
    _callProceedingDisplay.originalMinute = _originalMinutes;
    self.promotion = [dic objectForKey:@"promotion"];
    NSString *registered = [dic objectForKey:@"registered"];
    if ([registered length] > 0) {
        _decidedPal = YES;
    }
    _isPal = [registered boolValue];

    BOOL isActive = [@"1" isEqualToString:[dic objectForKey:@"isActive"]];
    NSInteger callType = [[TPCallActionController controller] getCallNumberTypeCustion:self.numberArr[0]];
    
    if (_callMode == CallModeTestType) {
        [_callProceedingDisplay showQueryResultIsPalOrNot:YES isActive:YES callType:-1];
    } else {
        [_callProceedingDisplay showQueryResultIsPalOrNot:_isPal isActive:isActive callType:callType];
    }
    
    [TouchpalMembersManager insertNumber:self.numberArr[0] andIfCootekUser:_isPal andIfRefreshNow:YES];
    if (!_isCallModeSet) {
        if (_callMode == CallModeBackCall){
            [self onCallModeSet:@"back"];
        } else {
            [self animateShowFunctionButtons];
        }
    }
    if (_isBackCall) {
        [_callProceedingDisplay showBackCallDecided];
    }
}

- (void)onConnected {
    if (_callMode==CallModeTestType && _isTest == NO) {
        return;
    }
    if (_isConnected) {
        return;
    }
    if ([[AppSettingsModel appSettings ] vibrate_when_connected]) {
       [CootekSystemService playVibrate];  
    }
   
    [DialerUsageRecord recordpath:EV_VOIP_CALL_SUCCESS kvs:Pair(@"isIncoming", @(_callMode == CallModeIncomingCall)), Pair(@"isBackCall",@(_isBackCall)), nil];
    _isConnected = YES;
    if ([UserDefaultsManager boolValueForKey:VOIP_IF_PRIVILEGA defaultValue:NO]){
        [_callProceedingDisplay ifShowFreeCallPrivilegaMessage];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_isPal || !_decidedPal) {
                [_callProceedingDisplay showFreeCallShouldHighlight:YES];
            } else {
                [_callProceedingDisplay showRemainingMinutes:_remainingMinutes];
            }
            if (_isTest) {
                [CallRingUtil  playTestFreeCallWithDelegate:self];
            }
        });
    }else{
        if (_isPal || !_decidedPal) {
            [_callProceedingDisplay showFreeCallShouldHighlight:YES];
        } else {
            [_callProceedingDisplay showRemainingMinutes:_remainingMinutes];
        }
        if (_isTest) {
            [CallRingUtil  playTestFreeCallWithDelegate:self];
        }
    }
    
    [_callProceedingDisplay stopMovingArrow];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (_callMode ==CallModeTestType && flag) {
        player.delegate = nil;
        [self playOverAutoHangup];
    }
}

-(void)playOverAutoHangup{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self onHangupButtonPressed];
    });
    
}
- (void)onRinging {
    if (_callMode == CallModeIncomingCall) {
        return;
    }
    [self onServerConnected];
    if (_ringingAccpet) {
        return;
    }
    _ringingAccpet = YES;
    if (!_decidedPal) {
        [_callProceedingDisplay showPalNotDecide];
    }
    [self setRinging];
    if (_webViewShow) {
        _callHeaderView.altLabel.text = @"正在呼叫";
    }
}

- (void)onSwitchingToC2P {
    [self onServerConnected];

    [UserDefaultsManager setObject:CALL_TYPE_C2P forKey:LAST_FREE_CALL_TYPE];
}

- (void)onDisconected {
    if (_hasHangup || _callMode == CallModeBackCall) {
        if (_pressBackCall) {
            [self startCall];
        } 
        return;
    }
    if (_isConnected) {
        [self hangupAfterAccept];
    } else{
        [self heHangupBeforeAccept];
    }
    [CootekSystemService playVibrate];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (3 * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^(){
        [CallRingUtil audioEnd];
    });
}

- (void)onCallModeSet:(NSString *)callMode {
    if (_isCallModeSet) {
        return;
    }
    [self onServerConnected];
    if ([callMode isEqualToString:VOIP_CALL_BACK]) {
        _isBackCall = YES;
        if (_callMode != CallModeBackCall) {
            // 被服务器告知，进入回拨模式
            _callMode = CallModeBackCall;
            [_callProceedingDisplay setInfoWhenBackcall];
            [self displayCallBackMode];
        }
    }
    _callProceedingDisplay.isBackCall = _isBackCall;
    _isCallModeSet = YES;
}

- (void)onCallErrorWithCode:(int)errorCode{
    _errorCode = errorCode;
    if (errorCode < BUSY_EVERYWHERE && errorCode != DECLINED) {
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_SHOULD_GUIDE_BACK_CALL];
    }
    if (errorCode == BUSY_EVERYWHERE) {
        [CallRingUtil playBusyHere];
        [self performSelector:@selector(errorOccur:)
                   withObject:@(errorCode)
                   afterDelay:4];
    } else {
        [self errorOccur:errorCode];
    }
}

- (void)errorOccur:(int)errorCode {
    if ((errorCode < BUSY_EVERYWHERE || errorCode == SERVICE_UNAVAILIABLE) && [self isTimeMeet]) {
        _errorHangupStamp = 1;
        TaskBonusManager *manager = [[TaskBonusManager alloc] init];
        [manager getTaskBonus:ERROR_HANGUP_PAY withSuccessBlock:^(int bonus, TaskBonusResultInfo *info) {
            _errorCompansate = bonus/60;
            [self checkSetDate:info];
            [self afterErrorCompasateAsk];
        } withFailedBlock:^(int resultCode, TaskBonusResultInfo *info) {
            [self checkSetDate:info];
            [self afterErrorCompasateAsk];
        } localJudgeTodayFinish:NO];
    } else {
        [self afterErrorCompasateAsk];
    }
}

- (BOOL)isTimeMeet {
    NSDate *date = [UserDefaultsManager dateForKey:ERROR_HANGUP_COMPSATE_SUCCESS_DATE];
    if (date == nil) {
        return YES;
    }
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *compLast = [calendar components:NSCalendarUnitDay fromDate:date];
    NSDateComponents *compNow = [calendar components:NSCalendarUnitDay fromDate:nowDate];
    BOOL isMeet = compNow.day > compLast.day;
    return isMeet;
}

- (void)checkSetDate:(TaskBonusResultInfo *)info {
    if (info.todayFinish || info.finish) {
        [UserDefaultsManager setObject:[NSDate date] forKey:ERROR_HANGUP_COMPSATE_SUCCESS_DATE];
    }
}


- (void)afterErrorCompasateAsk{
    _errorHangupStamp = 0;
    if (_hasHangup) {
        return;
    }
    if (_errorCode == SERVER_MAITAIN){
        HandlerWebViewController *controller = [[HandlerWebViewController alloc] init];
        controller.url_string = @"http://www.chubao.cn/s/voip_503/503.html";
        controller.header_title = @"服务器维护中";
        UINavigationController *naviController = ((TouchPalDialerAppDelegate *)[UIApplication sharedApplication].delegate).activeNavigationController;
        [naviController pushViewController:controller animated:YES];
        [FunctionUtility removeFromStackViewController:self];
        return;
    }
    if (_errorCode == BUSY_EVERYWHERE || _errorCode == DECLINE
        || _errorCode == DECLINED_LONGER || _errorCode == FLOW_FAILED
        || _errorCode == SYSTEM_CALL_INCOMING) {
        [CootekSystemService playVibrate];
        [self performSelector:@selector(notifyOtherAudioDevice) withObject:nil afterDelay:3];
    }else if (_errorCode < UNKNOWN_ERROR|| _errorCode ==ERR_REASON_COUNTRY_OFFLINE ||
            _errorCode ==  ERR_REASON_COUNTRY_UNSUPPORT ) {
        [CallRingUtil playDuTone];
        [self performSelector:@selector(notifyOtherAudioDevice) withObject:nil afterDelay:3];
    }
    [self errorHangup];

}

#pragma mark TimerDriveFunctions
-(void) onTimerStop{
}

-(void) onTimerTicker:(NSInteger) ticker{
    if (_isConnected && ticker % 10 == 0) {
        if (_webViewShow) {
            _callHeaderView.altLabel.text = [CallProceedingDisplay translateTickerToTime:_tick];
        } else {
            [_callProceedingDisplay showTicker:_tick];
        }
        
        if (!_isPal && _decidedPal && _tick == _minuteMinus) {
            if (_ratio < 0) {
                if ([[TPCallActionController alloc] getCallNumberTypeCustion:self.numberArr[0]]==VOIP_OVERSEA) {
                    //拨打海外用户时不显示扣费
                    _ratio = 0;
                }
                _remainingMinutes += _ratio*1;
                if (_remainingMinutes < 0) {
                    _remainingMinutes = 0;
                }
                [_callProceedingDisplay showRemainingMinutes:_remainingMinutes];
            }
            _minuteMinus+=60;
        }
        if (_tick > 0 && _tick % 3 ==0) {
            [self exchangeStateDisplay];
        }
        _tick++;
    }
    
    if (ticker % 5 == 0) {
        [_callProceedingDisplay animateIndicator];
    }
    if (ticker % 20 == 0) {
        [_snowGenerator startSnow];
    }

    if (_errorHangupStamp > 0) {
        _errorHangupStamp++;
        if (_errorHangupStamp == 20) {
            [self afterErrorCompasateAsk];
        }
    }
}



- (void)exchangeStateDisplay {
    [_callProceedingDisplay checkExchangeDisplayPromotionWithRemainingMinu:_remainingMinutes];
}


#pragma mark SystemCallDelegate
- (void)onSysHangupCall {
    [FunctionUtility saveLogInDebugToDocFile:@"log.txt" withLog:@{PATH_CALLBACK_HANGUP_CHECK:@{CALLBACK_HANGU_STATUS:@(1)}}];
    [DialerUsageRecord recordpath:PATH_CALLBACK_HANGUP_CHECK kvs:Pair(CALLBACK_HANGU_STATUS,@(1)), nil];
    if (_isBackCall) {
        _backCallHangup = YES;
        [FunctionUtility saveLogInDebugToDocFile:@"log.txt" withLog:@{PATH_CALLBACK_HANGUP_CHECK:@{CALLBACK_HANGU_STATUS:@(2)}}];
        [DialerUsageRecord recordpath:PATH_CALLBACK_HANGUP_CHECK kvs:Pair(CALLBACK_HANGU_STATUS,@(2)), nil];
        [self onHangupButtonPressed];
    }
}

- (void)onSysIncomingCall {
    if (_isBackCall) {
        _ringingAccpet = YES;
        _isSystemCallComing = YES;
        [_callProceedingDisplay showBackCall];
        [PJSIPManager setCallStateDelegate:nil];
    }
}

- (void)onSystemCallConnected {
    [DialerUsageRecord recordpath:EV_VOIP_CALL_SUCCESS kvs:Pair(@"isIncoming", @(_callMode == CallModeIncomingCall)), Pair(@"isBackCall",@(_isBackCall)), nil];
}

- (void)onBackCallInfo:(NSDictionary *)callInfo {
    [self onCallStateInfo:callInfo];
}

#pragma mark CallKeyboardDelegate
- (void)onKeyPressed:(NSString *)key {
    if (_isBackCall) {
        return;
    }
    [PJSIPManager sendDTMF:key];
}
#pragma mark HangupCommercialManagerDelegate
- (void)callingCommercialDataDidLoad:(AdMessageModel *)ad image:(UIImage *)image {
        _ad = ad;
        if(_ad){
            [[HangupCommercialManager instance] didShowAD:ad show:YES];
        }
}

-(void)AdReadyToShowWebInMainThread:(NSNotification *)noti{
    NSString *tu = noti.userInfo[@"tu"];
    cootek_log(@"Prepare",@"AdReadyToShowWebInMainThread = %@",tu);
    if (!_obserAD) {
        return;
    }
    if (![tu isEqualToString:kAD_TU_HANGUP] && ![tu isEqualToString:kAD_TU_BACKCALLHANG]) {
        return;
    }
    
    NSTimeInterval adReadyTime = [noti.userInfo[WEB_AD_READY_NOTI_TIME] doubleValue];
    if (adReadyTime > 0
        && adReadyTime < [HangupCommercialManager instance].lastWebAdRequestTime) {
        // 某次下载完成了，但此时对应的展现时机已经错过了，应该忽略这个通知。
        return;
    }
    cootek_log(@"Prepare","showWebView = %d",_webViewShow);
    if (_webViewShow ==YES) {
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


- (BOOL)showAd:(NSString *)filePath url_string:(NSString *)url_string tu:(NSString *)tu
{
    BOOL isHtmlTuEmpty = NO;
    NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *pattern = REG_PATTERN_COOTEK_AD;

    if (string.length>0 && [VoipUtils stringByRegularExpressionWithstring:string pattern:pattern tu:tu]) {
        cootek_log(@"PrepareThread calling url= %@",url_string);
        if (adWebViewController == nil) {
            adWebViewController = [[HandlerWebViewController alloc] init];
        }
        adWebViewController.ifLight = YES;
        adWebViewController.webViewFullScreen = YES;
        adWebViewController.webViewCanNotScroll = YES;
        adWebViewController.url_string = url_string;
        
        [adWebViewController.view setFrame:self.view.bounds];
        adWebViewController.view.alpha = 0;
        if (isIPhone5Resolution()) {
            [self animationWithView:adWebViewController.view];
        }else{
            adWebViewController.view.alpha = 1;
            if (_callMode == CallModeOutgoingCall
                || _callMode == CallModeBackCall) {
                if (!_isConnected) {
                    _callHeaderView.altLabel.text = @"正在呼叫";
                }
            }
        }
        _webViewShow = YES;
        [self.view addSubview:adWebViewController.view];
        [self.view bringSubviewToFront:_callHeaderView];
        [self.view bringSubviewToFront:_functionButtonView];
        [_callProceedingDisplay hideDisplay];
        [UserDefaultsManager setObject:AD_PAGE_NORMAL forKey:LAST_AD_PAGE_TYPE];
    } else {
        _webViewShow = NO;
        isHtmlTuEmpty = YES;
    }
    return isHtmlTuEmpty;
}

-(void)showWebView
{
    cootek_log(@"PrepareThread, show calling webview...");
    _webViewShow = NO;
    NSString *tu = nil;
    if (_isBackCall|| _callMode == CallModeBackCall) {
        tu = kAD_TU_BACKCALL;
    } else {
        tu = kAD_TU_CALLING;
    }
    NSString *filePath = nil;
    _usePrepare = NO;
    BOOL isHtmlTuEmpty = YES;
    BOOL canLoadAd = NO;
    NSString *url_string;
    if([[HangupCommercialManager instance] checkIfResourceReady]){
        canLoadAd = YES;
        if ([tu isEqualToString:kAD_TU_BACKCALL]) {
            filePath = [FileUtils getAbsoluteFilePath:[[Commercial stringByAppendingPathComponent:ADResource]
                                                       stringByAppendingPathComponent:ADBackCallHTML]];
        } else if ([tu isEqualToString:kAD_TU_CALLING]) {
            filePath = [FileUtils getAbsoluteFilePath:[[Commercial stringByAppendingPathComponent:ADResource]
                                                       stringByAppendingPathComponent:ADDirectCallHTML]];
        }
        url_string = [filePath stringByAppendingFormat:@"?tu=%@&st=%@",
                      tu,self.requestUuid];
    }
    if (!canLoadAd && self.prepare) {
        if (self.prepare) {
            canLoadAd = YES;
            _usePrepare = YES;
            filePath = self.prepare.fullHtmlPath;
            url_string = [filePath stringByAppendingFormat:@"?tu=%@&pst=%@",
                          tu,self.prepare.uuid];
        }
    }
 
    if (canLoadAd) {
        isHtmlTuEmpty = [self showAd:filePath url_string:url_string tu:tu];
    }
  
    if(isHtmlTuEmpty) {
        // for last ad stats
        NSMutableDictionary *lastAdStats = [[NSMutableDictionary alloc] initWithCapacity:1];
        [lastAdStats setObject:@(isHtmlTuEmpty) forKey:KEY_LAST_AD_HTML_TU_EMPTY];
        [lastAdStats setObject:tu forKey:KEY_LAST_AD_TU];
        [lastAdStats setObject:@"" forKey:KEY_LAST_AD_ERROR_CODE];
        [AdDebugStatsManager recordLastAdStats:lastAdStats];
    }
}

-(void)animationWithView:(UIView *)view{
    view.alpha = 0;
    [UIView animateWithDuration:1.5 delay:1 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
        view.alpha = 1;
    }completion:nil];
    if (_callMode == CallModeOutgoingCall
        || _callMode == CallModeBackCall) {
        if (!_isConnected) {
            _callHeaderView.altLabel.text = @"正在呼叫";
        }
    }
}

- (BOOL) hasVoipError: (HangupModel *) model {
    HangupViewModelGenerator *hangupModelGenerator = [[HangupViewModelGenerator alloc]initTocheckVoipErrorWithHangupModel:model];
    if([[hangupModelGenerator getModelGenerator] isKindOfClass:[ErrorHangupModelGenerator class]]) {
        return YES;
    }
    return NO;
}

#pragma mark helper
- (CallProceedingDisplay *)getProceedingDisplayByFrame:(CGRect)frame callMode:(CallMode)callMode {
    //
    NSMutableArray* normalizedNumberArr = [NSMutableArray array];
    for (NSString* num in self.numberArr) {
        if (callMode != CallModeTestType
            && ![num hasPrefix:@"+86"]) {
            [normalizedNumberArr addObject:[PhoneNumber getCNnormalNumber:num]];
        }else{
            [normalizedNumberArr addObject:num];
        }
    }
    
    return [[CallProceedingDisplay alloc] initWithHostView:self.view
                                     andDisplayArea:frame
                                           callMode:callMode
                                   otherPhoneNumberArr:normalizedNumberArr];
}

- (void)asyncGetAD {
    if (_userHangup || [self.numberArr[0] length] ==0 || [self.requestUuid length] == 0) {
        return;
    }
    _webViewShow = NO;
    NSString *tu;
    NSString *tuCalling;
    if (self.callMode == CallModeBackCall) {
        tu = kAD_TU_BACKCALLHANG;
        tuCalling = kAD_TU_BACKCALL;
    } else {
        tu = kAD_TU_HANGUP;
        tuCalling = kAD_TU_CALLING;
    }
   
    [self performSelector:@selector(requestTimeout:) withObject:tu afterDelay:TIME_OUT_MAX];
    self.prepare = [[PrepareAdManager instance] getPrepareAdItem:tu];
    [[AdStatManager instance] commitCommericalStat:tuCalling pst:self.prepare.uuid st:self.requestUuid];
    [[HangupCommercialManager instance] asyncAskCommercialWithCallingNumber:[PhoneNumber getCNnormalNumber:self.numberArr[0]]
                                                                andCallType:CALL_TYPE_C2C
                                                                         tu:tu
                                                                       uuid:self.requestUuid];
    
}

- (void)requestTimeout:(NSString *)tu {
    if([UserDefaultsManager intValueForKey:AD_WEB_HTML_DOWNLOAD_STATUS] != 1) {
        cootek_log(@"PrepareThread, requestTimeout...load prepare");
        _obserAD = NO;
        [self showWebView];
    }
}

#pragma mark -- recording data --
- (void) recordLastCallInfo {
    // collect debug info
    NSString *callerNumber = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:@""];
    [UserDefaultsManager setObject:callerNumber forKey:LAST_FREE_CALL_CALLER_NUMBER];
    [UserDefaultsManager setObject:self.numberArr[0] forKey:LAST_FREE_CALL_CALLEE_NUMBER];
    [UserDefaultsManager setObject:CALL_TYPE_C2C forKey:LAST_FREE_CALL_TYPE];
}

@end


