//
//  PJSIPManager.h
//  TPVoIP
//
//  Created by cootek on 4/9/14.
//  Copyright (c) 2014 lingmei xie. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <pjsua-lib/pjsua.h>
#import "ICallState.h"


@interface PJSIPManager : NSObject

+ (BOOL)checkInit;

+ (BOOL)confercenceCall:(NSArray *)numbers
           withDelegate:(id<CallStateChangeDelegate>)delegate;

+ (BOOL)call:(NSString *)number
    callback:(BOOL)callback
withDelegate:(id<CallStateChangeDelegate>)delegate;

+ (void)hangup:(NSString *)info;

+ (void)setSpeakerEnabled:(BOOL)enable;

+ (void)mute:(BOOL)isMute;

+ (NSString *)callingNumber;

+ (void)destroy;

+ (BOOL)acceptIncomingCall;

+ (void)setCallStateDelegate:(id<CallStateChangeDelegate>)delegate;

+ (BOOL)isInit;

+ (void)sendDTMF:(NSString *)chr;

+ (int)callDuration;

+ (BOOL)isAnswerIncomingCall;

@end
