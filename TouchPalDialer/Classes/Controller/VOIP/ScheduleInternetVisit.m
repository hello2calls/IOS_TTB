//
//  VOIPScheduleCall.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-6.
//
//

#import "ScheduleInternetVisit.h"
#import "EdgeSelector.h"
#import "UserDefaultsManager.h"
#import "FunctionUtility.h"
#import "SeattleFeatureExecutor.h"
#import "SmartGroupNode.h"
#import "VOIPCall.h"
#import "Reachability.h"
#import "ContactCacheDataManager.h"
#import "TouchpalMembersManager.h"
#import "CootekNotifications.h"
#import "Reachability.h"
#import "VoipConsts.h"
#import "GZipUtils.h"
#import "DefaultUIAlertViewHandler.h"
#import "EditVoipViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "CooTekServerDef.h"
#import <AdSupport/AdSupport.h>
#import "TouchPalVersionInfo.h"
#import "AppSettingsModel.h"
#import "SeattleExecutorHelper.h"
#import "NoahManager.h"
#import "TouchpalMembersManager.h"
#import "C2CHistoryInfo.h"
#import "FlowEditViewController.h"
#import "RootScrollViewController.h"
#import "UserStreamViewController.h"
#import "AppSettingsModel.h"
#import "DialerUsageRecord.h"
#import "UsageConst.h"
#import "TPDialerResourceManager.h"
#import "TaskBonusManager.h"
#import "TouchPalDialerAppDelegate.h"
#import "TaskBonusResultInfo.h"

#import "CheckboxAlertViewHandler.h"
#import "HeadbarNotiView.h"
#import "AntiharassManager.h"
#import "NSString+TPHandleNil.h"
#import <MJExtension.h>
#import "DateTimeUtil.h"

#import "YellowPageLocationManager.h"

#import "AntiharassDataManager.h"
#import "AntiharassAdressbookUtil.h"
#import "IndexConstant.h"
#import "NSDictionary+Default.h"
#import "BiBiPairManager.h"

#import <CallKit/CallKit.h>

@implementation ScheduleInternetVisit

+ (void)onAppDataLoaded {
    
    if ([UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME] > 14) {
        [self getDailyTaskBonus];
    } else {
        [self getWeeklyTastBonus];
    }
    [self saveEdgeListData];
}

+ (void)onAppDidBecomeActive {
    [self rainbowActivate];
    [self checkVoipConfigFiles:NO];
    [self checkUploadVoipLog];
    [self adActivate];
    [self checkTouchpals];
    [self updateProxyServer];
    [self updateAdUdpServer];
    [self checkPersonCenterInfo];
    [self updateUsedTodayWidget];
    [self checkAntiharassVersion];
    [self updateCityLocation];
    [self recodeUsage];
    [self checkAccountStatus];
    [self asyncDeleteADResourceFileAndPlistIfExpiredTime];
    if ([UserDefaultsManager intValueForKey:VOIP_REGISTER_TIME] > 14) {
        [self getDailyTaskBonus];
    } else {
        [self getWeeklyTastBonus];
    }
    [self checkGrowingIORemoteConfig];
    [self checkUsageControl];
}


+ (void)getWeeklyTastBonus {
    if ( ![UserDefaultsManager boolValueForKey:IS_VOIP_ON] )
        return;
    TaskBonusManager *manager = [[TaskBonusManager alloc]init];
    [manager getTaskBonus:WEEKLY_ACTIVE withSuccessBlock:^(int bonus, TaskBonusResultInfo *info) {
        if (bonus > 0) {
            NSString *strBonus = [NSString stringWithFormat:@"连续使用7天，送您%dM流量\n再坚持7天可获得更多免费流量！",bonus];
            if (bonus > 5) {
                strBonus = [NSString stringWithFormat:@"感谢您连续使用触宝电话，送您%dM流量",bonus];
            } else if (bonus > 4) {
                strBonus = [NSString stringWithFormat:@"坚持使用14天成就已达成\n送您%dM流量！",bonus];
            }
            if ([[TouchPalDialerAppDelegate naviController].topViewController isKindOfClass:[RootScrollViewController class]] && [(RootScrollViewController*)[((UINavigationController*)[[[UIApplication sharedApplication]delegate]window].rootViewController).viewControllers objectAtIndex:0] getSelectedControllerIndex] == 1) {
                [DefaultUIAlertViewHandler showAlertViewWithTitle:strBonus message:nil];
                [UserDefaultsManager setObject:@"" forKey:APP_TASK_BONUS];
            } else {
                [UserDefaultsManager setObject:strBonus forKey:APP_TASK_BONUS];
            }
        }
        [manager getTaskBonus:DAILY_ACTIVE withSuccessBlock:nil withFailedBlock:nil localJudgeTodayFinish:NO];
    } withFailedBlock:^(int resultCode,TaskBonusResultInfo *info){
        [self getDailyTaskBonus];
    } localJudgeTodayFinish:YES];

}

