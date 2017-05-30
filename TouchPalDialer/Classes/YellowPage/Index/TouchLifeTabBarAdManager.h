//
//  TouchLifeTabBarAdManager.h
//  TouchPalDialer
//
//  Created by tanglin on 16/6/3.
//
//

#import <Foundation/Foundation.h>

@interface TouchLifeTabBarAdManager : NSObject

+ (TouchLifeTabBarAdManager* ) instance;
- (void) remoteReqAd;
- (void) sendCMonitorUrl;

@end
