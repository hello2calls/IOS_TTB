//
//  BaiduMobAdNative.h
//  BaiduMobAdSdk
//
//  Created by lishan04 on 15-1-8.
//
//

#import <Foundation/Foundation.h>
#import "BaiduMobAdNativeAdDelegate.h"
@class BaiduMobAdNativeAdView;

@interface BaiduMobAdNative : NSObject
/**
 * 原生广告delegate
 */
@property (nonatomic ,assign) id<BaiduMobAdNativeAdDelegate> delegate;

/**
 * 请求多条原生广告
 */
- (void)requestNativeAds;


@end
