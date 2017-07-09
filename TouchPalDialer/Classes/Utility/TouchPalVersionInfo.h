//
//  TouchPalVersionInfo.h
//  TouchPalDialer
//
//  Created by Xu Elfe on 12-9-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef TouchPalDialer_TouchPalVersionInfo_h
#define TouchPalDialer_TouchPalVersionInfo_h

//begin: ----- info change for next version -----

#define	CURRENT_TOUCHPAL_VERSION	@"5674"
#define	VERSION_DATE	@"2017/01/24"
//  end: ----- info change for next version -----

// begin: ----- debug settings -----
#ifndef USE_DEBUG_SERVER
#define	USE_DEBUG_SERVER	YES
#endif

#ifndef NOAH_LOCAL_DEBUG
#define NOAH_LOCAL_DEBUG YES
#endif

//debug for noah test
#define ENABLE_NOAH_TEST_DEBUG NO
#define NOAH_TEST_DEDUG_SERVER_HOST @"ararat-test.cootekservice.com"
#define NOAH_TEST_DEBUG_HTTP_PORT   80


//debug for voip login
// defaultly `ENABLE_VOIP_DEBUG` is equivalent to `USE_DEBUG_SERVER`
//#define ENABLE_VOIP_DEBUG USE_DEBUG_SERVER
#define ENABLE_VOIP_DEBUG (NO && USE_DEBUG_SERVER)
//#define VOIP_DEDUG_SERVER_HOST @"121.52.235.231"
#define VOIP_DEDUG_SERVER_HOST @"121.52.250.39"
//#define VOIP_DEBUG_HTTP_PORT 40706
#define VOIP_DEBUG_HTTP_PORT 30007
#define VOIP_DEBUG_HTTPS_PORT 40725

//debug for AD
#define ENABLE_AD_DEBUG (NO)
#define AD_DEBUG_SERVER_HOST @"183.136.223.35"
#define AD_DEBUG_HTTP_PORT 8886
#define AD_DEBUG_HTTPS_PORT 443
#define AD_DEBUG_TU_LAUNCH_OTHERPHONE @"14744444471"
#define AD_DEBUG_TU_POPHTML_OTHERPHONE @"14744447477"

//debug for yellowPage
#define ENABLE_YP_DEBUG (NO && USE_DEBUG_SERVER)
#define YP_DEBUG_SERVER_HOST @"121.52.235.231"
#define YP_DEBUG_HTTP_PORT 40706
#define YP_DEBUG_HTTPS_PORT 443
// end:  ----- debug settings -----


//begin: ----- info never change -----
#define COOTEK_APP_NAME  @"com.cootek.smartdialer.ttb"
//#define COOTEK_APP_NAME  @"cootek.contactplus.ios.public"
#define COOTEK_APP_PLATFORM_IOS @"iphone"
#define IPHONE_CHANNEL_CODE @"OEM 172 B19 100"
//#define TOUCHPAL_APPKEY @"4763853977302293"
#define TOUCHPAL_APPKEY @"924881448494"
#define TOUCHPAL_APPSECRET @"047821ede36d48bebba5be24371c87ec"

#define TOUCHPAL_DIALER_APP_STORE_URL @"http://itunes.apple.com/app/id503130474"
#define TOUCHPAL_DIALER_APP_STORE_REVIEW_URL @"http://itunes.apple.com/us/app/chu-bao-zhi-neng-bo-hao/id503130474?ls=1&mt=8"
//  end: ----- info never change -----

#ifndef TEST_INTERNATIONAL_CALL_INVITE
#define TEST_INTERNATIONAL_CALL_INVITE NO
#endif

#define ENABLE_STATISTIC_NETWORK_INFO NO

#define DEFAULT_VOIP_BALANCE 600

#define HARD_CODE_C2C_SUPORT NO

#define ENABLE_DEFAULT_SNOW NO

#define ENABLE_COMMERICAL_PREPARE YES

#define VERSION_FOR_DOWNLOAD_SKIN        @"5400"
#define LOWEST_SKIN_VERSION_CAN_BE_USED  @"5510"
#define NEW_SKIN_VERSION_CAN_BE_USED     @"5649"


#define DEFAULT_ENABLE_CONATCTS_SYNC_IOS10 NO
#define LOCAL_ERROR_CODE_VERSION @"4"
#endif
