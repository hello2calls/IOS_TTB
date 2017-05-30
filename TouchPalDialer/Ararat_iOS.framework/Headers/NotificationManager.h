//
//  NotificationManager.h
//  Ararat_iOS
//
//  Created by SongchaoYuan on 15/12/3.
//  Copyright © 2015年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Notification;

@interface NotificationManager : NSObject

- (void)processNotification:(Notification *)notification;
- (void)uploadTokenInfoWithType:(NSString *)type;
- (void)setDeviceToken:(NSString *)deviceToken;
- (NSString *)getDeviceToken;
- (void)setUserToken:(NSString *)userToken;
- (NSString *)getUserToken;
- (void)setUploadStatus:(BOOL)success;
- (BOOL)getUploadStatus;

@end
