//
//  TouchPalDialerLaunch.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/10/23.
//
//

#import "TouchPalDialerLaunch.h"
#import "TouchPalDialerAppDelegate.h"
#import "RootScrollViewController.h"
#import "Reachability.h"
#import "ACTReporter.h"
#import "FunctionUtility.h"
#import "UserDefaultsManager.h"
#import "TouchPalVersionInfo.h"
#import "TPAddressBookWrapper.h"
#import "SyncContactWhenAppEnterForground.h"
#import "DialerUsageRecord.h"
#import "FeatureGuideTipsController.h"
#import "AntiharassGuideController.h"
#import "SmartDailerSettingModel.h"
#import "PhoneNumber.h"
#import "ContactGroupSyncService.h"
#import "ContactCacheDataManager.h"
#import "ContactPropertyCacheManager.h"
#import "YellowCityDataManager.h"
#import "PJSIPManager.h"
#import "ScheduleInternetVisit.h"
#import "ScheduleTaskManager.h"
#import "TaeClient.h"
#import "TouchpalMembersManager.h"
#import "QQShareController.h"
#import "TPUncaughtExceptionHandler.h"
#import "XinGePushManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "NoahManager.h"
#import <Usage_iOS/UsageRecorder.h>
#import "DialerUsageRecord.h"
#import "UperUsageAssist.h"
#import "BackupAttributeConfigurator.h"
#import "CallLog.h"
#import "VOIPCall.h"
#import "AntiharassAdressbookUtil.h"
#import  "PersonDBA.h"
#import "ContactSmartSearchDBA.h"
#import "IncomingNotificationManager.h"
#import "CommonTipsWithBolckView.h"
#import "DefaultLoginController.h"
#import "LaunchADController.h"
#import "HangupCommercialManager.h"
#import "AdMessageModel.h"
#import "SeattleFeatureExecutor.h"
#import "LaunchCommercialManager.h"
#import "FileUtils.h"
#import "VoipUtils.h"
#import "HMTAgentSDK.h"
#import "TPBuildTime.h"
#import "DateTimeUtil.h"
#import "NormalLaunchViewController.h"
#import "BiBiPairManager.h"
#import "PrepareAdManager.h"
#import "SyncTouchPalAccount.h"
#import <CallKit/CallKit.h>
#import "AntiharassDataManager.h"
#import "CommercialSkinManager.h"
#import "SkinDownloadManager.h"
#import "YellowPageMainTabController.h"
#import "AdStatManager.h"
#import "YellowPageLocationManager.h"
#import "AntiharassManager.h"
#import "AntiharassTools.h"
#import "FileUtils.h"
#import "TPDLib.h"

//#define BOARDIMAGEANDVERURL (@"http://183.136.223.45:30003/page_v3/get_commercial_call_content_img_link")
#define BOARDIMAGEANDVERURL (@"http://touchlife.cootekservice.com/page_v3/get_commercial_call_content_img_link")
@implementation TouchPalDialerLaunch {
    NSMutableArray *_statusBarAffectedViews;
}

+ (TouchPalDialerLaunch *)getInstance {
    static TouchPalDialerLaunch *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (void)didBecomeActiveFromStartOrPause {
    [UserDefaultsManager setBoolValue:NO forKey:next_active_show_guide];
    [UserDefaultsManager setBoolValue:YES forKey:active_in_background];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"active_in_background" object:nil];
    if ([AdvancedCalllog isAccessCallDB] && self.isDataInitialized) {
        [CallLog syncCalllog];
    }
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [DialerUsageRecord recordpath:PATH_REMOTE_NOTIFICATION kvs:Pair(START_APP_WITH_BADGE, @"1"), nil];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:N_APPLICATION_BECOME_ACTIVE object:nil userInfo:nil];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SyncContactWhenAppEnterForground setNeedsRespondToABChange:NO];
    });
    [VOIPCall checkIncomingCall];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UserDefaultsManager removeObjectForKey:@"notificationKey"];
    [UserDefaultsManager setIntValue:0 forKey:VOIP_INCOMING_ALERT_BADGE_NUMBER];
    [[IncomingNotificationManager instance]clearAllIncomingNotifications];
    [self checkForStatusBarChange];
    [self checkIfShouldShowNotRegisterFirstCallTip];
    [CommercialSkinManager asyncGetSkinInfo];
    [CommercialSkinManager getAnySkinIDFromExtiPlistRightTimeAndUseIt];
}

