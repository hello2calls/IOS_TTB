//
//  LoginController.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/2/11.
//
//

#import "LoginController.h"
#import "UserDefaultsManager.h"
#import "CommonLoginViewController.h"
#import "SeattleFeatureExecutor.h"
#import "UserDefaultsManager.h"
#import "AppSettingsModel.h"
#import "ScheduleInternetVisit.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"
#import "CallerIDInfoModel.h"
#import "SeattleExecutorHelper.h"
#import "TouchpalHistoryManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "TaskBonusManager.h"
#import "PJSIPManager.h"
#import "CootekNotifications.h"
#import "FunctionUtility.h"
#import "PushConstant.h"
#import "XinGePushManager.h"
#import "NoahManager.h"
#import "YPFeedsTask.h"
#import "BiBiPairManager.h"

@implementation LoginController
static CommnonLoginViewController *sLoginController;

+ (void)checkLoginWithDelegate:(id<LoginProtocol>)delegate{
    if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        NSDictionary *loginInfo = nil;
        if ([(id)delegate respondsToSelector:@selector(preInfo)]) {
            loginInfo = [delegate preInfo];
        }
        sLoginController = [CommnonLoginViewController loginWithPreInfo:loginInfo successNetBlock:^void{
            [self onLoginSuccessForNetOperaion:[delegate getIdentifyController]];
            } successUIBlock:^{
                
                if ([(id)delegate respondsToSelector:@selector(jumpSomeWhereAfterLogin:)]) {
                        [delegate jumpSomeWhereAfterLogin:YES];
                    [FunctionUtility removeFromStackViewController:sLoginController];
                } else {
                        [FunctionUtility removeFromStackViewController:sLoginController];
                }
                if ([(id)delegate respondsToSelector:@selector(doSomeThingAfterLoginSuccess)]) {
                    [delegate doSomeThingAfterLoginSuccess];
                }
            } failedNetBlock:^{
               [DialerUsageRecord recordpath:EV_VOIP_REGISGTER kvs:Pair(@"action", @"failed"), nil];
            } failedUIBlock:^{
                if ([(id)delegate respondsToSelector:@selector(doSomeThingAfterLoginFailed)]) {
                    [delegate doSomeThingAfterLoginFailed];
                }

            }];
        } else {
            if ([(id)delegate respondsToSelector:@selector(jumpSomeWhereAfterLogin:)]) {
                [delegate jumpSomeWhereAfterLogin:YES];
            }
        }
}

+ (void)setRegisterNumber:(NSString*)number{
    [sLoginController setRegisterNumber:number];
}

+ (void)onLoginSuccessForNetOperaion:(LoginControllerType)loginControllerType {
    NSDictionary *before = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO];
    if (!before) {
        NSDictionary *accountInfo = @{@"cards":@"0", @"bytes_f":@"0.00", @"coins":@"0.00", @"saved":@"0.00", @"minutes":@"0"};
        [UserDefaultsManager setObject:accountInfo forKey:VOIP_ACCOUNT_INFO];
    }
    [SeattleFeatureExecutor queryVOIPAccountInfo];
    [SeattleFeatureExecutor getVoipReward];
    if (loginControllerType != CALL_FLOW_PACKET &&
        loginControllerType != MARKET &&
        loginControllerType != PERSONAL_REDBAG) {
        [[AppSettingsModel appSettings] setSettingValue:[NSNumber numberWithBool:YES] forKey:IS_VOIP_ON];
        [UserDefaultsManager setBoolValue:YES forKey:TOUCHPAL_USER_HAS_LOGIN];
        [PJSIPManager checkInit];
        [[BiBiPairManager manager] asycBiBiPair];
    }
    if (loginControllerType == PERSONAL_CENTER_HEAD) {
        [UserDefaultsManager setIntValue:2 forKey:had_show_personCenterGuideStatus];
    }
    cootek_log(@"regisger success");
    [DialerUsageRecord recordpath:EV_VOIP_REGISGTER kvs:Pair(@"action", @"success"), nil];
    if (loginControllerType == START_VS_GUDIE) {
        [DialerUsageRecord recordpath:PATH_REGISTER_GUIDE_VIEW kvs:Pair(KEY_ACTION,VS_LOGIN_SUCCESS), nil];
    }else if(loginControllerType == START_COIN_GUDIE) {
        [DialerUsageRecord recordpath:PATH_REGISTER_GUIDE_VIEW kvs:Pair(KEY_ACTION,COIN_LOGIN_SUCCESS), nil];
    }else if(loginControllerType == TESTFREECALL_CLICK_TIP){
         [DialerUsageRecord recordpath:PATH_INAPP_TESTFREECALL_GUDIE kvs:Pair(KEY_ACTION,TESTFREECALL_TIP_LOGIN_SUCCESS), nil];
    }else if(loginControllerType == BEFORECALL){
        [DialerUsageRecord recordpath:PATH_CALL_REGISTER kvs:Pair(KEY_ACTION,BEFORECALL_LOGIN_SUCCESS), nil];
    }else if(loginControllerType == AFTERCALL){
        [DialerUsageRecord recordpath:PATH_CALL_REGISTER kvs:Pair(KEY_ACTION,AFTERCALL_LOGIN_SUCCESS), nil];
    }else if(loginControllerType == LONGCALL){
        [DialerUsageRecord recordpath:PATH_CALL_REGISTER kvs:Pair(KEY_ACTION,LONGCALL_LOGIN_SUCCESS), nil];
    }
    
    
    [UserDefaultsManager setBoolValue:YES forKey:VOIP_FIRST_LOGINED];
    
    [SeattleFeatureExecutor getAccountNumbersInfo];
    [SeattleFeatureExecutor getPersonProfile];
}

