//
//  CallLog.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-13.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "CallLog.h"
#import "CallLogDBA.h"
#import "ContactCacheDataManager.h"
#import "PhoneNumber.h"
#import "AdvancedCalllog.h"
#import "PhonePadModel.h"
#import "CootekNotifications.h"
#import "CallerDBA.h"
#import "CallerIDModel.h"
#import "UserDefaultsManager.h"
#import "SeattleFeatureExecutor.h"


CallLogDataModel *pendingCalllog;

@implementation CallLog

//获取所有通话记录
//输出：通话记录列表
//获取所有联系人
+(NSArray *)calllogsByCondition:(NSArray *)where
                   OrderByCause:(NSArray *)orderby
{
    NSArray *call_list=[CallLogDBA	calllogsByCondition:where
                                          GroupByCause:nil
                                          OrderByCause:orderby];
    
	if([call_list count]==0){
        return nil;
    }
    return call_list;
}

+ (NSArray *)calllogsByCondition:(NSArray *)where
                    GroupByCause:(NSArray *)groupby
                    OrderByCause:(NSArray *)orderby
{
    NSArray *call_list=[CallLogDBA	calllogsByCondition:where
                                          GroupByCause:groupby
                                          OrderByCause:orderby];
    
	if([call_list count]==0){
        return nil;
    }
    
    NSMutableArray *tmpCallloglist = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *set_calllog = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary *set_calllog_number = [NSMutableDictionary dictionaryWithCapacity:1];
	for (CallLogDataModel *call_log in call_list) {
        if (call_log.personID > 0) {
            CallLogDataModel *preCalllog = [set_calllog objectForKey:[NSNumber numberWithInt:call_log.personID]];
            if (preCalllog) {
                preCalllog.callCount =  preCalllog.callCount + call_log.callCount;
            }else{
                [tmpCallloglist addObject:call_log];
                [set_calllog setObject:call_log forKey:[NSNumber numberWithInt:call_log.personID]];
            }
        }else{
            NSString *currentnumber = [[PhoneNumber sharedInstance] getNormalizedNumber:call_log.number];
            CallLogDataModel *preCalllog = [set_calllog_number objectForKey:currentnumber];
            if (preCalllog) {
                preCalllog.callCount =  preCalllog.callCount + call_log.callCount;
            }else{
                [tmpCallloglist addObject:call_log];
                [set_calllog_number setObject:call_log forKey:currentnumber];
            }
        }
	}
    cootek_log(@"*******call log count = %d ******",[tmpCallloglist count]);
	return tmpCallloglist;
}

+ (NSArray *)queryAllCalllogs
{
    //order by
    LabelDataModel *order_by=[[LabelDataModel alloc] init];
    order_by.labelKey=[DataBaseModel getKOrderByKeyCallTime];
    order_by.labelValue=[DataBaseModel getKOrderByKeyValueDesc];
    NSMutableArray* order_array=[[NSMutableArray alloc] init];
    [order_array addObject:order_by];
    
    order_by=[[LabelDataModel alloc] init];
    order_by.labelKey=[DataBaseModel getKOrderByKeyCallCount];
    order_by.labelValue=[DataBaseModel getKOrderByKeyValueDesc];
    [order_array addObject:order_by];
    
    //group by
    NSMutableArray* group_array=[[NSMutableArray alloc] init];
    [group_array addObject:[DataBaseModel getKGroupByKeyPersonId]];
    [group_array addObject:[DataBaseModel getKGroupByKeyPhoneNumber]];
    
    NSArray *calllogs = [CallLog calllogsByCondition:nil
                                        GroupByCause:group_array
                                        OrderByCause:order_array];
    
    NSMutableDictionary *callerIDsDic = [CallerDBA getAllCacheCallerIDs];
    NSMutableArray *updateEngines = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *unkownNumbers = [NSMutableArray arrayWithCapacity:1];
    for (CallLogDataModel *calllog in calllogs) {
        if (calllog.personID > 0) {
            [updateEngines addObject:[CallCountModel callCount:calllog.personID
                                                         count:calllog.callCount
                                                      lastTime:calllog.callTime]];
        }else{
            NSString *normalNumber= [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:calllog.number];
            CallerIDInfoModel *callerID = [callerIDsDic objectForKey:normalNumber];
            if (callerID) {
                calllog.callerID = callerID;
            }else{

                if (callerIDsDic == nil) {
                    calllog.callerID = nil;
                }else{
                [unkownNumbers addObject:normalNumber];
                }
            }
        }
    }
    if ([updateEngines count] > 0) {
        [NSThread detachNewThreadSelector:@selector(updateContactsWeights:)
                                 toTarget:[OrlandoEngine instance]
                               withObject:updateEngines];
    }
    if ([unkownNumbers count] > 0) {
        [NSThread detachNewThreadSelector:@selector(queryCallerIDs:)
                                 toTarget:[CallerIDModel class]
                               withObject:unkownNumbers];
    }
    return calllogs;
}