+ (void)getDailyTaskBonus{
    if ( ![UserDefaultsManager boolValueForKey:IS_VOIP_ON] )
        return;
    TaskBonusManager *manager = [[TaskBonusManager alloc]init];
    [manager getTaskBonus:DAILY_ACTIVE withSuccessBlock:^(int bonus, TaskBonusResultInfo *info) {
        NSString *strBonus = [NSString stringWithFormat:@"今日启动 奖励%d分钟",(bonus / 60)];
        if (bonus > 3000) {
            strBonus = [NSString stringWithFormat:@"本月首次启动 奖励%d分钟",(bonus / 60)];
        }
        [self showBonusOnStatusbar:strBonus];
    } withFailedBlock:nil localJudgeTodayFinish:YES];
}

+ (void)saveEdgeListData {
  
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"udp_list.json"];
    NSData *json = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:json
                                                        options:NSJSONReadingMutableContainers
                                                          error:NULL];
    [self saveEdges:dic];
}

+ (void)saveEdges:(NSDictionary *)dic{
    int newVersion = [[dic objectForKey:@"voip_postboy_version"] integerValue];
    int version = [UserDefaultsManager intValueForKey:VOIP_POSTBOY_SERVERS_VERSION defaultValue:0];
    if (newVersion > version) {
        NSArray *edgeServers = [dic objectForKey:@"voip_postboy_list"];
        if (edgeServers.count > 0) {
            [UserDefaultsManager setIntValue:newVersion forKey:VOIP_POSTBOY_SERVERS_VERSION];
            int interval = [[dic objectForKey:@"voip_postkids_change_interval"] integerValue];
            float rate = [[dic objectForKey:@"voip_good_recv_rate_threshold"] floatValue];
            NSString *voip_fec_level = [dic objectForKey:@"voip_fec_level_config_3"];
            if([voip_fec_level length] > 0) {
                [UserDefaultsManager setObject:voip_fec_level forKey:VOIP_FEC_CONFIG_LEVEL];
            }
            [UserDefaultsManager setFloatValue:rate forKey:VOIP_REC_GOOD_RATE_THRESHOLD];
            [UserDefaultsManager setIntValue:interval forKey:VOIP_POSTKIDS_CHECK_INTERVAL];
            [UserDefaultsManager setObject:edgeServers forKey:VOIP_POSTBOY_SERVERS];
        }
    }
}

+ (void)checkAccountStatus {
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        NSTimeInterval cycleInterval = 3600 * 24; // 1 day
        if ([FunctionUtility isTimeUpForEvent:VOIP_ACCOUNT_INFO_CHECK_TIME
                                 withSchedule:cycleInterval
                               firstTimeCount:YES
                                 persistCheck:YES]) {
            dispatch_async([SeattleFeatureExecutor getQueue], ^{
                if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
                    [SeattleFeatureExecutor queryVOIPAccountInfo];
                }
            });
        }
    }
}


+ (void)checkUploadVoipLog{
    if ([Reachability network] == network_wifi && [FunctionUtility isTimeUpForEvent:VOIP_LOG_UPLOAD_CHECK withSchedule:3600*24 firstTimeCount:YES persistCheck:YES]) {
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            NSString *log = [self getStoredVoipLog];
            if (log) {
                if ([UserDefaultsManager boolValueForKey:VOIP_UPLOAD_CALLLOG defaultValue:NO]) {
                    [SeattleFeatureExecutor uploadVoipCallLog:log];
                }
                [self cleanVoipLog];
            }
            NSArray *attrs = [self getVoipAttrs];
            if (attrs.count > 0 && [self uploadVoipAttr:attrs]) {
                [self cleanVoipAttrs];
            }
        });
    }
}


