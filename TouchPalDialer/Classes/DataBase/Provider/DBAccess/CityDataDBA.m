//
//  CityDataDBA.m
//  TouchPalDialer
//
//  Created by xie lingmei on 12-9-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CityDataDBA.h"
#import "DataBaseModel.h"
#import "CallerDBA.h"
#import "NSString+SqlParam.h"

@implementation CityDataDBA

+(YellowCityModel *)queryUnstallCityById:(NSString *)cityId
{
    NSString *sql =[NSString stringWithFormat:@"SELECT cityId,name,mainFilePath,updateFilePath,mainVersion,updateVersion,mainSize,updateSize FROM CITY where cityId = '%@' and isDownload = 0",[NSString safeSqlParam:cityId]];
    __block YellowCityModel *city = nil;
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            if (result == SQLITE_ROW) {
                city = [[YellowCityModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    city.cityID = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                     encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                    city.cityName = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    city.mainPath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 3)!=NULL)
                {
                    city.updatePath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3)
                                                         encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 4)!=NULL)
                {
                    city.mainVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4)
                                                          encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 5)!=NULL)
                {
                    city.updateVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5)
                                                            encoding:NSUTF8StringEncoding];
                }
                city.mainSize = sqlite3_column_int(stmt, 6);
                city.updateSize = sqlite3_column_int(stmt, 7);
                city.isDown = YES;
            }
        }
        sqlite3_finalize(stmt);
    }];
    return city;
}

+ (YellowCityModel *)queryInstallCityById:(NSString *)cityId
{
    NSString *sql =[NSString stringWithFormat:@"SELECT cityId,name,mainFilePath,updateFilePath,mainVersion,updateVersion,mainSize,updateSize FROM CITY where cityId = '%@' and isDownload = 1",[NSString safeSqlParam:cityId]];
    __block YellowCityModel *city = nil;
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            if (result == SQLITE_ROW) {
                city = [[YellowCityModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    city.cityID = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                     encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                    city.cityName = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    city.mainPath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 3)!=NULL)
                {
                    city.updatePath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3)
                                                         encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 4)!=NULL)
                {
                    city.mainVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4)
                                                          encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 5)!=NULL)
                {
                    city.updateVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5)
                                                            encoding:NSUTF8StringEncoding];
                }
                city.mainSize = sqlite3_column_int(stmt, 6);
                city.updateSize = sqlite3_column_int(stmt, 7);
                city.isDown = YES;
            }
        }
        sqlite3_finalize(stmt);
    }];
    return city;
}

+ (NSArray *)queryAllUnloadCity
{
    NSString *sql = @"SELECT cityId,name,mainFilePath,updateFilePath,mainVersion,updateVersion,mainSize,updateSize FROM CITY where isDownload = 0 and cityId not in(select cityId from City where isDownload = 1)";
    NSMutableArray *citys=[NSMutableArray arrayWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                YellowCityModel *city = [[YellowCityModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    city.cityID = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                     encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                    city.cityName = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    city.mainPath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 3)!=NULL)
                {
                    city.updatePath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3)
                                                         encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 4)!=NULL)
                {
                    city.mainVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4)
                                                          encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 5)!=NULL)
                {
                    city.updateVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5)
                                                            encoding:NSUTF8StringEncoding];
                }
                city.mainSize = sqlite3_column_int(stmt, 6);
                city.updateSize = sqlite3_column_int(stmt, 7);
                city.isDown = NO;
                [citys addObject:city];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return citys;
}

+ (NSArray *)queryAllValidateUnloadCity
{
    NSString *sql = @"SELECT cityId,name,mainFilePath,updateFilePath,mainVersion,updateVersion,mainSize,updateSize FROM CITY where isDownload = 0 and cityId not in(select cityId from City where isDownload = 1) and mainVersion !='' and updateVersion!=''";
    NSMutableArray *citys=[NSMutableArray arrayWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                YellowCityModel *city = [[YellowCityModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    city.cityID = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                     encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                    city.cityName = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    city.mainPath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 3)!=NULL)
                {
                    city.updatePath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3)
                                                         encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 4)!=NULL)
                {
                    city.mainVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4)
                                                          encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 5)!=NULL)
                {
                    city.updateVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5)
                                                            encoding:NSUTF8StringEncoding];
                }
                city.mainSize = sqlite3_column_int(stmt, 6);
                city.updateSize = sqlite3_column_int(stmt, 7);
                city.isDown = NO;
                [citys addObject:city];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return citys;
}

