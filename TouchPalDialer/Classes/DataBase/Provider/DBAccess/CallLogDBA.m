//
//  CallLogDBA.m
//  AddressBook_DB
//
//  Created by Alice on 11-7-13.
//  Copyright 2011 CooTek. All rights reserved.
//

#import "CallLogDBA.h"
#import "CallLogDataModel.h"
#import "DataBaseModel.h"
#import "ContactCacheDataManager.h"
#import "DialResultModel.h"
#import "NumberPersonMappingModel.h"
#import "ContactCacheDataManager.h"
#import "OrlandoEngine+Contact.h"
#import "CallerDBA.h"
#import "CallerIDModel.h"
#import "CootekNotifications.h"
#import "NSString+PhoneNumber.h"
#import "NSString+SqlParam.h"
#import "VoipCommonModel.h"
#import "SeattleFeatureExecutor.h"

#define IS_POST_RECOGNIZER_FINISH   @"IS_POST_RECOGNIZER_FINISH"
#define max_interval_repeat 3

@implementation CallLogDBA

+ (NSArray *)calllogsByCondition:(NSArray *)where
                    GroupByCause:(NSArray *)groupby
                    OrderByCause:(NSArray *)orderby
{
    NSString *sql=nil;

    if (groupby && ![[DataBaseModel getGroupByCause:groupby] isEqualToString:@""]) {
        sql=@"select * From (select rowId,personID,phoneNumber, count(*) as callCount, callTime, callType, duration, ifVoip From (select * from calllog order by callTime asc) ";
        sql=[sql stringByAppendingString:[DataBaseModel getWhereCause:where DeleteFlag:NO]];
        sql=[sql stringByAppendingString:[DataBaseModel getGroupByCause:groupby]];
        sql=[sql stringByAppendingString:[DataBaseModel getOrderByCause:orderby]];
    }else {
        sql=@"select rowId,personID,phoneNumber, 1 as callCount,callTime, callType, duration, ifVoip From calllog ";
        sql=[sql stringByAppendingString:[DataBaseModel getWhereCause:where DeleteFlag:NO]];
        sql=[sql stringByAppendingString:[DataBaseModel getOrderByCause:orderby]];
    }
    NSMutableArray *callLogList = [NSMutableArray array];
    NSMutableArray *changeCalllog = [NSMutableArray array];
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                NSInteger callRowId = sqlite3_column_int(stmt, 0);
                NSInteger callPersonId = sqlite3_column_int(stmt, 1);
                NSString* callNumber = @"";
                if((char *)sqlite3_column_text(stmt, 2) != NULL) {
                    callNumber = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                    encoding:NSUTF8StringEncoding];
                }
                
                NSInteger callCount = sqlite3_column_int(stmt, 3);
                NSInteger callTime = sqlite3_column_int(stmt, 4);
                NSInteger callType = sqlite3_column_int(stmt, 5);
                NSInteger duration = sqlite3_column_int(stmt, 6);
                NSInteger ifVoip = sqlite3_column_int(stmt, 7);
                
                NSInteger personID = [NumberPersonMappingModel queryContactIDByNumber:callNumber];
                BOOL callLogChanged = NO;
                if (personID != callPersonId && (callPersonId >= 0 || personID > 0)) {
                    callPersonId = personID;
                    callLogChanged = YES;
                }
                
                CallLogDataModel *call_log = [[CallLogDataModel alloc] initWithPersonId:callPersonId
                                                                            phoneNumber:callNumber
                                                                               callType:callType
                                                                               duration:duration
                                                                          loadExtraInfo:YES];
                call_log.rowID = callRowId;
                call_log.callCount = callCount;
                call_log.callTime = callTime;
                call_log.ifVoip = ifVoip;
                [callLogList addObject:call_log];
                
                if (callLogChanged) {
                    LabelDataModel *toUpdate = [[LabelDataModel alloc] init];
                    toUpdate.labelKey = callNumber;
                    toUpdate.labelValue = [NSNumber numberWithInteger:callPersonId];
                    [changeCalllog addObject:toUpdate];
                }
                result = sqlite3_step(stmt);
            }
        }
        sqlite3_finalize(stmt);
    }];
    if ([changeCalllog count] >0) {
        [NSThread detachNewThreadSelector:@selector(updateCallLog:) toTarget:self withObject:changeCalllog];
    }
    return callLogList;
}
+ (void)updateCallLog:(NSArray *)changeCalllg
{
    @autoreleasepool {
        NSString *sqlUpdate = @"";
        for (int i = 0 ; i < [changeCalllg count]; i++) {
            LabelDataModel *calllog = [changeCalllg objectAtIndex:i];
            NSInteger personId = [((NSNumber *)calllog.labelValue) integerValue];
            NSString *phoneNumber = calllog.labelKey;
            sqlUpdate =  [NSString stringWithFormat:@"%@ UPDATE calllog SET personID = %d WHERE phoneNumber = '%@';",
                          sqlUpdate, personId, [NSString safeSqlParam:phoneNumber]];
        }
        if ([sqlUpdate length] > 0) {
            sqlUpdate = [NSString stringWithFormat:@"BEGIN TRANSACTION;%@;COMMIT;",sqlUpdate];
            [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
                char *errorMsg = NULL;
                int execResult = sqlite3_exec(db, [sqlUpdate UTF8String], NULL,NULL, &errorMsg);
                if (execResult == SQLITE_OK) {
                    cootek_log(@"excute call update = %d ",execResult);
                }
                sqlite3_free(errorMsg);
            }];
        }
    }
}

