//
//  CootekSystemService.h
//  TouchPalDialer
//
//  Created by Sendor on 11-10-21.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

void playSoundCompletionProc(SystemSoundID ssID, void* clientData);

@interface CootekSystemService : NSObject {

}

+ (void)playVibrate;
+ (void)playKeySound:(SystemSoundID)soundid;
+ (void)playCustomKeySound:(SystemSoundID)soundid;
+ (void)startLoopVibrate;
+ (void)stopLoopVibrate;
+ (void) stopPlayRecentSound;

@end
