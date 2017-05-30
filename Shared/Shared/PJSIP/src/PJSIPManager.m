//
//  PJSIPManager.m
//
//
//  Created by cootek on 4/9/14.
//  Copyright (c) 2014 Liangxiu. All rights reserved.
//

#import "PJSIPManager.h"
#import <CoreTelephony/CTCall.h>
#import "DefaultUIAlertViewHandler.h"
#import "UserDefaultsManager.h"
#import "UserDefaultKeys.h"
#import "Reachability.h"
#import "TouchPalVersionInfo.h"
#import "CootekNotifications.h"
#import "VOIPCall.h"
#import "TPCallActionController.h"
#import "FunctionUtility.h"
#import "DefaultLoginController.h"
#import "NoahManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "SIPConst.h"
#import "CallRingUtil.h"
#import <AVFoundation/AVFoundation.h>
#import "PJCore.h"
#import "PJCoreUtil.h"

@implementation PJSIPManager


+ (void)initialize{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppEnterBack)
                                                 name:N_APP_DID_ENTER_BACKGROUND
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetworkChanged)
                                                 name:N_REACHABILITY_NETWORK_CHANE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onVOIPSwitch)
                                                 name:N_REFRESH_IS_VOIP_ON
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
}

+ (void)onNetworkChanged {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
        if ([self isInit]) {
            [[PJCore instance] networkChanged];
        } else {
            if ([self canEnableVoip]) {
                [self chooseAndInit];
            }
        }
    });
}

+ (BOOL)checkInit {
    if ([self canEnableVoip]) {
        if ([self isInit]) {
            [[PJCore instance] keepOnline];
        } else {
            [self chooseAndInit];
        }
        return YES;
    }
    return NO;
}

+ (void)chooseAndInit {
    [[PJCore instance] initCore];
}

+ (NSString *)callingNumber {
    if ([self isCalling]) {
        return [[PJCore instance] callNumber];
    }
    return nil;
}

+ (int)callDuration {
    return [[PJCore instance] callDuration];
}

+ (BOOL)isAnswerIncomingCall {
    return [[PJCore instance] isAnswerIncomingCall];
}


+ (BOOL)canEnableVoip {
    ClientNetworkType netType = [[Reachability shareReachability] networkStatus];
    BOOL isVoipOn = [UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]
    && [UserDefaultsManager boolValueForKey:IS_VOIP_ON];
    if (!isVoipOn) {
        return NO;
    }
    return netType >= network_3g;
}

+ (BOOL)confercenceCall:(NSArray *)numbers withDelegate:(id<CallStateChangeDelegate>)delegate {
    if (![self prepareCall]) {
        return NO;
    }
    cootek_log(@"PJSIPManager call mode=conference,%@",[NSThread callStackSymbols]);
    if ([self isCalling]) {
        //is in call;
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"上一通电话还未完全挂断，请稍后再拨"
                                                  message:nil
                                  onlyOkButtonActionBlock:^() {
                                      [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:YES];
                                  }];
        return NO;
    }
    if ([numbers count] > 0) {
        NSString *number = [numbers componentsJoinedByString:@","];
        [[PJCore instance] inviteCall:number mode:VOIP_CALL_CONFERENCE delegate:delegate];
    }
    return false;
}

+ (BOOL)call:(NSString *)number callback:(BOOL)callback withDelegate:(id<CallStateChangeDelegate>)delegate
{

    if ([number length] == 0) {
        return NO;
    }
    if (![self prepareCall]) {
        return NO;
    }
    cootek_log(@"PJSIPManager call mode=%d,%@",callback,[NSThread callStackSymbols]);
    if ([self isCalling]) {
        //is in call;
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@"上一通电话还未完全挂断，请稍后再拨"
                                                  message:nil
                                  onlyOkButtonActionBlock:^() {
            [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:YES];
        }];
        return NO;
    }

    [[PJCore instance] inviteCall:number mode:callback ? VOIP_CALL_BACK:VOIP_CALL_DIRECT delegate:delegate];
    
    return YES;
}

