//
//  RemoveCallsCommand.m
//  TouchPalDialer
//
//  Created by Elfe Xu on 13-1-11.
//
//

#import "RemoveCallsCommand.h"
#import "CommandDataHelper.h"
#import "FunctionUtility.h"
#import "CooTekPopUpSheet.h"
#import "DataBaseModel.h"
#import "CallLog.h"
#import "NSString+PhoneNumber.h"
#import "PhonePadModel.h"
#import "PhoneNumber.h"
#import "CallLogDataModel.h"
#import "DialerUsageRecord.h"

@implementation RemoveCallsCommand

- (BOOL)canExecute {
    NSArray *times = [self getTheFirstANDLastCallTime];
    return [times count] > 0;
}

- (void)onExecute
{
    if ([self.targetData isKindOfClass:[CallLogDataModel class]]) {
        [DialerUsageRecord recordpath:PATH_LONG_PRESS kvs:Pair(KEY_CALLLOG_ACTION, @"delete"), nil];
    }
    
    
    NSArray *times = [self getTheFirstANDLastCallTime];
    
    if(times!=nil){
        int firstCallTime = [[times objectAtIndex:1] integerValue];
        int lastCallTime = [[times objectAtIndex:0] integerValue];
        int callCount = [[times objectAtIndex:2] integerValue];
        NSString * firstCallTimeString = [FunctionUtility getSystemFormatDateString:firstCallTime];
        NSString * lastCallTimeString = [FunctionUtility getSystemFormatDateString:lastCallTime];
        NSMutableArray *contentArray = [[NSMutableArray alloc] initWithCapacity:4];
        [contentArray addObject:NSLocalizedString(@"Remove last call", @"")];
        [contentArray addObject:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"on", @""),lastCallTimeString]];
        
        [contentArray addObject:NSLocalizedString(@"Clear all calls", @"")];
        [contentArray addObject:[NSString stringWithFormat:@"%d %@ %@ %@",callCount,NSLocalizedString(@"calls", @""),NSLocalizedString(@"since", @""),firstCallTimeString]];
        
        [self holdUntilNotified];
        CooTekPopUpSheet *popUpSheet = [[CooTekPopUpSheet alloc] initWithTitle:NSLocalizedString(@"Clear call logs", @"") content:contentArray type:PopUpSheetTypeDeleteLogs];
        popUpSheet.delegate = self;
        [self.navController.topViewController.view addSubview:popUpSheet];
    }
}

- (void)doClickOnCancelButtonWithTag:(int)tag
{
    [self notifyCommandExecuted];
}

- (void)doClickOnPopUpSheet:(int)index withTag:(int)tag info:(NSArray *)info
{
    NSMutableArray *condition_arr = [NSMutableArray arrayWithCapacity:3];
    NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
    NSString *phoneNumber = [CommandDataHelper phoneNumberFromData:self.targetData];
    
    if(personId > 0){
        WhereDataModel *condition_pid = [[WhereDataModel alloc] init];
        condition_pid.fieldKey = [DataBaseModel getKWhereKeyPersonID];
        condition_pid.oper = [DataBaseModel getKWhereOperationEqual];
        condition_pid.fieldValue = [NSString stringWithFormat:@"%d", personId];
        [condition_arr addObject:condition_pid];
    }else{
        WhereDataModel *condition_num = [[WhereDataModel alloc] init];
        
        condition_num.fieldKey = [DataBaseModel getKWhereKeyPhoneNumber];
        
        if ([[[PhoneNumber sharedInstance] getOriginalNumber:phoneNumber] length] >= 7) {
            condition_num.oper = [DataBaseModel getKWhereOperationLike];
            condition_num.fieldValue = [[PhoneNumber sharedInstance] getOriginalNumber:phoneNumber];
        } else {
            condition_num.oper = [DataBaseModel getKWhereOperationEqual];
            condition_num.fieldValue = [NSString stringWithFormat:@"%@", [phoneNumber digitNumber]];
        }
        
        [condition_arr addObject:condition_num];
    }
    
    if(index == 1){
        //clear all call logs
        [CallLog deleteCalllogByConditionalWithoutNotification:condition_arr];
        [[PhonePadModel getSharedPhonePadModel].calllog_list.searchResults removeObject:self.targetData];
    }else if(index == 0){
        //clear the last record
        // delete one call log item from data base.
        WhereDataModel *condition_date = [[WhereDataModel alloc] init];
        condition_date.fieldKey = [DataBaseModel getKWhereKeyCallTime];
        condition_date.oper = [DataBaseModel getKWhereOperationEqual];
        NSArray *times = [RemoveCallsCommand getTheFirstANDLastCallTimeWithPersonID:personId orPhoneNumber:phoneNumber];
        if(times != nil){
            condition_date.fieldValue = [NSString stringWithFormat:@"%d", [[times objectAtIndex:0] integerValue]];
            [condition_arr addObject:condition_date];
            [CallLog deleteCalllogByConditionalWithoutNotification:condition_arr];
        }
    }
    
    [[PhonePadModel getSharedPhonePadModel] setInputNumber:@""];
    [self notifyCommandExecuted];
}

