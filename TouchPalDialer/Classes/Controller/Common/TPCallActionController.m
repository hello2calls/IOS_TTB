//
//  TPCallActionController.m
//  TouchPalDialer
//
//  Created by Chen Lu on 12/5/12.
//
//

#import "TPCallActionController.h"
#import "TouchPalDialerAppDelegate.h"
#import "CallLog.h"
#import "DialResultModel.h"
#import "SyncContactWhenAppEnterForground.h"
#import "NumberPersonMappingModel.h"
#import "CootekNotifications.h"
#import "PhoneNumber.h"
#import "RuleModel.h"
#import "TPAddressBookWrapper.h"
#import "TestSupport.h"
#import "PhonePadModel.h"
#import "TPDLib.h"
#import "UINavigationController+TP.h"
#import "DefaultUIAlertViewHandler.h"
#import "SmartDailerSettingModel.h"
#import "UserDefaultsManager.h"
#import "IPExcudeNumberModelManager.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <AudioToolbox/AudioServices.h>
#import "NSString+PhoneNumber.h"
#import "PJSIPManager.h"
#import "VOIPCall.h"
#import "UserDefaultsManager.h"
#import "VoipCallPopUpView.h"
#import "ContactCacheDataManager.h"
#import "TouchpalNumbersDBA.h"
#import "TouchPalDialerAppDelegate.h"
#import "VoipFirstCallView.h"
#import "NotificationScheduler.h"
#import "PhoneNumber.h"
#import "VoipShareAllView.h"
#import "FreeCallLoginController.h"
#import "LoginController.h"
#import "TaskBonusManager.h"
#import "FunctionUtility.h"
#import "CallCommercialManager.h"
#import "TouchLifeShareMgr.h"
#import "DialerGuideAnimationUtil.h"
#import "HangupCommercialManager.h"
#import "HangupController.h"
#import "DialerUsageRecord.h"
#import "TouchPalDialerLaunch.h"
#import "TurnToneTips.h"
#import "CootekSystemService.h"
#import "CommonTipsWithBolckView.h"
#import "MarketLoginController.h"
#import "DialerViewController.h"
#import "TPAnalyticConstants.h"
#import "VoipUtils.h"
#import "AdStatManager.h"
#import "TPDVoipCallPopUpViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "TouchPalDialerAppDelegate+RDVTabBar.h"
#import "PrepareAdManager.h"
#import "PJSIPManager.h"
#import "TouchPalDialerAppDelegate.h"

#define ALERTVIEW_TAG_FOR_COOTEK_POPUP_SHEET 100

static TPCallActionController *instance_ = nil;
static BOOL isVOIPCall_;
static NSString *sSource;
@interface TPCallActionController () <VoipCallPopUpViewDelegate,VoipFirstCallViewDelegate> {
    int personIdThatIsGoingToBeCalled_;
    void(^willAppearPopupSheet_)();
    void(^willDisappearPopupSheet_)();
    BOOL isGestureCall_;
    UINavigationController *_defaultNaviController;
    VoipCallPopUpView *_popUpView;
    BOOL voipPass;
    BOOL _directVoipCall;
    double _connetedTime;
}
@property (nonatomic, retain) CTCallCenter *callCenter;
@property (nonatomic, copy) NSString *callStatus;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic,copy) CallLogDataModel *callLog;
@property (nonatomic,retain) NSString *phoneNumebrGoingToBeCalled;
@property (nonatomic, assign) BOOL callFromOurApp;
@property (nonatomic, assign) BOOL callFromOurAppForGuide;
@property (nonatomic, copy) NSString *adUUID;

- (void)makeCall:(CallLogDataModel *)phone withIpNumber:(NSString *)ipNumber;
- (NSString *)cleanPhoneNumber:(NSString *)phoneNumber;
- (void)releasePopupSheetBlock;
@end

@implementation TPCallActionController
@synthesize callLog = callLog_;
@synthesize phoneNumebrGoingToBeCalled = phoneNumebrGoingToBeCalled_;
@synthesize callCenter;
@synthesize callStatus;
@synthesize bgTask;



#pragma mark singleton lifecycle
+ (TPCallActionController *)controller
{
    return instance_;
}

+ (void)initialize
{
    instance_ = [[self alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initializeCallCenter];
        _defaultNaviController = [TouchPalDialerAppDelegate naviController];
    }
    return self;
}

