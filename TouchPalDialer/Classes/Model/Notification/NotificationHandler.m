//
//  RemoteNotificationHandler.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/7/23.
//
//

#import "NotificationHandler.h"
#import "DefaultUIAlertViewHandler.h"
#import "NoahManager.h"
#import "HandlerWebViewController.h"
#import "LoginController.h"
#import "UserDefaultsManager.h"
#import "MarketLoginController.h"
#import "TouchPalDialerAppDelegate.h"
#import "RootScrollViewController.h"
#import "SkinSettingViewController.h"
#import "CootekNotifications.h"
#import "DialerUsageRecord.h"
#import "TouchpalVersionInfo.h"
#import "PublicNumberListController.h"
#import "SeattleFeatureExecutor.h"
#import "HangupCommercialManager.h"
#import "AdMessageModel.h"
#import "TPVoipPrivilegeADView.h"
#import "TPEntryViewController.h"
#import "FunctionUtility.h"

@implementation NotificationHandler

+ (void)handleNotification:(NSDictionary*)userInfo {
    if ([[userInfo allKeys] containsObject:@"id"]) {
        NSString *notiId = [userInfo objectForKey:@"id"];
        if (notiId.length > 0) {
            [DialerUsageRecord recordpath:PATH_REMOTE_NOTIFICATION kvs:Pair(CLICK_REMOTE_NOTIFICATION, notiId), nil];
        }
        NSString *action = [self getNotificationAction:userInfo];
        NotificationType type = [self getNotificationActionType:userInfo];
        [self doActionFromNotification:action withType:type];
    } else if ([[userInfo allKeys] containsObject:@"limit"]) {
        [self doActionFromNotification:nil withType:NOTIFICATION_ACTION_TYPE_EXTRA_VIP];
    }
    
}

+ (NotificationType) getNotificationActionType:(NSDictionary*)userInfo {
    if ([[userInfo allKeys] containsObject:@"url"]) {
        return NOTIFICATION_ACTION_TYPE_URL;
    } else if ([[userInfo allKeys] containsObject:@"controller"]) {
        return NOTIFICATION_ACTION_TYPE_CONTROLLER;
    } else if ([[userInfo allKeys] containsObject:@"dialog"]) {
        return NOTIFICATION_ACTION_TYPE_DIALOG;
    }
    return [self getTypeByExtra:userInfo];
}

+ (NSString*) getNotificationAction:(NSDictionary*)userInfo {
    if ([[userInfo allKeys] containsObject:@"url"]) {
        return [userInfo objectForKey:@"url"];
    } else if ([[userInfo allKeys] containsObject:@"controller"]) {
        return [userInfo objectForKey:@"controller"];
    } else if ([[userInfo allKeys] containsObject:@"dialog"]) {
        return [userInfo objectForKey:@"dialog"];;
    }
    return nil;
}