+ (NSString *)getStoredVoipLog {
    NSString *filePath = [FunctionUtility documentFile:@"voip_log.txt"];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!isExist) {
        return nil;
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    NSData *tmpData              = [fileHandle readDataToEndOfFile];
    NSString *logString          = [[NSString alloc] initWithData: tmpData encoding: NSUTF8StringEncoding];
    [fileHandle closeFile];
    return logString;
}

+ (void)cleanVoipLog {
     [[NSFileManager defaultManager] removeItemAtPath:[FunctionUtility documentFile:@"voip_log.txt"] error:NULL];
}

+ (void)writeVoipLog:(NSString *)log {
    NSString *filePath = [FunctionUtility documentFile:@"voip_log.txt"];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!isExist) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    NSData* stringData  = [log dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:stringData];
    [fileHandle closeFile];
}

+ (void)recordVoipAttr:(NSDictionary *)attr {
    if(attr == nil) {
        cootek_log(@"recordVoipAttr not extis,return....");
        return;
    }
    cootek_log(@"recordVoipAttr = %@",attr);
    NSString *filePath = [FunctionUtility documentFile:@"voip_attr.txt"];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSMutableArray *attrs = nil;
    if (isExist) {
        attrs = [NSMutableArray arrayWithContentsOfFile:filePath];
        [attrs addObject:attr];
    } else {
        attrs = [NSMutableArray arrayWithObject:attr];
    }
    if(![self uploadVoipAttr:attrs]) {
        if (!isExist) {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }
        [attrs writeToFile:filePath atomically:YES];
    } else if (isExist) {
        [self cleanVoipAttrs];
    }
    return;
}

+ (BOOL)uploadVoipAttr:(NSArray *)attrs {
    if ([Reachability network] <= network_2g) {
        return NO;
    }
    if (attrs.count > 0) {
        BOOL success = YES;
        for (NSDictionary *dict in attrs) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            if (jsonData) {
                success = [SeattleFeatureExecutor uploadVoipCallAttr:[[NSString alloc] initWithBytes:[jsonData bytes] length:jsonData.length encoding:NSUTF8StringEncoding]];
                if (!success) {
                    break;
                }
            }
        }
        return success;
    }
    return YES;
}

+ (void)cleanVoipAttrs {
    [[NSFileManager defaultManager] removeItemAtPath:[FunctionUtility documentFile:@"voip_attr.txt"] error:NULL];
}

+ (NSArray *)getVoipAttrs {
    NSString *filePath = [FunctionUtility documentFile:@"voip_attr.txt"];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!isExist) {
        return nil;
    } else {
        NSArray *array = [NSArray arrayWithContentsOfFile:[FunctionUtility documentFile:@"voip_attr.txt"]];
        return array;
    }
}

