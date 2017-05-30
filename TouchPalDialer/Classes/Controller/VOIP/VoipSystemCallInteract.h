//
//  VoipSystemCallInteract.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/2/4.
//
//

#import <Foundation/Foundation.h>

@protocol SystemCallDelegate
- (void)onSysIncomingCall;
- (void)onSysHangupCall;
- (void)onSystemCallConnected;
@end

@interface VoipSystemCallInteract : NSObject
+ (void)setSystemCallDelegate:(id<SystemCallDelegate>)delegate;
@end
