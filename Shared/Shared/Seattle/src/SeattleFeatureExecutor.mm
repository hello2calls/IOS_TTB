////
//  SeattleFeatureExecutor.m
//  CallerInfoShow
//
//  Created by Elfe Xu on 13-1-31.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//

#import <stdlib.h>
#import "SeattleFeatureExecutor.h"
#import "SeattleChannel.h"
#import "SeattleSetting.h"
#import "SeattleEventHandler.h"
#import "tp_message_generated.h"
#import "CStringUtils.h"
#import "feature_runner.h"
#import "activate_feature.h"
#import "black_list_feature.h"
#import "contact_feature.h"
#import "call_log_feature.h"
#import "CommonUtil.h"
#import "FeatureQueue.h"
#import "Reachability.h"
#import "send_verification_feature.h"
#import "register_feature.h"
#import "UserDefaultsManager.h"
#import "PhoneNumber.h"
#import "DefaultUIAlertViewHandler.h"
#import "voip_c2c_account_feature.h"
#import "VoipAccountInfo.h"
#import "voip_use_invitecode_feature.h"
#import "voip_reward_feature.h"
#import "TouchpalVersionInfo.h"
#import "voip_calllog_upload_feature.h"
#import "voip_user_exist_feature.h"
#import "ContactCacheDataManager.h"
#import "ContactCacheDataModel.h"
#import "voip_c2c_history_feature.h"
#import "C2CHistoryInfo.h"
#import <AdSupport/AdSupport.h>
#import "TouchpalHistoryManager.h"
#import "voip_feedback_feature.h"
#import "SmartDailerSettingModel.h"
#import "LoginController.h"
#import "DefaultLoginController.h"
#import "CommonLoginViewController.h"
#import "task_bonus_feature.h"
#import "exchange_traffic_feature.h"
#import "ScheduleInternetVisit.h"
#import "traffic_new_feature.h"
#import "get_profile_feature.h"
#import "set_profile_feature.h"
#import "voip_call_reward_feature.h"
#import "FunctionUtility.h"
#import "yellowpage_info_feature.h"
#import "commercial_ad_feature.h"
#import "LocalStorage.h"
#import "DialerUsageRecord.h"
#import "SeattleExecutorHelper.h"
#import "ScheduleInternetVisit.h"
#import "logout_feature.h"
#import "voip_callstat_upload_feature.h"
#import "account_info_feature.h"
#import "redeem_exchange_feature.h"
#import "AccountInfoModel.h"
#import "app_download_award_feature.h"
#import "CootekNotifications.h"
#import "AdMessageModel.h"
#import "NSString+MD5.h"
#import "if_participate_voip_oversea_feature.h"
#import "participate_voip_oversea_feature.h"
#import "DialerUsageRecord.h"
#import <Usage_iOS/UsageRecorder.h>
#import "NSString+TPHandleNil.h"
#import "DialerViewController.h"
#import "find_voip_privilege_feature.h"
#import "ad_reward_feature.h"
#import "has_join_wechat_public_feature.h"
#import "hangup_invite_feature.h"
#import "PersonInfoDescViewController.h"
#import "JoinInterCallTipView.h"
#import "commercial_web_feature.h"
#import <Usage_iOS/GTMBase64.h>
#import "VoipUtils.h"
#import "voip_deal_strategy_feature.h"
#import "get_control_server_data_feature.h"
#import "TPADDSPController.h"
#import "DateTimeUtil.h"
#import "commercial_stat_feature.h"
#import "TPFilterRecorder.h"


#define MAX_CALLLOG_UPLOAD_COUNT 1000

#ifndef REDEEM_ISSUE_FAILED
#define REDEEM_ISSUE_FAILED 4100
#endif
#ifndef REDEEM_EXCHANGED
#define REDEEM_EXCHANGED 4101
#endif
#ifndef REDEEM_EXPIRED
#define REDEEM_EXPIRED 4102
#endif
#ifndef REDEEM_NOT_EXIST
#define REDEEM_NOT_EXIST 4103
#endif

#ifndef REDEEM_SERVICE_BAD
#define REDEEM_SERVICE_BAD 4104
#endif

#ifndef RESULT_CODE_PHONE_FORMAT_ERROR    //电话格式不正确
#define RESULT_CODE_PHONE_FORMAT_ERROR 4101
#endif
#ifndef RESULT_CODE_DATA_NOT_FOUND    //电话号码未找到
#define RESULT_CODE_DATA_NOT_FOUND 4103

#endif



#define VOIP_ACCOUNT_TYPE "com.cootek.auth.phone"

#define ACTIVATE_TYPE_NEW @"new"
#define ACTIVATE_TYPE_UPGRADE @"upgrade"
#define ACTIVATE_TYPE_RENEW @"renew"
// reinstall not supported yet
#define ACTIVATE_TYPE_REINSTALL @"reinstall"

@implementation SeattleFeatureExecutor

static FeatureQueue* _featureQueue;
static NSTimeInterval lastSuccessTime = 0;
static SeattleSetting *sSetting;
#define ACTIVATE_INTERVAL  60*60*24

+ (NSString *)nonNilString:(NSString *)str
{
    if (str) {
        return str;
    } else {
        return @"";
    }
}

+ (void)initialize
{
    _featureQueue = [[FeatureQueue alloc] init];
    SeattleChannelManager *mgr = new SeattleChannelManager();
    SeattleSetting *setting = new SeattleSetting();
    SeattleEventHandler *handler = new SeattleEventHandler();
    sSetting = setting;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
    FeatureRunner::initialize(mgr, setting, handler, CStringUtils::nsstr2cstr(documentDirectory));
}

+ (FeatureExecuteResult)executeSerilizedFeature:(SerilizableFeature *)feature
{
    SEL selector =  NSSelectorFromString(feature.featureSignature);
    NSMethodSignature *signature = [SeattleFeatureExecutor methodSignatureForSelector:selector];
    
    if (signature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:NSSelectorFromString(feature.featureSignature)];
        for (int i=0; i< feature.arguments.count; i++) {
            id tmp = feature.arguments[i];
            [invocation setArgument:&tmp atIndex:i+2];
        }
        [invocation setTarget:self];
        [invocation invoke];
        FeatureExecuteResult result;
        [invocation getReturnValue:&result];
        return result;
    }
    
    return FeatureExecuteResultFail;
}

+ (FeatureExecuteResult)executeFeature:(Feature *)feature
{
    if ([[Reachability shareReachability] currentReachabilityStatus] == NotReachable) {
        return FeatureExecuteResultFailCouldRetry;
    }
    FeatureRunner::get_inst().execute_feature(feature);
    switch (feature->get_status()) {
        case kFeatureDone:
            return FeatureExecuteResultSuccess;
        case kFeatureNeedRetry:
            return [self executeFeature:feature];
        case kFeatureNeedRetryLater:
            [NSThread sleepForTimeInterval:300];
            return [self executeFeature:feature];
        case kFeatureFailedMaybeRetryLater:
            return FeatureExecuteResultFailCouldRetry;
        default:
            return FeatureExecuteResultFail;
    }
}

+ (BOOL)activateWithType:(ActivateType)type
{
    return [RequiredSeattleExecutorHelper activateWithType:type];
}

