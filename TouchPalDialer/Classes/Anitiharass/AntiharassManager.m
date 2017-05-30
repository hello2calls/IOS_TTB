//
//  AntiharassModelManager.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/10.
//
//

#import "AntiharassManager.h"
#import "AntiharassModelManager.h"
#import "AntiharassViewManager.h"
#import "UserDefaultsManager.h"
#import "CootekNotifications.h"
#import "Reachability.h"
#import "DialerUsageRecord.h"
#import "UIView+Toast.h"
@interface AntiharassManager() <AntiharassViewManagerDelegate,AntiharassModelManagerDelegate>{
}

@end

static AntiharassManager *instance;
static AntiharassViewManager *_viewManager;
static AntiharassModelManager *_modelMananger;

@implementation AntiharassManager

+ (void)initialize{
    instance = [[AntiharassManager alloc]init];
    _viewManager = [[AntiharassViewManager alloc]init];
    _viewManager.delegate = instance;
    _modelMananger = [[AntiharassModelManager alloc]init];
    _modelMananger.delegate = instance;
}

+ (AntiharassManager *)instance{
    return instance;
}

- (void)openAntiharass{
    BOOL ifFirstUsed = [UserDefaultsManager boolValueForKey:ANTIHARASS_USED defaultValue:NO];
    if ( ifFirstUsed ){
        if ( [self judgeNetworkWithView] ){
            [_viewManager showView:ANTIHARASS_VIEW_LOADING];
            [_modelMananger doTask:ANTIHARASS_NEW_BUILD_UPDATE_STEP];
        }else{
            [_modelMananger setLastTask:ANTIHARASS_NEW_BUILD_UPDATE_STEP];
        }
    }else{
        [_viewManager showView:ANTIHARASS_VIEW_FIRST_START];
    }
}

- (void)closeAntiharass{
    [_viewManager showView:ANTIHARASS_VIEW_REMOVE_CONFIRM];
}

- (void)updateAntiharass{
    if ( [self judgeNetworkWithView]){
        [_viewManager showView:ANTIHARASS_VIEW_LOADING];
        [_modelMananger doTask:ANTIHARASS_START_UPDATE];
    }else{
        [_modelMananger setLastTask:ANTIHARASS_START_UPDATE];
    }
}
- (void)updateAntiharassInWifiInBackground{
    if ( [self judgeNetwork] == 2){
        [UserDefaultsManager  setBoolValue:YES forKey:ANTIHARASS_IS_UPDATE_IN_WIFI];
        [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_VIEW_REFRESH object:nil];
        [_modelMananger doTask:ANTIHARASS_START_UPDATE_IN_WIFI_BACKGROUND];
    }
    else if([self judgeNetwork]==1){
        [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_VIEW_REFRESH object:nil];
         [_modelMananger doTask:ANTIHARASS_UPDATE_IN_BACKGROUND];
        [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_UPDATE_IN_WIFI];        
    }
}


- (void)checkUpdateInBackground{
 
    BOOL ifAntiharass = [UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON];
    if ( !ifAntiharass )
        return;
    BOOL contactAccess = [UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY];
    if ( !contactAccess )
        return;

    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_AUTOUPDATEINWIFI_ON defaultValue:YES]) {
        if ( [self judgeNetwork] == 2){
            [UserDefaultsManager  setBoolValue:YES forKey:ANTIHARASS_IS_UPDATE_IN_WIFI];
            [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_VIEW_REFRESH object:nil];
            [_modelMananger doTask:ANTIHARASS_START_UPDATE_IN_WIFI_BACKGROUND];
        }
        else if([self judgeNetwork]==1){
            [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_VIEW_REFRESH object:nil];
            [_modelMananger doTask:ANTIHARASS_UPDATE_IN_BACKGROUND];
            [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_UPDATE_IN_WIFI];
        }

    }else{
        [_modelMananger doTask:ANTIHARASS_UPDATE_IN_BACKGROUND];
    }
    
}

- (NSInteger)judgeNetwork{
    if ([Reachability network] == network_none && [[Reachability shareReachability] currentReachabilityStatus] == NotReachable ) {
        return 0;
    }
    if ([Reachability network] < network_wifi) {
        return 1;
    }
    return 2;
}