- (void)makeCall:(CallLogDataModel *)phone
          appear:(void(^)())willAppearPopupSheet
       disappear:(void(^)())willDisappearPopupSheet
{
    willAppearPopupSheet_ = [willAppearPopupSheet copy];
    willDisappearPopupSheet_ = [willDisappearPopupSheet copy];
    self.callLog=phone;
    [self makeCall:phone];
}

- (void)makeGestureCall:(CallLogDataModel *)phone
{
    [self makeCallInternal:phone isGestureCall:YES];
}

- (void)makeCall:(CallLogDataModel *)phone
{
    [self makeCallInternal:phone isGestureCall:NO];
}

- (void)makeCallInternal:(CallLogDataModel *)phone
           isGestureCall:(BOOL)isGestureCall
{
    if (phone.callType ==CallLogTestType) {
        [self checkTestVoipCall:phone];
        return;
    }
    
    if([TestSupport isTestCommand:phone.number]) {
        [TestSupport executeTestCommand:phone.number];
        return;
    }
    isVOIPCall_ = NO;
    self.callLog = phone;
    isGestureCall_ = isGestureCall;
    NSInteger ifShowFirstCallView = -1;
    if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN] ||![UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        if ([self getCallNumberTypeCustion:callLog_.number] == VOIP_ENABLE) {
            if (![UserDefaultsManager boolValueForKey:have_click_vs_no_free]&&![UserDefaultsManager boolValueForKey:VOIP_FIRST_CALL     defaultValue:NO]) {
                ifShowFirstCallView = 0;
                }
        }else if([self getCallNumberTypeCustion:callLog_.number]== VOIP_OVERSEA && ![UserDefaultsManager boolValueForKey:VOIP_FIRST_INTERNATIONAL_CALL defaultValue:NO]){
            if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
                ifShowFirstCallView = 1;
                [UserDefaultsManager setBoolValue:YES forKey:VOIP_FIRST_INTERNATIONAL_CALL];
            }
        }
    }
    if (ifShowFirstCallView>=0) {
        [DialerUsageRecord recordpath:PATH_INAPP_TESTFREECALL_GUDIE kvs:Pair(KEY_ACTION , BEFORECALL_SHOW), nil];
        VoipFirstCallView *firstCallView = [[VoipFirstCallView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) ifOversea:[self getCallNumberTypeCustion:callLog_.number]== VOIP_OVERSEA];
        firstCallView.delegate = self;
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            [[UIView tpd_topWindow] addSubview:firstCallView];
        } else {
            [_defaultNaviController.topViewController.view addSubview:firstCallView];
        }

        
        return;
    }

    [self checkOverSea:phone];
}

- (void)checkOverSea:(CallLogDataModel *)phone{
    if ([FunctionUtility isInChina]) {
        [self prepareCallCommercial:phone];
        return;
    }
    if ([phone.number hasPrefix:@"+"]) {
        [self prepareCallCommercial:phone];
        return;
    }
    NSString *ipPrefixs = @"^(12593|179\\d\\d|10193|11808)\\d*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipPrefixs];
    if ([predicate evaluateWithObject:phone.number]) {
        [self prepareCallCommercial:phone];
        return;
    }
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"您拨打的是一个国内号码吗?" message:nil cancelTitle:@"否" okTitle:@"是" okButtonActionBlock:^{
            [self prepareCallCommercial:phone];
        } cancelActionBlock:^{
            [self makeCallAfterVoipChoice:phone isGestureCall:isGestureCall_];
        }];
        return;
    }
    if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN] && ![UserDefaultsManager boolValueForKey:VOIP_CALL_OVERSEA_REMIND]) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"您拨打的是一个国内号码吗?" message:nil cancelTitle:@"否" okTitle:@"是" okButtonActionBlock:^{
            [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALL_OVERSEA_REMIND];
            [self alertUserTurnOnVoip:phone];
            } cancelActionBlock:^{
            [self makeCallAfterVoipChoice:phone isGestureCall:isGestureCall_];
        }];
        return;
    }
    [self makeCallAfterVoipChoice:phone isGestureCall:isGestureCall_];
}