+ (BOOL)activateWithName:(NSString *)appName
                 version:(NSString *)version
            activateType:(ActivateType)activateType
                  osName:(NSString *)osName
               osVersion:(NSString *)osVersion
              deviceInfo:(NSString *)deviceInfo
             channelCode:(NSString *)channelCode
                    imei:(NSString *)imei
                    uuid:(NSString *)uuid
                   simid:(NSString *)simid
                  locale:(NSString *)locale
                     mnc:(NSString *)mnc
              identifier:(NSString *)identifier
              appleToken:(NSString *)appleToken
{
    @synchronized(self) {
        if (([[NSDate date] timeIntervalSince1970] - lastSuccessTime) < ACTIVATE_INTERVAL) {
            return YES;
        }
        
        ActivateFeature *feature = new ActivateFeature();
        ActivateRequestMessage *msg = (ActivateRequestMessage *)(feature->get_request()->get_data());
        
        NSString *t;
        switch (activateType) {
            case ActivateTypeNew: {
                t = @"new";
                [TPFilterRecorder recordpath:PATH_LOGIN
                                          kvs:Pair(LOGIN_ACTIVATE_TYPE, ACTIVATE_TYPE_NEW), nil];
                break;
            }
            case ActivateTypeRenew: {
                t = @"renew";
                [TPFilterRecorder recordpath:PATH_LOGIN
                                          kvs:Pair(LOGIN_ACTIVATE_TYPE, ACTIVATE_TYPE_RENEW), nil];
                break;
            }
            case ActivateTypeUpgrade: {
                t = @"upgrade";
                [TPFilterRecorder recordpath:PATH_LOGIN
                                          kvs:Pair(LOGIN_ACTIVATE_TYPE, ACTIVATE_TYPE_UPGRADE), nil];
                break;
            }
            default:
                // not supported
                return NO;
        }
        
        msg->activate_type = CStringUtils::nsstr2cstr(t);
        msg->app_name = CStringUtils::nsstr2cstr(appName);
        msg->app_version = CStringUtils::nsstr2cstr(version);
        msg->os_name = CStringUtils::nsstr2cstr(osName);
        msg->os_version = CStringUtils::nsstr2cstr(osVersion);
        msg->device_info = CStringUtils::nsstr2cstr(deviceInfo);
        msg->channel_code = CStringUtils::nsstr2cstr(channelCode);
        msg->imei = CStringUtils::nsstr2cstr(imei);
        msg->uuid = CStringUtils::nsstr2cstr(uuid);
        msg->simid = CStringUtils::nsstr2cstr(simid);
        msg->locale = CStringUtils::nsstr2cstr(locale);
        msg->mnc = CStringUtils::nsstr2cstr(mnc);
        msg->identifier = CStringUtils::nsstr2cstr(identifier);
        msg->idfa = CStringUtils::nsstr2cstr( [[[NSClassFromString(@"ASIdentifierManager") sharedManager] advertisingIdentifier] UUIDString]);
        msg->idfv = CStringUtils::nsstr2cstr([[[UIDevice currentDevice] identifierForVendor] UUIDString]);
        if (appleToken){
            msg->apple_token = CStringUtils::nsstr2cstr(appleToken);
        }
        
        NSString* stringBuilder = [NSString stringWithFormat:@"%@%@%@%@",
                                   appName, version, channelCode, identifier];
        NSString* md5Hash = [stringBuilder MD5Hash];
        NSMutableString* randomUUID = [NSMutableString string];
        [randomUUID appendString:[md5Hash substringWithRange:NSMakeRange(0, 8)]];
        [randomUUID appendString:@"-"];
        [randomUUID appendString:[md5Hash substringWithRange:NSMakeRange(8, 4)]];
        [randomUUID appendString:@"-"];
        [randomUUID appendString:[md5Hash substringWithRange:NSMakeRange(12, 4)]];
        [randomUUID appendString:@"-"];
        [randomUUID appendString:[md5Hash substringWithRange:NSMakeRange(16, 4)]];
        [randomUUID appendString:@"-"];
        [randomUUID appendString:[md5Hash substringWithRange:NSMakeRange(20, 12)]];
        msg->random_uuid = CStringUtils::nsstr2cstr(randomUUID);
        
        NSDictionary *beforeExecuteInfo = @{
            @"activate_type": [NSString nilToEmpty:t],
            @"channel_code": [NSString nilToEmpty:channelCode],
            @"apple_token": [NSString nilToEmpty:appleToken],
            @"identifier": [NSString nilToEmpty:identifier],
            REAL_TIME_ACTIVATE_TYPE : @"before_execute_new"
        };
        [DialerUsageRecord record:USAGE_TYPE_DIALER_IOS path:PATH_REAL_TIME_ACTIVATE values:beforeExecuteInfo];
        [UsageRecorder send];
        
        FeatureExecuteResult result = [self executeFeature:feature];
        
        NSDictionary *afterExecuteInfo = @{
            @"activate_type": [NSString nilToEmpty:t],
            @"channel_code": [NSString nilToEmpty:channelCode],
            @"apple_token": [NSString nilToEmpty:appleToken],
            @"identifier": [NSString nilToEmpty:identifier],
            REAL_TIME_ACTIVATE_TYPE : @"after_execute_new"
        };
        [DialerUsageRecord record:USAGE_TYPE_DIALER_IOS path:PATH_REAL_TIME_ACTIVATE values:afterExecuteInfo];
        [UsageRecorder send];
        
        if (result == FeatureExecuteResultSuccess) {
            lastSuccessTime = [[NSDate date] timeIntervalSince1970];
            [FunctionUtility writeDefaultKeyToDefaults:@"group.com.cootek.Contacts" andObject:[self getToken] andKey:@"touchpalToken"];
            [[NSNotificationCenter defaultCenter]postNotificationName:N_ACTIVATE_SUCCESS object:nil];
            
            NSDictionary *activateInfo = @{
                @"activate_type": [NSString nilToEmpty:t],
                @"channel_code": [NSString nilToEmpty:channelCode],
                @"apple_token": [NSString nilToEmpty:appleToken],
                @"identifier": [NSString nilToEmpty:identifier],
                REAL_TIME_ACTIVATE_TYPE : @"success_new"
            };
            [DialerUsageRecord record:USAGE_TYPE_DIALER_IOS path:PATH_REAL_TIME_ACTIVATE values:activateInfo];
            [UsageRecorder send];
        }
        
        delete feature;
        return (result == FeatureExecuteResultSuccess);
    }
}


+ (BOOL)uploadCallHistoryWithCount:(NSInteger)count
{
    FeatureExecuteResult result = FeatureExecuteResultSuccess;
    NSArray *callLogs = [RequiredSeattleExecutorHelper recentlyCalllogsWithCount:count];
    BOOL ret = YES;
    if(callLogs.count > 0){
        CallLogFeature  *feature = new CallLogFeature();
                CallLogRequestMessage *msg = (CallLogRequestMessage *)(feature->get_request()->get_data());
        
                for(int i=0;i<callLogs.count;i++){
                    CloudCallLogItem *callLog = callLogs[i];
                    CallItemMessage item;
                    item.other_phone = CStringUtils::nsstr2cstr(callLog.otherPhone);
                    item.type = CStringUtils::nsstr2cstr(callLog.type);
                    item.contact = callLog.isContact;
                    item.date = callLog.date;
                    if (callLog.duration > 0) {
                        item.duration = callLog.duration;
                    }
                    if(callLog.ringTime > 0){
                        item.ring_time = callLog.ringTime;
                    }
                    msg->insert_data(item);
                }
            result = [self executeFeature:feature];
            if (result == FeatureExecuteResultSuccess) {
                CallLogResponseMessage *result_message = (CallLogResponseMessage *)(feature->get_response()->get_data());
                NSInteger resultCode = result_message->error_code;
                ret = resultCode == 0 || resultCode == 1000;
            }
            delete feature;
        }
    return ret;
}

+ (BOOL)uploadContact{
    FeatureExecuteResult result = FeatureExecuteResultSuccess;
    NSArray *person_list = [[ContactCacheDataManager instance]getAllCacheContact];
    BOOL ret = NO;
    if ([person_list count] > 0) {
        ContactFeature *feature = new ContactFeature();
        ContactRequestMessage *msg = (ContactRequestMessage*) (feature->get_request()->get_data());
        for (int i = 0; i < person_list.count; i++) {
            ContactCacheDataModel *person = person_list[i];
            ContactItemMessage item;
            item.name = CStringUtils::nsstr2cstr(person.displayName);
            for (PhoneDataModel *phone in person.phones) {
                item.phone.push_back(CStringUtils::nsstr2cstr(phone.number));
            }
            msg->insert_NONAME(item);
        }
        result = [self executeFeature:feature];
        if (result == FeatureExecuteResultSuccess) {
            ContactResponseMessage *result_message = (ContactResponseMessage *)(feature->get_response()->get_data());
            NSInteger resultCode = result_message->error_code;
            ret = resultCode == 0 || resultCode == 1000;
        }
        delete feature;
    }
    return ret;
}


+ (NSArray *)queryCallerInfoWithSurvey:(BOOL)acceptSurvey
                                phones:(NSArray *)phones
{
    CLLocationCoordinate2D loc;
    loc.latitude = 0;
    loc.longitude = 0;
    return [self queryCallerInfoWithSurvey:acceptSurvey
                          phones:phones
                      networkMnc:nil
                     hasLocation:NO
                        location:loc];
    
}

+ (NSArray *)queryCallerInfoWithSurvey:(BOOL)acceptSurvey
                                phones:(NSArray *)phones
                            networkMnc:(NSString *)mnc
                           hasLocation:(BOOL)hasLocation
                              location:(CLLocationCoordinate2D)location
{
    YellowpageInfoFeature *feature = new YellowpageInfoFeature();
    YellowpageInfoRequestMessage *msg = (YellowpageInfoRequestMessage *)(feature->get_request()->get_data());
    msg->survey = acceptSurvey;
    for (NSString *phone in phones) {
        if ([phone length] > 0) {
            if ([CommonUtil isValidNormalizedPhoneNumber:phone]) {
                msg->phone.push_back(CStringUtils::nsstr2cstr(phone));
            }
        }
    }
    
    if (msg->phone.size() == 0) {
        delete  feature;
        return @[];
    }
    
    msg->network_mnc = CStringUtils::nsstr2cstr(mnc);
    if (hasLocation) {
        LocationMessage loc;
        loc.latitude = location.latitude;
        loc.longitude = location.longitude;
        msg->create_loc(loc);
    }
    NullableBooleanMessage guess;
    guess.NONAME = YES;
    msg->create_guess(guess);
    
    FeatureExecuteResult r = [self executeFeature:feature];
    NSMutableArray *result = nil;
    if (r == FeatureExecuteResultSuccess) {
        result = [NSMutableArray arrayWithCapacity:[phones count]];
        YellowpageInfoResponseMessage *response = (YellowpageInfoResponseMessage *)(feature->get_response()->get_data());
        for (int i=0; i<response->res.size(); i++) {
            CallerInfoMessage *item = response->res[i];
            if (!item) {
                continue;
            }
            
            CloudCallerIdInfo *info = [[CloudCallerIdInfo alloc] init];
            info.phone = CStringUtils::cstr2nsstr(item->phone.c_str());
            info.isVerified = (item->verify_type == "verified");
            info.classifyType = CStringUtils::cstr2nsstr(item->classify_type.c_str());
            info.areaCode = CStringUtils::cstr2nsstr(item->area_code.c_str());
            info.shopName = CStringUtils::cstr2nsstr(item->shop_name.c_str());
            info.markCount = [NSNumber numberWithLongLong:item->mark_count];
            if (item->survey) {
                info.survey = [[SurveyInfo alloc] init];
                info.survey.systemTag = CStringUtils::cstr2nsstr(item->survey->system_tag.c_str());
                info.survey.systemName = CStringUtils::cstr2nsstr(item->survey->system_name.c_str());
            }
            
            [result addObject:info];
            [RequiredSeattleExecutorHelper handleQueryCallerIdResult:info];
        }
    }
    delete feature;
    return result;
}


