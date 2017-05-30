//
//  CallerDBA.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CallerDBA.h"
#import "DataBaseModel.h"
#import "CallerIDInfoModel.h"
#import "CallerIDModel.h"
#import "CootekNotifications.h"
#import "SmartDailerSettingModel.h"
#import "NSString+SqlParam.h"
#import "OrlandoEngine.h"
#import "QueryCallerid.h"

@implementation CallerDBA

+ (void)updateCacheAfterCityDown
{
    NSString *sql = @"SELECT number FROM CALLER WHERE cacheLevel < 2";
    NSMutableArray *callerIDs  = [NSMutableArray arrayWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    NSString *number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                       encoding:NSUTF8StringEncoding];
                    [callerIDs addObject:number];
                }
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    NSMutableArray *insertCallerIDs  = [NSMutableArray arrayWithCapacity:1];
    for (int i=0; i<[callerIDs count]; i++) {
        NSString *number = [callerIDs objectAtIndex:i];
        CallerIDInfoModel *callerID = [[QueryCallerid shareInstance]getLocalCallerid:number];
        if (callerID) {
            [insertCallerIDs addObject:callerID];
        }
    }
    [CallerDBA addCallers:insertCallerIDs];
}
+ (void)deleteAllCache
{
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
            NSString *sqlDelete = @"DELETE FROM CALLER";
            char *errorMsg = NULL;
            int execResult = sqlite3_exec(db, [sqlDelete UTF8String], NULL,NULL, &errorMsg);
            if (execResult == SQLITE_OK) {
                cootek_log(@"excute ADD CALLER delete = %d sql =%@",execResult,sqlDelete);
            }
            sqlite3_free(errorMsg);
    }];
}

+ (NSMutableDictionary *)getAllCacheCallerIDs
{
    if(!SmartDailerSettingModel.isChinaSim){
        return nil;
    }
    int time = [[NSDate date] timeIntervalSince1970];
    NSString *sql = [NSString stringWithFormat:@"SELECT name,number,callerType,verifyType,markCount,cacheLevel,vipID,versionTime FROM CALLER WHERE ((cacheLevel>0 and cacheLevel < 4) and (dateTime + 15*24*3600) >%d) or (cacheLevel = 0 and (dateTime + 1*24*3600) >%d) or (cacheLevel = 5 and (dateTime + 30*24*3600) >%d) or (cacheLevel = 4)",time,time,time];
    NSMutableDictionary *callerIDsDic=[NSMutableDictionary dictionaryWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                CallerIDInfoModel *callerID = [[CallerIDInfoModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    callerID.name = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                    callerID.number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                         encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    callerID.callerType = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,2)
                                                             encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 7)!=NULL)
                {
                    callerID.versionTime = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,7)
                                                              encoding:NSUTF8StringEncoding];
                }
                callerID.isVerified = (sqlite3_column_int(stmt, 3) > 0);
                callerID.markCount = sqlite3_column_int(stmt, 4);
                callerID.callerIDCacheLevel = sqlite3_column_int(stmt, 5);
                callerID.vipID = sqlite3_column_int(stmt, 6);
                [callerIDsDic setObject:callerID forKey:callerID.number];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return callerIDsDic;
}
+ (NSMutableDictionary *)getAllCacheMarks
{
    NSString *sql = @"SELECT name, number, callerType, verifyType, markCount, cacheLevel, vipID, versionTime FROM CALLER WHERE cacheLevel > 3";
    NSMutableDictionary *callerIDsDic=[NSMutableDictionary dictionaryWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                CallerIDInfoModel *callerID = [[CallerIDInfoModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    callerID.name = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                    callerID.number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                         encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    callerID.callerType = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,2)
                                                             encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 7)!=NULL)
                {
                    callerID.versionTime = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,7)
                                                              encoding:NSUTF8StringEncoding];
                }
                callerID.isVerified = (sqlite3_column_int(stmt, 3) > 0);
                callerID.markCount = sqlite3_column_int(stmt, 4);
                callerID.callerIDCacheLevel = sqlite3_column_int(stmt, 5);
                callerID.vipID = sqlite3_column_int(stmt, 6);
                [callerIDsDic setObject:callerID forKey:callerID.number];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return callerIDsDic;
}
+ (void)addCallers:(NSArray *)callers notify:(BOOL)isNotify
{
    NSString *sqlUpdate = @"";
    for (int i = 0 ; i<[callers count]; i++) {
        CallerIDInfoModel *callerID = [callers objectAtIndex:i];
        int time = [[NSDate date] timeIntervalSince1970];
        
        if (callerID.callerIDCacheLevel == CallerIDQueryMarkLevel) {
            sqlUpdate = [NSString stringWithFormat:@"%@ DELETE FROM CALLER WHERE number = '%@';",
                         sqlUpdate, [NSString safeSqlParam:callerID.number]];
        } else {
            sqlUpdate = [NSString stringWithFormat:@"%@ DELETE FROM CALLER WHERE number = '%@' AND cacheLevel != %d;",
                         sqlUpdate, [NSString safeSqlParam:callerID.number], CallerIDQueryMarkLevel];
        }
        
        
        sqlUpdate =  [NSString stringWithFormat:@"%@ INSERT OR IGNORE INTO CALLER (name,number,callerType,verifyType,markCount,dateTime,cacheLevel,vipID,versionTime) VALUES('%@','%@','%@',%d,%d,%d,%d,%d,'%@');",sqlUpdate,[NSString safeSqlParam:callerID.name],[NSString safeSqlParam:callerID.number],[NSString safeSqlParam:callerID.callerType],(callerID.isVerified ? 1 : 0), callerID.markCount,time,callerID.callerIDCacheLevel,callerID.vipID,[NSString safeSqlParam:callerID.versionTime]];
    }
    if ([sqlUpdate length] >0) {
        sqlUpdate = [NSString stringWithFormat:@"BEGIN TRANSACTION;%@;COMMIT;",sqlUpdate];
        __block BOOL ret = NO;
        [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
            char *errorMsg = NULL;
            int execResult = sqlite3_exec(db, [sqlUpdate UTF8String], NULL,NULL, &errorMsg);
            if (execResult == SQLITE_OK) {
                ret = YES;
                cootek_log(@"excute ADD CALLER update = %d",execResult);
            }
            sqlite3_free(errorMsg);
        }];
        if (ret && isNotify) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_DID_CALLERIDS_CHANGED
                                                                object:nil
                                                              userInfo:nil];
        }
    }
}

