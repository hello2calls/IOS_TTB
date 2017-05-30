//
//  TouchpalNumbersDBA.m
//  TouchPalDialer
//
//  Created by Liangxiu on 14-11-19.
//
//

#import "TouchpalNumbersDBA.h"
#import "PhoneNumber.h"
#import "DataBaseModel.h"

@implementation TouchpalNumbersDBA
+ (NSInteger)insertNumber:(NSString *)number andIfCootekUser:(BOOL)ifCootekUser {
    __block NSInteger resultCode = 0;
    if (number.length == 0) {
        return 0;
    }
    NSString *normalNumber = [PhoneNumber getCNnormalNumber:number];
    if (![normalNumber hasPrefix:@"+861"] || normalNumber.length != 14) {
        return 0;
    }
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO touchpal_numbers(normalize_number,if_cootek_user) VALUES('%@',%d)", normalNumber,ifCootekUser];
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
        NSString *sqlSearch = [NSString stringWithFormat:@"select * from touchpal_numbers where normalize_number = '%@'", normalNumber];
        sqlite3_stmt *stmt;
        BOOL found = NO;
        int result = sqlite3_prepare_v2(db,[sqlSearch UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                if ((BOOL)sqlite3_column_int(stmt, 2) != ifCootekUser ){
                    NSString *sqlUpdate = [NSString stringWithFormat:@"update touchpal_numbers set if_cootek_user = %d where normalize_number = '%@' ",ifCootekUser,normalNumber];
                    char *errMsgUpdate = NULL;
                    int updateResult = sqlite3_exec(db, [sqlUpdate UTF8String], NULL, NULL, &errMsgUpdate);
                    cootek_log(@"update touchpal_numbers set if_cootek_user failed with error: %s, sql: %@ result: %d", errMsgUpdate, sqlUpdate, updateResult);
                    sqlite3_free(errMsgUpdate);
                    
                    resultCode = 1;
                }
                sqlite3_finalize(stmt);
                found = YES;
            }
        }
        if (!found) {
            char *errorMsg = NULL;
            result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &errorMsg);
            cootek_log(@"insert touchpal numbers failed with error: %s, sql: %@ result: %d", errorMsg, sql, result);
            sqlite3_free(errorMsg);
            resultCode = 1;
        }
    }];
    return resultCode;
}

+ (NSInteger)isNumberRegistered:(NSString *)number {
    if (number.length == 0) {
        return NO;
    }
    NSString *normalNumber = [PhoneNumber getCNnormalNumber:number];
    if (![normalNumber hasPrefix:@"+"]) {
        return NO;
    }
    __block NSInteger found = -1;
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
        NSString *sqlSearch = [NSString stringWithFormat:@"select * from touchpal_numbers where normalize_number = '%@'", normalNumber];
        sqlite3_stmt *stmt;
        int result = sqlite3_prepare_v2(db,[sqlSearch UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                found = (NSInteger)sqlite3_column_int(stmt, 2);
                sqlite3_finalize(stmt);
            }
        }
    }];
    return found;
}


+ (NSMutableDictionary *) getAllTouchPalNumbers{
    NSString *sql = [NSString stringWithFormat:@"select normalize_number,if_cootek_user from touchpal_numbers"];
    NSMutableDictionary *touchpalNumbersDic = [NSMutableDictionary dictionary];
    [DataBaseModel execute:DataBaseExecutionModeForSearch inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                NSString *normalLizeNumber = @"";
                if ((char *)sqlite3_column_text(stmt,0)!=NULL)
                {
                    normalLizeNumber = [NSString stringWithCString:(char *)sqlite3_column_text(stmt,0) encoding:NSUTF8StringEncoding];
                }
                BOOL ifCootekUser = sqlite3_column_int(stmt, 1);
                [touchpalNumbersDic setObject:@(ifCootekUser) forKey:normalLizeNumber];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return touchpalNumbersDic;
}
@end
