//
//  TPQuertyCallog.m
//  TouchPalDialer
//
//  Created by lingmei xie on 12-12-4.
//
//

#import "TPQueryCallog.h"
#import "CallLog.h"
#import "DataBaseModel.h"
#import "PhoneNumber.h"
#import "AdvancedCalllog.h"
#import "CallerDBA.h"
#import "CallerIDModel.h"

@implementation TPQueryCallogDefault

+ (TPQueryCallogDefault *)createQueryCalllogObject:(CalllogFilterType)type
{
    switch (type) {
        case AllCallLogFilter:
        {
            return [[TPQueyCallLogAll alloc] init];
            break;
        }
        case MissedCalllogFilter:
        {
            return [[TPQueryCallLogMissed alloc] init];
            break;
        }
        case OutgoingFilter:
        {
            return [[TPQueryCallLogOutgoing alloc] init];
            break;
        }
        case IncomingFilter:
        {
            return [[TPQueryCallLogIncoming alloc] init];
            break;
        }
        case UnknowCallLogFilter:
        {
            return [[TPQueryCallLogUnknown alloc] init];
            break;
        }
        default:
            break;
    }
    
    return nil;
}

+ (void)configureCallerIdWithCallLogDataModels:(NSArray *)callLogDataModels
{
    NSMutableDictionary *callerIDsDic = [CallerDBA getAllCacheCallerIDs];
    NSMutableArray *unknownNumbers = [NSMutableArray array];
    for (CallLogDataModel *calllog in callLogDataModels) {
        NSString *normalNumber= [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:calllog.number];
        CallerIDInfoModel *callerID = [callerIDsDic objectForKey:normalNumber];
        if (callerID) {
            calllog.callerID = callerID;
        } else {
            [unknownNumbers addObject:normalNumber];
        }
    }
    
    if ([unknownNumbers count] > 0) {
        [NSThread detachNewThreadSelector:@selector(queryCallerIDs:)
                                 toTarget:[CallerIDModel class]
                               withObject:unknownNumbers];
    }
}

- (NSArray *)queryCallog
{
    return nil;
}

+ (NSArray *)queryFilterCalllog:(CallLogType)type
{
    WhereDataModel *condition = [[WhereDataModel alloc] init];
	condition.fieldKey = [DataBaseModel getKWhereKeyCallType];
	condition.oper = [DataBaseModel getKWhereOperationEqual];
	condition.fieldValue = [NSString stringWithFormat:@"%d",type];
	NSArray *condition_arr = [NSArray arrayWithObject:condition];
	
	//group by
	NSMutableArray* group_array=[NSMutableArray arrayWithCapacity:1];
	[group_array addObject:[DataBaseModel getKGroupByKeyPersonId]];
	[group_array addObject:[DataBaseModel getKGroupByKeyPhoneNumber]];
	NSString *calltime=[DataBaseModel getKGroupByKeyCallTime];
	calltime=[calltime stringByAppendingFormat:@"/%d",86400];
	[group_array addObject:calltime];
	
	LabelDataModel *order = [[LabelDataModel alloc] init];
	order.labelKey = [DataBaseModel getKOrderByKeyCallTime];
	order.labelValue = [DataBaseModel getKOrderByKeyValueDesc];
	NSArray *order_arr = [NSArray arrayWithObject:order];
    
    NSArray *resultList = [CallLog calllogsByCondition:condition_arr
                                          GroupByCause:group_array
                                          OrderByCause:order_arr];
    [TPQueryCallogDefault configureCallerIdWithCallLogDataModels:resultList];
    
    return resultList;
}
@end

@implementation TPQueyCallLogAll

- (NSArray *)queryCallog
{
    NSArray *resultList = [CallLog queryAllCalllogs];
    if ([AdvancedCalllog isShowLogsType]) {
        NSMutableDictionary *missedCountDic = [CallLog allMissedContinue];
        for (CallLogDataModel *callog in resultList) {
            NSString *normalNumber= [[PhoneNumber sharedInstance] getNormalizedNumber:callog.number];
            int count = [[missedCountDic objectForKey:normalNumber] integerValue];
            if (count > 0) {
                callog.missedCount = count;
            }
        }
    }
    return resultList;
}

@end

@implementation TPQueryCallLogUnknown

- (NSArray *)queryCallog
{
    WhereDataModel *condition = [[WhereDataModel alloc] init];
	condition.fieldKey = [DataBaseModel getKWhereKeyPersonID];
	condition.oper = [DataBaseModel getKWhereOperationSmall];
	condition.fieldValue = [NSString stringWithFormat:@"%d",0];
	NSArray *condition_arr = [NSArray arrayWithObject:condition];
	
	//group by
	NSMutableArray* group_array= [NSMutableArray arrayWithCapacity:1];
	[group_array addObject:[DataBaseModel getKGroupByKeyPersonId]];
	[group_array addObject:[DataBaseModel getKGroupByKeyPhoneNumber]];
	NSString *calltime=[DataBaseModel getKGroupByKeyCallTime];
	calltime=[calltime stringByAppendingFormat:@"/%d",86400];
	[group_array addObject:calltime];
	
	LabelDataModel *order = [[LabelDataModel alloc] init];
	order.labelKey = [DataBaseModel getKOrderByKeyCallTime];
	order.labelValue = [DataBaseModel getKOrderByKeyValueDesc];
	NSArray *order_arr = [NSArray arrayWithObject:order];
    
    NSArray *tmpresultList = [CallLog calllogsByCondition:condition_arr
                                             GroupByCause:group_array
                                             OrderByCause:order_arr];
    [TPQueryCallogDefault configureCallerIdWithCallLogDataModels:tmpresultList];
    
    return tmpresultList;
}
@end

@implementation TPQueryCallLogIncoming

- (NSArray *)queryCallog
{
    return [TPQueryCallogDefault queryFilterCalllog:CallLogIncomingType];
}
@end

@implementation TPQueryCallLogOutgoing

-(NSArray *)queryCallog
{
    return [TPQueryCallogDefault queryFilterCalllog:CallLogOutgoingType];
}

@end

@implementation TPQueryCallLogMissed

-(NSArray *)queryCallog
{
    return [TPQueryCallogDefault queryFilterCalllog:CallLogIncomingMissedType];
}

@end