- (void)alertUserTurnOnVoip:(CallLogDataModel *)phone{
    [DefaultUIAlertViewHandler showAlertViewWithTitle:@"打回国很贵哦！要开启免费电话吗？" message:nil cancelTitle:@"不要" okTitle:@"要" okButtonActionBlock:^{
        [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:YES] forKey:IS_VOIP_ON];
        [VOIPCall makeCall:phone.number];
    } cancelActionBlock:^{
        [self makeCallAfterVoipChoice:phone isGestureCall:isGestureCall_];
    }];
}

- (void)prepareCallCommercial:(CallLogDataModel *)phone{
    [[CallCommercialManager instance] prepareCommercialFor:phone.number withBlock:^{
        [self checkVoipCall:phone];
    }];
}

- (void)checkVoipCall:(CallLogDataModel *)phone {
    BOOL isVoipOn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]
    && [UserDefaultsManager boolValueForKey:IS_VOIP_ON];
//    NSString *correspondingServiceNum = [self isServiceNumber:callLog_.number];
    voipPass = NO;
    NSInteger type = VOIP_PASS;
    if (isVoipOn) {
//        if (correspondingServiceNum == nil) {
//            type = [self getCallNumberTypeCustion:callLog_.number];
//            if(type == VOIP_OVERSEA){
//                type = VOIP_ENABLE;
//            }
//            }
//        else {
//            phone.number = correspondingServiceNum;
//            type = VOIP_ENABLE;
//        }
    
        
        NSString *number  = callLog_.number;
        number = [number stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSRange range = NSMakeRange(0, 2);
        NSString *temp = [number substringWithRange:range];
        if([temp isEqualToString:@"00"])
        {
            range = NSMakeRange(2, number.length - 2);
            number = [number substringWithRange:range];
        }
        if(number.length <= 4)
        {
            type = [self getCallNumberTypeCustion:callLog_.number];
        }else{
            range = NSMakeRange(0, 4);
            temp = [number substringWithRange:range];
            if([temp isEqualToString:@"2347"] || [temp isEqualToString:@"2348"] || [temp isEqualToString:@"2349"])
            {
                if(number.length == 13)
                {
                    type = VOIP_ENABLE;
                }
            }
            else if([temp isEqualToString:@"2341"] && number.length == 11)
            {
                type = VOIP_ENABLE;
            }
            else{
                type = [self getCallNumberTypeCustion:callLog_.number];
                if(type == VOIP_OVERSEA){
                    type = VOIP_PASS;
                }
            }
        }
      
        
    }
    
    AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
    BOOL hasTextCommercial = ([[CallCommercialManager instance] getCommercialModel] != nil);
    BOOL suitableForHtmlCommercial =
            isVoipOn
        && (appSettingsModel.dialerMode != DialerModeNormal)
        && ([[PrepareAdManager instance] getPrepareAdItem:kAD_TU_CALL_POPUP_HTML]!=nil);
    
    BOOL hasCommercial = hasTextCommercial || suitableForHtmlCommercial;
    
    if(hasCommercial) {
        [self showPopupView:phone type:type directVoipCall:NO];
    } else {
        BOOL hasParticipateOversea = [UserDefaultsManager boolValueForKey:have_participated_voip_oversea defaultValue:NO];
        BOOL numberSupportDirectVoip = type == VOIP_ENABLE || type == VOIP_PRE_17|| type == VOIP_LANDLINE ||
        (type == VOIP_OVERSEA && hasParticipateOversea);
        if(!isVoipOn || appSettingsModel.dialerMode == DialerModeNormal) {
            [self makeCallAfterVoipChoice:phone isGestureCall:isGestureCall_];
        } else if(_directVoipCall || (appSettingsModel.dialerMode == DialerModeVoip && numberSupportDirectVoip)){
            _directVoipCall = false;
            [self showPopupView:phone type:type directVoipCall:YES];
        } else {
            [self showPopupView:phone type:type directVoipCall:NO];
        }
    }
}

