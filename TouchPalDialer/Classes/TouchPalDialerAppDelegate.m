//
//  TouchPalDialerAppDelegate.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/15/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#define IOS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#import <Bugly/Bugly.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonDigest.h>
#import <CallKit/CallKit.h>
#import "TouchPalDialerAppDelegate.h"
#import "CootekNotifications.h"
#import "DeviceSim.h"
#import "SyncContactWhenAppEnterForground.h"
#import "ContactPropertyCacheManager.h"
#import "NewFeatureGuideManager.h"

#import "GroupDBA.h"
#import "ContactGroupSyncService.h"
#import "TPShareController.h"
#import "YellowCityDataManager.h"

#import "SmartDailerSettingModel.h"
#import "CallLog.h"
#import "TPUncaughtExceptionHandler.h"
#import "RootScrollViewController.h"
#import "DialerViewController.h"
#import "TPAddressBookWrapper.h"
//#import "FeatureGuideTipsController.h"

#import "AdvancedCalllog.h"
#import "AddressBookAccessUtility.h"
#import "CootekSystemService.h"
#import "ScheduleTaskManager.h"
#import "UIDevice+SystemVersion.h"
#import "UserDefaultsManager.h"
#import "DefaultUIAlertViewHandler.h"
#import "NetworkUtility.h"

#import "ContactCacheDataManager.h"
#import "AppSettingsModel.h"
#import "Reachability.h"
#import "BackupAttributeConfigurator.h"
#import "SeattleExecutorHelper.h"
#import "ScheduleInternetVisit.h"
#import "TouchpalMembersManager.h"
#import "NoahManager.h"
#import "UperUsageAssist.h"
#import <Usage_iOS/UsageRecorder.h>
#import "DialerUsageRecord.h"
#import <mach/mach.h>
#import "ACTReporter.h"
#import "TaeClient.h"
#import "TouchpalMembersManager.h"
#import "QQShareController.h"
#import "VoipUtils.h"
#import <AlipaySDK/AlipaySDK.h>
#import "TPDialerResourceManager.h"
#import "WXApi.h"
#import "PJSIPManager.h"
#import "VOIPCall.h"
#import "NotificationAlertManger.h"
#import "AlipayController.h"

#import <AVFoundation/AVFoundation.h>
#import "CallerIdModel.h"
#import "FunctionUtility.h"
#import "TPCallActionController.h"
#import "UpdateService.h"
#import "NotificationHandler.h"

#import "XinGePushManager.h"
#import "PushConstant.h"
#import "PublicNumberListController.h"

#import "YPNavigationTask.h"
#import "YellowPageMainQueue.h"
#import "AntiharassGuideController.h"
#import <CoreTelephony/CTCallCenter.h>
#import "PersonDBA.h"
#import "CommonTipsWithBolckView.h"
#import "AntiharassmentViewController.h"
#import "EdurlManager.h"
#import "YellowPageWebViewController.h"
#import "CTUrl.h"
#import "TPAnalyticConstants.h"
#import "SixpackUtil.h"
#import "TPPerformanceRecorder.h"
#import "VoipUrlUtil.h"
#import "AntiharassDataManager.h"
#import "TPDPhoneCallViewController.h"
#import "TouchPalDialerAppDelegate+RDVTabBar.h"
#import "RDVTabBarController+TPDExtension.h"

#import "GlobalVariables.h"
#import "TPFilterRecorder.h"
#import "TPDLib.h"
//#import <GrowingIO/Growing.h>
#import "RDVTabBarController.h"
#import "DiscoverAnimationButton.h"
#import <Masonry.h>
#import "SignBtnManager.h"
#import "FeedsSigninManager.h"
#import "FeedsBtnRefreshManager.h"
#import "TPDExperiment.h"
#import "YellowPageLocationManager.h"
#import "PushProvider.h"
#import "BiBiPairManager.h"

#define GROWING_IO_ID @"8a4ab35166a0a5d6"
#define GROWING_IO_URL_SCHEME @"growing.a77ddd37474d01ae"