- (NSArray *)getTheFirstANDLastCallTime
{
    NSArray *times = nil;
    NSInteger personId = [CommandDataHelper personIdFromData:self.targetData];
    NSString *phoneNumber = [CommandDataHelper phoneNumberFromData:self.targetData];
    times= [RemoveCallsCommand getTheFirstANDLastCallTimeWithPersonID:personId orPhoneNumber:phoneNumber];
    return times;
}

+ (NSArray *)getTheFirstANDLastCallTimeWithPersonID:(int)personId orPhoneNumber:(NSString *)phoneNumber{
    if(personId<0 && phoneNumber.length==0)
        return nil;
    NSMutableArray *condition_arr = [NSMutableArray arrayWithCapacity:2];
    if(personId>0){
        WhereDataModel *condition_pid = [[WhereDataModel alloc] init];
        condition_pid.fieldKey = [DataBaseModel getKWhereKeyPersonID];
        condition_pid.oper = [DataBaseModel getKWhereOperationEqual];
        condition_pid.fieldValue = [NSString stringWithFormat:@"%d", personId];
        [condition_arr addObject:condition_pid];
    }else if([phoneNumber length]>0){
        WhereDataModel *condition_num = [[WhereDataModel alloc] init];
        condition_num.fieldKey = [DataBaseModel getKWhereKeyPhoneNumber];
        
        if ([[[PhoneNumber sharedInstance] getOriginalNumber:phoneNumber] length] >= 7) {
            condition_num.oper = [DataBaseModel getKWhereOperationLike];
            condition_num.fieldValue = [[PhoneNumber sharedInstance] getOriginalNumber:phoneNumber];
        } else {
            condition_num.oper = [DataBaseModel getKWhereOperationEqual];
            condition_num.fieldValue = [DataBaseModel getFormatNumber:phoneNumber];
        }
        [condition_arr addObject:condition_num];
    }
    LabelDataModel *orderby = [[LabelDataModel alloc]init];
    orderby.labelKey = [DataBaseModel getKOrderByKeyCallTime];
    orderby.labelValue = [DataBaseModel getKOrderByKeyValueDesc];
    NSArray *orderbys = [NSArray arrayWithObject:orderby];
    
    NSArray * callLogs = [CallLog calllogsByCondition:condition_arr
                                         OrderByCause:orderbys];
    if([callLogs count]>0){
        CallLogDataModel *firstCallLog = [callLogs objectAtIndex:0];
        int minCallTime = firstCallLog.callTime;
        CallLogDataModel *lastCallLog = [callLogs objectAtIndex:callLogs.count-1];
        int maxCallTime = lastCallLog.callTime;
        return [NSArray arrayWithObjects:[NSNumber numberWithInt:minCallTime],[NSNumber numberWithInt:maxCallTime],[NSNumber numberWithInt:callLogs.count],nil];
    }else{
        return nil;
    }
}

@end
