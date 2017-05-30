//
//  NotificationScheduler.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-11-15.
//
//

#import "NotificationScheduler.h"
#import "NSKeyedUnarchiver+TPSafe.h"
 
#define NOTIFICATION_DATA_KEY @"NOTIFICATION_DATA_KEY"

@interface NotificationScheduler() {
    NSMutableArray* backgroundNotifications_;
    NSMutableArray* forgroundNotifications_;
}

+(void) removeDuplicateItems:(NSMutableArray*) items withKey:(NSString*)key;

@end

@implementation NotificationScheduler

@synthesize pendingNotification;

-(id) init {
    self = [super init];
    if(self) {
        backgroundNotifications_ = [[NSMutableArray alloc] init];
        forgroundNotifications_ = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) notifyBackgroundNotificationBy:(UIApplication*) application {
    
    for(TPNotification* noti in backgroundNotifications_) {
        UILocalNotification* n = [[UILocalNotification alloc] init];
        n.alertBody = noti.body;
        n.alertAction = noti.action;
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:noti];
        n.userInfo = [NSDictionary dictionaryWithObject:data forKey:NOTIFICATION_DATA_KEY];
        // add a randomized number, up to 10 minutes, to avoid notificaitons popup in the same time.
        //NSTimeInterval delay = noti.delayTime + (arc4random() % 600);
        n.fireDate = [NSDate dateWithTimeIntervalSinceNow:(1)];
        [application scheduleLocalNotification:n];
        cootek_log(@"schedule %@ for %@", n.alertBody, n.fireDate);
    }
    
    [backgroundNotifications_ removeAllObjects];
}

-(void) notifyForegroundNotificationBy:(UIApplication*) application {
    if(pendingNotification != nil) {
        [self application:[UIApplication sharedApplication] handleLocalNotification:pendingNotification];
        self.pendingNotification = nil;
        return;
    }
    
    TPNotification* noti = nil;
    for(TPNotification* n in forgroundNotifications_) {
        if(noti == nil) {
            noti = n;
            continue;
        }
        
        if(noti.priority > n.priority) {
            noti = n;
            continue;
        }
    }
    
    if(noti != nil) {
        [noti handleNotificationInApplication:application];
        [forgroundNotifications_ removeObject:noti];
    }
}

-(void) scheduleBackgroundNotification:(TPNotification*) item {
    [NotificationScheduler removeDuplicateItems:backgroundNotifications_ withKey:item.uniqueKeyInUserDefaults];
    [backgroundNotifications_ addObject:item];
}

-(void) scheduleForegroundNotification:(TPNotification *)item {
    [NotificationScheduler removeDuplicateItems:forgroundNotifications_ withKey:item.uniqueKeyInUserDefaults];
    [forgroundNotifications_ addObject:item];
}

+(void) removeDuplicateItems:(NSMutableArray*) items withKey:(NSString*)key {
    if(key == nil  || key.length == 0) {
        return;
    }
    
    int i=0;
    while(i<items.count) {
        TPNotification* t = [items objectAtIndex:i];
        if(t.uniqueKeyInUserDefaults != nil && [t.uniqueKeyInUserDefaults isEqualToString:key]) {
            [items removeObjectAtIndex:i];
        } else {
            i++;
        }
    }
}

-(void) scheduleImmediateNotification:(TPNotification*) item {
    [item handleNotificationInApplication:[UIApplication sharedApplication]];
}

-(void) application:(UIApplication*)app handleLocalNotification:(UILocalNotification*) notification {
    NSData* data = [[notification userInfo] objectForKey:NOTIFICATION_DATA_KEY];
    if (data == nil) {
        return;
    }
    TPNotification* noti = [NSKeyedUnarchiver safelyUnarchiveObjectWithData:data];
    [noti handleNotificationInApplication:app];
    [app cancelLocalNotification:notification];
}

@end