@implementation TouchPalWindow

// Usually we don't need to override any of these functions.
// In case we need to debug event releate bugs, we can un-comment the following function,
// to see what event is triggered, and in which view it hits
//-(void) sendEvent:(UIEvent *)event {
//    cootek_log(@"send event %@", event);
//    [super sendEvent:event];
//}
- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        NSLog(@"got remote event"); // this never happens either
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            {
                NSLog(@"handle play/pause");
                break;
            }
            default:
                break;
        }
    }
}

@end

@implementation TouchPalApplication

// similar as TouchPalWindow, we can override some functions for debug usage.

@end

@interface TouchPalDialerAppDelegate (){
    UINavigationController *navigationController_;
    
    BOOL addressBookAccessibility_;
    UIView *addressBookAccessHintView_;
    
    UINavigationController *featureGuideNavigationController_;
    
    NotificationScheduler* notificationScheduler_;
    
    BOOL _didregisterCallBack;
    BOOL _shouldStopBg;
    NSString *_pasteBoardString;
    BOOL _needHandleRemoteNotification;
    UILocalNotification *_remoteToLocalNotification;
    BOOL _appNewStarted;
    
    // for statistics
    BOOL _isActiveDuringLaunch;
}
@end

@implementation TouchPalDialerAppDelegate

@synthesize window = _window;
@synthesize isUserRegisteredBefore;

#pragma mark -
#pragma mark Application lifecycle

- (void)showAddressBookHintPictureOnly
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frame];
    UIViewController *controller = [[UIViewController alloc] init];
    _window.rootViewController = controller;
    addressBookAccessHintView_ = [AddressBookAccessUtility accessHintImageView];
    addressBookAccessHintView_.frame = CGRectMake(0, 0, TPScreenWidth(), TPScreenHeight());
    [controller.view addSubview:addressBookAccessHintView_];
    [self.window makeKeyAndVisible];
}

- (void)removeAddressBookHintPicture
{
    [addressBookAccessHintView_ removeFromSuperview];
    addressBookAccessHintView_ = nil;
}

- (void)askForAddressBookAuthorization:(NSDictionary*) launchOptions
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook,
                                             ^(bool granted, CFErrorRef error) {
                                                 if (granted) {
                                                     dispatch_async(dispatch_get_main_queue(), ^
                                                                    {
                                                                        [self removeAddressBookHintPicture];
                                                                        addressBookAccessibility_ = true;
                                                                        [[TouchPalDialerLaunch getInstance] normalLaunchWithOptions:launchOptions];
                                                                        [[TouchPalDialerLaunch getInstance] didBecomeActiveFromStartOrPause];
                                                                        CFRelease(addressBook);
                                                                    });
                                                 }
                                             });
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
        [DialerUsageRecord recordpath:PATH_LOGOUT kvs:Pair(SHOW_STARTUP_GUIDE, @(1)), nil];
//        FeatureGuideTipsController *featureGuideController = [[FeatureGuideTipsController alloc] init];
//        [navigationController_ pushViewController:featureGuideController animated:NO];
    } else if (shouldShowAntiharassGuide) {
        [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_GUIDE_SHOWN, @(1)), nil];
        AntiharassGuideController *antiharassController = [[AntiharassGuideController alloc] init];
        PersonalCenterController *personalCenterController = [[PersonalCenterController alloc] init];
        NSMutableArray *controllers = [navigationController_.viewControllers mutableCopy];
        [controllers addObject:personalCenterController];
        [controllers addObject:antiharassController];
        [navigationController_ setViewControllers:controllers animated:NO];
    }

}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    if (![UsageRecorder sAssist]) {
        [UsageRecorder initialize:[[UperUsageAssit alloc] init]];
    }
    [TPPerformanceRecorder recordWithTime:CFAbsoluteTimeGetCurrent() forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_WILL_FINISH_LAUNCH byAction:PERFORMANCE_ACTION_END];
    return YES;
}