+ (BOOL)insertCallLogs:(NSArray *)callLogs
{
    if ([callLogs count] == 0) {
        return NO;
    }
    
    NSMutableString *sql = [NSMutableString string];
    for (CallLogDataModel *item in callLogs) {
        NSInteger personID = [NumberPersonMappingModel  queryContactIDByNumber:item.number];
        if (item.personID != personID && (item.personID > 0 || personID > 0)) {
            item.personID = personID;
        }
        [sql appendFormat:@"INSERT INTO calllog(personID,phoneNumber,callTime,callType,duration,ifVoip) VALUES(%d,'%@',%d,%d,%d,%d);\n", item.personID, [NSString safeSqlParam:[DataBaseModel getFormatNumber:item.number]] , item.callTime, item.callType, item.duration,item.ifVoip];
    }
    
    __block BOOL changed = NO;
    if ([sql length] > 0) {
        sql = [NSMutableString stringWithFormat:@"BEGIN TRANSACTION;%@;COMMIT;",sql];
        [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
            char *errorMsg = NULL;
            int result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &errorMsg);
            cootek_log(@"insert calllogs filed with error: %s, sql: %@", errorMsg, sql);
            changed = (result == SQLITE_OK);
            sqlite3_free(errorMsg);
        }];
    }
	return changed;
}

+ (BOOL)excuteInsertSql:(NSString *)sqlInsert
{
    __block BOOL result = NO;
    if ([sqlInsert length] > 0) {
        sqlInsert = [NSString stringWithFormat:@"BEGIN TRANSACTION;%@;COMMIT;",sqlInsert];
        [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
            char *errorMsg = NULL;
            int execResult = sqlite3_exec(db, [sqlInsert UTF8String], NULL,NULL, &errorMsg);
            if (execResult == SQLITE_OK) {
                result = YES;
                cootek_log(@"excute inset CALL update = %d sql =%@",execResult,sqlInsert);
            }
            sqlite3_free(errorMsg);
        }];
    }
    return result;
}
+ (NSArray *) querycallogsStart:(NSInteger)startTime
                        endTime:(NSInteger)endTime
{
    NSString *sql =[NSString stringWithFormat:@"select rowId,personID,phoneNumber,callTime,callType,duration,ifVoip From calllog where callTime >=%d and callTime<=%d order by callTime desc",startTime,endTime];
    NSMutableArray *calllogs = [NSMutableArray arrayWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                int rowID = sqlite3_column_int(stmt,0);
                int personID = sqlite3_column_int(stmt,1);
                NSString *number = @"";
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                encoding:NSUTF8StringEncoding];
                }
                int callTime = sqlite3_column_int(stmt,3);
                int callType = sqlite3_column_int(stmt,4);
                int duration = sqlite3_column_int(stmt,5);
                int ifVoip = sqlite3_column_int(stmt,6);
                CallLogDataModel *calllog = [[CallLogDataModel alloc] initWithPersonId:personID phoneNumber:number callType:callType duration:duration loadExtraInfo:NO];
                calllog.callTime = callTime;
                calllog.rowID = rowID;
                calllog.ifVoip = ifVoip;
                [calllogs addObject:calllog];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return calllogs;
}

