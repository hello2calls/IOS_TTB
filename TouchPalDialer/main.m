//
//  main.m
//  TouchPalDialer
//
//  Created by zhang Owen on 7/15/11.
//  Copyright 2011 Cootek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchPalDialerAppDelegate.h"

CFAbsoluteTime mainStartTime = 0;

int main(int argc, char *argv[]) {
    mainStartTime = CFAbsoluteTimeGetCurrent(); // statistics for app performance
    
    int retVal;
    @autoreleasepool {
        [[NSThread currentThread] setThreadPriority:0.7];
        retVal = UIApplicationMain(argc, argv, NSStringFromClass([TouchPalApplication class]), NSStringFromClass([TouchPalDialerAppDelegate class]));
    }
    return retVal;
}