+ (void)checkVoipConfigFiles:(BOOL)forceCheck {
    if (![UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        return;
    }
    
    if ([Reachability network] < network_3g) {
        return;
    }
    [self checkEdgeServer:forceCheck];
    [self checkVoipFecConfigFile:forceCheck];

}

+ (void)checkEdgeServer:(BOOL)forceCheck{
    if (!forceCheck && ![FunctionUtility isTimeUpForEvent:VOIP_EDGE_SERVER_CHECK
                                             withSchedule:3600*24
                                           firstTimeCount:YES
                                             persistCheck:NO]) {
        return;
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        cootek_log(@"Trying to check edge server");
        NSString *edgeServerString = [FunctionUtility getRemoteTxtContent:EDGE_SERVER_CONFIG_URL];
        if (edgeServerString != nil) {
            NSData *jsonData = [edgeServerString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            [self saveEdges:dic];
            [UserDefaultsManager setObject:[NSDate date] forKey:VOIP_EDGE_SERVER_CHECK];
        }
    });
}


+ (void)checkVoipFecConfigFile:(BOOL)forceCheck {
    if (!forceCheck && ![FunctionUtility isTimeUpForEvent:VOIP_FEC_CHECK withSchedule:3600*24 firstTimeCount:YES persistCheck:NO]) {
        return;
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^ {
        cootek_log(@"Trying to check voip fec config");
        NSData *voipConfigData = [FunctionUtility getRemoteData:VOIP_CONFIG_URL];
        if (voipConfigData != nil) {
            NSData *deflateData = [voipConfigData gzipInflate];
            if (deflateData) {
                NSString *stringData = [[NSString alloc] initWithData:deflateData encoding:NSUTF8StringEncoding];
                if (stringData.length > 0 && [stringData rangeOfString:@"ios_fec:"].length > 0) {
                    NSArray *datas = [stringData componentsSeparatedByString:@"\n"];
                    if (datas.count >= 3) {
                        NSString *secondLine = [datas objectAtIndex:1];
                        NSString *thirdLine = [datas objectAtIndex:2];
                        NSString *attrString = [secondLine stringByReplacingOccurrencesOfString:@"ios_fec:" withString:@""];
                        [UserDefaultsManager setObject:attrString forKey:VOIP_CONFIG_STRING];
                        [UserDefaultsManager setObject:[NSDate date] forKey:VOIP_FEC_CHECK];
                        cootek_log(@"get voip fec config: %@", attrString);
                        if ([thirdLine rangeOfString:@"callback:"].length > 0) {
                            NSString *callBackValue = [thirdLine stringByReplacingOccurrencesOfString:@"callback:" withString:@""];
                            if ([callBackValue isEqual:@"1"] || [callBackValue isEqual:@"0"]) {
                                BOOL value = [callBackValue boolValue];
                                [UserDefaultsManager setBoolValue:value forKey:VOIP_BACK_CALL_ENABLE];
                            }
                        }
                    }
                }
            }
        }
    });
}



+ (void)adActivate{
    if ([UserDefaultsManager boolValueForKey:IS_APP_AD_ACTIVATE]) {
        return;
    }
    if ([FunctionUtility isTimeUpForEvent:AD_ACTIVATE_TIME_SCHEDULE withSchedule:60 firstTimeCount:YES persistCheck:YES]) {
        NSString *url = [NSString stringWithFormat:@"http://adwork.cootek.com/%@", @"ad/activate"];
        NSString *ifa = [[[NSClassFromString(@"ASIdentifierManager") sharedManager] advertisingIdentifier] UUIDString];
        if ([ifa length] == 0) {
            [UserDefaultsManager setBoolValue:YES forKey:IS_APP_AD_ACTIVATE];
            return;
        }
        NSString *ifv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *mac = @"02:00:00:00:00:00";
        NSString *urlWithAttr = [NSString stringWithFormat:@"%@?appId=%@&appVer=%@&ifa=%@&ifv=%@&uuid=%@", url, @"503130474", CURRENT_TOUCHPAL_VERSION, ifa, ifv, mac];
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            NSData *result = [FunctionUtility getRemoteData:urlWithAttr];
            if (result) {
                [UserDefaultsManager setBoolValue:YES forKey:IS_APP_AD_ACTIVATE];
            }
        });
    }
}

+ (void)rainbowActivate {
    if ([FunctionUtility isTimeUpForEvent:RAIBOW_ACTIVATE_SCHEDULE withSchedule:60 firstTimeCount:YES persistCheck:YES]) {
        dispatch_async([SeattleFeatureExecutor getQueue], ^{
            BOOL result = [SeattleExecutorHelper activateTouchPalForInstallation];
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_RAINBOW_ACTIVATE_SUCCESS object:NO];
                });
            }
        });
    }
}

+ (void)checkTouchpals {
    if ([UserDefaultsManager boolValueForKey:IS_VOIP_ON]) {
        ClientNetworkType status = [Reachability network];
        if (status < network_2g){
            return;
        }
        NSTimeInterval cycleInterval = 3600 * 12; // 1 day
        BOOL timeUp = [FunctionUtility isTimeUpForEvent:VOIP_USER_EXIST_CHECK_TIME withSchedule:cycleInterval firstTimeCount:YES persistCheck:YES];
        [TouchpalMembersManager checkTouchpals:timeUp];
    }
}


