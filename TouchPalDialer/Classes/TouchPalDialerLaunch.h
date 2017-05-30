//
//  TouchPalDialerLaunch.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/10/23.
//
//

#import <Foundation/Foundation.h>

@interface TouchPalDialerLaunch : NSObject

@property (atomic, assign) BOOL isDataInitialized;
@property (atomic, assign) BOOL isVoipCallInitialized;

+ (TouchPalDialerLaunch*)getInstance;

- (void)normalLaunchWithOptions:(NSDictionary*) launchOptions;
- (void)didBecomeActiveFromStartOrPause;
- (void)registerForStatusBarChange: (UIView *)targetView;
- (void)unregisterForStatusBarChange: (UIView *)targetView;
- (void)checkForStatusBarChange;
@end
