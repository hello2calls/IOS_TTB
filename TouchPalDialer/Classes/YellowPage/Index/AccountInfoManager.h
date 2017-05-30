//
//  AccountInfoManager.h
//  TouchPalDialer
//
//  Created by tanglin on 16/7/15.
//
//

#import <Foundation/Foundation.h>

@interface AccountInfoManager : NSObject

@property(assign, getter=shouldRequestAccountInfo, setter=setRequestAccountInfo:)BOOL shoudRequest;
@property(strong, getter=accountInfos, setter=setAccountInfos:)NSDictionary* accountInfos;

+ (AccountInfoManager *)instance;
- (void) updateAccountInfos;

@end
