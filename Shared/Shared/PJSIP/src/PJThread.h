//
//  PJSIPCore.h
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/12.
//
//

#import <Foundation/Foundation.h>
#import "ICallState.h"
#include <pjsua-lib/pjsua.h>
#import "EdgeSelector.h"

@interface PJThread : NSThread

- (id)initWithDelegate:(id<CallStateChangeDelegate>)delegate;

- (BOOL)initPJsip:(IPAddress *)edgeAddress keepOnline:(BOOL)isOnline;

- (pj_status_t)configAccount:(IPAddress *)updateAddress keepOnline:(BOOL)isOnline;

- (BOOL)inviteCall:(NSString *)number mode:(NSString *)mode location:(NSString *)location;

- (BOOL)inviteCall:(NSString *)number mode:(NSString *)mode rtp:(NSString *)ip location:(NSString *)location;

- (void)destoryCore;

- (void)stopPJThread;

- (void)onIncoming:(int)call_id pre:(NSString *)callIdString addSdp:(BOOL)isAddSdp;

- (void)onMediaConnect;

- (void)usePlayAndRecordDevice;

- (void)hangup;

- (void)answer;

- (void)sendDTMF:(NSString *)chr;

- (int)callDuration;

- (int)callId;

- (BOOL)currentCall:(NSString *)callString;

- (long)recPackage;

- (void)checkResponse:(NSString *)mode callId:(NSString *)callId;

- (void)usePlayAndRecordDevice;

- (void)disableDevice;

- (void)delAccount;

- (void)disconnectTcp:(pjsip_transport *)tp;

- (void)doKeepAlive;

- (BOOL)setRegister:(BOOL)enable;

- (void)weakup;

- (BOOL)doOption:(NSString *)ip;

- (void)setStreamWifiNetwork:(BOOL)iswifi;

- (void)setPostKidsAddress:(NSString *)address interval:(int)interval rate:(float)rate;

@end