- (void)testModel {
    NSArray *array = @[@"1",@"1",@"1"];
    if(![UserDefaultsManager objectForKey:WELCOME_ASSISTANT_BUTTON_STATUS]){
        [UserDefaultsManager setObject:array forKey:WELCOME_ASSISTANT_BUTTON_STATUS];
    }
}

extern CFAbsoluteTime mainStartTime;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // please don`t add any code in this func, or it will be reverted
    // if you want to add some functions, please go to TouchPalLaunch.class and add into normalLaunchWithOptions
    cootek_log(@"#####start didFinishLaunchingWithOptions");
    //bugly初始化
    [Bugly startWithAppId:@"53fd61fa51"];

    [TPDExperiment runAllExperiment];
    //小熊猫未读消息
    [self testModel];
    
    if ([UserDefaultsManager boolValueForKey:GRAY_LEVEL_DISTRIBUTE defaultValue:NO]) {
        [UserDefaultsManager setBoolValue:YES forKey:ENABLE_V6_TEST_ME];
    }else{
        [UserDefaultsManager setBoolValue:NO forKey:ENABLE_V6_TEST_ME];
    }
    [self checkToEnableGrowingIO];
    addressBookAccessibility_ = [AddressBookAccessUtility isAccessible];
    [UserDefaultsManager setBoolValue:addressBookAccessibility_ forKey:CONTACT_ACCESSIBILITY];
    
    CFAbsoluteTime didLaunchStartTime = CFAbsoluteTimeGetCurrent();
    if (addressBookAccessibility_) {
        // statistics for app performance
        dispatch_async(dispatch_get_main_queue(), ^{
            [TPPerformanceRecorder recordWithTimeInterval:(didLaunchStartTime - mainStartTime) forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_MAIN_ENTRY];
        });
    }
    
    // login数据统计
    if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN defaultValue:NO]) {
        [TPFilterRecorder recordpath:PATH_LOGIN kvs:Pair(LOGIN_LAUNCH_APP, @(1)), nil];
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue]>=9 && [[UIDevice currentDevice].systemVersion floatValue]<10) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [PersonDBA getAllios9IdDic];
        });
    }
    
     [SixpackUtil setupExperiment:EXPERIMENT_SKIPBUTTON
                     alternatives:@[SKIPBUTTON_CIRLE, SKIPBUTTON_WAVE,
                                    SKIPBUTTON_COUNTDOWN,SKIPBUTTON_NORMAL]];
    
    if ( !addressBookAccessibility_ ){
        [self showAddressBookHintPictureOnly];
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        ABAddressBookRequestAccessWithCompletion(addressBook,
                                                 ^(bool granted, CFErrorRef error) {
                                                     dispatch_async(dispatch_get_main_queue(), ^
                                                                    {
                                                                        [self removeAddressBookHintPicture];
                                                                        addressBookAccessibility_ = granted;
                                                                        [UserDefaultsManager setBoolValue:granted forKey:CONTACT_ACCESSIBILITY];
                                                                        [self doLaunch:application didFinishLaunchingWithOptions:launchOptions];
                                                                        if ( addressBook != NULL )
                                                                            CFRelease(addressBook);
                                                                    });
                                                 });
        return YES;
    }
    
    _appNewStarted = YES;
    
    [self doLaunch:application didFinishLaunchingWithOptions:launchOptions];
    
    
    // statistics for app performance
    [TPPerformanceRecorder recordWithTimeInterval:(CFAbsoluteTimeGetCurrent() - didLaunchStartTime) forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_DID_FINISH_LAUNCH];
    
    [TPPerformanceRecorder recordWithTime:CFAbsoluteTimeGetCurrent() forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_DID_FINISH_LAUNCH byAction:PERFORMANCE_ACTION_END];
    return YES;
}