- (void) showPopupView:(CallLogDataModel*) phone type:(NSInteger) type directVoipCall:(BOOL)directVoipCall{
    if (true) {
        TPDVoipCallPopUpViewController* vc = [[TPDVoipCallPopUpViewController alloc] init];
        vc.callLog = phone;
        vc.type = type;
        vc.view.backgroundColor = [UIColor clearColor];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
//        vc.view.alpha = .3;
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            nav.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }else{
            [TouchPalDialerAppDelegate naviController].modalPresentationStyle=UIModalPresentationCurrentContext;
        }
        
        
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            [((TouchPalDialerAppDelegate*)[UIApplication sharedApplication].delegate).tabBarController presentViewController:nav animated:NO completion:^{
            }];
        } else {
            [[TouchPalDialerAppDelegate naviController] presentViewController:nav animated:NO completion:^{
            }];
        }
        
        if(directVoipCall) {
            [vc callVoipDirectly];
        }
        
    }else{
        _popUpView = [[VoipCallPopUpView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight()) andCallLog:phone andType:type];
        _popUpView.delegate = self;
        
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            [[UIView tpd_topWindow] addSubview:_popUpView];
        } else {
            [_defaultNaviController.topViewController.view addSubview:_popUpView];
        }
        if(directVoipCall) {
            _popUpView.hidden = true;
            [_popUpView sendVoipButtonClickMessage];
        }
    }
}

- (void)checkTestVoipCall:(CallLogDataModel *)phone {
    
    TPDVoipCallPopUpViewController* vc = [[TPDVoipCallPopUpViewController alloc] init];
    vc.callLog = phone;
    vc.type = 40000;
    vc.callName = phone.name;
    vc.view.backgroundColor = [UIColor clearColor];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    //        vc.view.alpha = .3;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        nav.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }else{
        [TouchPalDialerAppDelegate naviController].modalPresentationStyle=UIModalPresentationCurrentContext;
    }
    
    
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        [((TouchPalDialerAppDelegate*)[UIApplication sharedApplication].delegate).tabBarController presentViewController:nav animated:NO completion:^{
        }];
    } else {
        [[TouchPalDialerAppDelegate naviController] presentViewController:nav animated:NO completion:^{
        }];
    }
    
}


- (NSString *)isServiceNumber:(NSString *)number{
    if (number.length < 5) {
        return nil;
    }
    NSString *servericeNumbers = [UserDefaultsManager stringForKey:SERVER_NUMBERS_FOR_FREE_CALL];
    NSArray *numbers = [servericeNumbers componentsSeparatedByString:@"\n"];
    if (numbers.count == 0) {
        return nil;
    }
    number = [number digitNumber];
    for (NSString *ele in numbers) {
        if ([ele hasPrefix:@"+86"]) {
            if ([ele hasSuffix:number]) {
                return ele;
            }
        } else if ([number hasSuffix:ele]) {
            return number;
        }
    }
    return nil;
}


- (void)makeCallAfterVoipChoice:(CallLogDataModel *)phone
                  isGestureCall:(BOOL)isGestureCall {
    SmartDailerSettingModel *setting = [[SmartDailerSettingModel alloc] init];
    [[GlobalVariables getInstance].enterCallPageSignal sendNext:nil];
    
    NSArray *numberRuleArray = nil;
    if(![[IPExcudeNumberModelManager sharedManager] isThisNumberExcludedFromSmartDial:phone.number]){
        SmartDailerSettingModel *smartDialSetting = [SmartDailerSettingModel settings];
        numberRuleArray = [[PhoneNumber sharedInstance] getSuggestionsNumber:phone.number
                                                                    autoDial:smartDialSetting.autoDialEnabled
                                                             smartDialAdvice:smartDialSetting.smartDialAdviceEnabled
                                                                     roaming:smartDialSetting.roaming
                                                        internationalRoaming:[smartDialSetting isInternationalRoaming]];
    }
    if ([numberRuleArray count] > 1 ||([numberRuleArray count] == 1 && [setting isInternationalRoaming])) {
        NSMutableArray *contentArray = [[NSMutableArray alloc] initWithCapacity:numberRuleArray.count*2];
        for(RuleModel *rule in numberRuleArray){
            [contentArray addObject:NSLocalizedString(rule.name,"")];
            [contentArray addObject:rule.number];
        }
        
        self.phoneNumebrGoingToBeCalled = phone.number;
        personIdThatIsGoingToBeCalled_ = [NumberPersonMappingModel queryContactIDByNumber:phone.number];
        CooTekPopUpSheet *popUpSheet = [[CooTekPopUpSheet alloc] initWithTitle:NSLocalizedString(@"Dialing assistant", @"")
                                                                       content:contentArray
                                                                          type:PopUpSheetTypeSmartRuleCall
                                                                        appear:willAppearPopupSheet_
                                                                     disappear:willDisappearPopupSheet_];
        popUpSheet.delegate = self;
        
        
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            [[UIView tpd_topWindow] addSubview:popUpSheet];
        } else {
            [_defaultNaviController.topViewController.view addSubview:popUpSheet];
        }
    }else{
        NSString *numberInput = @"";
        if ([numberRuleArray count] == 1) {
            RuleModel *rule= [numberRuleArray objectAtIndex:0];
            numberInput = rule.number;
        }
        [self makeCall:phone withIpNumber:numberInput];
    }
}


