//
//  ContactSmartSearchDBA.m
//  TouchPalDialer
//
//  Created by hengfengtian on 15/11/24.
//
//

#import "ContactSmartSearchDBA.h"
#import "DataBaseModel.h"
#import "OrlandoEngine.h"

@implementation ContactSmartSearchDBA

+ (void) increaseContactClickedTimes:(NSString *)query personId:(NSInteger)personId hitType:(NSInteger)hitType {
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
        NSString* select = [NSString stringWithFormat:@"select clicked_times from contact_smart_search where smart_search_key = '%@' and person_id = %d and hit_type = %d", query, personId, hitType];
        sqlite3_stmt* selectStmt;
        NSUInteger selectResult = sqlite3_prepare_v2(db, [select UTF8String], -1, &selectStmt, NULL);
        if (selectResult == SQLITE_OK && sqlite3_step(selectStmt) == SQLITE_ROW) {
            NSInteger times = sqlite3_column_int(selectStmt, 0);
            times++;
            [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
                NSString* update = [NSString stringWithFormat:@"update contact_smart_search set clicked_times = %d where smart_search_key = '%@' and person_id = %d and hit_type = %d", times, query, personId, hitType];
                char* errorMsg = NULL;
                int updateResult = sqlite3_exec(db, [update UTF8String], NULL, NULL, &errorMsg);
                if(updateResult == SQLITE_OK) {
                    cootek_log(@"update @% success", update);
                } else {
                    cootek_log(@"update @% errorMsg: %s", update, errorMsg);
                }
                sqlite3_free(errorMsg);
            }];
        } else {
            [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
                NSString* insert = [NSString stringWithFormat:@"insert into contact_smart_search values('%@', %d, %d, 1)", query, personId, hitType];
                char* errorMsg = NULL;
                int result = sqlite3_exec(db, [insert UTF8String], NULL, NULL, &errorMsg);
                if(result == SQLITE_OK) {
                    cootek_log(@"insert @% success", insert);
                } else {
                    cootek_log(@"insert @% errorMsg: %s", insert, errorMsg);
                }
                sqlite3_free(errorMsg);
            }];
        }
        sqlite3_finalize(selectStmt);
    }];
}

+ (void) queryAndInitContactClickedTimes {
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3 *db) {
        NSString* select = [NSString stringWithFormat:@"select * from contact_smart_search"];
        sqlite3_stmt* selectStmt;
        NSUInteger selectResult = sqlite3_prepare_v2(db, [select UTF8String], -1, &selectStmt, NULL);
        if(selectResult == SQLITE_OK) {
            NSMutableArray* searchKeyArray = [NSMutableArray array];
            NSMutableArray* personIdArray = [NSMutableArray array];
            NSMutableArray* hitTypeArray = [NSMutableArray array];
            NSMutableArray* clickedTimesArray = [NSMutableArray array];
            selectResult = sqlite3_step(selectStmt);
            while (selectResult == SQLITE_ROW) {
                NSString* query = [NSString stringWithCString:(char*)sqlite3_column_text(selectStmt, 0) encoding:NSUTF8StringEncoding];
                long personId = sqlite3_column_int64(selectStmt, 1);
                int hitType = sqlite3_column_int(selectStmt, 2);
                int clickedTimes = sqlite3_column_int(selectStmt, 3);
                [searchKeyArray addObject:query];
                [personIdArray addObject:[NSNumber numberWithLong:personId]];
                [hitTypeArray addObject:[NSNumber numberWithInt:hitType]];
                [clickedTimesArray addObject:[NSNumber numberWithInt:clickedTimes]];
                selectResult = sqlite3_step(selectStmt);
            }
            [[OrlandoEngine instance] initSmartSearchIndex:searchKeyArray personIdArray:personIdArray hitTypeArray:hitTypeArray clickedTimesArray:clickedTimesArray];
        }
        sqlite3_finalize(selectStmt);
    }];
}

@end