+ (void)updateProxyServer{
    if (![FunctionUtility isTimeUpForEvent:SEATTLE_PROXY_SCHEDULE withSchedule:3600*24*3 firstTimeCount:YES persistCheck:YES]) {
        return;
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^ {
        NSString *proxyVersionString = [FunctionUtility getRemoteTxtContent:PROXY_SERVER_VERSION_URL];
        if (proxyVersionString != nil) {
            NSDictionary *proxyVersionDic = [FunctionUtility getDictionaryFromJsonString:proxyVersionString];
            NSInteger proxyVersion = [[proxyVersionDic objectForKey:@"version"]integerValue];
            if ( proxyVersion != [UserDefaultsManager intValueForKey:SEATTLE_PROXY_VERSION defaultValue:0] ){
                NSString *proxyString = [FunctionUtility getRemoteTxtContent:PROXY_SERVER_CONFIG_URL];
                if ( proxyString != nil ){
                    NSArray *proxyArray = [proxyString componentsSeparatedByString:@"\n"];
                    if ( proxyArray != nil && [proxyArray count] >0 ){
                        [UserDefaultsManager setIntValue:proxyVersion forKey:SEATTLE_PROXY_VERSION];
                        [UserDefaultsManager setObject:proxyArray forKey:SEATTLE_PROXY_DICTIONARY];
                    }
                }
            }
        }
    });
    
}

#define UDP_ADDS_UPDATE_URL @"http://dialer.cdn.cootekservice.com/android/default/control/udp_ad_list.json"

+ (void)updateAdUdpServer {
    if (![FunctionUtility isTimeUpForEvent:CALL_AD_UDP_ADD_UPDATE withSchedule:3600*24 firstTimeCount:YES persistCheck:YES]) {
        return;
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        NSData *addressData = [FunctionUtility getRemoteData:UDP_ADDS_UPDATE_URL];
        if (addressData) {
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:addressData options:0 error:NULL];
            NSArray *array = dataDict[@"udp_ad_list"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:array.count];
            for (NSDictionary *addDict in array) {
                NSArray *addresses = addDict[@"ip_list"];
                for (NSDictionary *add in addresses) {
                    if (add[@"ip"]) {
                        [dict setObject:@([add[@"port"] intValue]) forKey:add[@"ip"]];
                    }
                }
            }
            if (dict.count > 0) {
                [UserDefaultsManager setObject:dict forKey:CALL_AD_UDP_ADDRESSES];
            }
        }
    });
}


+ (void)checkPersonCenterInfo {
    if ([Reachability network] < network_2g || [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] == nil) {
        return;
    }
    if (![FunctionUtility isTimeUpForEvent:PERSON_CENTER_INFO_CHECK_TIME withSchedule:43200 firstTimeCount:YES persistCheck:YES]) {
        return;
    }
    dispatch_async([SeattleFeatureExecutor getQueue], ^{
        [SeattleFeatureExecutor getAccountNumbersInfo];
    });
}

+ (void) showBonusOnStatusbar:(NSString*)title {
    HeadbarNotiView *notiView = [[HeadbarNotiView alloc]initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 20) withTitle:title];
    notiView.alpha = 0;
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:(UIStatusBarAnimationFade)];
    [uiWindow addSubview:notiView];
    [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
         notiView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                notiView.alpha = 0;
        } completion:^(BOOL finished) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:(UIStatusBarAnimationFade)];
        }];
    }];
}

+ (void)updateUsedTodayWidget{
    if ([[UIDevice currentDevice].systemVersion intValue] < 8)
        return;
    NSString *result = [FunctionUtility readDataFromNSUserDefaults:@"group.com.cootek.Contacts" andKey:@"todayWidgetUsedTimes"];
    NSInteger time = [result integerValue];
    if ( time == 0 )
        return;
    [DialerUsageRecord recordpath:PATH_TODAY_WIDGET kvs:Pair(ANTIHARASS_TODAY_WIDGET_USED_TIMES, @(time)), nil];
    [FunctionUtility writeDefaultKeyToDefaults:@"group.com.cootek.Contacts" andObject:@"0" andKey:@"todayWidgetUsedTimes"];

    NSString *result2 = [FunctionUtility readDataFromNSUserDefaults:@"group.com.cootek.Contacts" andKey:@"todayWidgetUpdateViewTimes"];
    NSInteger time2 = [result2 integerValue];
    if ( time2 == 0 )
        return;

    [DialerUsageRecord recordpath:PATH_TODAY_WIDGET kvs:Pair(ANTIHARASS_TODAY_WIDGET_UPDATEVIEW_SHOW_TIMES, @(time2)), nil];
    [FunctionUtility writeDefaultKeyToDefaults:@"group.com.cootek.Contacts" andObject:@"0" andKey:@"todayWidgetUpdateViewTimes"];

}

