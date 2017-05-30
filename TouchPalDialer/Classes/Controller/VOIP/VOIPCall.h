//
//  VOIPCall.h
//  TouchPalDialer
//
//  Created by Liangxiu on 14-10-29.
//
//

#import <Foundation/Foundation.h>

@interface VOIPCall : NSObject
+ (void)makeConferenceCall:(NSArray *)conferenceNumbers;
+ (void)makeCall:(NSString *)number;
+ (void)onIncomingCall:(NSString *)number;
+ (void)checkIncomingCall;
+ (void)needToRegisterAgainWithOkBlock:(void(^)(void))okBlock cancelBlock:(void(^)(void))cancelBlock;
+ (void)alertInternationalRoaming;
@end