+ (NSInteger)askVerifyCode:(NSString *)phoneNumber isVoiceType:(BOOL)isVoiceType
{
    SendVerificationFeature *feature = new SendVerificationFeature();
    SendVerificationRequestMessage *msg = (SendVerificationRequestMessage *)(feature->get_request()->get_data());
    NSString *account_name = [phoneNumber hasPrefix:@"+"] ? phoneNumber : [NSString stringWithFormat:@"+86%@", phoneNumber];
    msg->account_name = [account_name cStringUsingEncoding:NSUTF8StringEncoding];
    msg->account_type = VOIP_ACCOUNT_TYPE;
    msg->type = isVoiceType ? "call" : "sms";
    NSInteger resultCode = 0;
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        SendVerificationResponseMessage *result_message = (SendVerificationResponseMessage *)(feature->get_response()->get_data());
        resultCode = result_message->result_code;
    }
    delete feature;
    return resultCode;
}

+ (NSInteger)registerWithNumber:(NSString *)phoneNumber andVerifyCode:(NSString *)code
{
    RegisterFeature *feature = new RegisterFeature();
    RegisterRequestMessage *msg = (RegisterRequestMessage *)(feature->get_request()->get_data());
    NSString *account_name = [phoneNumber hasPrefix:@"+"] ? phoneNumber : [NSString stringWithFormat:@"+234%@", phoneNumber];
    msg->account_name = [account_name cStringUsingEncoding:NSUTF8StringEncoding];
    msg->verification = [code cStringUsingEncoding:NSUTF8StringEncoding];
    msg->account_type = VOIP_ACCOUNT_TYPE;
    
    NSInteger resultCode = 0;
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        RegisterResponseMessage *result_message = (RegisterResponseMessage *)(feature->get_response()->get_data());
        resultCode = result_message->result_code;
        if (resultCode == 2000){
            NSString *secret_code = [NSString stringWithUTF8String:result_message->result.c_str()];
            [UserDefaultsManager setObject:account_name forKey:VOIP_REGISTER_ACCOUNT_NAME];
            [UserDefaultsManager setObject:[FunctionUtility simpleEncodeForString:secret_code] forKey:VOIP_REGISTER_SECRET_CODE];
            NSString *ticket = [NSString stringWithUTF8String:result_message->ticket.c_str()];
            NSString *access_token = [NSString stringWithUTF8String:result_message->access_token.c_str()];
            cootek_log(@"auth/login success, ticket:%@, access_token:%@", ticket, access_token);
            [UserDefaultsManager setObject:ticket forKey:SEATTLE_AUTH_LOGIN_TICKET];
            [UserDefaultsManager setObject:access_token forKey:SEATTLE_AUTH_LOGIN_ACCESS_TOKEN];
        }
    }
    delete feature;
    return resultCode;
}


+ (NSDictionary *)queryVOIPAccountInfo {
    VoipAccountInfo *account = [[VoipAccountInfo alloc] init];
    VoipC2CAccountFeature *feature = new VoipC2CAccountFeature();
    VoipC2CAccountRequestMessage *request = (VoipC2CAccountRequestMessage *)(feature->get_request()->get_data());
    request->_channel_code = [IPHONE_CHANNEL_CODE cStringUsingEncoding:NSUTF8StringEncoding];
    request->_new_account = [UserDefaultsManager intValueForKey:VOIP_IS_NEW_ACCOUNT defaultValue:1];
    [self executeFeature:feature];
    VoipC2CAccountResponseMessage *msg = (VoipC2CAccountResponseMessage *)(feature->get_response()->get_data());
    int result_code = msg->result_code;
    if (result_code == 2000) {
        VoipC2CAccountMessage *info =  msg->result;
        account.timeStamp = [[NSDate date] timeIntervalSince1970];
        account.accountName = [NSString stringWithUTF8String:info->account_name.c_str()];
        account.balance = info->balance;
        [UserDefaultsManager setIntValue:(account.balance/60) forKey:VOIP_BALANCE];
        [UserDefaultsManager setIntValue:info->new_account forKey:VOIP_IS_NEW_ACCOUNT];
        account.bonusToday = info->bonus_today;
        account.deadLine = info->deadline;
        account.userType = [NSString stringWithUTF8String:info->user_type.c_str()];
        account.invitationCode = [NSString stringWithUTF8String:info->invitation_code.c_str()];
        [UserDefaultsManager setObject:account.invitationCode forKey:VOIP_INVITATION_CODE];
        account.invitationUsedCount = info->invitation_used;
        [UserDefaultsManager setIntValue:account.invitationUsedCount forKey:VOIP_INVITATION_USED_COUNT];
        account.qualification = [NSString stringWithUTF8String:info->qualification.c_str()];
        account.queueNumber = info->queue;
        account.shareTime = info->share_time;
        account.temporaryTime = info->temporary_time;
        if (account.temporaryTime > 0) {
            [UserDefaultsManager setIntValue:(account.temporaryTime/60) forKey:VOIP_MONTH_BALANCE];
        } else {
            [UserDefaultsManager setIntValue:account.temporaryTime forKey:VOIP_MONTH_BALANCE];
        }
        account.registerTime = info->register_time;
        [UserDefaultsManager setIntValue:(account.registerTime) forKey:VOIP_REGISTER_TIME];
        [UserDefaultsManager setIntValue:account.shareTime forKey:VOIP_SHARE_TIME_COUNT];
        
        [UserDefaultsManager setIntValue:(account.balance/60) forKey:@"voip_account_balance"];

        [[NSNotificationCenter defaultCenter]postNotificationName:@"getAccount" object:[NSString stringWithFormat:@"%d",account.balance/60]];
    }
    delete feature;
    return @{@"result_code":[NSNumber numberWithInt:result_code],@"VoipAcoountInfo":account};
}

+ (void)getVoipReward{
    VoipRewardFeature *feature = new VoipRewardFeature();
    [self executeFeature:feature];
}

+(BOOL)ifParticipateVoipOverseaWithPhone:(NSString *)phone{
    IfParticipateVoipOverseaFeature *feature = new IfParticipateVoipOverseaFeature();
    IfParticipateVoipOverseaRequestMessage *request = (IfParticipateVoipOverseaRequestMessage *)feature->get_request()->get_data();
    request->phone = [phone cStringUsingEncoding:NSUTF8StringEncoding];
    FeatureExecuteResult result = [self executeFeature:feature];
    bool boolAnswer = false;
    if (result == FeatureExecuteResultSuccess) {
        IfParticipateVoipOverseaResponseMessage *msg = (IfParticipateVoipOverseaResponseMessage *)feature->get_response()->get_data();
        boolAnswer= msg-> answer;
     }
    return boolAnswer;
}


+(BOOL)IfSuccessOnParticipateVoipOverseaWithPhone:(NSString *)phone{
    ParticipateVoipOverseaFeature *feature = new ParticipateVoipOverseaFeature() ;
    ParticipateVoipOverseaRequestMessage *request = (ParticipateVoipOverseaRequestMessage *)feature->get_request()->get_data();
    request->phone = [phone cStringUsingEncoding:NSUTF8StringEncoding];
    FeatureExecuteResult result = [self executeFeature:feature];
    bool boolAnswer = false;
    if (result == FeatureExecuteResultSuccess) {
        ParticipateVoipOverseaResponseMessage *msg = (ParticipateVoipOverseaResponseMessage *)feature->get_response()->get_data();
        boolAnswer= msg-> answer;
    }
    return boolAnswer;
}




+(void)redeemExchangeUseSeattleWithMessage:(NSString *)message{
        NSString *alertMsg;
        NSString *phone =[UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:@"0"];
        if ([message isEqualToString:ORIGINAL_INVITATION_CODE_BELTA]||[message isEqualToString:V536_INVITATION_CODE_BELTA]) {
            if([SeattleFeatureExecutor IfSuccessOnParticipateVoipOverseaWithPhone:phone]){
                alertMsg = INTERNATIONAL_CALL_OK;
            }
        }else{
        switch ([SeattleFeatureExecutor useInvitationCode:message]) {
            case 2000:
            {cootek_log(@"ok");
                if (![phone isEqualToString:@"0"]) {
                    if([SeattleFeatureExecutor IfSuccessOnParticipateVoipOverseaWithPhone:phone]){
                        alertMsg = INTERNATIONAL_CALL_OK;
                    }
                }
                break;
            }
            case REDEEM_ISSUE_FAILED:
            {
                alertMsg = @"你已经使用过同类邀请码了";
                break;
            }
            case REDEEM_EXCHANGED:
            {
                alertMsg = @"该邀请码已经使用过了";
                break;
            }
            case REDEEM_EXPIRED:
            {
                alertMsg = @"该邀请码已经过期了";
                break;
            }
            case REDEEM_NOT_EXIST:
            {
                alertMsg = @"该邀请码不存在";
                break;
            }
            default:
                alertMsg = @"服务器凌乱了";
                break;
        }
    }
    if ([alertMsg isEqualToString:INTERNATIONAL_CALL_OK]) {
        JoinInterCallTipView *joinTipView = [[JoinInterCallTipView alloc] init];
        [DialogUtil showDialogWithContentView:joinTipView inRootView:nil];
        [UserDefaultsManager setBoolValue:YES forKey:have_participated_voip_oversea];
        [DialerUsageRecord recordpath:INTERNATIONAL_CALL_PATH kvs:Pair(KEY_JOIN, OK), nil];
    }else{
        UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [uiWindow makeToast:alertMsg duration:1.0f position:CSToastPositionBottom];
    }
}




