//
//  PJCoreUtil.h
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/13.
//
//

#import <Foundation/Foundation.h>
#include <pjsua-lib/pjsua.h>
#import "EdgeSelector.h"

@interface PJCoreUtil : NSObject

+ (BOOL)isNormalCalling;

+ (NSString *)userSipAgent:(const char *)sipVersion;

+ (char *)getSipUri:(NSString *)number;

+ (char *)getConferenceUri:(NSString *)account;

+ (NSString *)getGroup:(NSString *)number;

+ (char *)turnServer:(NSString *)host;

+ (char *)getSipProxy:(IPAddress *)host;

+ (NSString *)stringWith:(const char *)pstr andLen:(int)len;

+ (NSDictionary *)parceSipMessage:(pjsip_event *)e
                         imcoming:(BOOL)incoming;

+ (BOOL)isAstriskIncoming:(NSString *)msg;

+ (NSString *)getSpecificLine:(NSString *)specific inMessage:(NSString *)message;

+ (int)parseErrorReason:(NSString *)reason code:(NSString *)code startTime:(long)startTime;

@end