-(void)checkIfShouldShowNotRegisterFirstCallTip{
    if ([UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME]<=1&&![UserDefaultsManager boolValueForKey:have_click_vs_no_free]) {
    if([UserDefaultsManager intValueForKey:unregister_fristCall10Min_tip]<2){
        if ([UserDefaultsManager intValueForKey:unregister_fristCall_tip]==1 || [UserDefaultsManager intValueForKey:unregister_fristCall10Min_tip]==1) {
        CommonTipsWithBolckView *view;
        if([UserDefaultsManager intValueForKey:unregister_fristCall10Min_tip]==1){
            [DialerUsageRecord recordpath:PATH_INAPP_TESTFREECALL_GUDIE kvs:Pair(KEY_ACTION , LONGCALL_SHOW), nil];
            view =[[CommonTipsWithBolckView alloc] initWithtitleString:nil lable1String:@"煲电话粥怎么能不开启免费电话呢？轻松为您省下高额话费" lable1textAlignment:0 lable2String:nil lable2textAlignment:0 leftString:@"不用了" rightString:@"立即开启" rightBlock:^{
                if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
                    [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:YES] forKey:IS_VOIP_ON];
                } else {
                    [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:BEFORECALL_LOGIN_SUCCESS]];
                }
            }leftBlock:nil];
            [UserDefaultsManager setIntValue:2 forKey:unregister_fristCall10Min_tip];
        }
       /* else if([UserDefaultsManager intValueForKey:unregister_fristCall_tip]==1){
            [DialerUsageRecord recordpath:PATH_INAPP_TESTFREECALL_GUDIE kvs:Pair(KEY_ACTION , AFTERCALL_SHOW), nil];
                view =[[CommonTipsWithBolckView alloc] initWithtitleString:nil lable1String:@"现在有空了嘛？试试免费电话功能吧！" lable1textAlignment:0 lable2String:nil lable2textAlignment:0 leftString:@"不需要" rightString:@"立即开启" rightBlock:^{
                    if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
                        [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:YES] forKey:IS_VOIP_ON];
                    } else {
                        [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:AFTERCALL_LOGIN_SUCCESS]];
                    }
                } leftBlock:nil];
                [UserDefaultsManager setIntValue:2 forKey:unregister_fristCall_tip];
            }*/
            
            if([[TouchPalDialerAppDelegate naviController].topViewController isKindOfClass:[RootScrollViewController class]] && [(RootScrollViewController*)[((UINavigationController*)[[[UIApplication sharedApplication]delegate]window].rootViewController).viewControllers objectAtIndex:0] getSelectedControllerIndex] == 1){
                [DialogUtil showDialogWithContentView:view inRootView:nil];
            }
        
        }
    }
    }
}

static void displayStatusChanged(CFNotificationCenterRef center,
                                 void *observer,
                                 CFStringRef name,
                                 const void *object,
                                 CFDictionaryRef userInfo) {
    if (name == CFSTR("com.apple.springboard.lockcomplete")) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisplayStatusLocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)normalLaunchWithOptions:(NSDictionary*) launchOptions{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //    getRemoteNoti = NO;
    //    if (launchOptions != nil){
    //        //opened from a push notification when the app is closed
    //        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    //        if (userInfo != nil){
    //            getRemoteNoti = YES;
    //            [NotificationHandler handleNotification:userInfo];
    //        }
    //
    //    }
   
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    displayStatusChanged,
                                    CFSTR("com.apple.springboard.lockcomplete"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    [UserDefaultsManager setBoolValue:YES forKey:active_in_background];
    
    //
    // 每次重启，设置视频新闻不允许在数据网络下播放
    //
    [UserDefaultsManager setBoolValue:NO forKey:FEEDS_VIDEO_PLAY_IN_DATA_CONNECTION];
    
    if ([UserDefaultsManager boolValueForKey:COLLECT_AND_UPLOAD_LOG]) {
        [self redirectNSLogToDocuments];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FunctionUtility getWebViewUserAgent];
    });
    [self setDefaultKeys];
    
    self.isDataInitialized = NO;
    
    [self initializeAddressBookListener];
    
    [Reachability startNotify];

    [self asyncInitDataBaseModel];
    [self loadInitialData];

    [[BiBiPairManager manager] asycBiBiPair];

    [self asyncLoadDBData];
    [self checkDownloadBoardImageView];
    NSURL* urlKey = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
    if (urlKey) {
        NSRange range = [urlKey.absoluteString rangeOfString:@"touchpal://yellowpageOpenUrl"];
        if (range.length <= 0) {
                [self loadFeatureGuideIfNecessary];
        }
    } else {
            [self loadFeatureGuideIfNecessary];
    }

    
    // Google iOS Download tracking snippet
    [ACTConversionReporter reportWithConversionID:@"961687065"
                                            label:@"ue2KCNP9uFgQmdzIygM" value:@"0.00" isRepeatable:NO];
    [FunctionUtility writeDefaultKeyToDefaults:@"group.com.cootek.Contacts" andObject:[NSString stringWithFormat:@"%d",[UserDefaultsManager boolValueForKey:IS_VOIP_ON defaultValue:NO]] andKey:@"isVoipOn"];

    // delete the usage files
    [self deleteFiles];
    
    //UsageRecorder should be initialized as soon as possible.
    //the sAssist is nil when UsageRecorder is not initialized.
    
    [UserDefaultsManager removeObjectForKey:CONTACT_TRANSFER_INSERTED_COUNT]; //
    
    [AntiharassDataManager updateCallExtensionEnableStatus];
}


