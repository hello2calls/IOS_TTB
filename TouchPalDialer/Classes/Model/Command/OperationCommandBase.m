//
//  OperationCommandBase.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "OperationCommandBase.h"

@interface OperationCommandBase() {
    BOOL holdDidExecuteCommandNotify_;
}
@end

@implementation OperationCommandBase

@synthesize targetData;
@synthesize delegate;
@synthesize navController;


- (BOOL)canExecute
{
    return targetData != nil;
}

- (void)onExecute
{
    // do nothing
}

- (void)execute
{
    holdDidExecuteCommandNotify_ = NO;
    [self.delegate didExecuteCommand];
    if (!([self canExecute] && [self.delegate willExecuteCommand])) {
        return;
    }
    
    [self onExecute];
    if (!holdDidExecuteCommandNotify_) {
        [self.delegate didExecuteCommand];
    }
}

- (void)holdUntilNotified
{
    holdDidExecuteCommandNotify_ = YES;
}

- (void)notifyCommandExecuted
{
    [self.delegate didExecuteCommand];
    holdDidExecuteCommandNotify_ = NO;
}

@end