+ (void)checkAntiharassVersion{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON]) {
            if (![UserDefaultsManager boolValueForKey:ANTIHARASS_REMOVE_ANTIHARASS_ADDRESSBOOK defaultValue:NO]) {
                if ([AntiharassAdressbookUtil removeAntiharassAddressbook]) {
                    [UserDefaultsManager setBoolValue:YES forKey:ANTIHARASS_REMOVE_ANTIHARASS_ADDRESSBOOK];
                    [UserDefaultsManager setBoolValue:NO forKey:ANTIHARASS_IS_ON];
                }
            }
        }
    });
  
    if (![FunctionUtility isTimeUpForEvent:ANTIHARASS_UPDATE_TIME withSchedule:3600*12 firstTimeCount:YES persistCheck:YES]) {
        
        if ([FunctionUtility is64bit] && [UIDevice currentDevice].systemVersion.floatValue >= 10) {
            if ([UserDefaultsManager intValueForKey:ANTIHARASS_DATAVERSION_iOS10NEW defaultValue:0]) return;
            [[AntiharassDataManager sharedManager] checkUpdateAntiDataInBackground];
        }
        return;
    }
    
    if ([FunctionUtility is64bit] && [UIDevice currentDevice].systemVersion.floatValue >= 10) {
        [[AntiharassDataManager sharedManager] checkUpdateAntiDataInBackground];
        return;
    }
    
    BOOL ifAntiharass = [UserDefaultsManager boolValueForKey:ANTIHARASS_IS_ON];
    if ( !ifAntiharass )
        return;
    BOOL contactAccess = [UserDefaultsManager boolValueForKey:CONTACT_ACCESSIBILITY];
    if ( !contactAccess )
        return;
    
    [[AntiharassManager instance]checkUpdateInBackground];
}

+ (void)updateCityLocation{
    if ( ![UserDefaultsManager boolValueForKey:YELLOW_PAGE_LOCATION_START_SCHEDULE defaultValue:NO] ){
        if ( [UserDefaultsManager intValueForKey:YELLOW_PAGE_LOCATION_WAIT_TIME defaultValue:0] == 0 ){
            NSInteger nowTime = [[NSDate date] timeIntervalSince1970];
            [UserDefaultsManager setIntValue:nowTime forKey:YELLOW_PAGE_LOCATION_WAIT_TIME];
            return;
        }else{
            NSInteger waitTime = [UserDefaultsManager intValueForKey:YELLOW_PAGE_LOCATION_WAIT_TIME];
            NSDate *waitDate = [NSDate dateWithTimeIntervalSince1970:waitTime];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"YYYY-MM-dd"];
            NSDate *judgeDate = [dateFormat dateFromString:[dateFormat stringFromDate:waitDate]];
            
            NSInteger nowTime = [[NSDate date] timeIntervalSince1970];
            NSInteger callDateTime = [judgeDate timeIntervalSince1970];
            if ( nowTime - callDateTime > 24*60*60 )
                [UserDefaultsManager setBoolValue:YES forKey:YELLOW_PAGE_LOCATION_START_SCHEDULE];
            else
                return;
        }
    }
    if ([Reachability network] < network_2g || [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME] == nil) {
        return;
    }
    if (![FunctionUtility isTimeUpForEvent:YELLOW_PAGE_LOCATION_SCHEDULE_TIME withSchedule:86400 firstTimeCount:YES persistCheck:YES]) {
        return;
    }
    [[YellowPageLocationManager instance] locate:YES checkPermission:NO];
}


+(void)recodeUsage{
    if ([FunctionUtility isTimeUpForEvent:RECODE_USAGE_DAY withSchedule:3600*24 firstTimeCount:YES persistCheck:YES]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            DailerKeyBoardType preChangedKeyBoardType = [PhonePadModel getSharedPhonePadModel].currentKeyBoard;
            [DialerUsageRecord recordpath:PATH_KEYBOARD kvs:Pair(BOARD_TYPE,@(preChangedKeyBoardType)), nil];
        });
    }
}

