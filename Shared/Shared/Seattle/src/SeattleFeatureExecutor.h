//
//  SeattleFeatureExecutor.h
//  CallerInfoShow
//
//  Created by Elfe Xu on 13-1-31.
//  Copyright (c) 2013年 callerinfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SeattleDataModel.h"
#import "FeatureQueue.h"
#import "VOIPAccountInfo.h"
#import "VoipFeedbackInfo.h"
#import "TaskBonusResultInfo.h"
#import "PersonInfo.h"
#import "HangupCommercialModel.h"
#import "TPAdDSPController.h"
#import "TPAdControlRequestParams.h"
#import "TPAdControlStrategy.h"

#define INVALID_LOCATION_VALUE -181.0
#define QUERY_ALL_CALLLOG -1

#define VOIP_HISTORY 2
#define FLOW_HISTORY 1
#define ALL_HISTORY 0

typedef enum {
    ActivateTypeNew,
    ActivateTypeRenew,
    ActivateTypeUpgrade,
} ActivateType;

typedef enum {
    YellowpageContributeTypeAdd,
    YellowpageContributeTypeReportError,
} YellowpageContributeType;

typedef enum {
    NullableBooleanValueNone = -1,
    NullableBooleanValueFalse = 0,
    NullableBooleanValueTrue = 1,
} NullableBooleanValue;

typedef enum {
    FeatureExecuteResultSuccess,
    FeatureExecuteResultFailCouldRetry,
    FeatureExecuteResultFail
}FeatureExecuteResult;

@interface RequiredSeattleExecutorHelper :NSObject
+ (BOOL) activateWithType:(ActivateType)type;
+ (void) handleQueryCallerIdResult:(CloudCallerIdInfo *)callerInfo;
+ (NSArray *)recentlyCalllogsWithCount:(int)count;
+ (NSArray *)calllogsSinceDate:(NSDate *)date;
+ (CLLocationCoordinate2D)currentLocation;
@end

@interface SeattleFeatureExecutor : NSObject

+ (BOOL)activateWithType:(ActivateType)activateType;
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
              appleToken:(NSString *)appleToken;
+ (BOOL)uploadCallHistoryWithCount:(NSInteger)count;
+ (BOOL)uploadContact;
+ (NSArray *)queryCallerInfoWithSurvey:(BOOL)acceptSurvey
                                phones:(NSArray *)phones;
+ (NSArray *)queryCallerInfoWithSurvey:(BOOL)acceptSurvey
                                phones:(NSArray *)phones
                            networkMnc:(NSString *)mnc
                           hasLocation:(BOOL)hasLocation
                              location:(CLLocationCoordinate2D)location;
+ (FeatureExecuteResult)executeSerilizedFeature:(SerilizableFeature *)feature;
//VOIP
+ (NSInteger) askVerifyCode:(NSString *)phoneNumber isVoiceType:(BOOL)isVoiceType;
+ (NSInteger) registerWithNumber:(NSString *)phoneNumber
                       andVerifyCode:(NSString *)code;
+ (NSDictionary *)queryVOIPAccountInfo;
+ (void)getVoipReward;
+ (int)useInvitationCode:(NSString *)code;
+ (dispatch_queue_t)getQueue;
+ (BOOL)uploadVoipCallLog:(NSString *)log;
+ (NSArray *)queryVoipUserExist:(NSArray *)userNumberList;
+ (void)reLogin;
+ (NSString *)getToken;
+ (NSArray *)getHistory:(NSInteger)bonusType;
+ (NSInteger)postFeedback:(VoipFeedbackInfo *)info;
+ (void)getTaskBonus:(NSInteger)eventId withSuccessBlock: (void (^)(int bonnus, TaskBonusResultInfo *))successBlock withFailedBlock:(void (^)(int resultCode,TaskBonusResultInfo *info))failedBlock;
+ (NSInteger)exchangeTraffic:(NSString*)nickName flow:(NSInteger)flow;
//+ (BOOL)isCommercialAccount;
+ (PersonInfo*)getPersonProfile;
+ (BOOL)setPersonProfile:(NSString*)profileUrl withType:(NSInteger)type withGender:(NSInteger)gender;
+ (BOOL)voipCallRewardWithCallId:(NSString *)callId andDurationSeconds:(int)seconds;
+ (NSDictionary *)getVoipPrivilegeAdInfoWithOtherNumber:(NSString *)number andCallType:(NSString *)callType;
+ (BOOL)logout;
+ (BOOL)uploadVoipCallAttr:(NSString *)attr;
+ (NSDictionary *)getAccountNumbersInfo;
+ (NSArray *)useInvitationCodeOldInterface:(NSString *)code;
+ (NSInteger)getAppDownloadAwardWithAppID:(NSString *)appid userPhoneNumber:(NSString *)phone;
+(BOOL)ifParticipateVoipOverseaWithPhone:(NSString *)phone;
+(BOOL)IfSuccessOnParticipateVoipOverseaWithPhone:(NSString *)phone;
+(void)redeemExchangeUseSeattleWithMessage:(NSString *)message;
+(void)findVoipPrivilegeInfo;
+ (NSInteger) ackADReward: (NSString *) feedbackInfo;
+ (NSDictionary *) fetchLaunchAD;
+ (void) findJoinWechatPublic:(NSString *)number;
+ (NSDictionary *)inviteShareRequest:(NSDictionary *)dict;

+ (NSDictionary *)requestCommercialWeb:(NSDictionary *)params;

+(void)getVoipDealStrategyWithCaller:(NSString *)caller callee:(NSString *)callee;

+ (TPAdControlStrategy *) getControlServerData:(TPAdControlRequestParams *)requestParams;

@end
