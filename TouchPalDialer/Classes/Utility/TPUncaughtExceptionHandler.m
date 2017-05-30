//
//  TPUncaughtExceptionHandler.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 12-6-6.
//  Copyright (c) 2012年 Cootek. All rights reserved.
//

#import <execinfo.h>
#import "TPUncaughtExceptionHandler.h"
#import "TouchPalVersionInfo.h"
#import "DialerUsageRecord.h"
#import <Usage_iOS/UsageRecorder.h>
#import "FunctionUtility.h"
#import "DefaultUIAlertViewHandler.h"
#import <mach-o/dyld.h>

#import "UserDefaultsManager.h"
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

NSString * const ReportEmailAddress = @"tp.contacts.crash@cootek.cn";
NSString * const ReportEmailSubject = @"TouchPal Contacts crash report";
NSString * const UncaughtSignalExceptionName = @"UncaughtSignalException";
NSString * const SignalKey = @"SignalKey";
NSString * const CallStackKey = @"CallStackKey";
NSString * const SlideKey = @"SlideKey";

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
#ifdef DEBUG
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace1: %@", [exception callStackSymbols]);
    NSLog(@"Stack Trace2: %@", [[exception userInfo] objectForKey:CallStackKey]);
    [TPUncaughtExceptionHandler sendingEmailForException:exception];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *name = exception.name;
//        NSArray* callStack;
//        NSString *callStackString = @"";
//        if(name == UncaughtSignalExceptionName) {
//            callStack = [[exception userInfo] objectForKey:CallStackKey];
//        } else {
//            callStack = [exception callStackSymbols];
//        }
//        if (callStack) {
//            callStackString = [callStack componentsJoinedByString:@"\n"];
//        }
//        [DefaultUIAlertViewHandler showAlertViewWithTitle:name message:callStackString];
//    });
      [TPUncaughtExceptionHandler sendingUsageRecordForException:exception];
#else
    [TPUncaughtExceptionHandler sendingUsageRecordForException:exception];
#endif
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
    
	[info setObject:callStack forKey:CallStackKey];
    [info setObject:@([TPUncaughtExceptionHandler getImageSlide]) forKey:SlideKey];
    [info setObject:@(signal) forKey:SignalKey];
	
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

/**
 *
 *  @return the slide of this binary image
 */
