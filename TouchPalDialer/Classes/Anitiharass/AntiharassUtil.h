//
//  AntiharassUtil.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/8.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworkOperation/AFHTTPRequestOperation.h>

#ifdef DEBUG
#define ANTIHARASS_FILE_PATH @"http://dialer.cdn.cootekservice.com/iphone/default/antiharass/db/"
#else
#define ANTIHARASS_FILE_PATH @"http://dialer.cdn.cootekservice.com/iphone/default/antiharass/db/"
#endif
#define GUIDE_PATH @"http://dialer.cdn.cootekservice.com/iphone/default/antiharass/helpHtml/faq_antiharass.html"
#define GUIDE_PATH_IOS10 @"http://dialer.cdn.cootekservice.com/iphone/default/antiharass/helpHtml_iOS10/faq_antiharass.html"

#define ANTIHARASS_DIRECT_FILE_PATH @"http://oss.aliyuncs.com/cootek-dialer-download/iphone/default/antiharass/db/"

typedef enum {
    BEIJING = 1,
    SHANGHAI = 2,
    GUANGZHOU = 3,
    SHENZHEN = 4,
    CHENGDU = 5,
    CHONGQING = 6,
    TIANJIN = 7,
    NANJING = 8,
    WUHAN = 9,
    XIAN = 10,
    ZHENZHOU = 11,
    OTHER = 12
} AntiharassType;

typedef enum {
    ANTIHARASS_VIEW_NO_NETWORK,
    ANTIHARASS_VIEW_GPRS_CONFIRM,
    ANTIHARASS_VIEW_FIRST_START,
    ANTIHARASS_VIEW_LOADING,
    ANTIHARASS_VIEW_NETWORK_ERROR,
    ANTIHARASS_VIEW_SUCCESS,
    ANTIHARASS_VIEW_REMOVE_SUCCESS,
    ANTIHARASS_VIEW_REMOVE_CONFIRM,
    ANTIHARASS_VIEW_GUIDE,
    ANTIHARASS_VIEW_REMOVE_LOADING,
    ANTIHARASS_VIEW_FAILED,
    ANTIHARASS_VIEW_VERSION_IS_NEWEST,
    ANTIHARASS_VIEW_NOTSHOW_IN_BACKGROUND
} AntiharassViewStep;

typedef enum{
    ANTIHARASS_NEW_BUILD_UPDATE_STEP,
    ANTIHARASS_NEW_BUILD_DOWNLOAD_STEP,
    ANTIHARASS_NEW_BUILD_REMOVE_ADDRESSBOOK,
    ANTIHARASS_NEW_BUILD_BUILD_ADDRESSBOOK,
    ANTIHARASS_REMOVE_ADDRESSBOOK,
    ANTIHARASS_START_UPDATE,
    ANTIHARASS_START_UPDATE_IN_WIFI_BACKGROUND,
    ANTIHARASS_UPDATE_IN_BACKGROUND,
    ANTIHARASS_NEW_BUILD_REMOVE_ADDRESSBOOK_IN_BACKGROUND,
    ANTIHARASS_NEW_BUILD_BUILD_ADDRESSBOOK_IN_BACKGROUND,
    ANTIHARASS_UPDATE_IN_DIALERVC
} AntiharassModelStep;

typedef enum{
    ANTIHARASS_NETWORK_ERROR,
    ANTIHARASS_NEW_BUILD_NEED_UPDATE,
    ANTIHARASS_NEW_BUILD_NOT_NEED_UPDATE,
    ANTIHARASS_NEW_BUILD_REMOVE,
    ANTIHARASS_DOWNLOAD_SUCCESS,
    ANTIHARASS_BUILD_SUCCESS,
    ANTIHARASS_REMOVE_SUCCESS,
    ANTIHARASS_FAILED,
    ANTIHARASS_VERSION_IS_NEWEST,
    ANTIHARASS_NEW_VERSION_NEED_UPDATE,
} AntiharassModelResult;

@interface AntiharassUtil : NSObject
+ (NSString *)getDBName:(AntiharassType)type;
+ (NSString *)getZipName:(AntiharassType)type;
+ (NSString *)getStringName:(AntiharassType)type;
+ (NSString *)getVersionFileName;
+ (NSString *)translateVersionToString:(NSString *)version;
+ (BOOL)ifDBTypeChanged;
+ (void)downloadFileFrom:(NSString *)urlString to:(NSString *)filePath withSuccessBlock:(void (^)(AFHTTPRequestOperation *, id))success withFailure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;
+ (void)showGuidePage;
@end