- (void)doLaunch:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // please don`t add any code in this func, or it will be reverted
    // if you want to add some functions, please go to TouchPalLaunch.class and add into normalLaunchWithOptions

    // WARNING: It is a big pitfall here, I have to comment this line to get around...
    //    _needHandleRemoteNotification = NO;

    [PushProvider instance];
    if ([FunctionUtility systemVersionFloat] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            cootek_log(@"UNUserNotificationCenter, requestAuthorizationWithOptions, granted= %d, error= %@",
                       granted, error);
        }];
        
    } else if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:UIUserNotificationTypeBadge|
                                                UIUserNotificationTypeSound|
                                                UIUserNotificationTypeAlert
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
    }
    
    /***************start ui******************/
    notificationScheduler_ = [[NotificationScheduler alloc] init];
    notificationScheduler_.pendingNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.backgroundColor = [UIColor whiteColor];
        self.tabBarController = [[RDVTabBarController alloc] init];
        self.tabBarController.delegate = self;
        [self setupAppRootViewController];
        
        UIButton* btn = [self.tabBarController customizeOverlayTabBarItemAtIndex:2 whenClick:^(id sender) {
            [self.tabBarController tabBar:self.tabBarController.tabBar didSelectItemAtIndex:2];
        }];
        
        [[SignBtnManager instance] createSignBtn: btn];
        
        [self.window setRootViewController:self.tabBarController];
        [self.window makeKeyAndVisible];
        self.tabBarController.tabBarHidden = YES;
    } else {
        RootScrollViewController *rootScroll = [[RootScrollViewController alloc] init];
        navigationController_ = [[UINavigationController alloc] initWithRootViewController:rootScroll];
        navigationController_.navigationBarHidden = YES;
        CGRect frame = [[UIScreen mainScreen] bounds];
        self.window = [[TouchPalWindow alloc] initWithFrame:frame];
        self.window.rootViewController = navigationController_;
        [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_UPDATE_IN_WIFI];
        [self.window makeKeyAndVisible];
    }

    /*******************************************/
    [[TouchPalDialerLaunch getInstance] normalLaunchWithOptions:launchOptions];
    cootek_log(@"#####end didFinishLaunchingWithOptions");

    NSDate *lastChangeSkinTime = (NSDate *)[UserDefaultsManager objectForKey:UserSkin_ChangedTime];
    if (lastChangeSkinTime.timeIntervalSince1970 - [NSDate date].timeIntervalSince1970 > 60 * 60 *24) {
        NSString *theme = [TPDialerResourceManager sharedManager].skinTheme;
        [DialerUsageRecord recordpath:PATH_SKIN kvs:Pair(SKIN_CHECK, theme), nil];
    }
    
    [UserDefaultsManager setObject:[NSDate date] forKey:UserSkin_ChangedTime];
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    cootek_log(@"注册失败，无法获取设备ID, 具体错误: %@", error);
    [DialerUsageRecord recordpath:PATH_APPLE_TOKEN kvs:Pair(GET_APPLE_TOKEN_ERROR, @"get device token error"), nil];
    if (_didregisterCallBack) {
        [UserDefaultsManager removeObjectForKey:APPLE_PUSH_TOKEN];
        [ScheduleInternetVisit onAppDidBecomeActive];
    }
    _didregisterCallBack = YES;
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenStr = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    cootek_log(@"Device Token: %@", deviceTokenStr);
    [UserDefaultsManager setObject:deviceTokenStr forKey:XINGE_DEVICE_TOKEN];
    [[NoahManager sharedPSInstance] registerDevice:deviceTokenStr];
    if (!_didregisterCallBack) {
        [UserDefaultsManager setObject:deviceTokenStr forKey:APPLE_PUSH_TOKEN];
        [ScheduleInternetVisit onAppDidBecomeActive];
    }
    _didregisterCallBack = YES;
}