+ (int)useInvitationCode:(NSString *)code {
    RedeemExchangeFeature *feature = new RedeemExchangeFeature();
    RedeemExchangeRequestMessage *request = (RedeemExchangeRequestMessage *)feature->get_request()->get_data();
    request->redeem_code = [code cStringUsingEncoding:NSUTF8StringEncoding];
    FeatureExecuteResult result = [self executeFeature:feature];
    int resultCode = 0;
    if (result == FeatureExecuteResultSuccess) {
        RedeemExchangeResponseMessage *msg = (RedeemExchangeResponseMessage *)feature->get_response()->get_data();
        resultCode = msg->result_code;
    }
    delete feature;
    return resultCode;
}

+ (NSArray *)useInvitationCodeOldInterface:(NSString *)code {
    VoipInvitecodeFeature *feature = new VoipInvitecodeFeature();
    VoipInvitecodeRequestMessage *request = (VoipInvitecodeRequestMessage *)feature->get_request()->get_data();
    request->invitation_code = [code cStringUsingEncoding:NSUTF8StringEncoding];
    FeatureExecuteResult result = [self executeFeature:feature];
    NSMutableArray *results = [NSMutableArray array];
    NSNumber *reward = [NSNumber numberWithInt:-1];
    NSNumber *resultCode = [NSNumber numberWithInt:-1];
    NSString *resultMessage = NSLocalizedString(@"voip_network_register_error_and_retry","");
    if (result == FeatureExecuteResultSuccess) {
        VoipInvitecodeResponseMessage *msg = (VoipInvitecodeResponseMessage *)feature->get_response()->get_data();
        if (msg->result_code == 2000) {
            VoipInviteRewardMessage *info = msg->result;
            reward = [NSNumber numberWithInt:info->reward];
        }
        resultMessage = [NSString stringWithUTF8String:msg->result->msg.c_str()];
        resultCode = [NSNumber numberWithInt:msg->result_code];
    }
    [results addObject:resultCode];
    [results addObject:reward];
    [results addObject:resultMessage];
    delete feature;
    return results;
}



+ (BOOL)uploadVoipCallLog:(NSString *)log{
    VoipCalllogUploadFeature *feature = new VoipCalllogUploadFeature();
    VoipCalllogUploadRequestMessage *request = (VoipCalllogUploadRequestMessage *)feature->get_request()->get_data();
    request->log = [log cStringUsingEncoding:NSUTF8StringEncoding];
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        VoipCalllogUploadResponseMessage *response = (VoipCalllogUploadResponseMessage *)feature->get_response()->get_data();
        return response->result_code == 2000;
    }
    delete feature;
    return false;
}

+ (BOOL)uploadVoipCallAttr:(NSString *)attr{
    if (attr.length == 0) {
        return YES;
    }
    BOOL result = NO;
    VoipCallStatUploadFeature *feature = new VoipCallStatUploadFeature();
    VoipCallStatUploadRequestMessage *requestMsg = (VoipCallStatUploadRequestMessage *)feature->get_request()->get_data();
    requestMsg->content = [attr UTF8String];
    FeatureExecuteResult resultStatus = [self executeFeature:feature];
    if (resultStatus == FeatureExecuteResultSuccess) {
        VoipCallStatUploadResponseMessage *responseMsg = (VoipCallStatUploadResponseMessage *)feature->get_response()->get_data();
        if (responseMsg->result_code == 2000) {
            result = YES;
        }
    }
    delete feature;
    return result;
}


+ (NSArray *)queryVoipUserExist:(NSArray *)numbers{
    NSMutableArray *results = [NSMutableArray array];
    VoipUserExistFeature *feature = new VoipUserExistFeature();
    VoipUserExistRequestMessage *request = (VoipUserExistRequestMessage *)(feature->get_request()->get_data());
    for (NSString *number in numbers) {
        request->user_account_list.push_back([number UTF8String]);
    }
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        VoipUserExistResponseMessage *msg = (VoipUserExistResponseMessage *)(feature->get_response()->get_data());
        [results addObject:[NSNumber numberWithInt:msg->result_code]];
        if (msg->result_code == 2000) {
            VoipUserExistMessage * user_result =  msg->result;
            [results addObject:[NSNumber numberWithInt:user_result->sleep]];
             for ( int i = 0 ; i < user_result->status.size() ; i++ ){
                 [results addObject:[NSNumber numberWithBool:user_result->status[i]]];
             }
        }
    }
    delete feature;
    return results;
}



+ (dispatch_queue_t)getQueue {
    return [_featureQueue getQueue];
}

+ (void)reLogin {
    NSString *token = [self getToken];
    cootek_log(@"test:%@,%d,%@,%@", [UserDefaultsManager objectForKey:USER_POPUP_API defaultValue:@""], [UserDefaultsManager intValueForKey:USER_POPUP_RESULT defaultValue:-1], [UserDefaultsManager objectForKey:USER_POPUP_RESPONSE defaultValue:@""], (token.length == 0 ? @"" : token));
    [DialerUsageRecord recordpath:PATH_LOGOUT kvs:Pair(SHOW_LOGIN_DIALOG, @(1)), Pair(POPUP_API, [UserDefaultsManager objectForKey:USER_POPUP_API defaultValue:@""]), Pair(POPUP_RESULT, @([UserDefaultsManager intValueForKey:USER_POPUP_RESULT defaultValue:-1])),Pair(POPUP_RESPONSE, [UserDefaultsManager objectForKey:USER_POPUP_RESPONSE defaultValue:@""]), Pair(POPUP_TOKEN, (token.length == 0 ? @"" : token)),nil];
    __weak UINavigationController *navi = [TouchPalDialerAppDelegate naviController];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something about the token is wrong, so do some recording work
        NSDictionary *usageInfo = @{
            POPUP_API: [UserDefaultsManager objectForKey:USER_POPUP_API defaultValue:@""],
            POPUP_RESULT: @([UserDefaultsManager intValueForKey:USER_POPUP_RESULT defaultValue:-1]),
            POPUP_RESPONSE: [UserDefaultsManager objectForKey:USER_POPUP_RESPONSE defaultValue:@""],
            @"token": [NSString nilToEmpty:token],
        };
        [DialerUsageRecord recordpath:PATH_RELOGIN
                                  kvs:Pair(RELOGIN_FROM_SEATTLE, usageInfo), nil];
        
        [VOIPCall needToRegisterAgainWithOkBlock:^{
            if ([navi.topViewController isKindOfClass: [EditVoipViewController class]] || [navi.topViewController isKindOfClass: [CommnonLoginViewController class]])
                [navi popViewControllerAnimated:NO];
                [LoginController checkLoginWithDelegate:[DefaultLoginController withOrigin:@"seattle_reload"]];
        } cancelBlock:^{
            if ([navi.topViewController isKindOfClass: [EditVoipViewController class]])
                [navi popViewControllerAnimated:YES];
        }];
        [LoginController removeLoginDefaultKeys];
        
    });
}

+ (NSString *)getToken {
    TPSTRING cookie = sSetting->getString(KEY_TP_COOKIE);
    if (cookie.length() > 0) {
        NSString *cookieString = [NSString stringWithUTF8String:cookie.c_str()];
        if ([cookieString rangeOfString:@"auth_token="].length == 0 || [cookieString rangeOfString:@";"].length == 0) {
            return cookieString;
        }
        NSRange range;
        range.location = @"auth_token=".length;
        range.length = [cookieString rangeOfString:@";"].location - range.location;
        NSString *token = [cookieString substringWithRange:range];
        return token;
    } else {
        return @"";
    }
}


+ (NSArray *)getHistory:(NSInteger)bonusType{
    BOOL ifContinue = NO;
    NSMutableArray *results = [NSMutableArray array];
    C2CHistoryFeature *feature = new C2CHistoryFeature();
    C2CHistoryRequestMessage *request = (C2CHistoryRequestMessage *)(feature->get_request()->get_data());
    request->start_time = (double)[TouchpalHistoryManager getLatestDatetime:bonusType] * 1000;
    request->max_number = 100;
    request->bonus_type = bonusType;
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        C2CHistoryResponseMessage *msg = (C2CHistoryResponseMessage *)feature->get_response()->get_data();
        if (msg->result_code == 2000){
            C2CHistoryMessage *user_result = msg->result;
            if ( user_result->history.size() == request->max_number ){
                ifContinue = YES;
            }
            for ( int i = user_result->history.size() - 1 ; i >= 0  ; i-- ){
                C2CHistoryInfoMessage *info = user_result->history[i];
                C2CHistoryInfo *historyInfo = [[C2CHistoryInfo alloc]init];
                historyInfo.eventName = [NSString stringWithUTF8String:info->event_name.c_str()];
                historyInfo.bonus = info->bonus;
                historyInfo.bonusType = info->bonus_type;
                historyInfo.datetime = info->datetime/1000;
                historyInfo.pop = info->pop;
                historyInfo.msg = [NSString stringWithUTF8String:info->msg.c_str()];
                [results addObject:historyInfo];
                if ( historyInfo.bonusType == bonusType || bonusType == 0){
                    [TouchpalHistoryManager insertHistory:historyInfo];
                }
            }
        }
    }
    delete feature;
    
    if ( ifContinue ){
        NSArray *conResults = [self getHistory:bonusType];
        if ( [conResults count] > 0){
            for ( C2CHistoryInfo *info in conResults ){
                [results addObject:info];
            }
        }
    }
    
    return results;
    
}