-(void) makeCall:(CallLogDataModel *)phone withIpNumber:(NSString *)ipNumber{
    if ([self promptIPadUserIfNecessary]) {
        return;
    }

    NSString *dailerNumber = phone.number;
    if ([ipNumber length] > 0) {
        dailerNumber = ipNumber;
    }
    
    NSRange range = [dailerNumber rangeOfString:@","];
    if (range.length > 0) {
        dailerNumber = [dailerNumber substringToIndex:range.location];
    }
    BOOL isNumberPassedToDial = [dailerNumber length] > 2 || ([[UIDevice currentDevice]systemVersion].floatValue >= 8.0f && ([dailerNumber hasPrefix:@"1"] && [dailerNumber length] > 1));
    
    if(!isNumberPassedToDial ||
       [dailerNumber rangeOfString:@"#"].length > 0 ||
       [dailerNumber rangeOfString:@"*"].length>0 ||
       [ipNumber rangeOfString:@"#"].length >0 ||
       [ipNumber rangeOfString:@"*"].length > 0 )
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
        if ([ipNumber length] > 0) {
            [pasteboard setString:ipNumber];
        }else{
            [pasteboard setString:phone.number];
        }
        NSString *message = NSLocalizedString(@"Due to the limit of the system,the number you selected can not be dialed out directly, it is already been copied to the clipboard.",@"");
        [DefaultUIAlertViewHandler showAlertViewWithTitle:message message:nil];
        return;
    }
    if (dailerNumber != nil && ![@"" isEqualToString:dailerNumber] && isNumberPassedToDial) {
        NSString *numberAfterClear = [self cleanPhoneNumber:dailerNumber];
        
        AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
        NSURL *phoneNumberUrl;
        if ([[[UIDevice currentDevice]systemVersion]floatValue] < 8.0 && appSettingsModel.call_confirm && ![sSource isEqualToString:@"YellowPage"] && (![UserDefaultsManager boolValueForKey:IS_VOIP_ON] || voipPass)) {
            NSString *numberString = [NSString stringWithFormat:@"telprompt://%@",numberAfterClear];
            numberString = [numberString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            phoneNumberUrl = [NSURL URLWithString:numberString];
        } else {
            NSString *numberString = [NSString stringWithFormat:@"tel://%@",numberAfterClear];
            numberString = [numberString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            phoneNumberUrl = [NSURL URLWithString:numberString];
        }
        
        if ( ![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN] && ![UserDefaultsManager boolValueForKey:VOIP_FIRST_CALL_FRIEND]){
            [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_WAIT];
            if ([UserDefaultsManager intValueForKey:unregister_fristCall_tip defaultValue:0]==0) {
                [UserDefaultsManager setIntValue:1 forKey:unregister_fristCall_tip];
            }
            int personId = [NumberPersonMappingModel queryContactIDByNumber:phone.number];
            if (personId > 0) {
                NotificationScheduler* scheduler = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) notificationScheduler];
                [scheduler scheduleBackgroundNotification:[TPFirstCallFriendWithoutVoipNotification notification]];
                [UserDefaultsManager setBoolValue:YES forKey:VOIP_FIRST_CALL_FRIEND];
            }
        }
        
        CallLogDataModel *call_log = [phone copy];
        call_log.number = dailerNumber;
        // The jailbreak version will ignore and clear the pending call log, and use syncCallLog instead.
        [CallLog addPendingCallLog:call_log];
        [[UIApplication sharedApplication] openURL:phoneNumberUrl];
        _callFromOurApp = YES;
        _callFromOurAppForGuide = YES;
        self.adUUID = [[AdStatManager instance] genenrateUUID];
        [[HangupCommercialManager instance] asyncAskCommercialWithCallingNumber:[PhoneNumber getCNnormalNumber:dailerNumber]
                                                                    andCallType:CALL_TYPE_P2P
                                                                             tu:kAD_TU_HANGUP
                                                                           uuid:self.adUUID];
        [DialerUsageRecord recordpath:PATH_DIAL kvs:Pair(DIAL_TYPE_KEY, DIAL_NOMAL_CALL), nil];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    callCenter.callEventHandler = nil;
}

