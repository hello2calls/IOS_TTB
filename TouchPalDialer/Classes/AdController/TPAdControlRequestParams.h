//
//  TPAdControlRequestParams.h
//  TouchPalDialer
//
//  Created by siyi on 16/6/22.
//
//

#ifndef TPAdControlRequestParams_h
#define TPAdControlRequestParams_h

// 以下常量取值由广告组的文档确定

// 用户当前网络类型，即network type，可取值：
#define TP_DSP_NETWORK_2G @"2G"
#define TP_DSP_NETWORK_3G @"3G"
#define TP_DSP_NETWORK_4G @"4G"
#define TP_DSP_NETWORK_WIFI @"WIFI"
#define TP_DSP_NETWORK_UNKNOWN @"UNKNOWN"

// call type

// 表示feeds中的广告来源， 非feeds流字段留空
typedef NS_ENUM(NSInteger, TPDSPFeedsType) {
    DSP_FEEDS_NULL = -1,
    DSP_FEEDS_YP = 101,
    DSP_FEEDS_TP_NEWS = 102,
    DSP_FEEDS_YP_READING = 103,
    DSP_FEEDS_HANGUP = 104,
    DSP_FEEDS_NOTI = 107,
    DSP_FEEDS_DIALER = 108,
    DSP_FEEDS_GUAJI = 109,
};

typedef NS_ENUM(NSUInteger, TPOSType) {
    OS_ANDROID = 1,
    OS_IOS = 2,
};

typedef NS_ENUM(NSUInteger, TPDSPPlatformId) {
    DSP_TYPE_TP_DAVINCI = 1,
    DSP_TYPE_BAIDU_MOBADS_SDK = 100,
    DSP_TYPE_TECENT_GDT_SDK = 101,
    DSP_TYPE_ADMOB_VOIP_SDK = 102,
};

typedef NS_ENUM(NSUInteger, TPProductType) {
    PRODUCT_TYPE_INPUT = 1,
    PRODUCT_TYPE_DIALER = 2,
    PRODUCT_TYPE_UNION_SDK = 3,
};

#import <Foundation/Foundation.h>

@interface TPAdControlRequestParams : NSObject

/*
 required: you MUST set these values explicitly
 */

@property (nonatomic, strong) NSString *tu;
@property (nonatomic, strong) NSArray<NSNumber *> *supportedPlatformIds;


/*
 required: these values will be set automaticlly.
 */
@property (nonatomic, strong) NSString *ipAddress; /* ip */
@property (nonatomic, assign) long long time; /* timestamp in seconds */
@property (nonatomic, assign) TPProductType productType; /* product */
@property (nonatomic, strong) NSString *networkType; /* nt */

/*
 optional: you can ommit to set these values as you want. 
        If not set, the field will not be packed into the http request. 
 */
@property (nonatomic, assign) BOOL debug;
@property (nonatomic, assign) TPDSPFeedsType feedsId; /* ftu */
@property (nonatomic, strong) NSString *callMode; /* vt */
@property (nonatomic, assign) TPOSType os;

@end

#endif /* TPAdControlRequestParams_h */
