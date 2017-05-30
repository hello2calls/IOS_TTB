//
//  CopyPhoneNumberCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "CopyPhoneNumberCommand.h"
#import "CommandDataHelper.h"
#import "UserDefaultsManager.h"
#import "DialerUsageRecord.h"
#import "CallLogDataModel.h"

@implementation CopyPhoneNumberCommand

- (BOOL)canExecute
{
    NSString *phoneNumber = [CommandDataHelper phoneNumberFromData:self.targetData];
    return [phoneNumber length] > 0;
}

- (void)onExecute
{
    
    if ([self.targetData isKindOfClass:[CallLogDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CALLLOG_ACTION, @"copy"), nil];
    }
    NSString *phoneNumber = [CommandDataHelper phoneNumberFromData:self.targetData];
    if(phoneNumber!=nil){
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [UserDefaultsManager setBoolValue:YES forKey:PASTEBOARD_COPY_FROM_TOUCHPAL];
        pasteBoard.string = phoneNumber;
        [pasteBoard setPersistent:YES];
    }
}

@end