- (void)checkDownloadBoardImageView {
    NSString *boardImageInfoPath = [FileUtils getNewFileInCommonFileWithPathComponent:@"boardImage/boardImage.plist" ifInsertDir:YES];
    NSMutableDictionary *boardImageInfoDic = [NSMutableDictionary dictionaryWithContentsOfFile:boardImageInfoPath];
    NSDate *oldDat = [boardImageInfoDic objectForKey:@"reqDate"];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:oldDat];

    if (boardImageInfoDic==nil || oldDat==nil || seconds>6*60*60) {
        NSString *token = [SeattleFeatureExecutor getToken];
        NSString *urlString = [[NSString stringWithFormat:@"%@?_token=%@",BOARDIMAGEANDVERURL,token] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            NSString *boardImagePath = [FileUtils getNewFileInCommonFileWithPathComponent:@"boardImage/board@2x.png" ifInsertDir:YES];
            NSString *boardImageInfoPath = [FileUtils getNewFileInCommonFileWithPathComponent:@"boardImage/boardImage.plist" ifInsertDir:YES];
            NSMutableDictionary *boardImageInfoDic = [NSMutableDictionary dictionaryWithContentsOfFile:boardImageInfoPath];
            if (boardImageInfoDic==nil) {
                boardImageInfoDic = [NSMutableDictionary dictionary];
            }
            [boardImageInfoDic setObject:[NSDate date] forKey:@"reqDate"];
            if (connectionError ==nil && data!=nil) {
                NSError *error = nil;
                NSDictionary *allResultDic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:&error];
                if (error ==nil && allResultDic != nil) {
                    NSDictionary *resultDic = allResultDic[@"result"];
                    NSNumber *error_code = allResultDic[@"result_code"];
                    cootek_log(@"res===%@",resultDic);
                    if (error_code.integerValue==2000 && resultDic.count>0) {
                        NSString *versionString = resultDic[@"version"];
                        NSString *linkString = resultDic[@"link"];
                        NSString *oldVersionString = boardImageInfoDic[@"version"];
                        if (oldVersionString.integerValue<versionString.integerValue) {
                            if (linkString.length==0) {
                                [FileUtils removeFileInAbsolutePath:boardImagePath];
                                [boardImageInfoDic writeToFile:boardImageInfoPath atomically:YES];
                            } else {
                                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                    STRONG(resultDic)
                                    STRONG(boardImagePath)
                                    STRONG(boardImageInfoPath)
                                    STRONG(boardImageInfoDic)
                                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:linkString]];
                                    [data writeToFile:boardImagePath atomically:YES];
                                    [boardImageInfoDic setObject:resultDic[@"version"] forKey:@"version"];
                                    [boardImageInfoDic writeToFile:boardImageInfoPath atomically:YES];
                                });
                            }
                            return;
                        }
                    }
                }
            }
            [boardImageInfoDic writeToFile:boardImageInfoPath atomically:YES];
        }];
    }
}

- (void)asyncLoadDBData {
    [AntiharassDataManager resetShouldReloadCountToExtentionCountWhenLuanch];
    [AntiharassDataManager checkAsyncLoadDBData];
}


- (void)setDefaultKeys{
    //set for today widget
    [UserDefaultsManager setBoolValue:NO forKey:CALL_POPUP_HTML_IS_QUERYING];
    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_NOW_LOADING_TO_EXTENTION];
    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_UPDATE_WITH_VIEW];
    [UserDefaultsManager setBoolValue:[UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON] forKey:ANTIHARASS_IS_ON];
    [UserDefaultsManager setBoolValue:[UserDefaultsManager boolValueForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON defaultValue:YES] forKey:ANTIHARASS_AUTOUPDATEINWIFI_ON];
    [UserDefaultsManager setObject:[UserDefaultsManager stringForKey:ANTIHARASS_REMOTE_VERSION] forKey:ANTIHARASS_REMOTE_VERSION];
    [UserDefaultsManager setObject:[UserDefaultsManager stringForKey:ANTIHARASS_VERSION] forKey:ANTIHARASS_VERSION];
    
