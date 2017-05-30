//
//  CallProvider.h
//  TouchPalDialer
//
//  Created by lingmeixie on 16/7/11.
//
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

#define IOS_10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

@interface C2CCallProvider : NSObject 

- (void)reportIncomingCall:(NSString *)number;

- (void)reportHangup:(void(^)())block;

- (BOOL)currentUseSystemUICalling;

- (void)reportOutgoingCall:(NSString *)number;

- (void)reportOutgoingCallConnected;

- (BOOL)isCurrent:(NSString *)uuid;

- (BOOL)isTouchPalVoipCall:(NSString *)uuid;

@end
