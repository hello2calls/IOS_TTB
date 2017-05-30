//
//  TPUncaughtExceptionHandler.h
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-6-6.
//  Copyright (c) 2012年 Cootek. All rights reserved.
//

#import <Foundation/Foundation.h>
//
//typedef enum{
//    ErrorHandlerTypeNone,
//    ErrorHandlerTypeSendingEmail,
//    // Add more handling approaches here
//} ErrorHandlerType;

@interface TPUncaughtExceptionHandler : NSObject {
    
}
+ (void) attachHandler;
+ (void) detachHandler;
+ (NSString *) crashFileAbsolutePath;
+ (NSString *) lastCrashFileAbsolutePath;
// Force crash. This function is for testing purpose.
//+ (void) crashWithException; 
//+ (void) crashWithSignal;
@end