+ (NSInteger)postFeedback:(VoipFeedbackInfo *)info{
    NSInteger resultCode = 0;
    VoipFeedbackFeature *feature = new VoipFeedbackFeature();
    VoipFeedbackRequestMessage *request = (VoipFeedbackRequestMessage *)(feature->get_request()->get_data());
    request->reason = info.reasonId;
    request->caller = [info.callerNumber cStringUsingEncoding:NSUTF8StringEncoding];
    request->callee = [info.calleeNumber cStringUsingEncoding:NSUTF8StringEncoding];
    request->start_time = info.startTime;
    request->net_type = [info.netType cStringUsingEncoding:NSUTF8StringEncoding];
    request->call_type = info.callType;
    request->phone_type = [[NSString stringWithFormat:@"%@",[[UIDevice currentDevice] model]] cStringUsingEncoding:NSUTF8StringEncoding];
    request->app_version = [CURRENT_TOUCHPAL_VERSION integerValue];
    request->duration = info.duration;
    SmartDailerSettingModel *tmpSettingModel = [[SmartDailerSettingModel alloc] init];
    request->carrieroperator = [[tmpSettingModel currentChinaCarrier] cStringUsingEncoding:NSUTF8StringEncoding];
    request->channel_code = [IPHONE_CHANNEL_CODE cStringUsingEncoding:NSUTF8StringEncoding];
    request->os_name = [[NSString stringWithFormat:@"iOS %@",[[UIDevice currentDevice] systemVersion]] cStringUsingEncoding:NSUTF8StringEncoding];
    
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        C2CHistoryResponseMessage *msg = (C2CHistoryResponseMessage *)feature->get_response()->get_data();
        resultCode = msg->result_code;
    }
    delete feature;
    return resultCode;
}

+ (void)getTaskBonus:(NSInteger)eventId withSuccessBlock: (void (^)(int bonus, TaskBonusResultInfo *))successBlock withFailedBlock:(void (^)(int resultCode,TaskBonusResultInfo *info))failedBlock{
    TaskBonusFeature *feature = new TaskBonusFeature();
    TaskBonusRequestMessage *request = (TaskBonusRequestMessage *)(feature->get_request()->get_data());
    request->_event_id = eventId;
    request->_type = 0;
    FeatureExecuteResult result = [self executeFeature:feature];
    NSInteger resultCode = 0;
    TaskBonusResultInfo *resultInfo = [[TaskBonusResultInfo alloc]init];
    if (result == FeatureExecuteResultSuccess) {
        TaskBonusResponseMessage *msg = (TaskBonusResponseMessage *)feature->get_response()->get_data();
        resultCode = msg->result_code;
        if (resultCode == 2000) {
            TaskBonusMessage *info = msg->result;
            resultInfo.finish = info->finish;
            resultInfo.todayFinish = info->today_finish;
            resultInfo.qulification = info->qualification;
            if ( info->today_finish )
                [UserDefaultsManager setIntValue:info->timestamp forKey:[NSString stringWithFormat:@"%@%d",TASK_BONUS_TIME_,eventId]];
            if (successBlock) {
                int bonus = info->bonus;
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(bonus, resultInfo);
                });
            }
            //[ScheduleInternetVisit getStreamHistory:YES onlyVoip:NO onlyFlow:NO];
        }else if (resultCode == 4323){
            TaskBonusMessage *info = msg->result;
            resultInfo.finish = info->finish;
            resultInfo.todayFinish = info->today_finish;
            resultInfo.qulification = info->qualification;
            if ( info->today_finish )
                [UserDefaultsManager setIntValue:info->timestamp forKey:[NSString stringWithFormat:@"%@%d",TASK_BONUS_TIME_,eventId]];
        }
    }
    if ( resultCode != 2000 ){
        if (failedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failedBlock(resultCode,resultInfo);
            });
        }
    }
    delete feature;
    
}

+ (NSInteger)exchangeTraffic:(NSString*)nickName flow:(NSInteger)flow{
    int resultCode = 0;
    ExchangeTrafficFeature *feature = new ExchangeTrafficFeature();
    ExchangeTrafficRequestMessage *request = (ExchangeTrafficRequestMessage *)(feature->get_request()->get_data());
    request->nick_name = [nickName cStringUsingEncoding:NSUTF8StringEncoding];
    request->flow = flow;
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        ExchangeTrafficResponseMessage *msg = (ExchangeTrafficResponseMessage *)feature->get_response()->get_data();
        resultCode = msg->result_code;
        if (msg->result_code == 2000) {
            ExchangeTrafficMessage *info = msg->result;
            cootek_log(@"%d",info->exchange);
        }
    }
    delete feature;
    return resultCode;
}


//+ (BOOL)isCommercialAccount {
//    TrafficCommercialFeature *feature = new TrafficCommercialFeature();
//    FeatureExecuteResult result = [self executeFeature:feature];
//    if (result == FeatureExecuteResultSuccess) {
//        TrafficCommercialResponseMessage *msg = (TrafficCommercialResponseMessage *)(feature->get_response()->get_data());
//        if (msg->result_code == 2000) {
//            TrafficCommercialMessage *msgResult = msg->result;
//            delete feature;
//            return msgResult->commecial;
//        }
//    }
//    delete feature;
//    return NO;
//}

+ (PersonInfo*)getPersonProfile {
    GetProfileFeature *feature = new GetProfileFeature();
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        GetProfileResponseMessage *msg = (GetProfileResponseMessage *)feature->get_response()->get_data();
        if (msg->result_code == 2000 && msg->result->success) {
            PersonInfo *info = [[PersonInfo alloc]init];
            info.photoUrl = [NSString stringWithUTF8String:msg->result->photo_uri.c_str()];
            info.photoType = msg->result->photo_type;
            info.gender = msg->result->gender;
            [UserDefaultsManager setObject:info.photoUrl forKey:PERSON_PROFILE_URL];
            [UserDefaultsManager setIntValue:info.photoType forKey:PERSON_PROFILE_TYPE];
            [UserDefaultsManager setIntValue:info.gender forKey:PERSON_PROFILE_GENDER];
            delete feature;
            return info;
        }
    }
    delete feature;
    return nil;
}

+ (BOOL)setPersonProfile:(NSString *)profileUrl withType:(NSInteger)type withGender:(NSInteger)gender {
    SetProfileFeature *feature = new SetProfileFeature();
    SetProfileRequestMessage *request = (SetProfileRequestMessage *)(feature->get_request()->get_data());
    request->photo_uri = [profileUrl cStringUsingEncoding:NSUTF8StringEncoding];
    request->photo_type = type;
    request->gender = gender;
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        SetProfileResponseMessage *msg = (SetProfileResponseMessage *)feature->get_response()->get_data();
        if (msg->result_code == 2000 && msg->result->success){
            delete feature;
            return YES;
        }
    }
    delete feature;
    return NO;
}

+ (BOOL)voipCallRewardWithCallId:(NSString *)callId andDurationSeconds:(int)seconds {
    VoipCallRewardFeature *feature = new VoipCallRewardFeature();
    VoipCallRewardRequestMessage *request = (VoipCallRewardRequestMessage *)(feature->get_request()->get_data());
    request->call_id = [callId UTF8String];
    request->billsec = seconds;
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        VoipCallRewardResponseMessage *msg = (VoipCallRewardResponseMessage *)feature->get_response()->get_data();
        if (msg->result_code == 2000) {
            delete feature;
            return YES;
        }
    }
    delete feature;
    return NO;
}


+ (NSDictionary *)getVoipPrivilegeAdInfoWithOtherNumber:(NSString *)number andCallType:(NSString *)callType{
    NSDictionary *settings = @{
        @"at": @"TUWEN",
        @"tu": kAD_TU_VOIP_PRIVILEGE,
        @"w": [FunctionUtility getADViewSizeWithTu:kAD_TU_VOIP_PRIVILEGE][@"w"],
        @"h": [FunctionUtility getADViewSizeWithTu:kAD_TU_VOIP_PRIVILEGE][@"h"]
};
    return [SeattleFeatureExecutor getAdInfoWithOtherNumber:number andCallType:callType requestSettings:settings];
}

+ (NSDictionary *) fetchLaunchAD {
    NSDictionary *settings = @{
                               @"at": @"IMG",
                               @"tu": kAD_TU_LAUNCH,
                               @"w": [FunctionUtility getADViewSizeWithTu:kAD_TU_LAUNCH][@"w"],
                               @"h": [FunctionUtility getADViewSizeWithTu:kAD_TU_LAUNCH][@"h"]
                               };
    return [SeattleFeatureExecutor getAdInfoWithOtherNumber:AD_DEBUG_TU_LAUNCH_OTHERPHONE andCallType:@"" requestSettings:settings];
}

