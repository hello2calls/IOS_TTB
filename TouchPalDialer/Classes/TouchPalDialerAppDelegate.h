//
//  TouchPalDialerAppDelegate.h
//  TouchPalDialer
//
//  Created by zhang Owen on 7/15/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "NotificationScheduler.h"
#import "TouchPalDialerLaunch.h"
#import <RDVTabBarController.h>
#import <RDVTabBarItem.h>
#import "TPDExtension.h"

// set to 1 or 0
#import <UserNotifications/UserNotifications.h>

@interface TouchPalWindow : UIWindow
@end

@interface TouchPalApplication : UIApplication
@end

@interface TouchPalDialerAppDelegate : NSObject <UIApplicationDelegate, UNUserNotificationCenterDelegate>


@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, readonly) UINavigationController *activeNavigationController;
@property (nonatomic, assign) BOOL isUserRegisteredBefore;
@property (nonatomic, readonly) NotificationScheduler* notificationScheduler;
+ (UINavigationController *)naviController;
+ (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

+ (void)popViewControllerWithAnimated:(BOOL)animated;


void UncaughtExceptionHandler(NSException *exception);
@end