#ifdef DEBUG
    // 完整版本号，比如 5448
    NSString *debugVersion = [CURRENT_TOUCHPAL_VERSION stringByReplacingOccurrencesOfString:@"." withString:@""];
    debugVersion = [NSString stringWithFormat:@"(DEBUG) %@", debugVersion];
    #ifdef TP_DEBUG_BUILD_TIME
    // 编译时刻, 比如 2016-07-14 11:14:22
    NSDate *buildDate = [NSDate dateWithTimeIntervalSince1970:TP_DEBUG_BUILD_TIME];
    NSString *buildTimeString = [DateTimeUtil dateStringByFormat:@"yyyy-MM-dd HH:mm:ss" fromDate:buildDate];
    // 编译版本 时间 分支 commit号
    NSString *infoString = [NSString stringWithFormat:@"debug_version=%@  build_time_string=%@  build_branch=%@  build_commit=%@",debugVersion,buildTimeString,TP_DEBUG_CURRENT_BRANCH,TP_DEBUG_CURRENT_COMMIT];
    [UserDefaultsManager setObject:infoString  forKey:DEBUG_INFO];
    #endif
    
#endif
    
    NSString *launchVersion = [UserDefaultsManager stringForKey:LAST_LAUNCH_VERSION];
    if ([CURRENT_TOUCHPAL_VERSION isEqualToString:@"5541"] && launchVersion.integerValue < 5541){
        [UserDefaultsManager setBoolValue:YES forKey:SHOWANTIHARASSGUIDEIN5541];
    }
    [UserDefaultsManager setBoolValue:NO forKey:SHOULD_SHOW_ANTIALERT_SWIITCH_OFF];

    if([launchVersion isEqualToString:CURRENT_TOUCHPAL_VERSION]) {
        return;
    }
    NSString *firstVersion = [UserDefaultsManager stringForKey:FIRST_LAUNCH_VERSION];
    if (firstVersion == nil) {
        // new user
        [UserDefaultsManager setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:TOUCHPAL_NEWER_FIRST_OPEN_DATE];
        [UserDefaultsManager setBoolValue:YES forKey:IS_TOUCHPAL_NEWER];
    } else {
        // upgraded user
        NSString *lastVersion = [UserDefaultsManager stringForKey:LAST_LAUNCH_VERSION];
        [UserDefaultsManager setObject:lastVersion forKey:VERSION_JUST_BEFORE_UPGRADE];
        [UserDefaultsManager setBoolValue:NO forKey:IS_TOUCHPAL_NEWER];
        [UserDefaultsManager setBoolValue:YES forKey:NEWER_WIZARD_READ];
        if (lastVersion.integerValue>5560) {
             [UserDefaultsManager setBoolValue:YES forKey:SHOULD_SHOW_ANTIALERT_SWIITCH_OFF];
        }
        if (lastVersion.integerValue < 5500) {
            [FunctionUtility copyNotNilReadyPlistToNilAllResourcePlistWhenUpdate];
        }
    }
    [UserDefaultsManager setObject:CURRENT_TOUCHPAL_VERSION forKey:LAST_LAUNCH_VERSION];
    
    NSInteger launchV = [launchVersion integerValue];
    if ( launchV < 5120 && launchVersion != nil ){
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_FIRST_CALL];
    }
    
    if ( launchV < 5110){
        [UserDefaultsManager setBoolValue:NO forKey:@"scrollTipsView"];
    }
    
    if ( launchV < 5130 ){
        [UserDefaultsManager setBoolValue:YES forKey:FLOW_STREAM_HEADER_BUTTON];
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_STREAM_HEADER_BUTTON];
        [UserDefaultsManager setObject:[UserDefaultsManager objectForKey:@"OpenUDID"] forKey:kOpenUDIDKey];
        [UserDefaultsManager removeObjectForKey:@"OpenUDID"];
    }
    
    if ( (launchV < 5130) && [UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE]) {
        [UserDefaultsManager setBoolValue:YES forKey:TOUCHPAL_USER_HAS_LOGIN];
    }
    
    if ( launchV < 5150 ){
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_BACK_CALL_ENABLE];
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_AUTO_BACK_CALL_ENABLE];
    }
    
    if (launchV < 5160) {
        [UserDefaultsManager setBoolValue:YES forKey:NOAH_SHOULD_COPY_LOCAL_FILE];
        [UserDefaultsManager setBoolValue:YES forKey:SHOULD_MENU_POINT_SHOW];
    }
    
    if (launchV < 5170) {
        [UserDefaultsManager setBoolValue:YES forKey:VOIP_ENABLE_CELL_DATA];
        NSString *secretCode = [UserDefaultsManager stringForKey:VOIP_REGISTER_SECRET_CODE];
        if (secretCode.length > 0) {
            [UserDefaultsManager setObject:[FunctionUtility simpleEncodeForString:secretCode] forKey:VOIP_REGISTER_SECRET_CODE];
        }
        if ([UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
            
        } else if(launchV > 0){
            [UserDefaultsManager setBoolValue:YES forKey:MESSAGE_BOX_DEFAULT_MESSAGE_NEED_ADD];
        }
        if ([UserDefaultsManager intValueForKey:VOIP_CALL_SPIT_BUTTON_PRESS_STATE] > 0) {
            [UserDefaultsManager setIntValue:1 forKey:VOIP_CALL_SPIT_BUTTON_PRESS_STATE];
        }
        
        [UserDefaultsManager setIntValue:7 forKey:SEATTLE_PROXY_VERSION];
        [UserDefaultsManager setObject:@[@"120.132.32.211",@"121.201.55.3"] forKey:SEATTLE_PROXY_DICTIONARY];
    }
    
    if (launchV < 5213) {
        [UserDefaultsManager setBoolValue:YES forKey:NOAH_SHOULD_COPY_LOCAL_FILE];
    }
    
    if (launchV < 5260) {
        [UserDefaultsManager setBoolValue:YES forKey:NOAH_SHOULD_COPY_LOCAL_FILE];
    }
    
    if (launchV < 5323) {
        [UserDefaultsManager setBoolValue:YES forKey:NOAH_SHOULD_COPY_LOCAL_FILE];
    }
    
    [UserDefaultsManager setObject:[NSDate distantPast] forKey:VOIP_FEC_CHECK];
    [UserDefaultsManager setObject:[NSDate distantPast] forKey:VOIP_EDGE_SERVER_CHECK];
    [UserDefaultsManager setBoolValue:YES forKey:NOAH_GUIDE_POINT_REFRESH];
    [UserDefaultsManager setBoolValue:YES forKey:NOAH_SHOULD_COPY_LOCAL_FILE];
    [UserDefaultsManager setBoolValue:YES forKey:SHOULD_MENU_POINT_SHOW];
    
    if ( ![UserDefaultsManager intValueForKey:ASK_LIKE_VIEW_SHOW_TIME defaultValue:0] ){
        NSInteger time = [[NSDate date] timeIntervalSince1970] + 4*24*60*60;
        [UserDefaultsManager setIntValue:time forKey:ASK_LIKE_VIEW_SHOW_TIME];
    }
    
    if (launchV <= 5531) {
        NSUserDefaults* userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.cootek.Contacts"];
        [userDefault removeObjectForKey:@"Number_List"];
        
        [UserDefaultsManager setIntValue:0 forKey:ANTIHARASS_DATAVERSION_iOS10NEW];
    }

}