+ (NSDictionary *)getAdInfoWithOtherNumber:(NSString *)number
                                     andCallType:(NSString *)callType
                                     requestSettings:(NSDictionary *) settings {
    NSString *tu = (NSString *)[settings objectForKey:@"tu" ];
    [UserDefaultsManager setObject:[NSDate date] forKey:AD_STEP_TIME];
    CommercialAdFeature *feature = new CommercialAdFeature();
    CommercialAdRequestMessage *request= (CommercialAdRequestMessage *)(feature->get_request()->get_data());
    double now = [[NSDate date] timeIntervalSince1970];
    request->ch = [COOTEK_APP_NAME UTF8String];
    request->v = [CURRENT_TOUCHPAL_VERSION UTF8String];
    request->prt = now;
    request->at = [[settings objectForKey:@"at"] UTF8String];
    request->tu = [[settings objectForKey:@"tu" ] UTF8String];
    request->adn = 1;
    request->adclass = "EMBEDDED";
    request->nt = [[FunctionUtility networkType].uppercaseString UTF8String];
    request->rt = "JSON";
    request->w = [[settings objectForKey:@"w"] intValue];
    request->h = [[settings objectForKey:@"h"] intValue];
    BOOL open_free_call =  [UserDefaultsManager boolValueForKey:IS_VOIP_ON defaultValue:NO];
    request->open_free_call = open_free_call;
    string city = "";
    string add = "";
    if (now * 1000 - [[LocalStorage getItemWithKey:NATIVE_PARAM_CITY_CACHE_TIME] longLongValue] <= 3*86400*1000) {
        NSString *cityNS = [LocalStorage getItemWithKey:NATIVE_PARAM_CITY];
        if (cityNS) {
            city = [cityNS UTF8String];
        }
        NSString *addNS = [LocalStorage getItemWithKey:NATIVE_PARAM_ADDR];
        if (addNS) {
            add = [addNS UTF8String];
        }
    }
    request->city = city;
    request->addr = add;
    NSString *cacheTimeString = [LocalStorage getItemWithKey:NATIVE_PARAM_LOCATION_CACHE_TIME];
    long cacheTime = [cacheTimeString longLongValue];
    if (cacheTime > 0 && now * 1000 - cacheTime <= 3600000) {
        NSString *cacheLoc = [LocalStorage getItemWithKey:NATIVE_PARAM_LOCATION];
        cacheLoc = [cacheLoc stringByReplacingOccurrencesOfString:@"[" withString:@""];
        cacheLoc = [cacheLoc stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *locAttr = [cacheLoc componentsSeparatedByString:@","];
        if (locAttr.count == 2 && ((NSString *)locAttr[0]).length > 0) {
            double latitude = [locAttr[0] doubleValue];
            double longitude = [locAttr[1] doubleValue];
            request->latitude = latitude;
            request->longtitude = longitude;
        }
    }
    request->other_phone = [number UTF8String];
    request->call_type = "outgoing";
    request->vt = [callType UTF8String];
    
    int personId = [NumberPersonMappingModel queryContactIDByNumber:number];
    if (personId > 0) {
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        request->contactname = [personData.fullName UTF8String];
    }
    
    int vipRequestResult = -1; // error
    
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        CommercialAdResponseMessage *msg = (CommercialAdResponseMessage *)feature->get_response()->get_data();
        if (msg && !msg->error_code && msg->ad.size() > 0) {
            NSMutableDictionary *ret = [NSMutableDictionary dictionary];
            TPSTRING std_msg_string = feature->get_response()->get_message_string();
            NSString *responseString = [NSString stringWithCString:std_msg_string.c_str()
                                                          encoding:NSUTF8StringEncoding];
            NSDictionary *responseAds = nil;
            if (responseString) {
                NSError *error;
                responseAds = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                if (error) {
                    responseAds = nil;
                }
            }
            NSArray *adOriginalPackages = responseAds ? [responseAds objectForKey:@"ad"] : nil;
            for (int i = 0; i < msg->ad.size(); ++i) {
                AdPackageMessage *pack = msg->ad[i];
                NSDictionary *adOriginalPakcage = adOriginalPackages[i];
                if (pack && pack->adn > 0 && pack->ads.size()) {
                    NSString *tu = [NSString stringWithUTF8String:pack->tu.c_str()];
                    AdMessage *adInfo = pack->ads[0];
                    AdMessageModel *model = [[AdMessageModel alloc] init];
                    if ([tu isEqualToString:kAD_TU_HANGUP]
                        || [tu isEqualToString:kAD_TU_VOIP_PRIVILEGE]
                        || [tu isEqualToString:kAD_TU_LAUNCH]) {
                        model = [[HangupCommercialModel alloc] init];
                    }
                    if ([tu isEqualToString:kAD_TU_VOIP_PRIVILEGE]) {
                        vipRequestResult = pack->adn;
                    }
                    model.adId = [NSString stringWithUTF8String:adInfo->ad_id.c_str()];
                    model.title = [NSString stringWithUTF8String:adInfo->title.c_str()];
                    model.desc = [NSString stringWithUTF8String:adInfo->desc.c_str()];
                    model.brand = [NSString stringWithUTF8String:adInfo->brand.c_str()];
                    model.curl = [NSString stringWithUTF8String:adInfo->curl.c_str()];
                    model.edurl = [NSString stringWithUTF8String:adInfo->edurl.c_str()];
                    model.surl = [NSString stringWithUTF8String:adInfo->surl.c_str()];
                    model.src = [NSString stringWithUTF8String:adInfo->src.c_str()];
                    model.at = [NSString stringWithUTF8String:adInfo->at.c_str()];
                    
                    //
                    model.turl = [NSString stringWithUTF8String:adInfo->turl.c_str()];
                    model.ttype = [NSString stringWithUTF8String:adInfo->ttype.c_str()];
                    model.tstep = [NSString stringWithUTF8String:adInfo->tstep.c_str()];
                    model.rdesc = [NSString stringWithUTF8String:adInfo->rdesc.c_str()];
                    model.checkcode = [NSString stringWithUTF8String:adInfo->checkcode.c_str()];
                    
                    model.clk_url = [NSString stringWithUTF8String:adInfo->clk_url.c_str()];
                    for (int i=0; i<adInfo->clk_monitor_url.size(); ++i) {
                        [model.clk_monitor_url addObject:[NSString stringWithUTF8String:adInfo->clk_monitor_url[i].c_str()]];
                    }
                    for (int i=0; i<adInfo->ed_monitor_url.size(); ++i) {
                        [model.ed_monitor_url addObject:[NSString stringWithUTF8String:adInfo->ed_monitor_url[i].c_str()]];
                    }

                    
                    
                    model.w = pack->w;
                    model.h = pack->h;
                    model.wtime = pack->wtime;
                    model.idws = pack->idws;
                    
                    model.s = [NSString stringWithUTF8String:pack->s.c_str()];
                    model.tu = [NSString stringWithUTF8String:pack->tu.c_str()];
                    model.reserved = [NSString stringWithUTF8String:adInfo->reserved.c_str()];
                    model.material = [NSString stringWithUTF8String:adInfo->material.c_str()];
                    cootek_log(@"ad-info, seattle feature, material: %@", model.material);
                    model.da = adInfo->da;
                    model.dtime = adInfo->dtime;
                    model.etime = adInfo->etime;
                    model.expireTimestamp = (long long)([[[NSDate alloc] init] timeIntervalSince1970] * 1000 + model.etime);
                    model.ec = adInfo->ec;
                    model.rawResponseString = responseString;
                    
                    model.orginalADJSONString = @"";

                    NSDictionary *originalADInfo = [[adOriginalPakcage objectForKey:@"ads"] objectAtIndex:0];
                    NSMutableDictionary *originalADDict = [[NSMutableDictionary alloc] initWithCapacity:1];
                    if (originalADInfo) {
                        originalADDict = [[NSMutableDictionary alloc] initWithDictionary:originalADInfo];
                    }
                    int tuInt = -1;
                    if (model.tu && model.tu.length > 0) {
                        tuInt = [model.tu intValue];
                    }
                    [originalADDict setObject:@(tuInt) forKey:@"tu"];

                    NSError *originalADError;
                    NSData *originalADData = [NSJSONSerialization dataWithJSONObject:originalADDict options:kNilOptions error:&originalADError];
                    if (!originalADError && originalADData) {
                        model.orginalADJSONString = [[NSString alloc] initWithData:originalADData encoding:NSUTF8StringEncoding];
                    }
                    [ret setObject:model forKey:tu];
                } else {
                    if ([[settings objectForKey:@"tu"] isEqualToString:kAD_TU_VOIP_PRIVILEGE]) {
                        vipRequestResult = 0; // no ads
                    }
                }
            }
            [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_REQUEST,@(1)), nil];
            if ([[settings objectForKey:@"tu"] isEqualToString:kAD_TU_VOIP_PRIVILEGE]) {
                [DialerUsageRecord recordpath:PATH_TASK_REQUEST kvs:Pair(VIP_TASK_REQUEST_RESULT, @(vipRequestResult)), nil];
            }
            
            delete feature;
            return ret;
        }
    }
    [DialerUsageRecord recordpath:PATH_DISCONNECT_COMMERCIAL kvs:Pair(COMMERCIAL_REQUEST,@(0)), nil];
    if ([[settings objectForKey:@"tu"] isEqualToString:kAD_TU_VOIP_PRIVILEGE]) {
        [DialerUsageRecord recordpath:PATH_TASK_REQUEST kvs:Pair(VIP_TASK_REQUEST_RESULT, @(vipRequestResult)), nil];
    }
    delete feature;
    return nil;
}


+ (BOOL)logout {
    LogoutFeature *feature = new LogoutFeature();
    FeatureExecuteResult result = [self executeFeature:feature];
    BOOL res = NO;
    if (result == FeatureExecuteResultSuccess) {
        LogoutResponseMessage *msg = (LogoutResponseMessage *)feature->get_response()->get_data();
        if (msg->result_code == 2000) {
            res = YES;
        }
    }
    delete feature;
    return res;
}

