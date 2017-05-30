//
//  YPAdTaskBaidu.h
//  TouchPalDialer
//
//  Created by tanglin on 16/5/27.
//
//

#import "YPTaskBase.h"
#import "BaiduMobAdNativeAdDelegate.h"
#import "BaiduMobAdNative.h"
#import "BaiduMobAdNativeAdView.h"
#import "BaiduMobAdNativeVideoView.h"
#import "BaiduMobAdNativeWebView.h"


@interface YPAdTaskBaidu : YPTaskBase
@property(nonatomic, retain)BaiduMobAdNative *native;

- (void) setBaiduDelegate:(id) delegate;
@end
