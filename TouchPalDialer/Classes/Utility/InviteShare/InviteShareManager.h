//
//  InviteShareManager.h
//  TouchPalDialer
//
//  Created by game3108 on 16/3/7.
//
//

#import <Foundation/Foundation.h>

@interface InviteShareManager : NSObject
+ (instancetype)instance;
- (void)requestInviteShare:(NSDictionary *)dict withInviteFailBlock:(void(^)())block;

@end