-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([@"remote" isEqualToString:notification.alertAction]) {
        [NotificationHandler handleNotification:notification.userInfo];
    } else {
        [notificationScheduler_ application:application handleLocalNotification:notification];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    cootek_log(@"got remote notification : %@, %@, %@", userInfo, [userInfo objectForKey:@"web"], [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    //for noah
    [[NoahManager sharedPSInstance]processReceivedNotification:userInfo];
//    if (!_needHandleRemoteNotification) {
//        if ([[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
//            _remoteToLocalNotification = [[UILocalNotification alloc]init];
//            _remoteToLocalNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
//            _remoteToLocalNotification.alertAction = @"remote";
//            _remoteToLocalNotification.userInfo = userInfo;
//        }
//        return;
//    }
    [NotificationHandler handleNotification:userInfo];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [self tp_receiveRemoteNotificationWithUserInfo:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [GlobalVariables getInstance].lastExitTimeFromDiscoverTab = [NSDate date];
    if (!addressBookAccessibility_) {
        return;
    }

	cootek_log(@"#### app will resign active.");
     //dismiss the alert view, to avoid keypad that come with "edit to call" alert view cover alert views that comes from the system.
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        for (UIView *view in window.subviews) {
            if ([view isKindOfClass:[UIAlertView class]]) {
                UIAlertView *alertView = (UIAlertView *)view;
                [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:NO];
            }
        }
    }
    // stop playing the custom dial ring
    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC);
    dispatch_after(stopTime, dispatch_get_main_queue(), ^{
        [CootekSystemService stopPlayRecentSound];
    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // statistics for app performance
    CFAbsoluteTime didEnterForegroundTime = CFAbsoluteTimeGetCurrent();
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground) {
        CTCloseType closeType = UNKNOW;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kDisplayStatusLocked"]) {
            closeType = HOME;
        } else {
            closeType = LOCK;
        }
        [[EdurlManager instance] removeAllNewsRecordWithCloseType:closeType];
    }
    
    if (!addressBookAccessibility_) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_APP_DID_ENTER_BACKGROUND object:nil];
    cootek_log(@"#### app Did Enter Background.");
    
    [self keepAliveInBackground:application];
    
    [notificationScheduler_ notifyBackgroundNotificationBy:application];
    
    [SyncContactWhenAppEnterForground setNeedsRespondToABChange:YES];
    
    [[ScheduleTaskManager scheduleManager] beginScheduleTasks];
    [DialerUsageRecord recordCrashReport];
    [UsageRecorder send];
    [[NoahManager sharedInstance] onAppEnterBackground];
    if (_remoteToLocalNotification != nil) {
        [application scheduleLocalNotification:_remoteToLocalNotification];
    }
    _remoteToLocalNotification = nil;
    _needHandleRemoteNotification = YES;
    
    // statistics for app performance
    if (!_isActiveDuringLaunch) {
        [TPPerformanceRecorder recordWithTime:didEnterForegroundTime forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_WILL_ENTER_FOREGROUND byAction:PERFORMANCE_ACTION_END];
        [TPPerformanceRecorder recordWithTimeInterval:(CFAbsoluteTimeGetCurrent() - didEnterForegroundTime) forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_WILL_ENTER_FOREGROUND];
    }

}