- (void)initializeAddressBookListener
{
    [TPAddressBookWrapper CreateAddressBookRefForCurrentThread];
    [SyncContactWhenAppEnterForground registerAddressBooKListener];
}

- (void)loadFeatureGuideIfNecessary
{
    NSString *launchVersion = [UserDefaultsManager stringForKey:FIRST_LAUNCH_VERSION];
    
    BOOL shouldShowAntiharassGuide = NO;
    NSString * versionBeforeUpgrade = [UserDefaultsManager stringForKey:VERSION_JUST_BEFORE_UPGRADE];
    if (versionBeforeUpgrade) {
        shouldShowAntiharassGuide = ([versionBeforeUpgrade integerValue] < 5300)
        && ([UserDefaultsManager boolValueForKey:SHOULD_SHOW_ANTIHARASS_GUIDE defaultValue:YES])
        && (![UserDefaultsManager boolValueForKey:IS_TOUCHPAL_NEWER defaultValue:NO]);
    }
    cootek_log(@"shown: %d, versioBeforeUpgrade:%@, new:%d, currentVersion:%@",
               [UserDefaultsManager boolValueForKey:ANTIHARASS_GUIDE_SHOWN defaultValue:NO],
               versionBeforeUpgrade,
               [UserDefaultsManager boolValueForKey:IS_TOUCHPAL_NEWER defaultValue:NO],
               CURRENT_TOUCHPAL_VERSION);
    
    if (!launchVersion){
        // new launch
        int appearCount = [UserDefaultsManager intValueForKey:FEATURE_GUIDE_TIPS_CONTROLLER_APPEAR_COUNT defaultValue:0];
        if (appearCount == 0) {
            [LaunchADController asyncGetLaunchADWithUuid:[[AdStatManager instance] genenrateUUID] preUuid:nil];
        }
        
        [DialerUsageRecord recordpath:PATH_LOGOUT kvs:Pair(SHOW_STARTUP_GUIDE, @(1)), nil];
        FeatureGuideTipsController *featureGuideController = [[FeatureGuideTipsController alloc] init];
        [[TouchPalDialerAppDelegate naviController] pushViewController:featureGuideController animated:NO];
        
    } else if (shouldShowAntiharassGuide) {
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_GUIDE_SHOWN, @(1)), nil];
        AntiharassGuideController *antiharassController = [[AntiharassGuideController alloc] init];
        PersonalCenterController *personalCenterController = [[PersonalCenterController alloc] init];
        NSMutableArray *controllers = [[TouchPalDialerAppDelegate naviController].viewControllers mutableCopy];
        [controllers addObject:personalCenterController];
        [controllers addObject:antiharassController];
        [[TouchPalDialerAppDelegate naviController] setViewControllers:controllers animated:NO];
    } else {
        [self tryToShowLaunchAD];
    }
}