+ (NSMutableDictionary  *) getPersonCallLogList
{
    WhereDataModel *condition = [[WhereDataModel alloc] init];
    condition.fieldKey = [DataBaseModel getKWhereKeyPersonID];
    condition.oper = [DataBaseModel getKWhereOperationLarger];
    condition.fieldValue = [NSString stringWithFormat:@"%d", 0];
    NSArray *condition_arr = [NSArray arrayWithObject:condition];
    
    LabelDataModel *order_by=[[LabelDataModel alloc] init];
    order_by.labelKey=[DataBaseModel getKOrderByKeyCallTime];
    order_by.labelValue=[DataBaseModel getKOrderByKeyValueDesc];
    NSMutableArray* order_array=[[NSMutableArray alloc] init];
    [order_array addObject:order_by];
    
    order_by=[[LabelDataModel alloc] init];
    order_by.labelKey=[DataBaseModel getKOrderByKeyCallCount];
    order_by.labelValue=[DataBaseModel getKOrderByKeyValueDesc];
    [order_array addObject:order_by];
    
    //group by
    NSMutableArray* group_array=[[NSMutableArray alloc] init];
    [group_array addObject:[DataBaseModel getKGroupByKeyPersonId]];
    [group_array addObject:[DataBaseModel getKGroupByKeyPhoneNumber]];
    
    NSArray *resultList = [CallLog calllogsByCondition:condition_arr
                                          GroupByCause:group_array
                                          OrderByCause:order_array];
    NSMutableDictionary *dicCalllog = [NSMutableDictionary dictionaryWithCapacity:1];
    int count = [resultList count];
    if (count>0) {
    	for (CallLogDataModel *call_log in resultList) {    
            if (call_log && call_log.personID > 0) {
                [dicCalllog setObject:call_log forKey:[NSNumber numberWithInt:call_log.personID]];
            }
        }
    }
    return dicCalllog;
}

+ (NSMutableDictionary *)allMissedContinue
{
    return [CallLogDBA allContinuousMissedCallCount];
}

+ (BOOL)addCallLog:(CallLogDataModel *)call_log
{
    if (call_log == nil) {
        return NO;
    }
    return [self addCallLogs:@[call_log]];
}

+ (BOOL)addCallLogs:(NSArray *)callLogs
{
    if (callLogs == nil || [callLogs count] == 0) {
        return NO;
    }
    BOOL success = [CallLogDBA insertCallLogs:callLogs];
    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:N_CALL_LOG_CHANGED
                                                            object:nil
                                                          userInfo:nil];
    }
	return success;
}

+ (void)addPendingCallLog:(CallLogDataModel *)call_log{
    [PhonePadModel getSharedPhonePadModel].isCommitCalllog = NO;
    [CallLog clearPendingCallLog];
    CallLogDataModel *callLog = [call_log copy];
	pendingCalllog = callLog;
}

+ (void)clearPendingCallLog
{
	if(pendingCalllog != nil)
	{
		pendingCalllog = nil;
	}
}

+ (void)syncCalllog
{
    @synchronized(self){
        BOOL result = [AdvancedCalllog synCalllog];
        if (result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_CALL_LOG_CHANGED
                                                                object:nil
                                                              userInfo:nil];
        }
    }
}

+ (void)commitPendingCallLog
{
    if (pendingCalllog == nil) {
        return;
    }
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
        [self commitPendingCallLogJob];
    });
}

+ (void)commitPendingLogWithCallDur:(int)duration isVoipCall:(BOOL)isVoip{
    if (duration < 0) {
        duration = 0;
    }
    if (pendingCalllog.callType == CallLogIncomingType && duration == 0) {
        pendingCalllog.callType = CallLogIncomingMissedType;
    }
    pendingCalllog.duration = duration;
    pendingCalllog.ifVoip = isVoip;
    [self commitPendingCallLog];
}

+ (void)commitPendingCallLogJob
{
    if(pendingCalllog != nil) {
        if ([AdvancedCalllog isAccessCallDB]) {
            [CallLog clearPendingCallLog];
            [CallLog syncCalllog];
        }else{
            [PhonePadModel getSharedPhonePadModel].isCommitCalllog = YES;
            pendingCalllog.callTime = [[NSDate date] timeIntervalSince1970];
            [CallLog addCallLog:pendingCalllog];
            [CallLog clearPendingCallLog];
        }
        int uploadCount = [UserDefaultsManager intValueForKey:DATA_CURRENT_CALLLOG_COUNT defaultValue:QUERY_ALL_CALLLOG];
        if (uploadCount != QUERY_ALL_CALLLOG) {
            [UserDefaultsManager setIntValue:(uploadCount + 1) forKey:DATA_CURRENT_CALLLOG_COUNT];
        }
    }
}

+ (BOOL)deleteCalllogByRowId:(NSInteger)row_id{
	return [CallLogDBA deleteCalllogByRowId:row_id];
}

//删除通话记录
//输入：删除条件
+ (BOOL)deleteCalllogByConditional:(NSArray *)whereby
{
	return [CallLogDBA deleteCalllogByConditional:whereby];
}

+ (BOOL)deleteCalllogByConditionalWithoutNotification:(NSArray *)whereby
{
	return [CallLogDBA deleteCalllogByConditionalWithoutNotification:whereby];
}

@end
