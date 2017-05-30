//
//  CallRingUtil.m
//  TouchPalDialer
//
//  Created by Liangxiu on 15/6/15.
//
//

#import "CallRingUtil.h"
#include <AudioToolbox/AudioToolbox.h>
#import "CootekSystemService.h"
#import "PJCore.h"

@interface CallRingUtil ()

@end

@implementation CallRingUtil

static AVAudioPlayer *sPlayer;
static CGFloat sOriginalVolume = 0;

+ (void)playIncomingRingTone {
    [self playerWithFile:@"c2c_ring.m4r" loops:-1 speaker:YES];
    sOriginalVolume = sPlayer.volume;
    [sPlayer setVolume:0.8f];
}
+ (void)playTestFreeCallWithDelegate:(id<AVAudioPlayerDelegate>)delegate{
    
    [self playerWithFile:@"testFreeCall.mp3" loops:0 speaker:YES];
    sOriginalVolume = sPlayer.volume;
    if (delegate!=nil) {
        sPlayer.delegate = delegate;
    }
    [sPlayer setVolume:0.5f];
}

+ (void)stop {
    cootek_log(@"play stop ring....");
    if (sPlayer) {
        if (sOriginalVolume > 0) {
            [sPlayer setVolume:sOriginalVolume];
            sOriginalVolume = 0;
        }
        [sPlayer stop];
        sPlayer = nil;
    }
  
}

+ (void)playBackCallConnectingTone {
    cootek_log(@"play callback ring now....");
    [self playerWithFile:@"04_backing_call.mp3" loops:0 speaker:NO];
    sOriginalVolume = sPlayer.volume;
    [sPlayer setVolume:0.8f];

}

+ (void)playBusyHere {
    [self playerWithFile:@"voip_c2c_busy.mp3" loops:0 speaker:NO];
}

+ (void)playDuTone {
    [self playerWithFile:@"05_du.mp3" loops:2 speaker:YES];
}

+ (void)playerWithFile:(NSString *)file loops:(int)loops speaker:(BOOL)speaker{
    sPlayer.delegate = nil;
    [self stop];
    [self audioStart:speaker];
    NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:file];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
    NSError *error = nil;
    sPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error: &error];
    if (loops != 0) {
        sPlayer.numberOfLoops = loops;
    }
    [sPlayer play];
    cootek_log(@"playerWithFile ring....");
}

+ (void)audioStart:(BOOL)isSpeaker {
    @synchronized(self) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
          cootek_log(@"playerWithFile setActive....%@",error);
        if (isSpeaker) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                             withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker
                                                   error:&error];
        } else {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                             withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                                   error:&error];
        }
        cootek_log(@"playerWithFile setCategory....%@",error);
    }
}

+ (void)audioEnd {
    if ([[PJCore instance] isCalling]) {
        return;
    }
    @synchronized(self) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                         withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                               error:NULL];
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:NO
                                       withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:&error];
        cootek_log(@"playerWithFile audioEnd....%@",error);
    }
}


@end
