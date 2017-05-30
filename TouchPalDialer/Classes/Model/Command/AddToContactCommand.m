//
//  AddToContactCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "AddToContactCommand.h"
#import "TouchPalDialerAppDelegate.h"
#import "CommandDataHelper.h"
#import "TPABPersonActionController.h"
#import "CallLogDataModel.h"
#import "DialerUsageRecord.h"

@implementation AddToContactCommand

- (BOOL)canExecute
{
    NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
    return personId <= 0;
}

- (void)onExecute
{
    
    if ([self.targetData isKindOfClass:[CallLogDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CALLLOG_ACTION, @"save"), nil];
    }
    
    [self holdUntilNotified];
//    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    UIViewController* aViewController = [TouchPalDialerAppDelegate naviController];
    NSString *phoneNumber = [CommandDataHelper phoneNumberFromData:self.targetData];
    [[TPABPersonActionController controller] chooseAddActionWithNewNumber:phoneNumber
                                                              presentedBy:aViewController
                                                        afterChooseAction:^(){
                                                            [self notifyCommandExecuted];
                                                        }];
}

@end
