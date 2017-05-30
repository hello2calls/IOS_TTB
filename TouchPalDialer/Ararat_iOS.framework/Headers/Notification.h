//
//  Notification.h
//  Ararat_iOS
//
//  Created by SongchaoYuan on 15/12/3.
//  Copyright © 2015年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (nonatomic, strong) NSString *serviceId;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, assign) NSInteger notiVersion;
@property (nonatomic, strong) NSDictionary *notiDict;

- (id)initWithNotification:(NSDictionary *)userInfo;

@end
