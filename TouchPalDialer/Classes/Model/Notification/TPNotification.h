//
//  TPNotification.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-15.
//
//

#import <Foundation/Foundation.h>

@interface TPNotification : NSObject<NSCoding>

@property (nonatomic, copy) NSString* action;
@property (nonatomic, copy) NSString* body;
@property (nonatomic, readonly) NSTimeInterval delayTime;
@property (nonatomic, readonly) NSInteger priority;
@property (nonatomic, readonly) NSString* uniqueKeyInUserDefaults;

-(void) handleNotificationInApplication:(UIApplication*) application;
-(void) handleNotificationInNavigationController:(UINavigationController*) controller;

@end

@interface TPPutAppToBottomNotification : TPNotification
+(id) notification;
@end

@interface TPFirstCallFriendWithoutVoipNotification : TPNotification
+(id) notification;
@end

@interface TPTaskGetBonusNotification : TPNotification
@property (nonatomic, assign) NSInteger taskId;
+(id) notification:(NSString*)body andTaskId:(NSInteger)taskId;
@end

@interface TPBackgroundSearchIfCallerIdNotification : TPNotification
+(id) notification:(NSString *)body;
@end

@interface TPInternationalRoamingNotification : TPNotification
+(id) notification;
@end