+ (NSDictionary *)getAccountNumbersInfo {
    AccountInfoFeature *feature = new AccountInfoFeature();
    FeatureExecuteResult result = [self executeFeature:feature];
    NSDictionary *accountInfo = nil;
    if (result == FeatureExecuteResultSuccess) {
        AccountInfoResponseMessage *responseMsg = (AccountInfoResponseMessage *)feature->get_response()->get_data();
        if (responseMsg->result_code == 2000) {
            AccountMessage *msg = responseMsg->result;
            
            NSString *cards = [NSString stringWithFormat:@"%ld", msg->cards];
            NSString *bytes = [NSString stringWithFormat:@"%ld", msg->bytes];
            NSString *coins = [NSString stringWithFormat:@"%.2f", msg->coins/100.0];
            NSString *saved = [NSString stringWithFormat:@"%.2f", msg->saved/100.0];
            NSString *minutes = [NSString stringWithFormat:@"%ld", msg->minutes/60];
            NSString *server_time = [NSString stringWithFormat:@"%ld", msg->server_time];
            NSString *vip_expired = [NSString stringWithFormat:@"%ld", msg->vip_expired];
            NSString *bytes_f = [NSString stringWithFormat:@"%.2f", msg->bytes_f];
            BOOL isCardUser = msg->is_card_user;
            [UserDefaultsManager setIntValue:(msg->minutes/60) forKey:VOIP_BALANCE];
            accountInfo = @{
                            CENTER_DETAIL_CRADS: cards,
                            CENTER_DETAIL_BYTES: bytes,
                            CENTER_DETAIL_COINS: coins,
                            CENTER_DETAIL_SAVED: saved,
                            CENTER_DETAIL_MINUTES: minutes,
                            CENTER_DETAIL_SERVER_TIME: server_time,
                            CENTER_DETAIL_VIP_EXPIRED: vip_expired,
                            CENTER_DETAIL_BYTES_F: bytes_f
                            };
            
            NSDictionary *oldInfo = [UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO];
            [self notifyVoipAccountChangeTo:accountInfo fromOldInfo:oldInfo];
            
            [UserDefaultsManager setObject:accountInfo forKey:VOIP_ACCOUNT_INFO];
            [UserDefaultsManager setBoolValue:isCardUser forKey:VOIP_ACCOUNT_IS_CARD_USER];
            
            [self findVoipPrivilegeInfo];
            if ([UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME].length>0 && [UserDefaultsManager intValueForKey:have_join_wechat_public_status]<1) {
                [self findJoinWechatPublic:[UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME]];
            }
        }
    }
    delete feature;
    return accountInfo;
}

+ (void) notifyVoipAccountChangeTo: (NSDictionary *) newInfo  fromOldInfo:(NSDictionary *) oldInfo {
    if (!newInfo) {
        return;
    }
    NSMutableDictionary *changedInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSArray *keys = newInfo.allKeys;
    for(NSString *key in keys) {
        NSString *newValue = (NSString *)[newInfo objectForKey:key];
        if (!newValue) {
            continue;
        }
        id oldValue = [oldInfo objectForKey:key];
        if (!oldValue) {
            [changedInfo setValue:newValue forKey:key];
        } else {
            NSString *oldValueStr = (NSString *)oldValue;
            if (![newValue isEqualToString:oldValueStr]) {
                [changedInfo setValue:newValue forKey:key];
            }
        }
    }
    if (changedInfo.count == 0) {
        return;
    }
    [UserDefaultsManager setObject:[changedInfo copy] forKey:VOIP_ACCOUNT_INFO_DIFF];
    for (NSString *changedKey in changedInfo.allKeys) {
        NSString *prefKey = [NSString stringWithFormat:@"%@_%@", SHOW_DOT, changedKey];
        [UserDefaultsManager setBoolValue:YES forKey:prefKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:N_VOIP_ACCOUNT_INFO_CHANGED
                                                        object:nil userInfo:nil];
}

+ (NSInteger) getAppDownloadAwardWithAppID:(NSString *)appid userPhoneNumber:(NSString *)phone {
    AppDownloadAwardFeature *feature = new AppDownloadAwardFeature();
    AppDownloadAwardRequestMessage *requstMsg = (AppDownloadAwardRequestMessage *)(feature->get_request()->get_data());
    requstMsg->app_id =[appid UTF8String];
    requstMsg->phone = [phone UTF8String];
    
    FeatureExecuteResult result = [self executeFeature:feature];
    NSInteger status = -1;
    if (result == FeatureExecuteResultSuccess) {
        AppDownloadAwardResponseMessage *responseMsg = (AppDownloadAwardResponseMessage *)(feature->get_response()->get_data());
        if (responseMsg->result_code == 2000) {
            status = responseMsg->result->status;
        }
    }
    delete feature;
    return status;
}

+ (NSInteger) ackADReward: (NSString *) adInfo {
    NSInteger status = -1;
    if (!adInfo) return status;
    ADRewardFeature *feature = new ADRewardFeature();
    ADRewardRequestMessage *requstMsg = (ADRewardRequestMessage *)(feature->get_request()->get_data());
    requstMsg->ad = [adInfo UTF8String];
    
    FeatureExecuteResult result = [self executeFeature:feature];
    
    if (result == FeatureExecuteResultSuccess) {
        ADRewardResponseMessage *responseMsg = (ADRewardResponseMessage *)(feature->get_response()->get_data());
        if (responseMsg->result_code == 2000) {
            status = responseMsg->result->res_code;
        }
    }
    delete feature;
    return status;
}

+ (void)findVoipPrivilegeInfo{
    NSDictionary *account =[UserDefaultsManager dictionaryForKey:VOIP_ACCOUNT_INFO defaultValue:nil];
    NSString *server_time = account[@"server_time"];
    NSString *vip_expired = account[@"vip_expired"];
    if (server_time.length>0 && vip_expired.length>0) {
        [UserDefaultsManager setBoolValue:server_time.integerValue<vip_expired.integerValue forKey:VOIP_IF_PRIVILEGA];
        cootek_log(@"%d",server_time.integerValue<vip_expired.integerValue);
        [UserDefaultsManager setObject:@(server_time.integerValue) forKey:VOIP_FIND_PRIVILEGA_SERVICE_TIME];
        [UserDefaultsManager setObject:@(vip_expired.integerValue) forKey:VOIP_PRIVILEGA_EXPIRED_TIME];
        if (vip_expired.integerValue-server_time.integerValue>0) {
            [UserDefaultsManager setObject:@((vip_expired.integerValue-server_time.integerValue)/60/60/24+1) forKey:VOIP_FIND_PRIVILEGA_DAY];
        }else{
             [UserDefaultsManager setObject:@(0) forKey:VOIP_FIND_PRIVILEGA_DAY];
        }
         [[NSNotificationCenter defaultCenter] postNotificationName:SHOULD_REFRESH_PC_HEADVIEW object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_INFOCONTROLLER_WITHPRIVILEGE object:nil userInfo:nil];
    }else{
        [UserDefaultsManager removeObjectForKey:VOIP_PRIVILEGA_EXPIRED_TIME];
        [UserDefaultsManager removeObjectForKey:VOIP_FIND_PRIVILEGA_SERVICE_TIME];
        [UserDefaultsManager removeObjectForKey:VOIP_FIND_PRIVILEGA_DAY];
    }
}
+(void)findJoinWechatPublic:(NSString *)number{
    HasJoinWechatPublicFeature *feature  = new HasJoinWechatPublicFeature();

    HasJoinWechatPublicRequestMessage *request = (HasJoinWechatPublicRequestMessage *)feature->get_request()->get_data();
    request->phone = [number UTF8String];
    FeatureExecuteResult result = [self executeFeature:feature];
    int answerStatus = 0;
    if (result == FeatureExecuteResultSuccess) {
        HasJoinWechatPublicResponseMessage  *msg = (HasJoinWechatPublicResponseMessage *)feature->get_response()->get_data();
        if (msg->result_code ==2000 ) {
        if (msg->result->status==0) {
            BOOL ifJoin =msg->result->join;
            answerStatus = ifJoin;
        }else{
            answerStatus = -1;
        }
        [UserDefaultsManager setIntValue:answerStatus forKey:have_join_wechat_public_status];
        [[NSNotificationCenter defaultCenter]postNotificationName:N_REFRESH_PERSONAL_INFO object:nil];
        return;
        }
    }
    answerStatus = -1;
    [UserDefaultsManager setIntValue:-1 forKey:have_join_wechat_public_status];
}

+ (NSDictionary *)requestCommercialWeb:(NSDictionary *)params {
    cootek_log(@"PrepareThread requestCommercialWeb = %@",params);
    CommercialWebFeature *feature  = new CommercialWebFeature();
    CommercialWebRequestMessage *request = (CommercialWebRequestMessage *)feature->get_request()->get_data();
    NSString *tu = [params objectForKey:@"tu"];
    NSString *at = [params objectForKey:@"at"];
    NSString *number = [params objectForKey:@"other_phone"];
    NSString *callType = [params objectForKey:@"call_type"];
    NSString *vt = [params objectForKey:@"vt"];
    NSString *ck = [params objectForKey:@"ck"];
    double now = [[NSDate date] timeIntervalSince1970];
    request->ch = [COOTEK_APP_NAME UTF8String];
    request->v = [CURRENT_TOUCHPAL_VERSION UTF8String];
    request->prt = now;
    if ([at length] > 0) {
        request->at  = [at UTF8String];
    }
    if ([tu length] > 0) {
        request->tu = [tu UTF8String];
    }
    if ([callType length] > 0) {
        request->call_type = [callType UTF8String];
    }
    if ([ck length] > 0) {
        request->ck = [ck UTF8String];
    }
    if ([vt length] > 0) {
        request->vt = [vt UTF8String];
    }
    if ([number length] > 0) {
        request->other_phone = [number UTF8String];
    }
    request->adn = 1;
    request->adclass = "EMBEDDED";
    request->nt = [[FunctionUtility networkType].uppercaseString UTF8String];
    request->rt = "HTML";
    request->w = [[params objectForKey:@"w"] intValue];
    request->h = [[params objectForKey:@"h"] intValue];
    request->pf = [[params objectForKey:@"pf"] intValue];
    
    BOOL open_free_call =  [UserDefaultsManager boolValueForKey:IS_VOIP_ON defaultValue:NO];
    request->open_free_call = open_free_call;
    
    string city = "";
    string add = "";
    if (now * 1000 - [[LocalStorage getItemWithKey:NATIVE_PARAM_CITY_CACHE_TIME] longLongValue] <= 3*86400*1000) {
        NSString *cityNS = [LocalStorage getItemWithKey:NATIVE_PARAM_CITY];
        if (cityNS) {
            city = [cityNS UTF8String];
        }
        NSString *addNS = [LocalStorage getItemWithKey:NATIVE_PARAM_ADDR];
        if (addNS) {
            add = [addNS UTF8String];
        }
    }
    request->city = city;
    request->addr = add;
    
    NSString *cacheTimeString = [LocalStorage getItemWithKey:NATIVE_PARAM_LOCATION_CACHE_TIME];
    long cacheTime = [cacheTimeString longLongValue];
    if (cacheTime > 0 && now * 1000 - cacheTime <= 3600000) {
        NSString *cacheLoc = [LocalStorage getItemWithKey:NATIVE_PARAM_LOCATION];
        cacheLoc = [cacheLoc stringByReplacingOccurrencesOfString:@"[" withString:@""];
        cacheLoc = [cacheLoc stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *locAttr = [cacheLoc componentsSeparatedByString:@","];
        if (locAttr.count == 2 && ((NSString *)locAttr[0]).length > 0) {
            double latitude = [locAttr[0] doubleValue];
            double longitude = [locAttr[1] doubleValue];
            request->latitude = latitude;
            request->longtitude = longitude;
        }
    }
  
    int personId = [NumberPersonMappingModel queryContactIDByNumber:number];
    if (personId > 0) {
        ContactCacheDataModel* personData = [[ContactCacheDataManager instance] contactCacheItem:personId];
        request->contactname = [personData.fullName UTF8String];
    }
    
    request->adn = 2;
    if ([tu isEqualToString:kAD_TU_CALL_POPUP_HTML] || [tu isEqualToString:kAD_TU_NUMPAD_HTML]) {
        request->adn = 1;
    }
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        NSString *rawResponseString = [NSString stringWithCString:feature->get_response()->get_message_string().c_str() encoding:NSUTF8StringEncoding];
        if (rawResponseString != nil) {
            NSData *data = [rawResponseString dataUsingEncoding:NSUTF8StringEncoding];
            if (data != nil) {
                NSError *error = nil;
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if (error == nil) {
                    return response;
                }
            }

        }
    }
    return nil;
}


+(void)getVoipDealStrategyWithCaller:(NSString *)caller callee:(NSString *)callee{
    VoipDealStrategyFeature  *feature  = new VoipDealStrategyFeature();
    
    VoipDealStrategyRequestMessage *request = (VoipDealStrategyRequestMessage *)feature->get_request()->get_data();
    request->caller = [caller UTF8String];
    request->callee = [callee UTF8String];
    
    request->version = [CURRENT_TOUCHPAL_VERSION UTF8String];
    request->channel_code = [IPHONE_CHANNEL_CODE UTF8String];
    
    
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        VoipDealStrategyResponseMessage  *msg = (VoipDealStrategyResponseMessage *)feature->get_response()->get_data();
        [UserDefaultsManager setIntValue:msg->deal_strategy_code forKey:deal_strategy_number];
        }
}


