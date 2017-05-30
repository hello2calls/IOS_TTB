
//  SQLiteManager.m
//  Dialer

//  Created by Jaison_Li_893 on 11-4-21.
//  Copyright 2011 CooTek. All rights reserved.


#import "FavoritesDBA.h"
#import <sqlite3.h>
#import "DataBaseModel.h"
#import "PersonDBA.h"
#import "consts.h"
#import "ContactCacheDataManager.h"

@implementation FavoritesDBA
//Description:get Favorites List
//Input:nil
//return:NSArray
+ (NSArray *)getFavoriteList
{
    __block NSMutableArray *favoriteList = nil;
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        if(!db) {
            favoriteList = nil;
            return;
        }
        sqlite3_stmt *stmt;
        const char *sql = "SELECT recordId FROM	favorite order by createTime asc";
		if (sqlite3_prepare_v2(db,sql, -1, &stmt, nil) != SQLITE_OK) {
			favoriteList = nil;
		}else {
			favoriteList = [[NSMutableArray alloc] init];
			while (sqlite3_step(stmt) == SQLITE_ROW) {
				[favoriteList addObject:[NSNumber numberWithInteger:sqlite3_column_int(stmt, 0)]];
			}
			sqlite3_finalize(stmt);
		}
    }];
    return favoriteList;
}

//Description:the person is in Favorites 
//Input:recordID
//return:bool
+ (BOOL)isExistFavorite:(NSInteger)recordId
{
	if (recordId <= 0) {
        return NO;
    }
	__block BOOL result = NO;
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        const char *existSql = "SELECT 1 FROM favorite WHERE recordId = ?";
        if (sqlite3_prepare_v2(db, existSql, -1, &stmt, nil) == SQLITE_OK) {
            sqlite3_bind_int(stmt,1,recordId);
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                result = YES;
            }
        }
        sqlite3_finalize(stmt);
    }];
	return result;
}

//Description:add person to Favorites 
//Input:recordID
//return:bool
+ (BOOL)addFavoriteByRecordId:(NSInteger)recordId
{
	if (recordId <= 0) {
        return NO;
    }
    
	if ([self isExistFavorite:recordId]) {
		return NO;
	}
	__block BOOL result = YES;
    
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt;
        const char *createSql = "INSERT INTO favorite(recordId,createTime) VALUES(?,datetime())";
        if (sqlite3_prepare_v2(db, createSql, -1, &stmt, nil) == SQLITE_OK) {
            sqlite3_bind_int(stmt,1,recordId);
            if (sqlite3_step(stmt) == SQLITE_ERROR) {
                result = NO;
            }
        }else {
            result = NO;
        }
        
        sqlite3_finalize(stmt);
    }];
	return result;
}

//Description:delete person from Favorites 
//Input:recordID
//return:bool
+ (BOOL)removeFavoriteByRecordId:(NSInteger)recordId
{
	if (recordId <= 0) {
        return NO;
    }
    
	if (![self isExistFavorite:recordId]) {
		return NO;
	}
	__block BOOL result = YES;
    
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        const char *deleteSql = "DELETE FROM favorite WHERE recordId = ?";
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(db, deleteSql, -1, &stmt, nil) == SQLITE_OK) {
            sqlite3_bind_int(stmt,1,recordId);
            if (sqlite3_step(stmt) == SQLITE_ERROR) {
                result = NO;
            }
        }else {
            result = NO;
        }
        sqlite3_finalize(stmt);
    }];
	return result;
}

@end
