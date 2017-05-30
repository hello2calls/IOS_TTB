//
//  CallRingUtil.h
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/15.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CallRingUtil : NSObject
+ (void)playIncomingRingTone;
+ (void)playTestFreeCallWithDelegate:(id<AVAudioPlayerDelegate>)delegate;
+ (void)playBackCallConnectingTone;
+ (void)playDuTone;
+ (void)stop;
+ (void)playBusyHere;
+ (void)audioEnd;
+ (void)audioStart:(BOOL)isSpeaker;
@end