#pragma mark -
#pragma mark methods
- (NSString*)cleanPhoneNumber:(NSString*)phoneNumber
{
    NSString* number = [NSString stringWithString:phoneNumber];
    NSString* number1 = [[[number stringByReplacingOccurrencesOfString:@" " withString:@""]
                          //                        stringByReplacingOccurrencesOfString:@"-" withString:@""]
                          stringByReplacingOccurrencesOfString:@"(" withString:@""]
                         stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    return number1;
}

- (BOOL)promptIPadUserIfNecessary
{
    BOOL couldRespondToTelprompt = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"telprompt://"]];
    BOOL couldRespondToTel = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
    
    if (couldRespondToTel || couldRespondToTelprompt) {
        return NO;
    } else {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"Sorry that you could not make calls from iPad or iPod.", @"")
                                                  message:nil];
        return YES;
    }
}


- (NSInteger)getCallNumberTypeCustion:(NSString*) phoneNumber{
    NSString *phoneType = [[PhoneNumber sharedInstance]getNumberAttribution:phoneNumber];
    if ([phoneType rangeOfString:@"新疆"].length > 0 || [phoneType rangeOfString:@"西藏"].length > 0){
        return VOIP_XINJIANG;
    }
    if ([phoneType rangeOfString:@"热线电话"].length > 0 ){
        return VOIP_SERVICE;
    }
    NSString *normalizePhone = [PhoneNumber getCNnormalNumber:phoneNumber];
    NSString *ownPhone = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME];
    if ( [ownPhone isEqualToString:normalizePhone])
        return VOIP_PASS;
    if( [normalizePhone hasPrefix:@"+"]){
        if ([normalizePhone hasPrefix:@"+86"]){
            return [self getCallNumberTypeWith86:[normalizePhone substringFromIndex:3]];
        }else{
            return VOIP_OVERSEA;
        }
    }
    else{
        return [self getCallNumberTypeWithout86:phoneNumber];
    }
}

- (NSInteger)getCallNumberTypeWith86:(NSString*) phoneNumber{
    if (phoneNumber.length != 11){
        return VOIP_PASS;
    }
    if ( [phoneNumber hasPrefix:@"17"] ){
        return VOIP_PRE_17;
    }
    return VOIP_ENABLE;
}



- (NSInteger)getCallNumberTypeWithout86:(NSString*) phoneNumber{
    if (![self isPureInt:phoneNumber])
        return VOIP_PASS;
    if ( [phoneNumber hasPrefix:@"400"] || [phoneNumber hasPrefix:@"955"] || [phoneNumber hasPrefix:@"800"] || ([phoneNumber hasPrefix:@"9"] && phoneNumber.length == 5)){
        return VOIP_SERVICE;
    }
    if ( (phoneNumber.length == 8 || phoneNumber.length == 7) ){
        return VOIP_LANDLINE;
    }
    return VOIP_PASS;
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}




#pragma mark VoipCallPopUpViewDelegate
- (void)onClickFreeCallButton:(NSString *)number{
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        callLog_.number = number;
        if (![[PhoneNumber sharedInstance] isCNSim]) {
            callLog_.number = [PhoneNumber getCNnormalNumber:callLog_.number];
        }
        [CallLog addPendingCallLog:callLog_];
        [VOIPCall makeCall:callLog_.number];
        
        isVOIPCall_ = YES;
    } else {
        [self onClickNormalCallButton];
        
    }
    [[GlobalVariables getInstance].enterCallPageSignal sendNext:nil];
    _popUpView = nil;
}


- (void)onClickNormalCallButton{
    [self makeCallAfterVoipChoice:callLog_ isGestureCall:isGestureCall_];
    
    
    _popUpView = nil;

}

