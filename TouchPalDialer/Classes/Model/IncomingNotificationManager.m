//
//  IncomingNotificationManager.m
//  TouchPalDialer
//
//  Created by hengfengtian on 15/12/2.
//
//

#import "IncomingNotificationManager.h"
#import "UserDefaultsManager.h"
#import "NumberPersonMappingModel.h"
#import "ContactCacheDataManager.h"

#define NOTIFICATION_KEY @"notificationKey"

@interface IncomingNotificationManager () {
    NSMutableDictionary<NSString*, UILocalNotification*>* incomingNotifications;
    NSMutableDictionary<NSString*, NSNumber*>* incomingNumbers;
}
@end

static IncomingNotificationManager* _instance;

@implementation IncomingNotificationManager

+ (IncomingNotificationManager *)instance {
    if(_instance == nil) {
        @synchronized([IncomingNotificationManager class]) {
            if(_instance == nil) {
                _instance = [[IncomingNotificationManager alloc] init];
            }
        }
    }
    return _instance;
}

- (NSString *)displayName:(NSString *)number {
    NSString *display = number;
    int personID = [NumberPersonMappingModel getCachePersonIDByNumber:number];
    if (personID > 0) {
       return [[[ContactCacheDataManager instance] contactCacheItem:personID] displayName];
    }
    return display;
}

- (void)notifyMissedCall:(NSString *)number {
    if([number length] == 0) {
        return;
    }
    UILocalNotification *notification = [incomingNotifications objectForKey:number];
    if (notification == nil) {
        notification  = [[UILocalNotification alloc] init];
    } else {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
    int count =  [[incomingNumbers objectForKey:number] integerValue];
    count++;
    [incomingNumbers setObject:@(count) forKey:number];
    [incomingNotifications setObject:notification forKey:number];
    notification.fireDate = [NSDate date];
    int hisCount = [UserDefaultsManager intValueForKey:VOIP_INCOMING_ALERT_BADGE_NUMBER];
    notification.applicationIconBadgeNumber = hisCount + 1;

    NSString *display = [self displayName:number];
    if (count == 1) {
        notification.alertBody = [NSString stringWithFormat:
                                  NSLocalizedString(@"incoming_single_call_notification", @""), display];
    } else {
        notification.alertBody=[NSString stringWithFormat:
                                NSLocalizedString(@"incoming_multi_calls_notification", @""), display, count];
    }
    [UserDefaultsManager setIntValue:hisCount+1 forKey:VOIP_INCOMING_ALERT_BADGE_NUMBER];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)notifyIncomingCall:(NSString *)number {
    UILocalNotification * notification = [incomingNotifications objectForKey:number];
    int count = 0;
    BOOL flag = NO;
    NSMutableArray *arr = [[UserDefaultsManager arrayForKey:NOTIFICATION_KEY] mutableCopy];
    if(notification){
        flag = YES;
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        for (UILocalNotification * notification_arr in arr) {
            if ([notification.fireDate isEqual:notification_arr.fireDate]){
                [arr removeObject:notification_arr];
                [UserDefaultsManager setObject:arr forKey:NOTIFICATION_KEY];
            }
        }
        count = [[incomingNumbers objectForKey:number] intValue];
    }else{
        notification = [[UILocalNotification alloc] init];
    }
    count++;
    [incomingNumbers setObject:@(count) forKey:number];
    [incomingNotifications setObject:notification forKey:number];
    notification.fireDate=[NSDate date]; //触发通知的时间
    notification.soundName = @"c2c_ring.m4r";
    int hisCount = [UserDefaultsManager intValueForKey:VOIP_INCOMING_ALERT_BADGE_NUMBER];
    notification.applicationIconBadgeNumber = hisCount + 1;
    NSString *display = [self displayName:number];
    if (count == 1) {
        notification.alertBody = [NSString stringWithFormat:
                                  NSLocalizedString(@"incoming_single_call_notification", @""), display];
    } else {
        notification.alertBody = [NSString stringWithFormat:
                                NSLocalizedString(@"incoming_multi_calls_notification", @""), display, count];
    }
    [UserDefaultsManager setIntValue:hisCount+1 forKey:VOIP_INCOMING_ALERT_BADGE_NUMBER];
    if (flag) {
        for (UILocalNotification * notification_arr in arr) {
             [[UIApplication sharedApplication] scheduleLocalNotification:notification_arr];
        }
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    [IncomingNotificationManager addNotificationToUserDefault:notification];
}

+ (void)addNotificationToUserDefault:(UILocalNotification *)notification {
    if ([UserDefaultsManager arrayForKey:NOTIFICATION_KEY] != nil){
        NSMutableArray *arr = [[UserDefaultsManager arrayForKey:NOTIFICATION_KEY] mutableCopy];
        [arr addObject:notification];
        [UserDefaultsManager setObject:arr forKey:NOTIFICATION_KEY];
    }else{
        [UserDefaultsManager setObject:@[notification] forKey:NOTIFICATION_KEY];
    }
}

-(void) clearAllIncomingNotifications {
    [incomingNotifications removeAllObjects];
    [incomingNumbers removeAllObjects];
 }

- (id)init {
    if(self = [super init]) {
        incomingNotifications = [NSMutableDictionary dictionary];
        incomingNumbers = [NSMutableDictionary dictionary];
    }
    return self;
}
@end