+ (NSArray *) queryRecentlyCallLogsWithCount:(int)count
{
    NSString *sql =[NSString stringWithFormat:@"select rowId,personID,phoneNumber,callTime,callType,duration,ifVoip From calllog order by callTime desc limit 0,%d",count];
    if (count == QUERY_ALL_CALLLOG) {
        sql = @"select rowId,personID,phoneNumber,callTime,callType,duration,ifVoip From calllog order by callTime desc";
    }
    NSMutableArray *calllogs=[NSMutableArray arrayWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                int rowID = sqlite3_column_int(stmt,0);
                int personID = sqlite3_column_int(stmt,1);
                NSString *number = @"";
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                encoding:NSUTF8StringEncoding];
                }
                int callTime = sqlite3_column_int(stmt,3);
                int callType = sqlite3_column_int(stmt,4);
                int duration = sqlite3_column_int(stmt,5);
                int ifVoip = sqlite3_column_int(stmt,6);
                CallLogDataModel *calllog = [[CallLogDataModel alloc] initWithPersonId:personID phoneNumber:number callType:callType duration:duration loadExtraInfo:NO];
                calllog.callTime = callTime;
                calllog.rowID = rowID;
                calllog.ifVoip = ifVoip;
                [calllogs addObject:calllog];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return calllogs;
}

+ (NSMutableDictionary *) allContinuousMissedCallCount
{
    NSString *sql = @"select phoneNumber,callType From calllog order by callTime desc";
    NSMutableDictionary *missedDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            NSString *preNumber = @"";
            NSMutableDictionary *missedCallCounts = [NSMutableDictionary dictionaryWithCapacity:1];
            while (result == SQLITE_ROW) {
                NSString *number = @"";
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                encoding:NSUTF8StringEncoding];
                }
                int callType = sqlite3_column_int(stmt,1);
                NSString *normalNumber= [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:number];
                int count = [[missedCallCounts objectForKey:preNumber] integerValue];
                if (callType == CallLogIncomingMissedType
                    && [preNumber isEqualToString:normalNumber]
                    && count > 0){
                    int count = [[missedCallCounts objectForKey:normalNumber] integerValue];
                    [missedCallCounts setObject:@(count+1) forKey:normalNumber];
                }else{
                    if (count > 0) {
                        int countExtis = [[missedDic objectForKey:preNumber] integerValue];
                        [missedDic setObject:@(count+countExtis) forKey:preNumber];
                        [missedCallCounts removeObjectForKey:preNumber];
                    }
                    if (callType == CallLogIncomingMissedType
                        && ![missedCallCounts objectForKey:normalNumber]) {
                        [missedCallCounts setObject:@1 forKey:normalNumber];
                    }else{
                        [missedCallCounts setObject:@0 forKey:normalNumber];
                    }
                }
                preNumber = normalNumber;
                result = sqlite3_step(stmt);
            }
            int count = [[missedCallCounts objectForKey:preNumber] integerValue];
            if (count > 0) {
                [missedDic setObject:@(count) forKey:preNumber];
            }
            sqlite3_finalize(stmt);
        }
    }];
    return missedDic;
}

+ (BOOL)deleteCalllogByRowId:(NSInteger)rowId
{
	if (rowId <= 0) {
		return NO;
	}
	__block BOOL result = YES;
    
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        const char *deleteSql = "DELETE FROM calllog WHERE rowId = ?";
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(db, deleteSql, -1, &stmt, NULL) == SQLITE_OK) {
            sqlite3_bind_int(stmt,1,rowId);
            sqlite3_step(stmt);
        }else {
            result = NO;
        }
        sqlite3_finalize(stmt);
    }];
	if (result) {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_CALL_LOG_CHANGED object:nil userInfo:nil];
	}
    
	return result;
}