- (BOOL)handleTPSchema:(NSURL *)url
{
    cootek_log(@"URL=%@",url);

    NSString *scheme = [url scheme];
    NSArray *supportedSchemes = [NSArray arrayWithObjects:@"tp",@"touchpal",@"ct",@"cootek",
                                 @"dialer",@"tpdialer",@"tpcontacts",nil];
    for (NSString* s in supportedSchemes) {
        if ([scheme isEqualToString:s]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // GrowingIO
//    if ([Growing handleUrl:url])  {
//        return YES;
//    }
    
    return ([[TPShareController controller] handleOpenURL:url] || [[QQShareController instance]handleOpenURL:url]);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [DialerUsageRecord recordpath:PATH_APPLICATION_TERMINATE kvs:nil, nil];
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler
{
    return [VoipUrlUtil handleUserActivity:userActivity];
}


- (BOOL)handleYellowPage:(NSURL *)url
{
    // GrowingIO
//    if ([Growing handleUrl:url])  {
//        return YES;
//    }
    
    NSString *urlStr = [url absoluteString];
    NSRange callUrlRange = [urlStr rangeOfString:@"touchpal://callNumber:"];
    NSRange updateUrlRange = [urlStr rangeOfString:@"touchpal://update"];
    NSRange yellowpageOpenUrlRange = [urlStr rangeOfString:@"touchpal://yellowpageOpenUrl?"];
    if ( callUrlRange.length > 0){
        UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
        if ( [[navi.viewControllers objectAtIndex:0] isKindOfClass:[RootScrollViewController class]]){
            RootScrollViewController *con = [navi.viewControllers objectAtIndex:0];
            [con selectTabIndex:1];
        }
        [navi popToRootViewControllerAnimated:NO];
        
        NSString *number = [urlStr substringFromIndex:callUrlRange.length+callUrlRange.location];
        CallLogDataModel *call_model = [[CallLogDataModel alloc] init];
        call_model.number = number;
        [[TPCallActionController controller] makeCall:call_model];
    }
    if (updateUrlRange.length>0) {
        UINavigationController *navi = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
        if ( [[navi.viewControllers objectAtIndex:0] isKindOfClass:[RootScrollViewController class]]){
            RootScrollViewController *con = [navi.viewControllers objectAtIndex:0];
            [con selectTabIndex:1];
        }
        [navi popToRootViewControllerAnimated:NO];
        [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_UPDATE_FROM_TODAYWIDGET];
        [DialerUsageRecord recordpath:PATH_ANTIHARASS_UPDATEVIEW kvs:Pair(UPDATEVIEW_IN_TODAY, @(1)), nil];
            CommonTipsWithBolckView *tips = [[CommonTipsWithBolckView alloc]initWithtitleString:nil lable1String:NSLocalizedString(@"It may take a little time to update the Update Now", "")  lable1textAlignment:1 lable2String:nil lable2textAlignment:0 leftString:@"暂不更新" rightString:@"立即更新" rightBlock:^{
            AntiharassmentViewController *con = [[AntiharassmentViewController alloc]init];
            PersonalCenterController *PersonalCenter = [[PersonalCenterController alloc] init];
            NSMutableArray *array = [[TouchPalDialerAppDelegate naviController].viewControllers mutableCopy];
            [array addObjectsFromArray:@[PersonalCenter,con]];
            [[TouchPalDialerAppDelegate naviController] setViewControllers:array animated:YES];
            [con updateAntiharassVersionInDialerVC];
            [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_UPDATE_FROM_TODAYWIDGET];
            [DialerUsageRecord recordpath:PATH_ANTIHARASS_UPDATEVIEW kvs:Pair(UPDATEVIEW_IN_TODAY, @(2)), nil];
        } leftBlock:nil];
        [DialogUtil showDialogWithContentView:tips inRootView:nil];
    }
    
    BOOL wasHandled = [[TaeSDK sharedInstance]handleOpenURL:url];
    if ([url.host isEqualToString:@"safepay"]) {
        
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback: ^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            [[AlipayController instance] handleResultDic:resultDic];
        }];
        
        return YES;
    }
    
    if (yellowpageOpenUrlRange.length > 0) {
        NSString *urlParamString = [urlStr substringFromIndex:yellowpageOpenUrlRange.length+yellowpageOpenUrlRange.location];
        if(urlParamString != nil && [urlParamString isKindOfClass:[NSString class]] && [urlParamString hasPrefix:@"service_id="]){
            NSString *service_id = [urlParamString substringFromIndex:11];
            if (service_id != nil && [UserDefaultsManager objectForKey:[@"shortcut" stringByAppendingString:service_id]] != nil) {
                
                NSDictionary* json = (NSDictionary*)[UserDefaultsManager objectForKey:[@"shortcut" stringByAppendingString:service_id]];
                CTUrl* ctUrl = [[CTUrl alloc]initWithJson:json];
                [ctUrl startWebView];
                [DialerUsageRecord recordYellowPage:EV_YELLOWPAGE_OPEN_URL_FROM_DESK_TOP kvs:Pair(@"open_url_from_desk_shortcut", @"selected"), Pair(@"shortcut_url", ctUrl.url), nil];
                return YES;
            }
        }
    }
  return wasHandled;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return ([self handleYellowPage:url] || [VoipUrlUtil handleOpenURL:url] || [self handleTPSchema:url] ||
            [[TPShareController controller] handleOpenURL:url] ||
            [[QQShareController instance]handleOpenURL:url] || [[[TaeClient alloc ]init]handleOpenURL:url]);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    CFAbsoluteTime willEnterForegroundTime = CFAbsoluteTimeGetCurrent();
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisplayStatusLocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[TouchPalDialerLaunch getInstance] checkForStatusBarChange];
    if (!addressBookAccessibility_) {
        return;
    }
    
	cootek_log(@"#### app will enter foreground. === started");
    [[BiBiPairManager manager] asycBiBiPair];
	// when internet is accessible
    [notificationScheduler_ notifyForegroundNotificationBy:application];
    if (!_appNewStarted) {
        [ScheduleInternetVisit onAppDidBecomeActive];
    }
    _appNewStarted = NO;
    [PJSIPManager checkInit];
    _needHandleRemoteNotification = NO;
    
    // statistics for app performance
    if (!_isActiveDuringLaunch) {
        [TPPerformanceRecorder recordWithTime:willEnterForegroundTime forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_WILL_ENTER_FOREGROUND byAction:PERFORMANCE_ACTION_END];
        [TPPerformanceRecorder recordWithTimeInterval:(CFAbsoluteTimeGetCurrent() - willEnterForegroundTime) forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_WILL_ENTER_FOREGROUND];
    }
    
	cootek_log(@"#### app will enter foreground. === finished");

    [AntiharassDataManager updateCallExtensionEnableStatus];
    
    [[YellowPageLocationManager instance] requestLocationAuth:nil];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // please don`t add any code in this func, or it will be reverted
    // if you want to add some functions, please go to TouchPalLaunch.class
    
     // statistics for app performance
    
    [[GlobalVariables getInstance].applicationDidBecomeActiveSignal sendNext:nil];

    CFAbsoluteTime didBecomeActiveTime = CFAbsoluteTimeGetCurrent();
    
    [[NSNotificationCenter defaultCenter] postNotificationName:N_APP_ACTIVE_SHWO_PASTEBOARD object:nil];
    if (!addressBookAccessibility_) {
        return;
    }
    
    cootek_log(@"#### app Did become active.");
    
    if ([Reachability network]==network_wifi && [UserDefaultsManager boolValueForKey:APP_BECOME_ACTIVE_SHOW_BUILD_SUCCESS]) {
        UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [uiWindow makeToast:NSLocalizedString(@"骚扰号码库已经更新", "") duration:1.0f position:CSToastPositionBottom];
    }
    
    [UserDefaultsManager setBoolValue:NO forKey:APP_BECOME_ACTIVE_SHOW_BUILD_SUCCESS];
    
    _shouldStopBg = YES;
    [[TouchPalDialerLaunch getInstance] didBecomeActiveFromStartOrPause];
    
    // statistics for app performance
    if (!_isActiveDuringLaunch) {
        _isActiveDuringLaunch = YES;
        [TPPerformanceRecorder recordWithTime:didBecomeActiveTime forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_DID_BECOME_ACTIVE byAction:PERFORMANCE_ACTION_END];
        [TPPerformanceRecorder recordWithTimeInterval:(CFAbsoluteTimeGetCurrent() - didBecomeActiveTime) forPath:PATH_PERFORMANCE inDuration:PERFORMANCE_DID_BECOME_ACTIVE];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	cootek_log(@"*****************applicationDidReceiveMemoryWarning************");
}

-(void)keepAliveInBackground:(UIApplication *)application
{
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        cootek_log(@"###!!!One of keepAlive tasks is going to expire, and we have BackgroundTimeRemaing: %f",
                   [app backgroundTimeRemaining]);
        [app endBackgroundTask:bgTask];
    }];
}

