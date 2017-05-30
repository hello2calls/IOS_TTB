//
//  VoipSystemCallInteract.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/2/4.
//
//

#import "VoipSystemCallInteract.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import "PJCore.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"

@implementation VoipSystemCallInteract
static CTCallCenter *sCallCenter;
__weak static id<SystemCallDelegate> sSystemCallDelegate;

+ (void)setSystemCallDelegate:(id<SystemCallDelegate>)delegate {
    sSystemCallDelegate = delegate;
    if (delegate) {
        [self setupGSMInteraction];
    } else {
        [self removeCTCallCenterCb];
    }
}

+ (void)removeCTCallCenterCb
{
    if (sCallCenter != nil) {
        sCallCenter.callEventHandler = NULL;
    }
    sCallCenter = nil;
}

+ (void)setupGSMInteraction
{
    if (sCallCenter == nil) {
        sCallCenter = [[CTCallCenter alloc] init];
        sCallCenter.callEventHandler = ^(CTCall* call) {
            [self performSelectorOnMainThread:@selector(handleGSMCallInteraction:)
                                   withObject:call
                                waitUntilDone:YES];
        };
    }
}

+ (void)handleGSMCallInteraction:(CTCall *)call
{
    if (!sSystemCallDelegate) {
        return;
    }
    if ([[PJCore instance] isCurrentCall:call.callID] ||
        [[PJCore instance] isTouchPalVoipCall:call.callID]) {
        return;
    }
    
    if (call && [call.callState isEqual:CTCallStateIncoming])
    {
        [[PJCore instance] systemCall:SystemCallStatusIncoming];
        [sSystemCallDelegate onSysIncomingCall];
    } else if(!call || [call.callState isEqual:CTCallStateDisconnected]) {
        cootek_log(@"on sys incoming call hangup");
        [[PJCore instance] systemCall:SystemCallStatusDisconnect];
        [sSystemCallDelegate onSysHangupCall];
    } else if (call && [call.callState isEqual:CTCallStateConnected]) {
        [[PJCore instance] systemCall:SystemCallStatusConnect];
        [sSystemCallDelegate onSystemCallConnected];
    } else if (call && [call.callState isEqual:CTCallStateDialing]) {
        [[PJCore instance] systemCall:SystemCallStatusCalling];
    }
}

@end
