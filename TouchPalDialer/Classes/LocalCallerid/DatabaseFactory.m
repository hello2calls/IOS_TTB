//
//  DatabaseFactory.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/10.
//
//

#import "DatabaseFactory.h"
#import "NationalDB.h"
#import "NameDB.h"
#import "NameUpdateDB.h"

@implementation DatabaseFactory

+ (BaseDB *)newDataBase:(NSString *)dbFilePath {
    DataBaseTable dbType = [self getTableType:dbFilePath];
    if (dbType == UNKNOW_TABLE) {
        return nil;
    } else if (dbType == NATIONAL_TABLE) {
        return [[NationalDB alloc]initWithDBFile:dbFilePath];
    } else if (dbType == NAME_TABLE) {
        return [[NameDB alloc]initWithDBFile:dbFilePath];
    } else if (dbType == NAME_UPDATE_TABLE) {
        return [[NameUpdateDB alloc]initWithDBFile:dbFilePath];
    }
    return nil;
    
}

+ (DataBaseTable)getTableType:(NSString*)dbFilePath {
    if (!dbFilePath || dbFilePath.length < 1) {
        return UNKNOW_TABLE;
    }
    NSString *fileName = [dbFilePath lastPathComponent];
    if ([fileName hasPrefix:@"1000_up"] && [fileName hasSuffix:@".db"]) {
        return NATIONAL_UPDATE_TABLE;
    } else if ([fileName hasPrefix:@"1000"] && [fileName hasSuffix:@".db"]) {
        return NATIONAL_TABLE;
    } else if ([fileName hasPrefix:@"1100"] && [fileName hasSuffix:@".db"]) {
        return NAME_TABLE;
    }
    return UNKNOW_TABLE;
}

@end
