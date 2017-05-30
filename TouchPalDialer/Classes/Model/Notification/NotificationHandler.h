//
//  RemoteNotificationHandler.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/7/23.
//
//

typedef enum {
    NOTIFICATION_ACTION_TYPE_URL,
    NOTIFICATION_ACTION_TYPE_CONTROLLER,
    NOTIFICATION_ACTION_TYPE_DIALOG,
    NOTIFICATION_ACTION_TYPE_EXTRA_VIP,
    NOTIFICATION_ACTION_TYPE_UNKNOWN,
}NotificationType;

#import <Foundation/Foundation.h>

@interface NotificationHandler : NSObject

+ (void) handleNotification:(NSDictionary*)userInfo;

@end