-(void)asyncInitDataBaseModel{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [DataBaseModel instance];
    });
}
// The loadInitialData should be executed in background thread
- (void)loadInitialData
{
    if([NSThread isMainThread]) {
        [self performSelectorInBackground:@selector(loadInitialData) withObject:nil];
        return;
    }
    @autoreleasepool {
        SmartDailerSettingModel *smartDial = [SmartDailerSettingModel settings];
        [PhoneNumber  setupOrlandoWithSimMnc:[smartDial simMnc]
                                  networkMnc:[smartDial networkMnc]
                            residentAreaCode:[smartDial residentAreaCode]
                                     roaming:[smartDial isRoaming]];
   
        [AdvancedCalllog prepare];
        [AdvancedCalllog reportVersion];
        [[SmartDailerSettingModel settings] reportEnabledVoipRulesToAnalyticManager];
        
        [self initializeCarrier];
        
        [TouchpalMembersManager init];
        
        [TPAddressBookWrapper CreateAddressBookRefForCurrentThread];
        
        
        [[ContactCacheDataManager instance] loadInitialData];
        [ContactGroupSyncService asyncContactGroup];
        //voipscheduleCall 增加了contactpropertycache的notification
        [[PhonePadModel getSharedPhonePadModel] loadInitialData];
        [ContactPropertyCacheManager shareManager];
        self.isDataInitialized = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:N_INITIAL_DATA_COMPLETED object:nil userInfo:nil];
        [YellowCityDataManager initCallerTellSearch];
        
        [TPAddressBookWrapper ReleaseAddressBookForCurrentThread];
        [SyncTouchPalAccount updateAllContactTouchPalAccount];
        [self launchNetworkOperation];
        [PJSIPManager checkInit];
        [self initialDataLoaded];
        [ScheduleInternetVisit onAppDataLoaded];
        [[ScheduleTaskManager scheduleManager] addScheduleTask:[CalleridUpdate task]];
        if (!USE_DEBUG_SERVER) {
            [[ScheduleTaskManager scheduleManager] addScheduleTask:[UploadCalllogScheduleTask task]];
            [[ScheduleTaskManager scheduleManager] addScheduleTask:[UploadContactScheduleTask task]];
        }
        [TaeClient setInfoBeforeInit];
        [[TaeClient instance] initTae];
        [[QQShareController instance]registerQQApi];
        
        [TPUncaughtExceptionHandler attachHandler];
        [[NoahManager sharedPSInstance] startNotificationRegistration];
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [AntiharassAdressbookUtil removeAntiharassAddressbookAtbackgrondOfOthers];
//        });
        [ContactSmartSearchDBA queryAndInitContactClickedTimes];
        [VoipUtils getErrorCodeInfo];
// enable HMT only in production mode in case that it interferes with the crash handling.
#ifndef DEBUG
    [HMTAgentSDK initWithAppKey:@"ua-touchpal-00002" channel:CURRENT_TOUCHPAL_VERSION];
#endif

    };
}


- (void)initializeCarrier
{
    CTTelephonyNetworkInfo *carrierInfo_ = [[CTTelephonyNetworkInfo alloc] init];
    carrierInfo_.subscriberCellularProviderDidUpdateNotifier =^(CTCarrier* carrier){
        SmartDailerSettingModel *settingModel = [[SmartDailerSettingModel alloc] init];
        NSString *sim_mnc = [settingModel simMnc];
        NSString *network_mnc = [settingModel networkMnc];
        [[PhoneNumber sharedInstance] setSimOperationCode:sim_mnc];
        [[PhoneNumber sharedInstance] setNetworkOperationCode:network_mnc];
    };
}

