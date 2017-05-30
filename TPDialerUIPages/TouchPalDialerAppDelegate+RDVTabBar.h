//
//  TouchPalDialerAppDelegate+RDVTabBar.h
//  TouchPalDialer
//
//  Created by weyl on 16/9/20.
//
//

#import "TouchPalDialerAppDelegate.h"

@interface TouchPalDialerAppDelegate (RDVTabBar)
@property (nonatomic, strong) RDVTabBarController* tabBarController;

- (void)setupAppRootViewController;

@end
