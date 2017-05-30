//
//  EditToCallCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "EditToCallCommand.h"
#import "CommandDataHelper.h"
#import "AlertWithTextInputView.h"
#import "CallLogDataModel.h"
#import "TPCallActionController.h"
#import "TouchPalDialerAppDelegate.h"
#import "CallLogDataModel.h"
#import "DialerUsageRecord.h"

@implementation EditToCallCommand

- (BOOL)canExecute
{
    NSString *phoneNum = [CommandDataHelper defaultPhoneNumberFromData:self.targetData];
    return [phoneNum length] > 0;
}

- (void)onExecute
{
    
    if ([self.targetData isKindOfClass:[CallLogDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CALLLOG_ACTION, @"edit_dial"), nil];
    }
    NSString *phoneNum = [CommandDataHelper phoneNumberFromData:self.targetData];
    __block NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
    __weak EditToCallCommand* cmd = self;
    [self holdUntilNotified];
    [AlertWithTextInputViewHandler showAlertWithTextFieldViewWithTitle:NSLocalizedString(@"Edit to call", @"") message:nil textInTextField:phoneNum oKTitle:NSLocalizedString(@"Call", @"") okButtonActionBlock:^(NSString *textInTextField){
        NSString *phoneNumber = [textInTextField stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        CallLogDataModel *call_log=[[CallLogDataModel alloc] initWithPersonId:personId phoneNumber:phoneNumber loadExtraInfo:NO];
        [cmd notifyCommandExecuted];
        [TPCallActionController logCallFromSource:@"LongPress"];
        [[TPCallActionController controller] makeCall:call_log];
    }
                                               cancelButtonActionBlock:^(){
                                                   [cmd notifyCommandExecuted];
                                               }
     ];
}

@end
