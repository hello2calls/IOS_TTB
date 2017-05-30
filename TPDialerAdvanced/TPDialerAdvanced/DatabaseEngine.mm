//
//  DatabaseEngine.m
//  TPDialerAdvanced
//
//  Created by Elfe Xu on 12-10-9.
//
//

#import "CStringUtils.h"
#import "NSString+SqlParam.h"
#import "DatabaseEngine.h"
#import <sqlite3.h>
#import "Util.h"
#import "AdvancedSettingKeys.h"
#import "AdvancedSettingUtility.h"
#import "TPDialerAdvanced.h"



@implementation DatabaseEngine

+ (BOOL) openDataBase:(sqlite3**) db {
    NSString* database = [AdvancedSettingUtility mainDatabasePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:database]) {
        cootek_log(@"No database file %@.", database);
        return NO;
    }
    
    int ret = sqlite3_open([database UTF8String], db);
    if(SQLITE_OK != ret) {
        cootek_log(@"Failed to open database. Error code is %d", ret);
        sqlite3_close(*db);
    } else {
        sqlite3_busy_timeout(*db, 1000);
    }
    
    return (SQLITE_OK == ret);
}

+ (NSArray*) queryAllCityFiles {
    cootek_log_function;
    NSMutableArray* cities = [NSMutableArray arrayWithCapacity:1];
    
    sqlite3* db;
    if([self openDataBase:&db]) {
        NSString *sql = @"SELECT mainFilePath FROM CITY where isDownload = 1";
        sqlite3_stmt *stmt = NULL;
        
        int ret = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (ret == SQLITE_OK) {
            ret = sqlite3_step(stmt);
            while (ret == SQLITE_ROW) {
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    NSString* cityPath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                            encoding:NSUTF8StringEncoding];
                    
                    [cities addObject:cityPath];
                }
                ret = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
        sqlite3_close(db);
        
        cootek_log(@"All cities: %@", cities);
    }
    
    return cities;
}

+ (BOOL) fillNumberInfo:(NumberInfoModel*) infoData {
    cootek_log_function;
    
    BOOL found = NO;
    sqlite3* db;
    if(![self openDataBase:&db]) {
        return NO;
    }
    
    cootek_log(@"db opened");
    int time = [[NSDate date] timeIntervalSince1970];
    NSString *sql = [NSString stringWithFormat:@"SELECT name,number,callerType,verifyType,markCount,cacheLevel,vipID,versionTime FROM CALLER WHERE (number = ('%@')) and ((cacheLevel>0 and cacheLevel < 4) and ((dateTime + 15*24*3600) >%d) or (cacheLevel = 0 and (dateTime + 1*24*3600) >%d) or (cacheLevel = 5 and (dateTime + 30*24*3600) >%d) or (cacheLevel = 4))", infoData.normalizedNumber, time,time,time];
    sqlite3_stmt *stmt;
    NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
    cootek_log(@"sql: %@", sql);
    cootek_log(@"search result: %d", result);
    if (result == SQLITE_OK) {
        result = sqlite3_step(stmt);
        while (result == SQLITE_ROW) {
            const char* name = (const char*) sqlite3_column_text(stmt, 0);
            if (name != NULL) {
                infoData.name = CStringUtils::cstr2nsstr(name);
            }
            NSLog(@"%s", sqlite3_column_text(stmt, 1));
            const char* classify = (const char*) sqlite3_column_text(stmt, 2);
            if (classify != NULL) {
                infoData.classify = CStringUtils::cstr2nsstr(classify);
            }
            infoData.markCount = sqlite3_column_int(stmt, 4);
            result = sqlite3_step(stmt);
            infoData.isCallerId = YES;
            found = YES;
        }
        sqlite3_finalize(stmt);
    }

    sqlite3_close(db);
    return found;
}

+(void) addData:(NumberInfoModel *)infoData {
    sqlite3* db;
    if(![self openDataBase:&db]) {
        return;
    }
    
    int time = [[NSDate date] timeIntervalSince1970];
    NSString* sqlUpdate =  [NSString stringWithFormat:@"DELETE FROM CALLER WHERE number = '%@'; INSERT OR IGNORE INTO CALLER (name,number,callerType,verifyType,markCount,dateTime,cacheLevel,vipID,versionTime) VALUES('%@','%@','%@',%d,%d,%d,%d,%d,'%@');", [NSString safeSqlParam:infoData.normalizedNumber], [NSString safeSqlParam:infoData.name], [NSString safeSqlParam:infoData.normalizedNumber], [NSString safeSqlParam:infoData.classify], (infoData.verified ? 1 : 0), infoData.markCount, time, infoData.cacheLevel, infoData.vipId, [NSString safeSqlParam:infoData.versionTime]];
    char *errorMsg = NULL;
    int execResult = sqlite3_exec(db, [sqlUpdate UTF8String], NULL,NULL, &errorMsg);
    if (execResult == SQLITE_OK) {
        cootek_log(@"excute ADD CALLER update = %d sql =%@",execResult,sqlUpdate);
    }
    sqlite3_free(errorMsg);
    sqlite3_close(db);
}

@end
