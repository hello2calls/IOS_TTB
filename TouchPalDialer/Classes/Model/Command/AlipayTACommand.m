//
//  AlipayTACommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "AlipayTACommand.h"
#import "SmartDailerSettingModel.h"
#import "CommandDataHelper.h"
#import "AlipayUtil.h"
#import "Person.h"

@implementation AlipayTACommand
- (BOOL)canExecute
{
    NSArray *validNumbers = [self extractValidNumbers];
    return [validNumbers count] > 0;
}

- (void)onExecute
{
    if (![SmartDailerSettingModel isChinaSim]) {
        return;
    }
    
    NSString *displayName = [CommandDataHelper displayNameFromData:self.targetData];
    NSString *number = [CommandDataHelper phoneNumberFromData:self.targetData];
    int personId = [CommandDataHelper personIdFromData:self.targetData];
    if (personId <= 0) {
        return;
    }
    
    if ([AlipayUtil checkAndInstallAlipayWithName:displayName]) {
        return;
    }
    
    NSArray *labelDataModels = [Person getPhonesByRecordID:personId];
    
    if(number) //for the view controllers displaying number in items
    {
        NSMutableArray *phones = [NSMutableArray arrayWithCapacity:[labelDataModels count]];
        for (LabelDataModel *model in labelDataModels) {
            [phones addObject:model.labelValue];
        }
        NSString *alipayNumber = [AlipayUtil extractAlipayPhoneNumber:number matchesOneOf:phones];
        if (alipayNumber) {
            [AlipayUtil jumpToAlipayWithAlipayPhoneNumber:alipayNumber name:displayName];
        }
    }
    else {
        int validNumberCount = 0;
        NSString * aValidNumber = nil;
        for (int i = 0; i < [labelDataModels count]; i++) {
            LabelDataModel *model = [labelDataModels objectAtIndex:i];
            // AlipayNumber is nil if the raw number cannot be converted to a valid alipayNumber
            NSString* alipayNumber = [AlipayUtil extractAlipayPhoneNumber:[model labelValue]];
            if (alipayNumber) {
                validNumberCount ++;
                aValidNumber = alipayNumber;
            }
            // Set the related number as alipayNumber for later usage
            [model setLabelValue:alipayNumber];
        }
        if (validNumberCount == 1) {
            [AlipayUtil jumpToAlipayWithAlipayPhoneNumber:aValidNumber name:displayName];
        } else if (validNumberCount > 1) {
            // Let user choose the number
            NSMutableArray *numbersOfKeyAndValue = [NSMutableArray array];
            for (int i = 0; i < [labelDataModels count]; i++) {
                LabelDataModel *model = [labelDataModels objectAtIndex:i];
                // if the model has a valid alipayNumber
                if (model.labelValue) {
                    [numbersOfKeyAndValue addObject:model.labelValue];
                    [numbersOfKeyAndValue addObject:model.labelKey];
                }
            }
            [self holdUntilNotified];
            CooTekPopUpSheet *numberChoosePopUp = [[CooTekPopUpSheet alloc] initWithTitle:NSLocalizedString(@"Choose the number", @"") content:numbersOfKeyAndValue type:PopUpSheetTypenumbersPay];
            numberChoosePopUp.delegate = self;
            [self.navController.topViewController.view addSubview:numberChoosePopUp];
        }
    }

}

- (NSArray *)extractValidNumbers
{
    if (![SmartDailerSettingModel isChinaSim]) {
        return nil;
    }
    
    NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
    if (personId <= 0) {
        return nil;
    }
        
    NSString *number = [CommandDataHelper phoneNumberFromData:self.targetData];
    NSMutableArray *result = [NSMutableArray array];
    
    NSArray *labelDataModels = [Person getPhonesByRecordID:personId];
    if(number) //for the view controllers displaying number in items
    {
        NSMutableArray *phones = [NSMutableArray arrayWithCapacity:[labelDataModels count]];
        for (LabelDataModel *model in labelDataModels) {
            [phones addObject:model.labelValue];
        }
        NSString *alipayNumber = [AlipayUtil extractAlipayPhoneNumber:number matchesOneOf:phones];
        if (alipayNumber) {
            [result addObject:alipayNumber];
        }
    }
    else {
        for (int i = 0; i < [labelDataModels count]; i++) {
            LabelDataModel *model = [labelDataModels objectAtIndex:i];
            // AlipayNumber is nil if the raw number cannot be converted to a valid alipayNumber
            NSString* alipayNumber = [AlipayUtil extractAlipayPhoneNumber:[model labelValue]];
            if (alipayNumber) {
                [result addObject:alipayNumber];
            }
        }
    }
    
    return result;

}

- (void)doClickOnCancelButtonWithTag:(int)tag
{
    [self notifyCommandExecuted];
}

- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info{
    NSString *displayName = [CommandDataHelper displayNameFromData:self.targetData];
    NSString *number = [CommandDataHelper phoneNumberFromData:self.targetData];
    
    if ([info count] == 2) {
        [AlipayUtil jumpToAlipayWithAlipayPhoneNumber:number name:displayName];
    }
    
    [self notifyCommandExecuted];
}



@end
