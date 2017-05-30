//
//  PJEventSource.m
//  TouchPalDialer
//
//  Created by lingmeixie on 15/11/12.
//
//

#import "PJEventSource.h"
#import "BasicUtil.h"

@interface PJEventSource () {
    CFRunLoopSourceRef _eventSource;
    CFRunLoopRef _runLoop;
    NSTimer *_timerSource;
}

@property(nonatomic,assign)PJThread *mCore;

void addSourceSchedule (void *info, CFRunLoopRef rl, CFStringRef mode);
void performSchedule (void *info);
void removeSourceSchedule (void *info, CFRunLoopRef rl, CFStringRef mode);
void timerValidate(CFRunLoopTimerRef timer,void *info);
@end

@implementation PJEventSource

- (id)initEventSource:(PJThread *)core{
    self = [super init];
    if (self != nil) {
        self.mCore = core;
        CFRunLoopSourceContext context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
            &addSourceSchedule,
            removeSourceSchedule,
            performSchedule};
        _eventSource = CFRunLoopSourceCreate(NULL, 0, &context);
        _timerSource = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                interval:1
                                                  target:self
                                                selector:@selector(doTimerTask)
                                                userInfo:nil
                                                 repeats:YES];

    }
    return self;
}

- (void) weakupPJThread {
    if(_runLoop) {
        CFRunLoopSourceSignal(_eventSource);
        CFRunLoopWakeUp(_runLoop);
    }
}

- (void) addEventSourceToRunloop {
    _runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(_runLoop, _eventSource, kCFRunLoopDefaultMode);
    [[NSRunLoop currentRunLoop] addTimer:_timerSource forMode:NSDefaultRunLoopMode];
    [_timerSource fire];
}

- (void)doTimerTask {
    NSLog(@"PJThread timerSource schedule......");
    [self.mCore timerSchedule];
}


- (void) removeEventRunRoop {
    [_timerSource invalidate];
    CFRunLoopRemoveSource(_runLoop,_eventSource,kCFRunLoopDefaultMode);
    CFRunLoopStop(_runLoop);
}
- (void) dealloc {
    self.mCore = nil;
    _timerSource = nil;
    SAFE_CFRELEASE_NULL(_eventSource);
   
}

void addSourceSchedule (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    NSLog(@"PJThread add eventSource......");
}

void performSchedule (void *info)
{
    NSLog(@"PJThread run perform action......");
}

void removeSourceSchedule (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    NSLog(@"PJThread remove evevtSource......");
}

@end