- (void)onClickCancelButton{
    if (isGestureCall_){
        isGestureCall_ = NO;

        [[NSNotificationCenter defaultCenter] postNotificationName:N_CANCEL_CALL_CLICK object:nil userInfo:nil];
    }
    _popUpView = nil;
}

- (void)onClickInviteButton{
    VoipShareAllView *voipShareView = [[VoipShareAllView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight())];
    voipShareView.msgPhone = callLog_.number;
    voipShareView.fromWhere = @"dial_view";
    
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        [[UIView tpd_topWindow] addSubview:voipShareView];
    } else {
        [_defaultNaviController.topViewController.view addSubview:voipShareView];
    }
}

#pragma mark VoipFirstCallDelegate
- (void)clickRegisterButton{
    if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:YES] forKey:IS_VOIP_ON];
        _directVoipCall = YES;
        [self checkOverSea:self.callLog];
    } else {
        if([self getCallNumberTypeCustion:callLog_.number]== VOIP_OVERSEA){
            MarketLoginController *marketLoginController = [MarketLoginController withOrigin:@"personal_center_market"];
            marketLoginController.url = INVITATION_URL_STRING;
            
            [LoginController checkLoginWithDelegate:marketLoginController];
        }else{
        [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"voip_first_call_register"]];
        }
    }
    [UserDefaultsManager setBoolValue:YES forKey:VOIP_FIRST_CALL];
}

- (void)clickNoInterestButton{
    [self makeCallAfterVoipChoice:callLog_ isGestureCall:isGestureCall_];
    [UserDefaultsManager setBoolValue:YES forKey:VOIP_FIRST_CALL];
}


#pragma SmartRuleDelegate
- (void)clickRuleForCall:(NSString *)ipNumber
{
    [self makeCall:callLog_ withIpNumber:ipNumber];
}

#pragma mark CootekPopUpSheetDelegate
- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info
{
    if(tag == PopUpSheetTypeSmartRuleCall){
        if(info.count == 2){
            [self clickRuleForCall:[info objectAtIndex:1]];
        }
    } else {
            [self makeCallAfterVoipChoice:callLog_ isGestureCall:isGestureCall_];
    }
}

-(void)doClickOnCancelButtonWithTag:(int)tag
{
    if (isGestureCall_ && tag == PopUpSheetTypeSmartRuleCall) {
        isGestureCall_ = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:N_CANCEL_CALL_CLICK object:nil userInfo:nil];
    }
}

- (void)doClickOnAddedCell
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Are you sure not to apply IP rules for this number",@"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    alertView.tag = ALERTVIEW_TAG_FOR_COOTEK_POPUP_SHEET;
    alertView.delegate = self;
    [alertView show];
}
#pragma mark AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [[IPExcudeNumberModelManager sharedManager] addItemsToExcludedList:@[phoneNumebrGoingToBeCalled_]];
    }
}

+ (void)logCallFromSource:(NSString*) source
{
    sSource = source;
}

- (void)initializeCallCenter
{
    self.callCenter = [[CTCallCenter alloc] init];
    __weak TPCallActionController *blockSelf = self;
	callCenter.callEventHandler=^(CTCall* call)
	{
        [blockSelf performSelectorOnMainThread:@selector(onSystemCallState:) withObject:call waitUntilDone:NO];
    };
}