+ (BOOL) deleteCalllogByConditional:(NSArray *)whereby
{
	BOOL result = [self deleteCalllogByConditionalWithoutNotification:whereby];
	if (result) {
		[[NSNotificationCenter defaultCenter] postNotificationName:N_CALL_LOG_CHANGED object:nil userInfo:nil];
	}
	return result;
}

+ (BOOL)deleteCalllogByConditionalWithoutNotification:(NSArray *)whereby
{
	__block BOOL result = YES;
    
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        NSString *sql=@"DELETE FROM calllog ";
        sql=[sql stringByAppendingString:[DataBaseModel getWhereCause:whereby DeleteFlag:YES]];
        const char *deleteSql = [sql UTF8String];
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, deleteSql, -1, &stmt, NULL) == SQLITE_OK) {
            int count = 0;
            if(whereby) {
                count = [whereby count];
            }
            for (int i = 0; i < count; i++) {
                WhereDataModel *where=[whereby objectAtIndex:i];
                if ([DataBaseModel isExistsWhereKey:where.fieldKey]) {
                    if ([DataBaseModel getKWhereKeyType:where.fieldKey]) {
                        sqlite3_bind_int(stmt,i+1,[where.fieldValue integerValue]);
                    }else {
                        NSString *tmp = where.fieldValue;
                        if ([where.oper isEqualToString:[DataBaseModel getKWhereOperationLike]]) {
                            tmp = [NSString stringWithFormat:@"%%%@",tmp];
                        }
                        sqlite3_bind_text(stmt,i+1,[tmp UTF8String], -1, SQLITE_TRANSIENT);
                    }
                }
            }
            sqlite3_step(stmt);
        }else {
            result = NO;
        }
        sqlite3_finalize(stmt);
    }];
	return result;
}

+ (CallCountModel *)callCountReturnByPersonID:(NSInteger)personID
{
	if (personID <= 0) {
		return nil;
	}
	NSString *selectSql = [NSString stringWithFormat:@"select count(*) as callCount,callTime from  calllog where personID=%d order by callTime desc",personID];
	
    CallCountModel *callCount = [[CallCountModel alloc] init];
	callCount.personID = personID;
    
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, [selectSql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {	
                    callCount.callCount = sqlite3_column_int(stmt, 0);
                    callCount.callTime = sqlite3_column_int(stmt, 1);
                }
        }
        sqlite3_finalize(stmt);
    }];
	return	callCount;
} 

+ (NSArray *)searchCalllog:(NSString *)number
{
    NSString *content = [DataBaseModel getFormatNumber:number];
    if (!content||[content isEqualToString:@""]) {
        return nil;
    }
    NSMutableDictionary *callerIDsDic = [CallerDBA getAllCacheCallerIDs];
    NSMutableArray *result_list = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
     NSString *sqlSearch = @"";
     if ([number length] == 1) {
         sqlSearch = @"select distinct(phoneNumber) from calllog where personID <= 0 and phoneNumber like '";
     }else {
         sqlSearch = @"select distinct(phoneNumber) from calllog where personID <= 0 and phoneNumber like '%";
     }
     sqlSearch = [sqlSearch stringByAppendingString:content];
     sqlSearch = [sqlSearch stringByAppendingString:@"%' order by callTime desc"];
     
      sqlite3_stmt *stmt;
      int result = sqlite3_prepare_v2(db,[sqlSearch UTF8String], -1, &stmt, NULL);
      if (result == SQLITE_OK) {
          while (sqlite3_step(stmt) == SQLITE_ROW) {
              if((char *)sqlite3_column_text(stmt, 0)!=NULL)
              {
                  NSString *number = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
                  NSString *digitNumber = [number digitNumber];
                  NSInteger personID = [NumberPersonMappingModel queryContactIDByNumber:digitNumber];
                  if (!(personID > 0)) {
                      DialResultModel *result = [[DialResultModel alloc] init];
                      result.number = number;
                      result.number = [result.number formatPhoneNumberByDigitNumber:digitNumber];
                      NSString *str = [content digitNumber];
                      result.hitNumberInfo = [result.number rangeOfStringInNumbers:str digitNumber:digitNumber];
                      NSString *normalNumber = [[PhoneNumber sharedInstance] getNormalizedNumber:result.number];
                      CallerIDInfoModel *callerID = [callerIDsDic objectForKey:normalNumber];
                
                      if (callerID) {
                          result.callerID = callerID;
                      }
                      if (![dic objectForKey:normalNumber]) {
                          [result_list addObject:result];
                          [dic setObject:result forKey:normalNumber];
                      }
                  }
              }
          }
        sqlite3_finalize(stmt);
      }
    }];
    return result_list;
}