+(void)asyncDeleteADResourceFileAndPlistIfExpiredTime{
    if ([FunctionUtility isTimeUpForEvent:DELETE_ADRESOURCEFILEANDPLIST_DAY withSchedule:PlastResourceExpiredSecond firstTimeCount:YES persistCheck:YES]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [FunctionUtility deleteFileAndPlistIfExpiredTime];
        });
    }
}

#pragma mark GrowingIO

#define RESULT_CODE_OK (2000)
#define EXP_RESULT_ENABLE @"yes"

#define EXP_API_PATH @"/yellowpage_v3/experiment_query"

#define ONLINE_EXP_SERVER @"http://search.cootekservice.com:80"

+ (void) checkGrowingIORemoteConfig {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL growingIOEnabled = [UserDefaultsManager boolValueForKey:ENABLE_GROWING_IO defaultValue:NO];
        if (growingIOEnabled) {
            NSDate *lastSucessDate = (NSDate *)[UserDefaultsManager objectForKey:GROWING_IO_LAST_SUCCESS_TIME defaultValue:nil];
            if (lastSucessDate != nil) {
                NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastSucessDate];
                if (interval <= 7 * DAY_IN_SECOND) {
                    cootek_log(@"checkGrowingIORemoteConfig, interval < 7 days, do not check");
                    return;
                    
                } else {
                    cootek_log(@"checkGrowingIORemoteConfig, interval >= 7 days, set ENABLE_GROWING_IO to NO");
                    [UserDefaultsManager setBoolValue:NO forKey:ENABLE_GROWING_IO];
                }
            }
            cootek_log(@"checkGrowingIORemoteConfig, growingIOEnabled= %d,lastSucessDate= %@",
                       growingIOEnabled, lastSucessDate);
        }
        
        NSString *token = [SeattleFeatureExecutor getToken];
        NSString *server = ONLINE_EXP_SERVER;
        cootek_log(@"checkGrowingIORemoteConfig, growingIOEnabled= %d, token= %@, server= %@",
                   growingIOEnabled, token, server);
        
        if ([NSString isNilOrEmpty:token]) {
            return;
        }
        NSString *url = [server stringByAppendingString:EXP_API_PATH];
        NSMutableString *urlString = [[NSMutableString alloc] initWithString:url];
        NSDictionary *queries = @{
                @"_token": token,
                @"experiment_name": @"growingio_access"};
        NSArray *keys = queries.allKeys;
        for(int i = 0, len = keys.count; i < len; i++) {
            NSString *key = keys[i];
            if (i == 0) {
                if (![urlString hasPrefix:@"?"]) {
                    [urlString appendString:@"?"];
                }
                [urlString appendFormat:@"%@=%@", key, queries[key]];
            } else {
                [urlString appendFormat:@"&%@=%@", key, queries[key]];
            }
        }
        NSData *data = [FunctionUtility getRemoteData:[urlString copy]];
        cootek_log(@"checkGrowingIORemoteConfig, data == nil ? %d, url= %@", data == nil, urlString);
        if (data == nil) {
            return;
        }
        
        NSDictionary *response = [data mj_JSONObject];
        long resultCode = [[response objectForKey:@"result_code"] longValue];
        cootek_log(@"checkGrowingIORemoteConfig, response= %@, resultCode: %ld",
                   response, resultCode);
        
        if (resultCode == RESULT_CODE_OK) {
            NSDictionary *result = [response objectForKey:@"result"];
            if (result != nil) {
                NSString *expriment = [[result objectForKey:@"experiment_result"] lowercaseString];
                BOOL enabled = [expriment isEqualToString:EXP_RESULT_ENABLE];
                [UserDefaultsManager setBoolValue:enabled forKey:ENABLE_GROWING_IO];
                if (enabled) {
                    [UserDefaultsManager setObject:[NSDate date] forKey:GROWING_IO_LAST_SUCCESS_TIME];
                }
                cootek_log(@"checkGrowingIORemoteConfig, enabled= %d", enabled);
            }
        }
    });
}