- (BOOL)ifNumber:(NSString*)string{
    if ( string.length < 5 || string.length > 20)
        return NO;
    if ( [string hasPrefix:@"+"] ){
        return [self isPureInt:[string substringFromIndex:1]];
    }else{
        return [self isPureInt:string];
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UINavigationController*) activeNavigationController
{
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
       
            navigationController_ =  [TouchPalDialerAppDelegate naviController];
    } else {
        if (navigationController_ == nil) {
            navigationController_ = [TouchPalDialerAppDelegate naviController];
        }
    }
    
       return navigationController_;
}

- (NotificationScheduler*) notificationScheduler
{
    return notificationScheduler_;
}

+ (UINavigationController *)naviController {
    if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
        TouchPalDialerAppDelegate *delegate = (TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate];
        return (UINavigationController *)delegate.tabBarController.selectedViewController;
    } else {
        UINavigationController *appRootController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
        return appRootController;
    }
}

+ (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    YPNavigationTask* task = [YPNavigationTask new];
    task.type = TYPE_PUSH;
    task.viewController = viewController;
    [[YellowPageMainQueue instance] addTask:task];
}

+ (void)popViewControllerWithAnimated:(BOOL)animated
{
    YPNavigationTask* task = [YPNavigationTask new];
    task.type = TYPE_POP;
    [[YellowPageMainQueue instance] addTask:task];
}

