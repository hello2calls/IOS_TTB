//
//  NotificationAlertManger.h
//  TouchPalDialer
//
//  Created by game3108 on 15/3/26.
//
//

#import <Foundation/Foundation.h>

@interface NotificationAlertManger : NSObject
+ (instancetype)instance;
- (void)checkShowAlert;
@end