+ (NSDictionary *)inviteShareRequest:(NSDictionary *)dict{
    HangupInviteFeature *feature = new HangupInviteFeature();
    
    HangupInviteRequestMessage *request = (HangupInviteRequestMessage *)feature->get_request()->get_data();
    request->target_phone = [dict[@"target_phone"] UTF8String];
    request->target_name = [dict[@"target_name"] UTF8String];
    request->duration = [dict[@"duration"] intValue];
    request->is_general_contact = [dict[@"is_general_contact"] intValue];
    request->current_timestamp = [dict[@"current_timestamp"] intValue];
    request->close_time = [dict[@"close_time"] intValue];
    
    FeatureExecuteResult result = [self executeFeature:feature];
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc]init];
    if (result == FeatureExecuteResultSuccess) {
        HangupInviteResponseMessage  *msg = (HangupInviteResponseMessage *)feature->get_response()->get_data();
        
        if (msg->result == nil)
            return nil;
        
        NSInteger nextUpdateTime = msg->result->next_update_time;
        if ( nextUpdateTime > 0 ){
            cootek_log(@"inviteShareMananger %d", nextUpdateTime);
            [UserDefaultsManager setIntValue:nextUpdateTime forKey:@"invite_share_next_update_time"];
        }
        if (msg->result_code ==2000 ) {
            resultDict[@"ios_invite_icon"]          = [NSString stringWithUTF8String:msg->result->invite_content->ios_invite_icon.c_str()];
            resultDict[@"ios_invite_icon_font"]     = [NSString stringWithUTF8String:msg->result->invite_content->ios_invite_icon_font.c_str()];
            resultDict[@"invite_title_text"]        = [NSString stringWithUTF8String:msg->result->invite_content->invite_title_text.c_str()];
            resultDict[@"invite_title_content"]     = [NSString stringWithUTF8String:msg->result->invite_content->invite_title_content.c_str()];
            resultDict[@"invite_first_title"]       = [NSString stringWithUTF8String:msg->result->invite_content->invite_first_title.c_str()];
            resultDict[@"invite_second_title"]      = [NSString stringWithUTF8String:msg->result->invite_content->invite_second_title.c_str()];
            resultDict[@"invite_left_button_text"]  = [NSString stringWithUTF8String:msg->result->invite_content->invite_left_button_text.c_str()];
            resultDict[@"invite_right_button_text"] = [NSString stringWithUTF8String:msg->result->invite_content->invite_right_button_text.c_str()];
            resultDict[@"share_header_title"]       = [NSString stringWithUTF8String:msg->result->invite_content->share_header_title.c_str()];
            resultDict[@"share_title"]              = [NSString stringWithUTF8String:msg->result->invite_content->share_title.c_str()];
            resultDict[@"share_message"]            = [NSString stringWithUTF8String:msg->result->invite_content->share_message.c_str()];
            resultDict[@"share_url"]                = [NSString stringWithUTF8String:msg->result->invite_content->share_url.c_str()];
            resultDict[@"share_img_url"]            = [NSString stringWithUTF8String:msg->result->invite_content->share_img_url.c_str()];
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for (TPSTRING share_string : msg->result->invite_content->share_list){
                [array addObject:[NSString stringWithUTF8String:share_string.c_str()]];
            }
            resultDict[@"share_list"]               = [array copy];
            resultDict[@"share_target_phone"]       = [NSString stringWithUTF8String:msg->result->invite_content->share_target_phone.c_str()];
            resultDict[@"share_type"]               = @(msg->result->invite_content->share_type);
        }
    }
    return [resultDict copy];
}

+ (TPAdControlStrategy *) getControlServerData:(TPAdControlRequestParams *)requestParams {
    GetControlServerDataFeature *feature = new GetControlServerDataFeature();
    GetControlServerDataRequestMessage *msg = (GetControlServerDataRequestMessage *)feature->get_request()->get_data();
    
    // required
    msg->tu = [requestParams.tu integerValue];
    msg->time = requestParams.time;
    msg->ip = [requestParams.ipAddress UTF8String];
    msg->nt = [requestParams.networkType UTF8String];
    for (NSNumber *plaformId in requestParams.supportedPlatformIds) {
        msg->support_ad_platform_id.push_back([plaformId intValue]);
    }
    
    // optional
    msg->debug = requestParams.debug;
    msg->os = requestParams.os;
    msg->product = requestParams.productType;
    if (requestParams.feedsId != DSP_FEEDS_NULL) {
        msg->ftu = requestParams.feedsId;
    }
    if (requestParams.callMode) {
        msg->vt = [requestParams.callMode UTF8String];
    }
    
    FeatureExecuteResult result = [self executeFeature:feature];
    if (result == FeatureExecuteResultSuccess) {
        GetControlServerDataResponseMessage *response = (GetControlServerDataResponseMessage *)feature->get_response()->get_data();
        if (response != NULL
            && response->error_code == 0) {
            TPAdControlStrategy *strategy = [[TPAdControlStrategy alloc] init];
            strategy.rawMessageString = [NSString stringWithUTF8String:feature->get_response()->get_message_string().c_str()];
            strategy.tu =[@(response->tu) stringValue];
            strategy.expId = response->expid;
            strategy.s = [NSString stringWithUTF8String:response->s.c_str()];
            
            NSMutableArray *enabledIds = [[NSMutableArray alloc] initWithCapacity:1];
            for(TPNUMERIC enabledId : response->enable_platform_list) {
                [enabledIds addObject:@(enabledId)];
            }
            strategy.platformIdsForNextRequst = [enabledIds copy];
            
            NSMutableArray *effectiveIds = [[NSMutableArray alloc] initWithCapacity:1];
            for(TPNUMERIC platformId : response->ad_platform_id) {
                [effectiveIds addObject:@(platformId)];
            }
            strategy.effectivePlatformIds = [effectiveIds copy];
            
            NSMutableArray *dataId = [[NSMutableArray alloc] initWithCapacity:1];
            for(GetControlServerDataMessage *msg: response->data_id) {
                NSMutableDictionary *adInfo = [[NSMutableDictionary alloc] initWithCapacity:1];
                NSString *placementId = [NSString stringWithUTF8String:msg->placement_id.c_str()];
                if (![NSString isNilOrEmpty:placementId]) {
                    [adInfo setObject:placementId forKey:TP_AD_PLACEMENT_ID];
                }
                [adInfo setObject:@(msg->ad_platform_id) forKey:TP_AD_PLATFORM_ID];
                
                [dataId addObject:[adInfo copy]];
            }
            strategy.dataId = [dataId copy];
            
            cootek_log(@"%@", strategy);
            
            delete feature;
            return strategy;
        }
    }
    delete feature;
    return nil;
}

@end