- (void) application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [[TouchPalDialerLaunch getInstance] checkForStatusBarChange];
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIViewController *currentViewController = [self topViewController];
    
    if ([currentViewController respondsToSelector:@selector(canAutoRotate)]) {
        NSMethodSignature *signature = [currentViewController methodSignatureForSelector:@selector(canAutoRotate)];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        [invocation setSelector:@selector(canAutoRotate)];
        [invocation setTarget:currentViewController];
        
        [invocation invoke];
        
        BOOL canAutorotate = NO;
        [invocation getReturnValue:&canAutorotate];
        
        if (canAutorotate) {
            return UIInterfaceOrientationMaskAll;
        }
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)topViewController
{
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

//- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration  {
//    NSArray *windows = [application windows];
//    for (UIWindow *nextWindow in windows) {
//        [[nextWindow.rootViewController class] attemptRotationToDeviceOrientation];
//    }
//}

#pragma mark Remote Notification Hanlers
- (void) tp_receiveRemoteNotificationWithUserInfo:(NSDictionary *)userInfo {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if (userInfo == nil) {
        return;
    }
    cootek_log(@"got silent remote notification : %@, %@, %@", userInfo, [userInfo objectForKey:@"web"], [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    
    [[NoahManager sharedPSInstance]processReceivedNotification:userInfo];
    
    if ([userInfo objectForKey:@"limit"]) {
        [NotificationHandler handleNotification:userInfo];
    }
    
    if (!_needHandleRemoteNotification) {
        if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
            [NotificationHandler handleNotification:userInfo];
        }
//        if ([[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
//            _remoteToLocalNotification = [[UILocalNotification alloc]init];
//            _remoteToLocalNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
//            _remoteToLocalNotification.alertAction = @"remote";
//            _remoteToLocalNotification.userInfo = userInfo;
//        }
//        
        return;
        
    }
    [NotificationHandler handleNotification:userInfo];
}

#pragma mark - UNUserNotificationCenterDelegate
- (void) userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    _needHandleRemoteNotification = YES;
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self tp_receiveRemoteNotificationWithUserInfo:userInfo];
}

- (void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
}
#pragma mark SDKs
/*
    SDK info provided by GrowingIO :
    id: 8a4ab35166a0a5d6
    url scheme: growing.a77ddd37474d01ae
 
 */
- (BOOL) shouldEnableGrowingIO {
#ifdef DEBUG
    return NO;
#endif
    return [UserDefaultsManager boolValueForKey:ENABLE_GROWING_IO defaultValue:NO]
        && [UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO];
}

- (void) checkToEnableGrowingIO {
//    if ([self shouldEnableGrowingIO]) {
//        [Growing startWithAccountId:GROWING_IO_ID];
//#ifdef DEBUG
//        [Growing setEnableLog:YES];
//#endif
//    }
}

@end