-(BOOL)judgeNetworkWithView{
    if ([self judgeNetwork]==0) {
        [_viewManager showView:ANTIHARASS_VIEW_NO_NETWORK];
        return NO;
    }
    if([self judgeNetwork]==1){
        [_viewManager showView:ANTIHARASS_VIEW_GPRS_CONFIRM];
        return NO;
    }
    return YES;
}



#pragma mark AntiharassViewManagerDelegate

- (void)finishViewStep:(AntiharassViewStep)step{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (step) {
            case ANTIHARASS_VIEW_FIRST_START:{
                if ( [self judgeNetworkWithView] ){
                    [_viewManager showView:ANTIHARASS_VIEW_LOADING];
                    [_modelMananger doTask:ANTIHARASS_NEW_BUILD_UPDATE_STEP];
                }else{
                    [_modelMananger setLastTask:ANTIHARASS_NEW_BUILD_UPDATE_STEP];
                }
                break;
            }
            case ANTIHARASS_VIEW_LOADING:{
                break;
            }
            case ANTIHARASS_VIEW_NO_NETWORK:{
                [_viewManager clearView];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
                break;
            }
            case ANTIHARASS_VIEW_GPRS_CONFIRM:{
                [_viewManager showView:ANTIHARASS_VIEW_LOADING];
                [_modelMananger doLastTask];
                break;
            }
            case ANTIHARASS_VIEW_NETWORK_ERROR:{
                [_viewManager showView:ANTIHARASS_VIEW_LOADING];
                [_modelMananger doLastTask];
                break;
            }
            case ANTIHARASS_VIEW_REMOVE_CONFIRM:{
                [_viewManager showView:ANTIHARASS_VIEW_REMOVE_LOADING];
                [_modelMananger doTask:ANTIHARASS_REMOVE_ADDRESSBOOK];
                break;
            }
            case ANTIHARASS_VIEW_SUCCESS:{
                if ( ![UserDefaultsManager boolValueForKey:ANTIHARASS_IS_FIRST_USED defaultValue:NO] ){
                    [_viewManager showView:ANTIHARASS_VIEW_GUIDE];
                    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_IS_FIRST_USED];
                }else{
                    [_viewManager clearView];
                }
                
                break;
            }
            case ANTIHARASS_VIEW_GUIDE:{
                [AntiharassUtil showGuidePage];
                [_viewManager clearView];
                break;
            }
            case ANTIHARASS_VIEW_REMOVE_SUCCESS:{
                [_viewManager clearView];
                break;
            }
            case ANTIHARASS_VIEW_VERSION_IS_NEWEST:{
                [_viewManager clearView];
                break;
            }
            default:
                break;
        }
    });
    
}

#pragma mark AntiharassModelManagerDelegate