+ (void)hangup:(NSString *)info
{
    if (![self isCalling]){
        return;
    }
    [[PJCore instance] hangup:info];
}

+ (void)mute:(BOOL)isMute {
    if (![self isCalling]){
        return;
    }
    [[PJCore instance] setCallMute:isMute];
}

+ (void)updateC2Cmute {
    if (![self isCalling]){
        return;
    }
    [[PJCore instance] setCallMute];
}

+ (void)setSpeakerEnabled:(BOOL)enable {
    if (![self isCalling]){
        return;
    }
    [[PJCore instance] setCallSpeaker:enable];
}

+ (BOOL)acceptIncomingCall {
    if (![self isCalling]){
        return false;
    }
    [[PJCore instance] answer];
    return true;
}

+ (void) destroy
{
    if ([self isInit]) {
        [[PJCore instance] deinitPJCore];
    }

}

#pragma mark - Audio route Functions

+ (BOOL)prepareCall
{
    if ([PJCoreUtil isNormalCalling]) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:@""
                                                  message:@"已处于通话中，不能再发起新通话"
                                  onlyOkButtonActionBlock:^() {
                                       [[TouchPalDialerAppDelegate naviController] popViewControllerAnimated:YES];
                                  }];
        
		return NO;
    }
    return YES;
}

+ (void)keepAlive {
    if (![self canEnableVoip]) {
        return;
    }
    [[PJCore instance] keepOnline];
}

+ (void)onAppEnterBack {
    if (![self canEnableVoip]) {
        return;
    }
    
    [[UIApplication sharedApplication] setKeepAliveTimeout:600
                                                   handler:^{

       [self keepAlive];
       BOOL hasRemind = [UserDefaultsManager boolValueForKey:VOIP_INTERNATIONAL_ROAMING_REMINDER];
       BOOL isIntl = ![FunctionUtility isInChina];
       if (isIntl && !hasRemind) {
           [VOIPCall alertInternationalRoaming];
           [UserDefaultsManager setBoolValue:YES forKey:VOIP_INTERNATIONAL_ROAMING_REMINDER];
       }
        
        [[NoahManager sharedPSInstance] presentationUpdate];
        if ([FunctionUtility isTimeUpForEvent:INTERVAL_APP_ACTIVATE
                                 withSchedule:3600*12
                               firstTimeCount:YES
                                 persistCheck:YES]) {
           NSString* channelId = IPHONE_CHANNEL_CODE;
           if ([channelId isEqualToString:@"010100"]) {
               channelId = nil;
           }
        }
     }
     ];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10) {
        [[PJCore instance] unregister];
    }
}

+ (BOOL)isCalling{
    return [[PJCore instance] isCalling];
}

    
+ (void)setCallStateDelegate:(id<CallStateChangeDelegate>)delegate {
    [[PJCore instance] setCallStatusDelegate:delegate];
}

+ (BOOL)isInit {
    return [[PJCore instance] isInit];
}

+ (void)audioInterruption:(NSNotification *)notifcation {
    
    NSDictionary *info = [notifcation userInfo];
    cootek_log(@"audioInterruption = %@,%@",info,NSStringFromClass(info.class));
    if (info == nil) {
        return;
    }
    int type = [[info objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if(type == AVAudioSessionInterruptionTypeEnded) {
        [[PJCore instance] connectDevice];
    }
}

+ (void)onVOIPSwitch {
    BOOL isVoipOn = [UserDefaultsManager boolValueForKey:IS_VOIP_ON];
    if (isVoipOn) {
        [self checkInit];
    } else {
        [self destroy];
    }
}

+ (void)sendDTMF:(NSString *)chr
{
     if ([self isCalling]) {
         [[PJCore instance] sendDTMF:chr];
     }
}

@end
