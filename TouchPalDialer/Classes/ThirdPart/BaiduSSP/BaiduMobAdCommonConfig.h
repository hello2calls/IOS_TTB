//
//  BaiduMobAdCommonConfig.h
//  BaiduMobAdSdk
//
//  Created by dengjinxiang on 13-8-22.
//
//

#ifndef BaiduMobAdSdk_BaiduMobAdCommonConfig_h
#define BaiduMobAdSdk_BaiduMobAdCommonConfig_h
//SDK版本号
#define SDK_NATIVE_VERSION_IN_MSSP @"1.28"

/**
 * BaiduMobAdCommonConfig define some common config
 */
typedef enum {
    NORMAL, // 一般图文或图片广告
    VIDEO, // 视频播放类广告，需开发者增加播放器支持
    HTML // 信息流模版广告
} MaterialType;

typedef enum {
    BaiduMobNativeAdActionTypeLP = 1,
    BaiduMobNativeAdActionTypeDL = 2
} BaiduMobNativeAdActionType;


typedef enum {
    onClickToPlay,//点击播放
    onStart, //开始播放
    onError, //播放失败
    onComplete, //完整播放
    onClose, //播放结束
    onFullScreen, //全屏观看
    onClick //广告点击
} BaiduAdNativeVideoEvent;

/**
 *  性别类型
 */
typedef enum
{
	BaiduMobAdMale=0,
	BaiduMobAdFeMale=1,
    BaiduMobAdSexUnknown=2,
} BaiduMobAdUserGender;

/**
 *  广告请求失败类型枚举
 */
typedef enum _BaiduMobFailReason
{
    BaiduMobFailReason_NOAD = 0,
    // 没有推广返回
    BaiduMobFailReason_EXCEPTION
    //网络或其它异常
} BaiduMobFailReason;

/**
 *  广告asset类型枚举
 */
enum {
    NativeAdAssetTypeTitle = 1,
    NativeAdAssetTypeText = 2,
    NativeAdAssetTypeIconImage = 4,
    NativeAdAssetTypeMainImage = 8
};
typedef NSUInteger NativeAdAssetType DEPRECATED_ATTRIBUTE;

/**
 *  广告点击类型枚举
 */
#define ACTION_TYPE_LANDING_PAGE @"LP"
#define ACTION_TYPE_DOWNLOAD @"DL"
#define TOPIC @"topic"


typedef enum {
    BaiduMobAdNativeLpStyleDefault,
    BaiduMobAdNativeLpStyleRed,
    BaiduMobAdNativeLpStyleGreen,
    BaiduMobAdNativeLpStyleBrown,
    BaiduMobAdNativeLpStyleDarkBlue,
    BaiduMobAdNativeLpStyleLightBlue,
    BaiduMobAdNativeLpStyleBlack
} BaiduMobAdNativeLpStyle;

#endif