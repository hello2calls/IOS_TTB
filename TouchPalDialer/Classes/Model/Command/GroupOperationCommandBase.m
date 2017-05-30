//
//  OperationCommandBase.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "GroupOperationCommandBase.h"

@interface GroupOperationCommandBase() {
    BOOL holdDidExecuteCommandNotify_;
}
@end

@implementation GroupOperationCommandBase

@synthesize targetData;
@synthesize delegate;
@synthesize navController;

- (BOOL)canExecute:(OperationSheetType)sheetType
{
    return targetData != nil;
}

- (void)onExecute:(NSArray *)personList
{
    // do nothing
}

- (void)onClickedWithPageNode:(LeafNodeWithContactIds *)pageNode withPersonArray:(NSMutableArray *)personArray;
{
    //do nothing
}

- (void)execute
{
    holdDidExecuteCommandNotify_ = NO;
 /*   if (!([self canExecute] && [self.delegate willExecuteCommand])) {
        return;
    }*/
    
    [self onExecute:nil];
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

- (NSString *)getCommandName
{
    return @"";
}

@end
