//
//  MakeCallCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "MakeCallCommand.h"
#import "CommandDataHelper.h"
#import "Person.h"
#import "NumberPersonMappingModel.h"
#import "CallLogDataModel.h"
#import "TPCallActionController.h"
#import "DialerUsageRecord.h"

@implementation MakeCallCommand
- (BOOL)canExecute
{
    NSString *phoneNum = [CommandDataHelper defaultPhoneNumberFromData:self.targetData];
    return [phoneNum length] > 0;
}

- (void)onExecute
{
    
    if ([self.targetData isKindOfClass:[ContactCacheDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CONTACT_ACTION, @"dial"), nil];
    }
    
    NSString *phoneNum = [CommandDataHelper defaultPhoneNumberFromData:self.targetData];
    if ([phoneNum length] > 0) {
        NSInteger mainIndex = 0;
        NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
        NSArray* phones = [Person getPhonesByRecordID:personId mainIndex:&mainIndex];
        if([phones count]== 1){
            LabelDataModel* phoneData = [phones objectAtIndex:0];
            [self makeCall:phoneData.labelValue];
        }else if([phones count]>1){
            NSMutableArray *numberArr =[[NSMutableArray alloc] initWithCapacity:[phones count]];
            for (int j=0; j<phones.count; j++) {
                LabelDataModel* data = [phones objectAtIndex:j];
                [numberArr addObject:[data labelValue]];
                [numberArr addObject:[data labelKey]];
            }
            [self holdUntilNotified];
            CooTekPopUpSheet *numberChoosePopUp = [[CooTekPopUpSheet alloc] initWithTitle:NSLocalizedString(@"Choose the number",@"") content:[NSArray arrayWithArray:numberArr] type:PopUpSheetTypeNumbersCall];
            numberChoosePopUp.delegate = self;
            [self.navController.topViewController.view addSubview:numberChoosePopUp];
        }else{
            [self makeCall:nil];
        }
    }
}

- (void)doClickOnCancelButtonWithTag:(int)tag
{
    [self notifyCommandExecuted];
}

- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info{
    
    if([info count]<2) {
        [self makeCall:nil];
    } else {
        [self makeCall:[info objectAtIndex:0]];
    }
    [self notifyCommandExecuted];
}

- (void)makeCall:(NSString *)phoneNumber{
    if(phoneNumber==nil || phoneNumber.length ==0){
        return;
    }
    
    CallLogDataModel *call_log=[[CallLogDataModel alloc] initWithPersonId:[CommandDataHelper personIdFromData:self.targetData]
                                                              phoneNumber:phoneNumber
                                                            loadExtraInfo:YES];
    [TPCallActionController logCallFromSource:@"LongPress"];
    [[TPCallActionController controller] makeCall:call_log];
}

@end
