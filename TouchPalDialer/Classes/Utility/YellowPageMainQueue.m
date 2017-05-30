//
//  YellowPageMainQueue.m
//  TouchPalDialer
//
//  Created by tanglin on 15/9/2.
//
//

#import "YellowPageMainQueue.h"
#import "TouchPalDialerAppDelegate.h"
#import "UserDefaultsManager.h"

@interface YellowPageMainQueue()
{
    dispatch_queue_t queue;
    NSMutableArray* tasks;
}

@end

YellowPageMainQueue *queue_instance_ = nil;
@implementation YellowPageMainQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        queue = dispatch_queue_create("com.dispatch.serial", DISPATCH_QUEUE_SERIAL);
        tasks = [NSMutableArray new];
        
    }
    return self;
}

+ (id)instance
{
    return queue_instance_;
}

+ (void)initialize
{
    if (self == [YellowPageMainQueue class]) {
        queue_instance_ = [YellowPageMainQueue new];
    }
}

- (void) addTask:(YPNavigationTask* )task
{
    if ([self isIOS7]) {
        cootek_log(@" add tasks.count = %d", tasks.count);
        if (tasks.count > 0) {
            [tasks addObject:task];
            return;
        } else {
            [tasks addObject:task];
            [self execute];
        }
    } else {
        cootek_log(@"---- not ios7 ---");
        UINavigationController *appRootController = nil;
        if ([UserDefaultsManager boolValueForKey:ENABLE_V6_TEST_ME defaultValue:NO]) {
            appRootController = [TouchPalDialerAppDelegate naviController];
        } else {
            appRootController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
        }
        if (task.type == TYPE_PUSH) {
            [appRootController pushViewController:task.viewController animated:YES];
        }else{
            [appRootController popViewControllerAnimated:YES];
        }
    }

}

- (void) execute
{
    YPNavigationTask* task = [tasks firstObject];
    UINavigationController *appRootController = [((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]) activeNavigationController];
    if (task.type == TYPE_PUSH) {
        [appRootController pushViewController:task.viewController animated:YES];
    }else{
        [appRootController popViewControllerAnimated:YES];
    }
}

- (void) removeFirstTask
{
    if ([self isIOS7]) {
        cootek_log(@"remove tasks.count = %d", tasks.count);
        if (tasks.count > 0) {
            [tasks removeObjectAtIndex:0];
            if (tasks.count > 0) {
                [self execute];
            }
            return;
        }
    }
}

- (BOOL) isIOS7
{
    return [[UIDevice currentDevice]systemVersion].floatValue >= 7.0 &&
    [[UIDevice currentDevice]systemVersion].floatValue < 8.0;
}
@end