- (void)launchNetworkOperation {
    //autorate app
    [[NoahManager sharedInstance] initNoah:NO];
}

- (void)initialDataLoaded
{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(initialDataLoaded) withObject:nil waitUntilDone:YES];
        return;
    }
    [self skipBackupAttributeForDefaultFiles];
    NotificationScheduler* scheduler = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) notificationScheduler];
    [scheduler notifyForegroundNotificationBy:[UIApplication sharedApplication]];
}

- (void)skipBackupAttributeForDefaultFiles
{
    // TODO [elfe] the citydata and skin need to be stored in Cache folder
    // the database file should not skip backup,
    // but we need to handle scenarios that the database status is has city files,
    // while the reality is city files have been deleted
    // Currently add skip attribute to all these files/folders as a workaround
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *cityPath = [documentDirectory stringByAppendingPathComponent:@"cityData"];
    [self createFolderIfNecessary:cityPath];
    NSString *skinPath = [documentDirectory stringByAppendingPathComponent:@"Skin"];
    [self createFolderIfNecessary:skinPath];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"data.sqlite"];
    
    [BackupAttributeConfigurator skipBackupAttributeAtPath:cityPath skipOrBackup:YES];
    [BackupAttributeConfigurator skipBackupAttributeAtPath:skinPath skipOrBackup:YES];
    [BackupAttributeConfigurator skipBackupAttributeAtPath:dbPath skipOrBackup:NO];
}

- (void)createFolderIfNecessary:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)redirectNSLogToDocuments
{
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    NSString *pathForLog = [documentsDirectory stringByAppendingPathComponent:@"cootek_log.txt"];
    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

- (void) registerForStatusBarChange:(UIView *)targetView {
    if (targetView == nil) {
        return;
    }
    if (_statusBarAffectedViews == nil) {
        _statusBarAffectedViews = [[NSMutableArray alloc] initWithCapacity:3];
    }
    [_statusBarAffectedViews addObject:targetView];
}

- (void) unregisterForStatusBarChange:(UIView *)targetView {
    if (targetView == nil) {
        return;
    }
    [_statusBarAffectedViews removeObject:targetView];
}

- (void) checkForStatusBarChange {
    //test the status bar height change event and get rect dimentions
    CGRect rootViewFrame = [TouchPalApplication sharedApplication].delegate.window.rootViewController.view.frame;
    if (!CGRectIsNull(rootViewFrame)) {
        CGFloat currentY = rootViewFrame.origin.y;
        // since the initial staus bar's origin x may be 0(when height is 20 in normal status)
        // or 20(when height is 40 in call status);
        // so the default value of the key `PREVIOUS_STATUS_BAR_HEIGHT_INCREMENT` can not be set to 0.0f.
        float previousY = [UserDefaultsManager floatValueForKey:PREVIOUS_STATUS_BAR_ORIGIN_Y defaultValue:-1.0f];
        cootek_log(@"status_bar, y: %f, previousY: %f", currentY, previousY);
        if (previousY == -1.0f) {
            [UserDefaultsManager setFloatValue:currentY forKey:PREVIOUS_STATUS_BAR_ORIGIN_Y];
            
        } else if ( currentY != previousY) {
            float diffY = previousY - currentY;
            [UserDefaultsManager setFloatValue:currentY forKey:PREVIOUS_STATUS_BAR_ORIGIN_Y];
            
            if (_statusBarAffectedViews) {
                for(UIView *targetView in _statusBarAffectedViews) {
                    cootek_log(@"status_bar, diffY: %f, view: %@", diffY, targetView);
                    if ([targetView isMemberOfClass:[RootScrollView class]]) {
                        targetView.frame = CGRectMake(targetView.frame.origin.x,
                                                      targetView.frame.origin.y,
                                                      targetView.bounds.size.width,
                                                      targetView.bounds.size.height + diffY);
                    } else {
                       targetView.frame = CGRectOffset(targetView.frame, 0, diffY);
                    }
                    [targetView setNeedsDisplay];
                } // end for loop
            }
        }
    }
}

- (void) deleteFiles {
    
    if ([FunctionUtility is64bit] || ([UIDevice currentDevice].systemVersion.floatValue >= 10)) {
        if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON]) {
            if (![UserDefaultsManager boolValueForKey:ANTIHARASS_REMOVE_ANTIHARASS_ADDRESSBOOK defaultValue:NO]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    if ([AntiharassAdressbookUtil removeAntiharassAddressbook]) {
                        [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_REMOVE_ANTIHARASS_ADDRESSBOOK];
                        [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_ON];
                    }
                });
            }
        }
    }
    
    BOOL usageFilesDeleted = [UserDefaultsManager boolValueForKey:USAGE_PLIST_FILES_DELETED defaultValue:NO];
    if (usageFilesDeleted) {
        return;
    }
    NSString *versionBeforeUpgrade = [UserDefaultsManager stringForKey:VERSION_JUST_BEFORE_UPGRADE defaultValue:nil];
    if ([NSString isNilOrEmpty:versionBeforeUpgrade]) {
        return;
    }
    NSInteger versionIntBefore = [versionBeforeUpgrade integerValue];
    if (versionIntBefore >= 5390 && versionIntBefore <= 5399) {
        NSFileManager *fs = [NSFileManager defaultManager];
        NSString *documentPath = [FileUtils absolutePathOfDocument];
        if (!documentPath ) {
            return;
        }
        NSError *error = nil;
        NSArray *files = [fs contentsOfDirectoryAtPath:documentPath error:&error];
        if (error) {
            return;
        }
        for(NSString *filePath in files) {
            if ([filePath hasSuffix:@"Records.plist"]) {
                NSString *absFilePath = [FileUtils getAbsoluteFilePath:filePath];
                if (absFilePath) {
                    NSError *deletError = nil;
                    [fs removeItemAtPath:absFilePath error:&deletError];
                    cootek_log(@"deleteRecords, absFilePath: %@, error: %@",\
                               absFilePath, deletError);
                }
            }
        }
        [UserDefaultsManager setBoolValue:YES forKey:USAGE_PLIST_FILES_DELETED];
    }
}

