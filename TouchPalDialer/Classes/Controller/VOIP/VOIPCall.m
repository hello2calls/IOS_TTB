//
//  VOIPCall.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-10-29.
//
//

#import "VOIPCall.h"
#import "TouchPalDialerAppDelegate.h"
#import "CallViewController.h"
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
#import "CootekNotifications.h"
#import "CallbackWizardViewController.h"
#import "Reachability.h"
#import "SmartDailerSettingModel.h"
#import "Reachability.h"
#import "MagicUltis.h"
#import "PJSIPManager.h"
#import "NumberPersonMappingModel.h"
#import "ContactCacheDataManager.h"
#import "FunctionUtility.h"
#import "CootekSystemService.h"
#import "HangupController.h"
#import "DialerUsageRecord.h"
#import "IncomingNotificationManager.h"
#import <AVFoundation/AVFoundation.h>
#import "TPCallActionController.h"
#import "VoipCallPopUpView.h"
#import "CallInternationalWizardViewController.h"
#import "CallRingUtil.h"

@implementation VOIPCall
+ (void)makeConferenceCall:(NSArray *)conferenceNumbers {
    if (conferenceNumbers.count == 1) {
        [self makeCall:conferenceNumbers[0]];
    }else{
        // 国际电话要在makecall之前就过滤掉
        if ([self decideUsingCallBackMode]) {
            if (![UserDefaultsManager boolValueForKey:VOIP_CALLBACK_WIZARD_SHOWN defaultValue:NO]) {
                [[TouchPalDialerAppDelegate naviController] pushViewController: [CallbackWizardViewController instanceWithNumberArr:conferenceNumbers]animated:YES];
                [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLBACK_WIZARD_SHOWN];
            } else {
                [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumberArr:conferenceNumbers andCallMode:CallModeBackCall] animated:YES];
            }
        } else if ([UserDefaultsManager boolValueForKey:VOIP_CALL_CELL_DATA_HAS_REMIND] || [Reachability network] >= network_wifi){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumberArr:conferenceNumbers andCallMode:CallModeOutgoingCall] animated:YES];
            });
        } else {
            [DefaultUIAlertViewHandler showAlertViewWithTitle:@"使用免费电话会消耗流量，建议连接WiFi后使用" message:nil cancelTitle:@"取消" okTitle:@"继续拨打" okButtonActionBlock:^{
                [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumberArr:conferenceNumbers andCallMode:CallModeOutgoingCall] animated:YES];
            }];
            [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALL_CELL_DATA_HAS_REMIND];
        }
        [DialerUsageRecord recordpath:PATH_DIAL kvs:Pair(DIAL_TYPE_KEY, DIAL_VOIP_CALL), nil];
    }
    
    
}

+ (void)makeCall:(NSString *)number {
    if ([number isEqualToString:NSLocalizedString(@"touchpal_test_number", @"触宝测试专线")]) {
        [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumber:number andCallMode:CallModeTestType] animated:YES];
        return;
    }
    
    if ([self decideUsingCallBackMode]) {
        if (![UserDefaultsManager boolValueForKey:VOIP_CALLBACK_WIZARD_SHOWN defaultValue:NO]) {
            [[TouchPalDialerAppDelegate naviController] pushViewController: [CallbackWizardViewController instanceWithNumber:number]animated:YES];
            [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLBACK_WIZARD_SHOWN];
        } else {
            [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumber:number andCallMode:CallModeBackCall] animated:YES];
        }
    } else if ([UserDefaultsManager boolValueForKey:VOIP_CALL_CELL_DATA_HAS_REMIND] || [Reachability network] >= network_wifi){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[TPCallActionController alloc] getCallNumberTypeCustion:number]==VOIP_OVERSEA) {
                [UserDefaultsManager setBoolValue:YES forKey:VOIP_FIRST_INTERNATIONAL_CALL];
                 if (![UserDefaultsManager boolValueForKey:VOIP_CALLINTERNATIONAL_WIZARD_SHOWN defaultValue:NO]) {
                      [[TouchPalDialerAppDelegate naviController] pushViewController:[CallInternationalWizardViewController instanceWithNumber:number] animated:YES];
                     [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLINTERNATIONAL_WIZARD_SHOWN];
                     
                 }else{
                     [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumber:number andCallMode:CallModeOutgoingCall] animated:YES];
                 }
            }else{
            [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumber:number andCallMode:CallModeOutgoingCall] animated:YES];
            }
        });
        } else {
            if ([UserDefaultsManager boolValueForKey:@"show_vip_null" defaultValue:NO]) {
                [UserDefaultsManager setBoolValue:NO forKey:@"show_vip_null"];
                if ([[TPCallActionController alloc] getCallNumberTypeCustion:number]==VOIP_OVERSEA) {
                    if (![UserDefaultsManager boolValueForKey:VOIP_CALLINTERNATIONAL_WIZARD_SHOWN defaultValue:NO]) {
                        [[TouchPalDialerAppDelegate naviController] pushViewController:[CallInternationalWizardViewController instanceWithNumber:number] animated:YES];
                        [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLINTERNATIONAL_WIZARD_SHOWN];
                    }else{
                        [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumber:number andCallMode:CallModeOutgoingCall] animated:YES];
                    }
                }else{
                    [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumber:number andCallMode:CallModeOutgoingCall] animated:YES];
                }
            }else{
                [DefaultUIAlertViewHandler showAlertViewWithTitle:@"使用免费电话会消耗流量，建议连接WiFi后使用" message:nil cancelTitle:@"取消" okTitle:@"继续拨打" okButtonActionBlock:^{
                    if ([[TPCallActionController alloc] getCallNumberTypeCustion:number]==VOIP_OVERSEA) {
                        if (![UserDefaultsManager boolValueForKey:VOIP_CALLINTERNATIONAL_WIZARD_SHOWN defaultValue:NO]) {
                            [[TouchPalDialerAppDelegate naviController] pushViewController:[CallInternationalWizardViewController instanceWithNumber:number] animated:YES];
                            [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALLINTERNATIONAL_WIZARD_SHOWN];
                        }else{
                            [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumber:number andCallMode:CallModeOutgoingCall] animated:YES];
                        }
                    }else{
                        [[TouchPalDialerAppDelegate naviController] pushViewController:[CallViewController instanceWithNumber:number andCallMode:CallModeOutgoingCall] animated:YES];
                    }
                }];
                [UserDefaultsManager setBoolValue:YES forKey:VOIP_CALL_CELL_DATA_HAS_REMIND];
            }
    }
    [DialerUsageRecord recordpath:PATH_DIAL kvs:Pair(DIAL_TYPE_KEY, DIAL_VOIP_CALL), nil];
}