+ (void)parseDialogAction:(NSString*)dialogString {
    NSData *data = [dialogString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error =nil;
    NSMutableDictionary *contentDic= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
    NSString *title = [contentDic objectForKey:@"title"];
    NSString *subtitle = [contentDic objectForKey:@"subtitle"];
    NSString *dialogType = @"default";
    if ([[contentDic allKeys] containsObject:@"type"]) {
        dialogType = [contentDic objectForKey:@"type"];
    }
    
    NSString *cancelTitle = nil;
    NSString *cancelAction = nil;
    NotificationType cancelActionType = NOTIFICATION_ACTION_TYPE_UNKNOWN;
    if ([[contentDic allKeys] containsObject:@"cancel"]) {
        NSDictionary *cancelDic = [contentDic objectForKey:@"cancel"];
        cancelTitle = [cancelDic objectForKey:@"title"];
        NSDictionary *cancelActionDic = [cancelDic objectForKey:@"action"];
        if ([cancelActionDic allKeys].count > 0) {
            cancelAction = [self getNotificationAction:cancelActionDic];
            cancelActionType = [self getNotificationActionType:cancelActionDic];
        }

    }
    
    NSString *confirmTitle = nil;
    NSString *confirmAction = nil;
    NotificationType confirmActionType = NOTIFICATION_ACTION_TYPE_UNKNOWN;
    if ([[contentDic allKeys]containsObject:@"confirm"]) {
        NSDictionary *confirmDic = [contentDic objectForKey:@"confirm"];
        confirmTitle = [confirmDic objectForKey:@"title"];
        NSDictionary *confirmActionDic = [confirmDic objectForKey:@"action"];
        if ([confirmActionDic allKeys].count > 0) {
            confirmAction = [self getNotificationAction:confirmActionDic];
            confirmActionType = [self getNotificationActionType:confirmActionDic];
        }
    }
    if ([dialogType isEqualToString:@"default"]) {
        [DefaultUIAlertViewHandler showAlertViewWithTitle:title message:subtitle cancelTitle:cancelTitle okTitle:confirmTitle okButtonActionBlock:^{
            if (confirmActionType == NOTIFICATION_ACTION_TYPE_CONTROLLER || confirmActionType == NOTIFICATION_ACTION_TYPE_URL) {
                [self doActionFromNotification:confirmAction withType:confirmActionType];
            }
        }cancelActionBlock:^{
            if (cancelActionType == NOTIFICATION_ACTION_TYPE_CONTROLLER || cancelActionType == NOTIFICATION_ACTION_TYPE_URL) {
                [self doActionFromNotification:cancelAction withType:cancelActionType];
            }
        }];
    }
    
}

+ (void)doActionFromNotification:(NSString*)action withType:(NSInteger)type {
    switch (type) {
        case NOTIFICATION_ACTION_TYPE_CONTROLLER:
            if ([action isEqualToString:@"SkinSettingViewController"]) {
                SkinSettingViewController *vc = [[SkinSettingViewController alloc] init];
                vc.startPage = REMOTE_TAB_SKIN_INDEX;
                [[TouchPalDialerAppDelegate naviController] pushViewController:vc animated:YES];
            } else if ([action isEqualToString:@"DialerViewController"]) {
                [self pushViewToRootViewController:@"1"];
            } else if ([action isEqualToString:@"ContactViewController"]) {
                [self pushViewToRootViewController:@"0"];
            } else if ([action isEqualToString:@"YellowPageMainTabController"]) {
                [self pushViewToRootViewController:@"2"];
            } else if ([action isEqualToString:@"PublicNumberListController"]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:N_PUBLIC_NUMBER_UPDATE object:nil];
                        [[NoahManager sharedInstance] lauchLocalController:action];
                    });
                });
            } else {
                [[NoahManager sharedInstance] lauchLocalController:action];
            }
            break;
        case NOTIFICATION_ACTION_TYPE_URL: {
            for(UIViewController *controller in [TouchPalDialerAppDelegate naviController].viewControllers) {
                if ([controller isKindOfClass:[TPEntryViewController class]]) {
                    [FunctionUtility removeFromStackViewController:controller];
                }
            }
            if ([action isEqualToString:TOUCHPAL_DIALER_APP_STORE_URL]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TOUCHPAL_DIALER_APP_STORE_URL]];
            } else if ([action hasPrefix:@"[Login]"]) {
                MarketLoginController *marketLoginController = [MarketLoginController withOrigin:@"personal_center_market"];
                marketLoginController.url = [action stringByReplacingOccurrencesOfString:@"[Login]" withString:@""];
                [LoginController checkLoginWithDelegate:marketLoginController];
                [UserDefaultsManager setBoolValue:NO forKey:NOAH_GUIDE_POINT_MARKET];
            } else {
                [[NoahManager sharedInstance] openUrl:action WebTitle:@"" RequestToken:NO];
            }
            break;
        }
        case NOTIFICATION_ACTION_TYPE_DIALOG:
            [self parseDialogAction:action];
            break;
        case NOTIFICATION_ACTION_TYPE_EXTRA_VIP: {
            NSDictionary *ads = [SeattleFeatureExecutor getVoipPrivilegeAdInfoWithOtherNumber:@"" andCallType:CALL_TYPE_C2P];
            HangupCommercialModel *vipADModel = ads[kAD_TU_VOIP_PRIVILEGE];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_VOIP_PRIVILEGE_AD_DATA_READY object:vipADModel];
            break;
        }
        default:
            break;
    }
}

+ (void)pushViewToRootViewController:(NSString*)indexStr {
    while (![[TouchPalDialerAppDelegate naviController].topViewController isKindOfClass:[RootScrollViewController class]]) {
        [[TouchPalDialerAppDelegate naviController] popToRootViewControllerAnimated:NO];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_JUMP_TO_REGISTER_INDEX_PAGE object:indexStr];
    if ([indexStr isEqualToString:@"1"]) {
        [[PhonePadModel getSharedPhonePadModel] setPhonePadShowingState:YES];
    }
}

+ (NotificationType) getTypeByExtra:(id) extraInfo {
    if ([[extraInfo allKeys] containsObject:@"limit"]) {
        NSNumber *limit = [extraInfo objectForKey:@"limit"];
        if ([limit intValue] == 1) {
            double notiTime = [[extraInfo objectForKey:@"time"] doubleValue];
            NSDate *dateNow = [[NSDate alloc] init];
            double diffTimeInSeconds = dateNow.timeIntervalSince1970 - notiTime;
            [DialerUsageRecord recordpath:PATH_VIP kvs:Pair(VIP_CALL_BACK, @(diffTimeInSeconds * 1000)), nil];
            if (notiTime > 0 && (diffTimeInSeconds <= VOIP_VIP_LIMIT_MAX_DELAY)) {
                return NOTIFICATION_ACTION_TYPE_EXTRA_VIP;
            }
        }
    }
    return NOTIFICATION_ACTION_TYPE_UNKNOWN;
}

@end
