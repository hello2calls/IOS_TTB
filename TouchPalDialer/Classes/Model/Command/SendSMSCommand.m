//
//  SendSMSCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "SendSMSCommand.h"
#import "CommandDataHelper.h"
#import "Person.h"
#import "CooTekPopUpSheet.h"
#import "TPMFMessageActionController.h"
#import "TouchPalDialerAppDelegate.h"

#import "DialerUsageRecord.h"
#import "CallLogDataModel.h"
@implementation SendSMSCommand

- (BOOL)canExecute
{
    NSString *phoneNum = [CommandDataHelper defaultPhoneNumberFromData:self.targetData];
    return [phoneNum length] > 0;
}

- (void)onExecute
{
    
    if ([self.targetData isKindOfClass:[ContactCacheDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CONTACT_ACTION, @"sms"), nil];
    }
    
    if ([self.targetData isKindOfClass:[CallLogDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CALLLOG_ACTION, @"sms"), nil];
    }
    NSString *phoneNum = [CommandDataHelper defaultPhoneNumberFromData:self.targetData];
    if ([phoneNum length] > 0) {
        int personId = [CommandDataHelper personIdFromData:self.targetData];
        NSString * phoneNumber = [CommandDataHelper phoneNumberFromData:self.targetData];
        if(phoneNumber!=nil)
        {
            [self sendSmsTo:[NSArray arrayWithObject:phoneNumber]];
        }else if(personId>0){
            NSInteger mainIndex = 0;
            NSArray* phones = [Person getPhonesByRecordID:personId mainIndex:&mainIndex];
            if([phones count]== 1){
                LabelDataModel* phoneData = [phones objectAtIndex:0];
                [self sendSmsTo:[NSArray arrayWithObject:phoneData.labelValue]];
            }else if([phones count]>1){
                NSMutableArray *numberArr =[[NSMutableArray alloc] initWithCapacity:[phones count]];
                for (int j=0; j<phones.count; j++) {
                    LabelDataModel* datatmp = [phones objectAtIndex:j];
                    [numberArr addObject:[datatmp labelValue]];
                    [numberArr addObject:[datatmp labelKey]];
                }
                [self holdUntilNotified];
                CooTekPopUpSheet *numberChoosePopUp = [[CooTekPopUpSheet alloc] initWithTitle:NSLocalizedString(@"Choose the number",@"") content:[NSArray arrayWithArray:numberArr] type:PopUpSheetTypeNumbersSendMessage];
                numberChoosePopUp.delegate = self;
                [self.navController.topViewController.view addSubview:numberChoosePopUp];
            }else{
                [self sendSmsTo:nil];
            }
        }else{
            [self sendSmsTo:nil];
        }
    }
}

- (void)sendSmsTo:(NSArray *)all_checked_member_phones{
//    UIViewController *aViewController = ((TouchPalDialerAppDelegate *)[[UIApplication sharedApplication] delegate]).activeNavigationController;
    UIViewController* aViewController = [TouchPalDialerAppDelegate naviController];
    [TPMFMessageActionController sendMessageToNumbers:all_checked_member_phones withMessage:@"" presentedBy:aViewController];
}

- (void)doClickOnCancelButtonWithTag:(int)tag
{
    [self notifyCommandExecuted];
}

- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info
{
    if([info count]<2) {
        [self sendSmsTo:[NSArray arrayWithObjects:nil]];
    } else {
        [self sendSmsTo:[NSArray arrayWithObjects:[info objectAtIndex:0], nil]];
    }
    [self notifyCommandExecuted];
}
@end