- (void)doModelResult:(AntiharassModelResult)result{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (result) {
            case ANTIHARASS_NETWORK_ERROR:{
                if (![UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]) {
                        [_viewManager showView:ANTIHARASS_VIEW_NETWORK_ERROR];
                }else{
                    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_UPDATE_IN_WIFI];
                }
                break;
            }
            case ANTIHARASS_NEW_BUILD_NEED_UPDATE:{
                [_modelMananger doTask:ANTIHARASS_NEW_BUILD_DOWNLOAD_STEP];
                break;
            }
            case ANTIHARASS_NEW_BUILD_NOT_NEED_UPDATE:{
                [_modelMananger doTask:ANTIHARASS_NEW_BUILD_REMOVE_ADDRESSBOOK];
                break;
            }
            case ANTIHARASS_DOWNLOAD_SUCCESS:{
                [_modelMananger doTask:ANTIHARASS_NEW_BUILD_REMOVE_ADDRESSBOOK];
                break;
            }
            case ANTIHARASS_NEW_BUILD_REMOVE:{
                [_modelMananger doTask:ANTIHARASS_NEW_BUILD_BUILD_ADDRESSBOOK];
                break;
            }
            case ANTIHARASS_BUILD_SUCCESS:{
                [UserDefaultsManager setIntValue:[UserDefaultsManager intValueForKey:ANTIHARASS_TYPE] forKey:ANTIHARASS_DATABASE_TYPE];
                cootek_log(@"now version: %@ now city: %@",[UserDefaultsManager stringForKey:ANTIHARASS_VERSION],[AntiharassUtil getStringName:[UserDefaultsManager intValueForKey:ANTIHARASS_TYPE]]);
                [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_IS_ON];
                [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_USED];
                [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_SHOW_DOT];
                [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_CLOSE_TODAY_VIEW];

                [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_START_AND_UPDATE_SUCCESS, @(1)), nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_SWTICH_CHANGE object:nil];
                
                [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW];
                [[NSNotificationCenter defaultCenter] postNotificationName:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW object:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        if (![UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]) {
                            if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_SHOW_TODAY_VIEW]) {
                                if (![UserDefaultsManager boolValueForKey:ANTIHARASS_NOT_AUTO_SHOW_TODAY_VIEW_ONCE defaultValue:NO]){
                                [DialerUsageRecord recordpath:PATH_TODAYWIDGETANIMATION kvs:Pair(SHOW_AND_TOAST_SHOW, @(1)), nil];
                                }
                                UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
                                [uiWindow makeToast:NSLocalizedString(@"骚扰号码库更新完毕", "") duration:1.0f position:CSToastPositionBottom];
                                [_viewManager clickCancelButton];
                            }else{
                                [DialerUsageRecord recordpath:PATH_TODAYWIDGETANIMATION kvs:Pair(SHOW_AND_TOAST_SHOW, @(0)), nil];
                                [_viewManager showView:ANTIHARASS_VIEW_SUCCESS];
                            }
                        }else{
                            [UserDefaultsManager setBoolValue:NO  forKey:ANTIHARASS_IS_UPDATE_IN_WIFI];
                            if ([UIApplication sharedApplication].applicationState==UIApplicationStateActive) {
                                UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
                                [uiWindow makeToast:NSLocalizedString(@"骚扰号码库已经更新", "") duration:1.0f position:CSToastPositionBottom];
                            }
                            else{
                                [UserDefaultsManager setBoolValue:YES forKey:APP_BECOME_ACTIVE_SHOW_BUILD_SUCCESS];
                            }
                        }
                        });
                break;
            }
            case ANTIHARASS_REMOVE_SUCCESS:{
                [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_ON];
                [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_REMOVE_ADDRESSBOOK_SUCCESS, @(1)), nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_SWTICH_CHANGE object:nil];
                    [_viewManager showView:ANTIHARASS_VIEW_REMOVE_SUCCESS];
                break;
            }
            case ANTIHARASS_FAILED:{
                if (![UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]) {
                [_viewManager showView:ANTIHARASS_VIEW_FAILED];
                }
                
                break;
            }
            case ANTIHARASS_VERSION_IS_NEWEST:{
                [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_SHOW_DOT];
                [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW];
                [[NSNotificationCenter defaultCenter] postNotificationName:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW object:nil];
                
                [DialerUsageRecord recordpath:PATH_ANTIHARASS kvs:Pair(ANTIHARASS_UPDATE_IS_NEWEST, @(1)), nil];
                if (![UserDefaultsManager boolValueForKey:ANTIHARASS_IS_UPDATE_IN_WIFI]) {
                    if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_SHOW_TODAY_VIEW]) {
                        UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
                        [uiWindow makeToast:NSLocalizedString(@"骚扰号码库已是最新", "") duration:1.0f position:CSToastPositionBottom];
                        [_viewManager clickCancelButton];
                    }else{
                        [_viewManager showView:ANTIHARASS_VIEW_VERSION_IS_NEWEST];
                    }
                }else{
                    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_UPDATE_IN_WIFI];
                }
                break;
            }
            case ANTIHARASS_NEW_VERSION_NEED_UPDATE:{
                [[NSNotificationCenter defaultCenter] postNotificationName:N_ANTIHARASS_VIEW_REFRESH object:nil];
                [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW];
                [[NSNotificationCenter defaultCenter] postNotificationName:ANTIHARASS_SHOULD_SHOW_UPDATEVIEW object:nil];
                
                break;
            }
            default:
                break;
        }
    });
}

- (void)refreshLoadingViewPercent:(NSInteger)percent{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_viewManager refreshLoadingViewPercent:percent];
    });
}

- (void)refreshLoadingViewStage:(AntiharassModelStep)step{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_viewManager refreshLoadingViewStage:step];
    });
}



@end
