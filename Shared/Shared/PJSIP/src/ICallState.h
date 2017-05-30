//
//  ICallState.h
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/13.
//
//

#ifndef ICallState_h
#define ICallState_h


#endif /* ICallState_h */

typedef enum CallState {
    CallState_InviteSend,
    CallState_EARLY,
    CallState_Ringing,
    CallState_Connected,
    CallState_DisConnected,
    CallState_Error,
} CallState;


@protocol CallStateChangeDelegate

@optional
- (void)onSwitchingToC2P;
- (void)onRinging;
- (void)onConnected;
- (void)onCallStateInfo:(NSDictionary *)info;
- (void)onDisconected;
- (void)onCallErrorWithCode:(int)errorCode;
- (void)onCallModeSet:(NSString *)callMode;
- (void)notifyEdgeNotStable;
- (void)onIncoming:(NSString *)number;
@end
