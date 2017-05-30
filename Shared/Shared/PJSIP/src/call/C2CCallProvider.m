//
//  CallProvider.m
//  TouchPalDialer
//
//  Created by lingmeixie on 16/7/11.
//
//

#import "C2CCallProvider.h"
#import <PushKit/PushKit.h>
#import "SIPConst.h"
#import "PJCore.h"

@interface C2CCallProvider () <CXProviderDelegate> {
    CXProvider *_provider;
    CXCallController *_callController;
    NSUUID *_currentUUID;
    NSUUID *_lastHangupUUID;
    void (^_hangupBlock)();
}

@end

@implementation C2CCallProvider

- (CXProviderConfiguration *) providerConfiguration {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *localizedName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    CXProviderConfiguration  *providerConfiguration = [[CXProviderConfiguration alloc] initWithLocalizedName:localizedName];
    providerConfiguration.maximumCallsPerCallGroup = 1;
    providerConfiguration.maximumCallGroups = 1;
    providerConfiguration.supportsVideo = NO;
    providerConfiguration.ringtoneSound = @"c2c_ring.m4r";
    providerConfiguration.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypePhoneNumber)];
    return providerConfiguration;
}

- (void)reportOutgoingCall:(NSString *)number {
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:number];
    NSUUID *uuid = [NSUUID UUID];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:uuid handle:handle];
    startCallAction.video = NO;

    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:startCallAction];
    [_callController requestTransaction:transaction completion:^(NSError *error) {
        cootek_log(@"reportOutgoingCall .... %@",error);
    }];
    _currentUUID = uuid;
}

- (void)reportOutgoingCallConnected {
    if (_currentUUID) {
        [_provider reportOutgoingCallWithUUID:_currentUUID connectedAtDate:[NSDate date]];
    }
}

- (void)reportOutgoingCallConnecting {
    if (_currentUUID) {
        [_provider reportOutgoingCallWithUUID:_currentUUID startedConnectingAtDate:[NSDate date]];
    }
}

- (id)init {
    self = [super init];
    if (self != nil) {
        _provider = [[CXProvider alloc] initWithConfiguration:[self providerConfiguration]];
        [_provider setDelegate:self queue:nil];
        _callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];

    }
    return self;
}

- (BOOL)currentUseSystemUICalling {
    return _currentUUID != nil;
}

- (BOOL)isTouchPalVoipCall:(NSString *)uuid {
    if (_lastHangupUUID) {
        return [_lastHangupUUID.UUIDString isEqualToString:uuid];
    }
    return NO;
}

- (BOOL)isCurrent:(NSString *)uuid {
    if (_currentUUID) {
        return [_currentUUID.UUIDString isEqualToString:uuid];
    }
    return NO;
}

- (void)reportHangup:(void(^)())block {
    if (_currentUUID == nil) {
        return;
    }

    _hangupBlock = [block copy];
    _lastHangupUUID = [_currentUUID copy];

    cootek_log(@"reportHangup ......");
    CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:_lastHangupUUID];
    CXTransaction *transcation = [[CXTransaction alloc] init];
    [transcation addAction:action];
    [_callController requestTransaction:transcation completion:^(NSError *err) {
        cootek_log(@"requestTransaction result = %@", err);
    }];
    
    _currentUUID = nil;
    cootek_log(@"reportHangup ......end");
}

- (void)reportIncomingCall:(NSString *)number {
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:number];
    update.hasVideo = NO;
    update.supportsHolding = NO;
    NSUUID *uuid = [NSUUID UUID];
    [_provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError *error) {
        if (error != nil) {
            cootek_log(@"reportIncomingCall .... success");
        }
    }];
    _currentUUID = uuid;
}


/// Called when the provider has been reset. Delegates must respond to this callback by cleaning up all internal call state (disconnecting communication channels, releasing network resources, etc.). This callback can be treated as a request to end all calls without the need to respond to any actions
- (void)providerDidReset:(CXProvider *)provider {
    cootek_log(@"providerDidReset .... ");
}

/// Called when the provider has been fully created and is ready to send actions and receive updates
- (void)providerDidBegin:(CXProvider *)provider {
    cootek_log(@"providerDidBegin .... ");
}

/// Called whenever a new transaction should be executed. Return whether or not the transaction was handled:
///
/// - NO: the transaction was not handled indicating that the perform*CallAction methods should be called sequentially for each action in the transaction
/// - YES: the transaction was handled and the perform*CallAction methods should not be called sequentially
///
/// If the method is not implemented, NO is assumed.
- (BOOL)provider:(CXProvider *)provider executeTransaction:(CXTransaction *)transaction {
    cootek_log(@"executeTransaction .... ");
    return NO;
}

// If provider:executeTransaction:error: returned NO, each perform*CallAction method is called sequentially for each action in the transaction
- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    cootek_log(@"performStartCallAction .... ");
    [self reportOutgoingCallConnecting];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    cootek_log(@"performAnswerCallAction .... ");
    [[PJCore instance] answer];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    cootek_log(@"performEndCallAction .... ");
    if (_currentUUID) {
        [[PJCore instance] hangup:HANGUP_SYSTEM];
    }
    _currentUUID = nil;
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    cootek_log(@"performSetHeldCallAction .... ");
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    [[PJCore instance] setCallMute];
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action {
    cootek_log(@"performSetGroupCallAction .... ");
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    [[PJCore instance] sendDTMF:action.digits];
    [action fulfill];
}

/// Called when an action was not performed in time and has been inherently failed. Depending on the action, this timeout may also force the call to end. An action that has already timed out should not be fulfilled or failed by the provider delegate
- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action {
    cootek_log(@"timedOutPerformingAction .... %@",action);
    if ([[PJCore instance] isCalling] &&
        [action isKindOfClass:[CXStartCallAction class]]) {
        [[PJCore instance] connectDevice];
    }
    [action fulfill];
}

/// Called when the provider's audio session activation state changes.
- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    [[PJCore instance] connectDevice];
    cootek_log(@"didActivateAudioSession");
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    cootek_log(@"didDeactivateAudioSession");
    if (_hangupBlock) {
        _hangupBlock();
        _hangupBlock = nil;
    }
}


@end