+ (void) removeLoginDefaultKeys{
    if (![UserDefaultsManager boolValueForKey:TOUCHPAL_USER_HAS_LOGIN]) {
        return;
    }
    [UserDefaultsManager removeObjectForKey:VOIP_REGISTER_ACCOUNT_NAME];
    [UserDefaultsManager removeObjectForKey:VOIP_REGISTER_SECRET_CODE];
    [UserDefaultsManager removeObjectForKey:IS_VOIP_ON];
    [FunctionUtility writeDefaultKeyToDefaults:@"group.com.cootek.Contacts" andObject:[NSString stringWithFormat:@"%d",[UserDefaultsManager boolValueForKey:IS_VOIP_ON defaultValue:NO]] andKey:@"isVoipOn"];
    [UserDefaultsManager removeObjectForKey:VOIP_BALANCE];
    [UserDefaultsManager removeObjectForKey:VOIP_IS_NEW_ACCOUNT];
    [UserDefaultsManager removeObjectForKey:VOIP_INVITATION_CODE];
    [UserDefaultsManager removeObjectForKey:VOIP_INVITATION_USED_COUNT];
    [UserDefaultsManager removeObjectForKey:VOIP_QUEUE_PAGE_HAS_VISIT];
    [UserDefaultsManager removeObjectForKey:TOUCHPAL_USER_HAS_LOGIN];
    [UserDefaultsManager removeObjectForKey:FLOW_BONUS];
    [UserDefaultsManager removeObjectForKey:VOIP_SHARE_TIME_COUNT];
    [UserDefaultsManager removeObjectForKey:VOIP_LOGIN_QUEUE_NUMBER_TIME];
    [UserDefaultsManager removeObjectForKey:VOIP_USER_EXIST_CHECK_TIME];
    [UserDefaultsManager removeObjectForKey:PERSON_PROFILE_GENDER];
    [UserDefaultsManager removeObjectForKey:PERSON_PROFILE_TYPE];
    [UserDefaultsManager removeObjectForKey:PERSON_PROFILE_URL];
    
    [UserDefaultsManager removeObjectForKey:VOIP_IF_PRIVILEGA];
    [UserDefaultsManager removeObjectForKey:VOIP_PRIVILEGA_EXPIRED_TIME];
    [UserDefaultsManager removeObjectForKey:VOIP_FIND_PRIVILEGA_SERVICE_TIME];
    [UserDefaultsManager removeObjectForKey:VOIP_FIND_PRIVILEGA_DAY];
    [UserDefaultsManager removeObjectForKey:have_join_wechat_public_status];
    
    [UserDefaultsManager removeObjectForKey:VOIP_ACCOUNT_INFO];
    [UserDefaultsManager removeObjectForKey:VOIP_ACCOUNT_INFO_DIFF];
    
    //[UserDefaultsManager removeObjectForKey:[NSString stringWithFormat:@"%@%d",TASK_BONUS_ID_,FLOW_CALL_ID]];
    [UserDefaultsManager removeObjectForKey:[NSString stringWithFormat:@"%@%d",TASK_BONUS_TIME_,FLOW_CALL_ID]];
    
    //Feeds info
    [UserDefaultsManager removeObjectForKey:FEEDS_QEURY_RED_PACKET_TIME];
    [UserDefaultsManager removeObjectForKey:FEEDS_QEURY_SIGN_TIME];
    
    [TouchpalHistoryManager deleteAllData];
    [PJSIPManager destroy];
    cootek_log(@"logout, xinge userid-clientid cancel map");
    [UserDefaultsManager setBoolValue:NO forKey:XINGE_ADDUSER_SUCCESS];
    [AppSettingsModel appSettings].dialerMode = DialerModeNormal;
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        BOOL logoutSuc = [SeattleFeatureExecutor logout];
        if (logoutSuc) {
            cootek_log(@"logout success, xinge userid-clientid begin rebuild new map");
            NSString *token = [SeattleFeatureExecutor getToken];
            cootek_log(@"new token: %@", token);
            NSString *deviceTokenStr = [UserDefaultsManager stringForKey:XINGE_DEVICE_TOKEN];
            [[NoahManager sharedPSInstance] registerDevice:deviceTokenStr];
        }
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:N_VOIP_LOGINOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_TOUCHPAL_NODE_ALERT object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_REFRESH_ALL_VIEW_CONTROLLER object:nil];
}


@end
