//
//  TouchpalHistoryDBA.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/26.
//
//

#import "TouchpalHistoryDBA.h"
#import "DataBaseModel.h"

@implementation TouchpalHistoryDBA

+ (NSInteger)getLatestDatetime:(NSInteger)bonusType{
    __block NSInteger lastDatetTime = 0;
    
    NSString *sql = [NSString stringWithFormat:@"select datetime from touchpal_history where bonus_type=%d order by datetime desc limit 1",bonusType];
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                lastDatetTime = sqlite3_column_int(stmt, 0);
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];

    return lastDatetTime;
}


+ (BOOL)insertHistory:(C2CHistoryInfo *)info{
    __block BOOL result = NO;
    
    if ( info == nil || info.eventName == nil){
        return result;
    }
    
    NSInteger lastDatetime = [self getLatestDatetime:info.datetime];
    
    if ( info.datetime < lastDatetime ){
        return result;
    }
    
    NSString *sqlInsert = [NSString stringWithFormat:@"INSERT INTO touchpal_history(event_name,bonus,bonus_type,datetime,pop) VALUES('%@',%d,%d,%d,%d)", info.eventName,info.bonus,info.bonusType,info.datetime,info.pop];
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
        char *errorMsg = NULL;
        int execResult = sqlite3_exec(db, [sqlInsert UTF8String], NULL,NULL, &errorMsg);
        if (execResult == SQLITE_OK) {
            result = YES;
            cootek_log(@"sqlInsert insert history result = %d sql =%@",execResult,sqlInsert);
        }
        sqlite3_free(errorMsg);
    }];
    
    return result;
}


+ (NSMutableArray *) getAllTouchpalHistory:(NSInteger)bonusType{
    NSString *sql = [NSString stringWithFormat:@"select * from touchpal_history where bonus_type=%d order by datetime desc limit 0,100",bonusType];
    NSMutableArray *touchpalHistoryArray = [NSMutableArray array];
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                NSString *eventName = @"";
                if ((char *)sqlite3_column_text(stmt, 1)!=NULL){
                    eventName = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
                }
                NSInteger bonus = sqlite3_column_int(stmt, 2);
                NSInteger bonusType = sqlite3_column_int(stmt, 3);
                NSInteger datetime = sqlite3_column_int(stmt, 4);
                NSInteger pop = sqlite3_column_int(stmt, 5);
                
                C2CHistoryInfo *historyInfo = [[C2CHistoryInfo alloc] init];
                historyInfo.eventName = eventName;
                historyInfo.bonus = bonus;
                historyInfo.bonusType = bonusType;
                historyInfo.datetime = datetime;
                historyInfo.pop = pop;
                
                [touchpalHistoryArray addObject:historyInfo];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return touchpalHistoryArray;
}

+ (void)deleteAllData{
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
        NSString *sqlDelete = @"delete from touchpal_history";
        char *errorMsg = NULL;
        int execResult = sqlite3_exec(db, [sqlDelete UTF8String], NULL,NULL, &errorMsg);
        if (execResult == SQLITE_OK) {
            cootek_log(@"excute touchpal_history delete = %d sql =%@",execResult,sqlDelete);
        }
        sqlite3_free(errorMsg);
    }];
}

@end
