//
//  NotificationScheduler.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-15.
//
//

#import <Foundation/Foundation.h>
#import "TPNotification.h"

@interface NotificationScheduler : NSObject

@property (nonatomic, retain) UILocalNotification* pendingNotification;

-(void) notifyBackgroundNotificationBy:(UIApplication*) application;
-(void) notifyForegroundNotificationBy:(UIApplication*) application;
-(void) scheduleBackgroundNotification:(TPNotification*) item;
-(void) scheduleForegroundNotification:(TPNotification*) item;
-(void) scheduleImmediateNotification:(TPNotification*) item;
-(void) application:(UIApplication*)app handleLocalNotification:(UILocalNotification*) notification;

@end
