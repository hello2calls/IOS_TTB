//
//  VoipUtils.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/2/4.
//
//

#import <Foundation/Foundation.h>
#import "FileUtils.h"
#define VOIP_CALL_NAME @"V 触宝免费电话"
#define VOIP_CALL_MAIN_NUMBER @"4001183315"

#define Commercial  @"Commercial"
#define ADdownLoadResource @"ADdownLoadResource"
#define ADResource @"ADResource"


#define ADDirectCallHTML @"directCall.html"
#define ADBackCallHTML @"backCall.html"
#define ADNumPadHTML @"numPad.html"
#define ADPopupCallHTML @"popupCall.html"
#define ADLaunchHTML @"launch.html"

#define READY_RESOURCE_PLIST @"ready_resouce.plist"
#define REQUEST_RESOURCE_PLIST @"request_resource.plist"
#define ALL_RESOURCE_WITHIN_TIME_PLIST @"all_resource_within_time.plist"

#define SUFFIX_HTML @"html"
#define NAME_AD_POPUP_CALL @"popupCall"


#define REG_PATTERN_COOTEK_AD @"var\\s*COOTEK_AD\\s*=(.+);?\\s*</script>\\s*</head>"

/**
 enable pre-insert numbers for "V 触宝免费电话" conact item
 (NOT related to noah pushing)
 */
#define ENABLE_LOCAL_TOUCHPAL_V_NUMBER (NO)


@interface VoipUtils : NSObject
typedef enum {
    STATE_CALL_ERROR_DIR      = 1001,
    STATE_CALL_ERROR_BACK       = 1002,
    MEDIA_INIT_ERROR   = 1003,
    NO_RTP_TIME_OUT_C2C    = 1004,
    NO_RTP_TIME_OUT_C2P = 1005,
    NETWORK_CHANGED = 1006,
    CAN_NOT_TOUCH_TURN = 1007,
    REQUEST_TIME_OUT = 1008,
    NETWORK_ERROR = 1009,
    CONNECTION_RESET = 1010,
    CONNECT_INTERRUPT = 1011,
    ERR_REASON_UNKNOWN_EXCEPTION_INVITE = 1012,
    ERR_REASON_INIT_FAILED_INVITE = 1013,
    NETWORK_DISCONNECT = 1016,
    
    FORBIDDEN = 2001,
    LOOP_DETECTED = 2002,
    DECLINED = 2003,
    CONNECTION_TIME_OUT = 2004,
    WAIT_RESULT_TIME_OUT = 2005,
    WAIT_TRYING_TIME_OUT = 2006,
    INVITE_CALL_FAILED = 3001,
    STATE_CORE_NOT_READY = 3002,
    TRANSPORT_FAILURE = 3003,
    BAD_REQUEST = 3004,
    BUSY_EVERYWHERE = 4001,
    DECLINE = 4002,
    DECLINED_LONGER = 4003,
    SERVICE_UNAVAILIABLE = 4004,
    GONE = 4005,
    VERSION_EXPIRED = 4006,
    SERVER_MAITAIN = 4007,
    FLOW_FAILED = 4008,
    BLACK_LIST = 4009,
    AUTH_FAILED = 4010,
    SYSTEM_CALL_INCOMING = 4011,
    ERR_REASON_CALLEE_TOUCHPAL = 4013,
    ERR_REASON_CALLER_LOCATION = 4012,
    ERR_REASON_COUNTRY_OFFLINE = 5001,
    ERR_REASON_COUNTRY_UNSUPPORT = 5002,
    ERR_REASON_EXCESSIVE_CALLS = 5003,
    ERR_REASON_INVALID_CALLER =5004,
    ERR_REASON_HARASSING = 5005,
    ERR_REASON_CALLEE_NUMBER_UNSPORRT = 5006,
    ERR_REASON_CALLEE_TYPE_UNSPORRT =5007,
    ERR_REASON_CALLEE_OFFLINE_UNSPORRT = 5008,
    ERR_REASON_BYE_SERVER = 6001,
    UNKNOWN_ERROR = 9999,
} VOIPCallError;

+ (NSDictionary *)extractCallInfo:(NSString *)sipMessage;

+ (NSString *)getVoipEnvironmentString:(NSString *)callabck;

+ (NSString *)dictString:(NSString *)string;

+ (BOOL)addVoipBackCallNumberToAddressBook;

+ (void)checkBackCallNumberPerson;

+ (void)updateBackCallNumberPerson:(NSArray*)numbers;
+ (NSDictionary *)translateJSONWithErrorCode:(int)errorCode;
//+ (void)translateErrorCode:(int)errorCode
//              withCallBack:(void(^)(NSString *errorMessage, NSString *extraInfo, NSString *remind,NSString *solution ,NSString *solution_action))callBack;
+ (void)translateErrorCode:(int)errorCode withCallBack:(void(^)(
                                                                NSString *errorMessage,
                                                                NSString *extraInfo,
                                                                NSString *remind,
                                                                NSString *solution,
                                                                NSString* solution_action,
                                                                NSString *dialog_solution_action,
                                                                NSString *dialog_solution_btn,
                                                                NSString *dialog_solution_main                                                    ))callBack ;
+ (void)uploadCallLog:(NSString *)log;

+ (void)uploadCallStat:(NSDictionary *)attr;
+ (void)getErrorCodeInfo;
+(BOOL)ifShowADWithErrorCode:(NSInteger)error_code ifOutging:(BOOL)outgoing;
+(void)updateVoipErrorCodeJsonWithPath:(NSString *)path withVersion:(NSString *)version;
+(void)checkVersionIfDownLoadSourceWithdestString:(NSString *)destString srcString:(NSString *)srcString ver:(NSString *)ver tu:(NSString *)tu;
+(void)checkIfCreatAdDir;

+ (void) updateHtmlFileWithString:(NSString *)string tu:(NSString *)tu;

+(BOOL)stringByRegularExpressionWithstring:(NSString *)string pattern:(NSString *)pattern tu:(NSString *)tu;

+ (BOOL) isCommercialCacheReadyForTu:(NSString *)tu;

+ (NSString *) absoluteCommercialDirectoryPath:(NSString *)subDir;

+ (NSString *) commercialHTMLNameForTu:(NSString *)tu;
+ (NSString *) absoluteCommercialHTMLPathForTu:(NSString *)tu;

/**
 *  use this method when you the file name is related to the ad info
 *
 *  @param tu   ad positon
 *  @param info ad info as dict
 *
 *  @return file name consisting the tu-based name and item from the ad info
 */
+ (NSString *) commercialHTMLNameForTu:(NSString *)tu adInfo:(NSDictionary *)info;
+ (NSString *) absoluteCommercialHTMLPathForTu:(NSString *)tu adInfo:(NSDictionary *)info;

+ (BOOL) isCommercialCacheReadyForTu:(NSString *)tu;

+ (NSString *) popupHTMLName;


+ (void) asyncGetCallPopupADWithSetting:(NSDictionary *)settings;

+ (NSDictionary *) firstADFromHTMLFile:(NSString *)path byTu:(NSString *)tu;
+ (NSDictionary *) firstADFromHTMLFileAtTu:(NSString *)tu;

+(void)saveNoAdReasonWithKey:(NSString *)key value:(NSObject *)value;
+ (NSString *) pathForResoucePlist:(NSString *)fileName;
+ (NSArray *) getResource:(NSString *)fileName;
+ (NSArray *) notFetchedFromRequestResource:(NSArray *)requestedList withReadyResources:(NSArray *)readyList;
@end