+ (long) getImageSlide {
    long slide = -1;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (_dyld_get_image_header(i)->filetype == MH_EXECUTE) {
            slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
//    cootek_log(@"TPUncaughtExceptionHandler, slide: %s", @(slide).description);
    return slide;
}

+ (void) sendingUsageRecordForException: (NSException*) exception {
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSArray* callStack;
    NSString *callStackString = @"";
    
    NSString *abstract = @"???";
    if (name != nil && [name length] > 0) {
        abstract = [NSString stringWithFormat:@"%@: %@", name, reason];
    } else if (reason != nil) {
        abstract = [@"Caused by: " stringByAppendingString:reason];
    }
    
    // get the slide of this loaded binary image
    if(name == UncaughtSignalExceptionName) {
        callStack = [[exception userInfo] objectForKey:CallStackKey];
    } else {
        callStack = [exception callStackSymbols];
    }
    if (callStack) {
        long slide = [self getImageSlide];
        int signal = -1; // default is 0, no error
        if (exception.userInfo) {
            id signalInfo = [[exception userInfo] objectForKey:SignalKey];
            if (signalInfo) {
                signal = [signalInfo intValue];
            }
        }
        NSString *phone = [UserDefaultsManager stringForKey:VOIP_REGISTER_ACCOUNT_NAME defaultValue:@""];
        NSMutableDictionary *extendedDict = [@{
                                       @"slide": @(slide),
                                       @"app_version":CURRENT_TOUCHPAL_VERSION,
                                       @"signal": @(signal)
                                       } mutableCopy];
        if (phone.length>0) {
            [extendedDict setObject:phone forKey:@"phone"];
        }
        NSError *error;
        NSData *extendedData = [NSJSONSerialization dataWithJSONObject:extendedDict options:kNilOptions error:&error];
        if (!error && extendedData) {
            NSString *extendedString = [[NSString alloc] initWithData:extendedData encoding:NSUTF8StringEncoding];
            // "#" is prepend as a special character which differs with other frame numbers.
            // "\n" is append for displaying in the web page.
            extendedString = [NSString stringWithFormat:@"#%@", extendedString];
            
            NSMutableArray *extendedCallStack = [[NSMutableArray alloc] initWithArray:callStack];
            [extendedCallStack insertObject:extendedString atIndex:0];
            
            callStack = [extendedCallStack copy];
        }
        
        callStackString = [callStack componentsJoinedByString:@" |\n"];
        callStackString = [callStackString stringByAppendingString:@" |"];
    }
    UIDevice *device=[UIDevice currentDevice];
    int time = [[NSDate date] timeIntervalSince1970];
    
    NSDictionary *exceptionDic = @{@"device":[FunctionUtility deviceName],
                                   @"app_version":CURRENT_TOUCHPAL_VERSION,
                                   @"manufacturer":@"Apple",
                                   @"detail":callStackString,
                                   @"os_version":[NSString stringWithFormat:@"iOS %@",device.systemVersion],
                                   @"abstract":abstract,
                                   @"os_name":@"iOS",
                                   @"timestamp":[NSString stringWithFormat:@"%d",time],
                                   @"app_name":@"com.cootek.Contacts",
                                   };
    [self writeToFile:exceptionDic];

}

+ (void) writeToFile: (NSDictionary *)dic{
    NSString *settingPath = [self crashFileAbsolutePath];
    NSString *lastCrashPath = [self lastCrashFileAbsolutePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    if ( [fileManager fileExistsAtPath:lastCrashPath]) {
        BOOL success = [fileManager removeItemAtPath:lastCrashPath error:&error];
        if(success){
            [dic writeToFile:lastCrashPath atomically:YES];
        }
    }else{
            [dic writeToFile:lastCrashPath atomically:YES];
    }
   
    if ( [fileManager fileExistsAtPath:settingPath]) {
        BOOL success = [fileManager removeItemAtPath:settingPath error:&error];
        if(!success){
            NSLog(@"Error remove crash report fail :%@", error);
            return;
        }
    }
    
    BOOL success = [dic writeToFile:settingPath atomically:YES];
    if(success) {
        cootek_log(@"crash report write to file success!");
    }else{
        cootek_log(@"crash report write to file fail!");
    }
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
        callStackString = [callStack componentsJoinedByString:@" |\n"];
    }
    
    UIDevice *device=[UIDevice currentDevice];
    
    NSString *detailFormat = @"<br><br><br>Details:<br>Version=%@ Device= %@  iOS=%@%@<br><br>%@<br>--------------------------<br>%@<br>--------------------------<br>%@";
    NSString *detailContent = [NSString stringWithFormat:detailFormat, 
                                            CURRENT_TOUCHPAL_VERSION, 
                                            device.model, 
                                            device.systemName, 
                                            device.systemVersion, 
                                            name, 
                                            reason, 
                                            callStackString];
    cootek_log(@"%@",detailContent);
	NSString *urlStr = [NSString stringWithFormat:@"mailto://%@?subject=%@&body=%@%@",
                            ReportEmailAddress, 
                            ReportEmailSubject,  
                            NSLocalizedString(@"TouchPal has hit a critical error and is terminated. Please send us the crash report, to help us fix the problem. Thank you!",@"" ),
                            detailContent];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
	[[UIApplication sharedApplication] openURL:url];  
}

+ (NSString *) crashFileAbsolutePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *settingPath = [documentsDirectory stringByAppendingPathComponent:@"ios_crash.plist"];
    return settingPath;
}

+ (NSString *) lastCrashFileAbsolutePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *settingPath = [documentsDirectory stringByAppendingPathComponent:@"ios_last_crash.plist"];
    return settingPath;
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
