//
//  AdLandingPageManager.h
//  TouchPalDialer
//
//  Created by weihuafeng on 15/11/24.
//
//

#import <Foundation/Foundation.h>
#import "WebviewControllerDelegate.h"


// 统计LandingPage广告数据
@class AdMessageModel;
@interface AdLandingPageManager : NSObject

- (instancetype)initWithAd:(AdMessageModel *)ad webController:(UIViewController *)controller;

@end