- (void) tryToShowLaunchAD {

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @try {
            NSMutableDictionary *launchAppDic = [[NSMutableDictionary alloc] initWithCapacity:1];
            [launchAppDic setObject:STARTUP_COMMERCIAL_CUSTOM_EVENT_CAN_SHOW forKey:STARTUP_COMMERCIAL_CUSTOM_EVENT_STEP_NAME];
            [launchAppDic setObject:@(1) forKey:STARTUP_COMMERCIAL_CUSTOM_EVENT_STEP_VALUE];
            [launchAppDic setObject:[DialerUsageRecord getClientNetWorkType] forKey:@"network"];
            [launchAppDic setObject:@([DateTimeUtil currentTimestampInMillis]) forKey:@"local_ts"];
            [DialerUsageRecord recordCustomEvent:PATH_STARTUP_COMMERCIAL_CUSTOM_EVENT extraInfo:[launchAppDic copy]];
        } @catch (NSException *exception) {
            [DialerUsageRecord recordCustomEvent:PATH_STARTUP_COMMERCIAL_CUSTOM_EVENT];
        }
    });
    __weak typeof(self) wkSelf = self;
    if ([[NSThread currentThread] isMainThread]) {
        [self checkIfPushLuanchControllerOnMainThread];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONG(wkSelf)
            [wkSelf checkIfPushLuanchControllerOnMainThread];
            
        });
    }

    
}

-(void)checkIfPushLuanchControllerOnMainThread {
    if(self.isVoipCallInitialized) {
        return;
    }
    NSLog(@"ad-voip, tryToShowLaunchAD");
    HangupCommercialModel *cachedModel = [LaunchADController getPlistModel];
    NSLog(@"ad-voip, tryToShowLaunchAD, cachedModel: %@", cachedModel);
    if (cachedModel && cachedModel.idws) {
        // find the cached model
        NSString *uuid = [[AdStatManager instance] genenrateUUID];
        LaunchADController *launchADController  = [[LaunchADController alloc] initWithADModel:cachedModel
                                                                                         uuid:uuid
                                                                        viewDidAppearCallback:^(){
                                                                        }];
        [[TouchPalDialerAppDelegate naviController] pushViewController:launchADController animated:NO];
        PrepareAdItem *prepare = [[PrepareAdManager instance] getPrepareAdItem:kAD_TU_LAUNCH];
        [[AdStatManager instance] commitCommericalStat:kAD_TU_LAUNCH pst:prepare.uuid st:uuid];
    } else {
        // no cache or do not show the launch-ad
        NormalLaunchViewController *normalLaunchController =[[NormalLaunchViewController alloc] init];
        [[TouchPalDialerAppDelegate naviController] pushViewController:normalLaunchController animated:NO];
        PrepareAdItem *prepare = [[PrepareAdManager instance] getPrepareAdItem:kAD_TU_LAUNCH];
        [LaunchADController asyncGetLaunchADWithUuid:[[AdStatManager instance] genenrateUUID] preUuid:prepare.uuid];
    }
}



@end