+ (NSArray *)queryAllRecognitionCallogs
{
    NSArray *calllogs = [self querAllUnknowCallogs];
    return [self recognitionCalllogs:calllogs];
}

+ (NSArray *)recognitionCalllogs:(NSArray *)calllogs
{
    NSMutableArray *calllogsCallers = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *callerIDsDic = [CallerDBA getAllCacheCallerIDs];
    NSMutableDictionary *callogDic = [NSMutableDictionary dictionaryWithCapacity:[calllogsCallers count]];
    for (CallLogDataModel *calllog in calllogs) {
        NSString *normalNumber= [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:calllog.number];
        CallerIDInfoModel *callerID = [callerIDsDic objectForKey:normalNumber];
        CallLogDataModel *tmpcallog = [callogDic objectForKey:normalNumber];
        if (!tmpcallog &&
            callerID &&
            [callerID isCallerIdUseful] &&
            callerID.callerIDCacheLevel <= CallerIDQueryLocalLevel) {
            calllog.callerID = callerID;
            [calllogsCallers addObject:calllog];
            [callogDic setObject:calllog forKey:normalNumber];
        }
    }
    return calllogsCallers;
}

+ (NSArray *)queryAllMarkCallogs
{
    NSArray *calllogs = [self querAllUnknowCallogs];
    return [self marksCallogs:calllogs];
}

+ (NSArray *)marksCallogs:(NSArray *)calllogs
{
    NSMutableArray *calllogsCallers = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *callerIDsDic = [CallerDBA getAllCacheMarks];
    NSMutableDictionary *callogDic = [NSMutableDictionary dictionaryWithCapacity:[calllogsCallers count]];
    for (CallLogDataModel *calllog in calllogs) {
        NSString *normalNumber= [[PhoneNumber sharedInstance] getNormalizedNumberAccordingNetwork:calllog.number];
        CallerIDInfoModel *callerID = [callerIDsDic objectForKey:normalNumber];
        CallLogDataModel *tmpcallog = [callogDic objectForKey:normalNumber];
        if (!tmpcallog&&
            callerID) {
            calllog.callerID = callerID;
            [calllogsCallers addObject:calllog];
            [callogDic setObject:calllog forKey:normalNumber];
        }
    }
    return calllogsCallers;
}

+ (NSInteger)unknowCalllogCount
{
    NSString *sql = @"select count(DISTINCT(phonenumber)) as count From calllog where personID <= 0 ";
    __block NSInteger count = 0;
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            sqlite3_step(stmt);
            count = sqlite3_column_int(stmt,0);
            sqlite3_finalize(stmt);
        }
    }];
    return count;
}

+ (NSArray *)querAllUnknowCallogs
{
    NSString *sql = @"select DISTINCT(phoneNumber), max(calltime) as calltime From calllog where personID <= 0 group by phoneNumber order by calltime desc limit 0,300";
    NSMutableArray *calllogs=[NSMutableArray arrayWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                CallLogDataModel *calllog = [[CallLogDataModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    calllog.number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                        encoding:NSUTF8StringEncoding];
                }
                
                calllog.callTime = sqlite3_column_int(stmt,1);
                [calllogs addObject:calllog];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return calllogs;
}

+ (NSArray *)queryTopFrequentContacts:(int)count {
    NSString *sql = [NSString stringWithFormat:@"select phoneNumber, personID, count(*) as callCount from calllog where personID > 0 group by personID order by callCount desc limit %d", count];
    NSMutableArray *calllogs=[NSMutableArray arrayWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                FrequentCallModel  *calllog = [[FrequentCallModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    calllog.number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                        encoding:NSUTF8StringEncoding];
                }
                calllog.personID = sqlite3_column_int(stmt,1);
                calllog.callCount = sqlite3_column_int(stmt,2);
                if (calllog.personID > 0) {
                    [calllogs addObject:calllog];
                }
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return calllogs;
}
@end