+ (void)makeTestCall:(NSString *)number {
    [[TouchPalDialerAppDelegate naviController] pushViewController:[CallInternationalWizardViewController instanceWithNumber:number] animated:YES];
}

+ (void)onIncomingCall:(NSString *)number {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        BOOL enableNotification = false;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0) {
            UIUserNotificationType type = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
            enableNotification = (type!= UIRemoteNotificationTypeNone);
        } else {
            enableNotification = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone);
        }
        if (enableNotification) {
             [self alertIncomingCall:number];
        } else {
            [CootekSystemService playVibrate];
            [CallRingUtil playIncomingRingTone];
        }
    } else {
        [self checkIncomingCall:number];
    }
    [DialerUsageRecord recordpath:PATH_DIAL kvs:Pair(DIAL_TYPE_KEY, DIAL_VOIP_INCOMING), nil];
}

+ (void)checkIncomingCall {
    NSString *number = [PJSIPManager callingNumber];
    if ([number length]  > 0) {
        [self checkIncomingCall:number];
    }
}

+ (void)checkIncomingCall:(NSString *)number {
    if (![PJSIPManager isInit]) {
        return;
    }
    if ([[[TouchPalDialerAppDelegate naviController] topViewController] isKindOfClass:[CallViewController class]]) {
        return;
    }
    if ([[[TouchPalDialerAppDelegate naviController] topViewController] isKindOfClass:[HangupController class]]) {
        [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:NO];
    }
    CallViewController *controller = [CallViewController instanceWithNumber:number andCallMode:CallModeIncomingCall];
    [PJSIPManager setCallStateDelegate:controller];
    [[TouchPalDialerAppDelegate naviController] pushViewController:controller animated:YES];
}

+ (BOOL)decideUsingCallBackMode {
    if (![UserDefaultsManager boolValueForKey:VOIP_BACK_CALL_ENABLE] ||
        ![UserDefaultsManager boolValueForKey:VOIP_AUTO_BACK_CALL_ENABLE defaultValue:YES]) {
        return NO;
    }
    if (![FunctionUtility isInChina]) {
        return NO;
    }
    NetworkStatus status = [Reachability network];
    if (status < network_3g) {
        return YES;
    }
    return NO;
}

+ (void)needToRegisterAgainWithOkBlock:(void(^)(void))okBlock cancelBlock:(void(^)(void))cancelBlock{
    if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        return;
    }
    [DefaultUIAlertViewHandler showAlertViewWithTitle:NSLocalizedString(@"voip_need_register_again", "")
                                              message:nil
                                          cancelTitle:NSLocalizedString(@"Cancel", "")
                                              okTitle:NSLocalizedString(@"Ok", "")
                                  okButtonActionBlock:^(){
                                      if (okBlock) {
                                          okBlock();
                                      }
                                  }
                                    cancelActionBlock:^(){
                                        if (cancelBlock) {
                                            cancelBlock();
                                        }
                                    }];
}

+ (void)alertIncomingCall:(NSString *)number {
    int personId = [NumberPersonMappingModel queryContactIDByNumber:number];
    NSString *displayName = number;
    if (personId > 0) {
        displayName = [[ContactCacheDataManager instance] contactCacheItem:personId].displayName;
    }
    [[IncomingNotificationManager instance] notifyIncomingCall:displayName];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

}



+ (void)alertInternationalRoaming {
    NotificationScheduler* scheduler = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) notificationScheduler];
    [scheduler scheduleBackgroundNotification:[TPInternationalRoamingNotification notification]];
}
@end
