//
//  PJCore.h
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/13.
//
//

#import <Foundation/Foundation.h>
#import "ICallState.h"
#import "PJThread.h"

typedef enum SystemCallStatus {
    SystemCallStatusCalling,
    SystemCallStatusIncoming,
    SystemCallStatusConnect,
    SystemCallStatusDisconnect,
} SystemCallStatus;


typedef enum CoreStatus {
    CoreStatusShutDown,
    CoreStatusRegistering,
    CoreStatusIdle,
    CoreStatusIncoming,
    CoreStatusOutgoning,
    CoreStatusCallTalking,
} CoreStatus;


@interface PJCore : NSObject

+ (PJCore *)instance;

- (void)setCallStatusDelegate:(id<CallStateChangeDelegate>)delegate;

- (void)initCore;

- (void)deinitPJCore;

- (void)keepOnline;

- (void)unregister;

- (BOOL)isInit;

- (BOOL)isCalling;

- (BOOL)isAnswerIncomingCall;

- (int)callDuration;

- (NSString *)callNumber;

- (void)hangup:(NSString *)info;

- (void)answer;

- (void)sendDTMF:(NSString *)chr;

- (void)inviteCall:(NSString *)number
              mode:(NSString *)isCallback
          delegate:(id<CallStateChangeDelegate>)delegate;

- (void)connectDevice;

- (void)networkChanged;

- (void)setCallSpeaker:(BOOL)isSpeaker;

- (void)setCallMute:(BOOL)mute;

- (void)setCallMute;

- (BOOL)isCurrentCall:(NSString *)uuid;

- (BOOL)isTouchPalVoipCall:(NSString *)uuid;

- (void)systemCall:(SystemCallStatus)status;

- (void)onCallStateChanged:(int)state
                    callId:(NSString *)callId
                     event:(pjsip_event *)e;

- (void)onIncomingCall:(int)callid addSdp:(BOOL)isAddSdp;

- (void)onDestroyStream:(int)callid poskid:(NSString *)kids;

- (void)onTransportState:(pjsip_transport_state)state transport:(pjsip_transport *)tp;

- (void)onOptionResonse:(NSString *)info;

- (void)onRegister:(BOOL)active sipCode:(int)code;

- (void)onMediaConnect;

- (void)onLog:(NSString *)msg;

@end