- (void)onSystemCallState:(CTCall *)call {
    cootek_log(@"_callState =%@;_callID = %@",call.callState,call.callID);
    if (([self.callStatus isEqualToString:CTCallStateDialing]) && ([call.callState isEqualToString:CTCallStateConnected])) {
        if ([[AppSettingsModel appSettings] vibrate_when_connected]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        if (self.callFromOurApp) {
            _connetedTime = [[NSDate date] timeIntervalSince1970];
        }
    }
    if (([self.callStatus isEqualToString:CTCallStateConnected] || [self.callStatus isEqualToString:CTCallStateDialing]) && ([call.callState isEqualToString:CTCallStateDisconnected])) {
        if ([[AppSettingsModel appSettings] vibrate_when_disconnected]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        if (self.callFromOurApp) {
            [self checkToShowCommercialHangup];
            double dur = 0;
            if (_connetedTime > 0) {
                dur = [[NSDate date] timeIntervalSince1970] - _connetedTime;
                _connetedTime = 0;
            }
            TouchLifeShare *touchLifeShare = [[TouchLifeShareMgr instance] newTouchLifeShare];
            NSDictionary *param = [touchLifeShare generateShareRequestParamWithCallNumber:callLog_.number callDuration:(NSInteger)(dur) isVoipCall:YES];
            [touchLifeShare checkShareWithRequestParam:param];
            
            [CallLog commitPendingLogWithCallDur:dur isVoipCall:NO];
            
            AppSettingsModel* appSettingsModel = [AppSettingsModel appSettings];
            if ([UserDefaultsManager objectForKey:@"SHARE_RING_DATA"]!=nil && appSettingsModel.dial_tone==YES
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
        }
        self.callFromOurApp = NO;
        
    }
    self.callStatus = call.callState;
    BOOL isDBReady = [TouchPalDialerLaunch getInstance].isDataInitialized;
    if (!isDBReady) {
        return;
    }
    if (isVOIPCall_) {
        return;
    }
//    if ((call.callState == CTCallStateDialing && ![AdvancedCalllog isAccessCallDB]) ||
//        (call.callState == CTCallStateDisconnected && [AdvancedCalllog isAccessCallDB])) {
//        [CallLog commitPendingCallLog];
//    }
    if ( call.callState == CTCallStateDisconnected && self.callFromOurAppForGuide){
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [DialerGuideAnimationUtil shouldReFreshLocalNoah];
            self.callFromOurAppForGuide = NO;
        });
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

- (void)makeCallWithNumber:(NSString *)number {
    [self makeCallWithNumber:number fromOutside:NO];
}

- (void)makeCallWithNumber:(NSString *)number fromOutside:(BOOL)outside {
    if(number==nil || number.length ==0){
        return;
    }
    if (outside) {
        NSArray *views = [NSArray arrayWithArray:[_defaultNaviController.topViewController.view subviews]];
        for (UIView *tmp in views) {
            if ([tmp isKindOfClass:[VoipCallPopUpView class]] ||
                [tmp isKindOfClass:[VoipFirstCallView class]] ||
                [tmp isKindOfClass:[CooTekPopUpSheet class]] ||
                [tmp isKindOfClass:[VoipShareAllView class]]) {
                [tmp removeFromSuperview];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [TouchPalDialerLaunch getInstance].isVoipCallInitialized = YES;
        [[TouchPalDialerAppDelegate naviController] popToRootViewControllerAnimated:NO];
        CallLogDataModel *call_model = [[CallLogDataModel alloc] init];
        call_model.number = number;
        call_model.callFromOutside = outside;
        [[TPCallActionController controller] makeCall:call_model];
    });

}

+ (void)onVoipCallHangupWithCallDur:(int)duration isDirectCall:(BOOL)isDirectCall{
    [CallLog commitPendingLogWithCallDur:duration isVoipCall:YES];
    NSArray *array = [UserDefaultsManager arrayForKey:@"notificationKey"];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    for (UILocalNotification *notification in array) {
        notification.soundName= nil;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)releasePopupSheetBlock
{
    if (willAppearPopupSheet_) {
        willAppearPopupSheet_ = nil;
    }
    if (willDisappearPopupSheet_) {
        willDisappearPopupSheet_ = nil;
    }
}

- (void)checkToShowCommercialHangup {
    NSString *filePath = [FileUtils getAbsoluteFilePath:[[Commercial stringByAppendingPathComponent:ADResource] stringByAppendingPathComponent:ADDirectCallHTML]];
    NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *pattern = REG_PATTERN_COOTEK_AD;
    
    if ([[HangupCommercialManager instance] isDirectAD]) {
        [[HangupCommercialManager instance] showDirectAD];
    } else
        if ([[HangupCommercialManager instance] checkIfResourceReady] && string.length>0 &&
            [VoipUtils stringByRegularExpressionWithstring:string pattern:pattern tu:kAD_TU_HANGUP]) {
            HangupController *newController = [[HangupController alloc] initWithCallNumber:callLog_.number
                                                                                 startTime:callLog_.callTime
                                                                                   callDur:callLog_.duration
                                                                                 isP2PCall:YES
                                                                                      uuid:self.adUUID];
            [[TouchPalDialerAppDelegate naviController] pushViewController:newController animated:NO];
    }else{
        [VoipUtils saveNoAdReasonWithKey:@"phone" value:callLog_.number];
    }
}


@end
