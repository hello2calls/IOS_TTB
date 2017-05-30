//
//  CootekSystemService.m
//  TouchPalDialer
//
//  Created by Sendor on 11-10-21.
//  Copyright 2011 Cootek. All rights reserved.
//

#import "CootekSystemService.h"
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#import "TPDialerResourceManager.h"
#import "UserDefaultsManager.h"
#import "AppSettingsModel.h"
#import "TPSkinInfo.h"
static int a = 0;
void playSoundCompletionProc(SystemSoundID ssID, void* clientData) {
    AudioServicesDisposeSystemSoundID(ssID);
}

static SystemSoundID lastPlayedSoundID = 0;

@implementation CootekSystemService
+ (void)playKeySound:(SystemSoundID)soundid {
//    CFURLRef soundFileURLRef;
//    SystemSoundID soundID;
//    CFBundleRef mainBundle = CFBundleGetMainBundle();
//    soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("Tock"), CFSTR("caf"), NULL);
//    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
//    CFRelease(soundFileURLRef);
//    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, playSoundCompletionProc, NULL);
    AudioServicesPlaySystemSound(soundid);
}

+ (void)playCustomKeySound:(SystemSoundID)soundid{
        CFURLRef soundFileURLRef;
        SystemSoundID soundID;
    NSString *path ;
    NSArray *arr= [TPDialerResourceManager sharedManager].allSkinInfoList;
    for (TPSkinInfo *skinInfo  in arr) {
        if ([skinInfo.skinID isEqualToString:[TPDialerResourceManager sharedManager].skinTheme]) {
            path = skinInfo.skinDir;
        }
    }
    path = [NSString stringWithFormat:@"%@/sounds",path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (soundid==100||soundid==101) {
            return;
        }
        AudioServicesPlaySystemSound(soundid+1200);
        return;
    }
    else{
        if ([TPDialerResourceManager sharedManager].isChangeThemeForSound == YES) {
            [TPDialerResourceManager sharedManager].isChangeThemeForSound = NO;
            a=0;
        }
    switch (soundid) {
        case 100:
            path = [path stringByAppendingPathComponent:@"dial.mp3"];
            break;
        case 101:
            path = [path stringByAppendingPathComponent:@"delete.mp3"];
            break;

        default:
        { NSString *str = [NSString stringWithFormat:@"%d.mp3",a];
          NSError *error = nil;
          NSArray *array = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:path error:&error];
                if (array==nil){
                    break;
                }
                else if (![array containsObject:str]) {
                        a=0;
                    }
            path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.mp3",a]];
            a++;
        }
        break;
    }
    soundFileURLRef =(__bridge_retained CFURLRef)[NSURL URLWithString:path];
    if (soundFileURLRef==nil){
        return;
    }
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
    if (soundFileURLRef!=nil){
        CFRelease(soundFileURLRef);
    }
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, playSoundCompletionProc, NULL);
    AudioServicesPlaySystemSound(soundID);
    lastPlayedSoundID = soundID;
    }
}

+ (void) stopPlayRecentSound {
    if ([AppSettingsModel appSettings].dial_tone
        && (lastPlayedSoundID > 0)) {
        AudioServicesDisposeSystemSoundID(lastPlayedSoundID);
    }
}


+ (void)playVibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)playCaf {
    CFURLRef soundFileURLRef;
    SystemSoundID soundID;
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("Reminder"), CFSTR("caf"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
    CFRelease(soundFileURLRef);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, playSoundCompletionProc, NULL);
    AudioServicesPlaySystemSound(soundID);
}

static int sCount = 0;
#define VIBRATE_COUNT 5
+ (void)startLoopVibrate {
    if (sCount > 0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sCount = VIBRATE_COUNT;
        while (sCount-- > 0) {
            if (sCount != VIBRATE_COUNT -1) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self playVibrate];
                });
            }
            sleep(2);
        }
    });
    
}

+ (void)stopLoopVibrate {
    sCount = 0;
}

@end