+ (NSArray *)queryAllInstallCity
{
    NSString *sql = @"SELECT cityId,name,mainFilePath,updateFilePath,mainVersion,updateVersion,mainSize,updateSize FROM CITY where isDownload = 1";
    NSMutableArray *citys=[NSMutableArray arrayWithCapacity:1];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            while (result == SQLITE_ROW) {
                YellowCityModel *city = [[YellowCityModel alloc] init];
                if((char *)sqlite3_column_text(stmt, 0)!=NULL)
                {
                    city.cityID = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0)
                                                     encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 1)!=NULL)
                {
                    city.cityName = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 2)!=NULL)
                {
                    city.mainPath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2)
                                                       encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 3)!=NULL)
                {
                    city.updatePath = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3)
                                                         encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 4)!=NULL)
                {
                    city.mainVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4)
                                                          encoding:NSUTF8StringEncoding];
                }
                if((char *)sqlite3_column_text(stmt, 5)!=NULL)
                {
                    city.updateVersion = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5)
                                                            encoding:NSUTF8StringEncoding];
                }
                city.mainSize = sqlite3_column_int(stmt, 6);
                city.updateSize = sqlite3_column_int(stmt, 7);
                city.isDown = YES;
                [citys addObject:city];
                result = sqlite3_step(stmt);
            }
            sqlite3_finalize(stmt);
        }
    }];
    return citys;
}

+ (void)updateCity:(YellowCityModel *)city
{
    NSString *sql =[NSString stringWithFormat:@"UPDATE CITY SET mainFilePath = '%@' ,updateFilePath = '%@',mainVersion = '%@',updateVersion = '%@',mainSize = %d,updateSize = %d WHERE cityId = '%@' and isDownload = %d",[NSString safeSqlParam:city.mainPath],[NSString safeSqlParam:city.updatePath],[NSString safeSqlParam:city.mainVersion],[NSString safeSqlParam:city.updateVersion],city.mainSize,city.updateSize,[NSString safeSqlParam:city.cityID],city.isDown];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            cootek_log(@"update result = %d",result);
        }
    }];
}

+ (void)insertCity:(YellowCityModel *)city
{
    NSString *sql = @"INSERT INTO CITY(cityId,name,mainFilePath,updateFilePath,mainVersion,updateVersion,mainSize,updateSize,isDownload) VALUES(?,?,?,?,?,?,?,?,?)";
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            sqlite3_bind_text(stmt,1,[city.cityID UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt,2,[city.cityName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt,3,[city.mainPath UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt,4,[city.updatePath UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt,5,[city.mainVersion UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(stmt,6,[city.updateVersion UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(stmt,7,city.mainSize);
            sqlite3_bind_int(stmt,8,city.updateSize);
            sqlite3_bind_int(stmt,9,city.isDown);
            result = sqlite3_step(stmt);
            cootek_log(@"insertCity = %d",result);
        }
    }];
    if (city.isDown && ![city.cityID isEqualToString:KEY_NATIONAL_ID]) {
        [CallerDBA updateCacheAfterCityDown];
    }
}

+ (void)deleteInstallCityById:(NSString *)cityId
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM CITY WHERE cityId = '%@' and isDownload = 1",[NSString safeSqlParam:cityId]];
    [DataBaseModel execute:DataBaseExecutionModeForeground inDatabase:^(sqlite3* db) {
        sqlite3_stmt *stmt = NULL;
        NSInteger result = sqlite3_prepare_v2(db,[sql UTF8String], -1, &stmt, NULL);
        if (result == SQLITE_OK) {
            result = sqlite3_step(stmt);
            cootek_log(@"deleteInstallCityById = %d",result);
        }
    }];
}

+ (void)deleteInstallCitys:(NSArray *)citys
{
    if ([citys count] == 0) {
        return;
    }
    NSMutableString *sql = [NSMutableString string];
    for (YellowCityModel *city in citys) {
        [sql appendFormat:@"DELETE FROM CITY WHERE cityId = '%@' and isDownload = 1;",[NSString safeSqlParam:city.cityID]];
    }
    if ([sql length] == 0) {
        return;
    }
    sql = [NSMutableString stringWithFormat:@"BEGIN TRANSACTION;%@;COMMIT;",sql];
    [DataBaseModel execute:DataBaseExecutionModeBackground inDatabase:^(sqlite3* db) {
        char *errorMsg = NULL;
        int result = sqlite3_exec(db, [sql UTF8String], NULL, NULL, &errorMsg);
        cootek_log(@"deleteInstallCitys, sql: %@,%d", sql,result);
        sqlite3_free(errorMsg);
    }];
}

@end