+ (void)checkUsageControl
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([FunctionUtility isTimeUpForEvent:UPDATE_CUSTOM_EVENT_STRATEGY
                                 withSchedule:3600 * 6
                               firstTimeCount:YES
                                 persistCheck:NO]) {
            NSString *url = [NSString stringWithFormat:@"%@/yellowpage_v3/usage_control", TOUCHLIFE_SITE];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            if (data != nil) {
                NSDictionary *result = [data mj_JSONObject];
                cootek_log([NSString stringWithFormat:@"remote usage control: %@", [result mj_JSONString]]);
                long resultCode = [result[@"result_code"] longValue];
                if (resultCode == RESULT_CODE_OK) {
                    NSDictionary *config = result[@"result"];
                    NSArray *whiteList = config[@"white-list"];
                    NSArray *blackList = config[@"black-list"];
                    BOOL defaultSwitcher = [config objectForKey:@"default-on" withDefaultBoolValue:YES];

                    // clean obsolete configurations
                    NSString *oldWhiteListInString = [UserDefaultsManager stringForKey:USAGE_CUSTOM_EVENT_WHITE_LIST];
                    if (oldWhiteListInString != nil) {
                        NSArray *oldWhiteList = [oldWhiteListInString mj_JSONObject];
                        [oldWhiteList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [UserDefaultsManager removeObjectForKey:obj];
                        }];
                        [UserDefaultsManager removeObjectForKey:USAGE_CUSTOM_EVENT_WHITE_LIST];
                    }
                    NSString *oldBlackListInString = [UserDefaultsManager stringForKey:USAGE_CUSTOM_EVENT_BLACK_LIST];
                    if (oldBlackListInString != nil) {
                        NSArray *oldBlackList = [oldBlackListInString mj_JSONObject];
                        [oldBlackList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [UserDefaultsManager removeObjectForKey:obj];
                        }];
                        [UserDefaultsManager removeObjectForKey:USAGE_CUSTOM_EVENT_BLACK_LIST];
                    }

                    // setup default switcher
                    [UserDefaultsManager setBoolValue:defaultSwitcher forKey:USAGE_CUSTOM_EVENT_DEFAULT_ON];

                    // resolve conflicts
                    NSMutableSet *whiteListSet = [[NSMutableSet alloc] init];
                    NSMutableSet *blackListSet = [[NSMutableSet alloc] init];
                    [whiteListSet addObjectsFromArray:whiteList];
                    [blackListSet addObjectsFromArray:blackList];
                    if (defaultSwitcher) {
                        [blackListSet minusSet:whiteListSet];
                    } else {
                        [whiteListSet minusSet:blackListSet];
                    }

                    // setup white list
                    NSSet *finalWhiteListSet = [NSSet setWithSet:whiteListSet];
                    if (finalWhiteListSet.count > 0) {
                        NSMutableArray *prefixedWhiteList = [[NSMutableArray alloc] init];
                        [finalWhiteListSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                            NSString *prefixedEventName = [NSString stringWithFormat:@"%@%@", USAGE_CUSTOM_EVENT_PREFIX, obj];
                            [UserDefaultsManager setBoolValue:YES forKey:prefixedEventName];
                            [prefixedWhiteList addObject:prefixedEventName];
                        }];
                        NSString *newWhiteListInString = [prefixedWhiteList mj_JSONString];
                        [UserDefaultsManager setObject:newWhiteListInString forKey:USAGE_CUSTOM_EVENT_WHITE_LIST];
                    }

                    // setup black list
                    NSSet *finalBlackListSet = [NSSet setWithSet:blackListSet];
                    if (finalBlackListSet.count > 0) {
                        NSMutableArray *prefixedBlackList = [[NSMutableArray alloc] init];
                        [finalBlackListSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                            NSString *prefixedEventName = [NSString stringWithFormat:@"%@%@", USAGE_CUSTOM_EVENT_PREFIX, obj];
                            [UserDefaultsManager setBoolValue:NO forKey:prefixedEventName];
                            [prefixedBlackList addObject:prefixedEventName];
                        }];
                        NSString *newBlackListInString = [prefixedBlackList mj_JSONString];
                        [UserDefaultsManager setObject:newBlackListInString forKey:USAGE_CUSTOM_EVENT_BLACK_LIST];
                    }

                    // record update time
                    [UserDefaultsManager setObject:[NSDate date] forKey:UPDATE_CUSTOM_EVENT_STRATEGY];
                }
            }
        }
    });
}

@end
