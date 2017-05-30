//
//  IncomingNotificationManager.h
//  TouchPalDialer
//
//  Created by hengfengtian on 15/12/2.
//
//

#import <Foundation/Foundation.h>

@interface IncomingNotificationManager : NSObject

- (id)init;

- (void)notifyIncomingCall: (NSString*) number;

- (void)clearAllIncomingNotifications;

- (void)notifyMissedCall:(NSString *)number;

+ (IncomingNotificationManager *)instance;

@end
