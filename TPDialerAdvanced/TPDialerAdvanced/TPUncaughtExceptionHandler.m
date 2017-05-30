//
//  TPUncaughtExceptionHandler.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-6-6.
//  Copyright (c) 2012年 Cootek. All rights reserved.
//

#import <execinfo.h>
#import "TPUncaughtExceptionHandler.h"

//Define the private methods
@interface TPUncaughtExceptionHandler() {
}

+ (NSArray *)backtrace;
+ (void) sendingEmailForException: (NSException*) exception;
+ (void) handleExceptionAndExit: (NSException*) exception;
void UncaughtExceptionHandler(NSException *exception);
void SignalHandler__(int signal);
@end

@implementation TPUncaughtExceptionHandler

// The crash signals we want to catch and report error.
// According to http://cocoawithlove.com/2010/05/handling-unhandled-exceptions-and.html,
// these signals already cover most error status, and we can add more when we found necessary.
// but NEVER add SIGKILL and SIGSTOP.
static int monitorSignals[] = {SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE};
static int signalCounts = sizeof(monitorSignals)/sizeof(int);

NSString * const UncaughtSignalExceptionName = @"UncaughtSignalException";
NSString * const SignalKey = @"SignalKey";
NSString * const CallStackKey = @"CallStackKey";

+ (void) attachHandler {
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler); 
    for(int i = 0; i< signalCounts; i++) {
        signal(monitorSignals[i], SignalHandler__);
    }
}

+ (void) detachHandler {
    NSSetUncaughtExceptionHandler(NULL);
    for(int i = 0; i< signalCounts; i++) {
        signal(monitorSignals[i], SIG_DFL);
    }
}

// 1. Sending email with exception information
// 2. Detach the handler, so the duplicated signal/exception will not cause email to be sent twice.
// 3. Raise the exception. As the handler is detached in Step#2, it will cause the app crash as we expected.
+ (void) handleExceptionAndExit: (NSException*) exception {
    [TPUncaughtExceptionHandler sendingEmailForException:exception];
    [TPUncaughtExceptionHandler detachHandler];
    [exception raise];
}

void UncaughtExceptionHandler(NSException *exception) {
    [TPUncaughtExceptionHandler handleExceptionAndExit:exception];
}

// The signal handler for bad signls defined in monitorSignals array
// Gather callstack, convert to exception and then use the same exception handling approach.
void SignalHandler__(int signal) {
    NSMutableDictionary *info =
        [NSMutableDictionary
            dictionaryWithObject:[NSNumber numberWithInt:signal]
            forKey:SignalKey];
    
	NSArray *callStack = [TPUncaughtExceptionHandler backtrace];
    
	[info
        setObject:callStack
        forKey:CallStackKey];
	
	 [TPUncaughtExceptionHandler handleExceptionAndExit:
            [NSException
                    exceptionWithName:UncaughtSignalExceptionName
                    reason:[NSString stringWithFormat:@"Signal %d was raised.", signal]
                    userInfo:info]];
}

// Get call stack.
+ (NSArray *)backtrace
{
    const int maxCount = 128;
    void* callstack[maxCount];
    int count = backtrace(callstack, maxCount);
    char **strs = backtrace_symbols(callstack, count);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++)
    {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

+ (void) sendingEmailForException: (NSException*) exception {
    NSString *reason = [exception reason];
	NSString *name = [exception name];
    NSArray* callStack;
    NSString *callStackString = @"";
    if(name == UncaughtSignalExceptionName) {
        callStack = [[exception userInfo] objectForKey:CallStackKey];
    } else {
        callStack = [exception callStackSymbols];
    }
    
    if (callStack) {
        callStackString = [callStack componentsJoinedByString:@"<br>"];
    }
    
    NSLog(@"%@, %@", reason, callStackString);
   
} 

#pragma mark ForceCrashForTesting
//+  (void)crashWithSignal {
//    void (*nullFunction)() = NULL;
//    nullFunction();
//}
//
//+ (void) crashWithException {
//    @throw [[[NSException alloc] initWithName:@"test" reason:@"test" userInfo:nil] autorelease];
//}
#pragma mark -
@end