+ (void)addCallers:(NSArray *)callers
{
    [self addCallers:callers notify:YES];
}

+ (CallerIDInfoModel *)queryCacheCallerIdByNumber:(NSString *)number
{
    if(!SmartDailerSettingModel.isChinaSim){
        return nil;
    }
    int time = [[NSDate date] timeIntervalSince1970];
    NSString *sql = [NSString stringWithFormat:@"SELECT name,number,callerType,verifyType,markCount,cacheLevel,vipID,versionTime FROM CALLER WHERE (((cacheLevel>0 and cacheLevel < 4) and (dateTime + 15*24*3600) >%d) or (cacheLevel = 0 and (dateTime + 1*24*3600) >%d) or (cacheLevel = 5 and (dateTime + 30*24*3600) >%d) or cacheLevel = 4) and number = '%@'",time,time,time,[NSString safeSqlParam:number]];
    __block CallerIDInfoModel *callerID  = nil;
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                callerID = [[CallerIDInfoModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    callerID.name = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                    callerID.number = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                         encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    callerID.callerType = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,2)
                                                             encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 7)!=NULL)
                {
                    callerID.versionTime = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,7)
                                                              encoding:NSUTF8StringEncoding];
                }
                callerID.isVerified = sqlite3_column_int(stmt, 3) > 0;
                callerID.markCount = sqlite3_column_int(stmt, 4);
                callerID.callerIDCacheLevel = sqlite3_column_int(stmt, 5);
                callerID.vipID = sqlite3_column_int(stmt, 6);
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return callerID;
}

+ (void)deleteMarkedCallerForNumber:(NSString *)number
 {
    NSString *sqlUpdate = @"";
    sqlUpdate =  [NSString stringWithFormat:@"DELETE FROM CALLER WHERE number = '%@' and cacheLevel=%d",[NSString safeSqlParam:number],CallerIDQueryMarkLevel];
    if ([sqlUpdate length] >0) {
        __block BOOL ret = NO;
        [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
            char *errorMsg = NULL;
            int execResult = sqlite3_exec(db, [sqlUpdate UTF8String], NULL,NULL, &errorMsg);
            if (execResult == SQLITE_OK) {
                ret = YES;
                NSLog(@"excute deleteMarkedCallerForNumber = %d sql =%@",execResult,sqlUpdate);
            }
            sqlite3_free(errorMsg);
        }];
        if (ret) {
            [[NSNotificationCenter defaultCenter] postNotificationName:N_DID_CALLERIDS_CHANGED
                                                                object:nil
                                                              userInfo:nil];
        }
    }
}

@end
