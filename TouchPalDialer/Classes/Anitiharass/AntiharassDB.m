//
//  AntiharassDB.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/8.
//
//

#import "AntiharassDB.h"
#import "PhoneConvertUtil.h"

@implementation AntiharassDB

- (instancetype) initWithDBFile:(NSString *)dbFile{
    self = [super init];
    if ( self ){
        self.dbFile = dbFile;
        self.tableName = CALLERID_TABLE_NAME;
        self.colNumber = CALLER_NUMBER;
        self.colName = CALLER_NAME;
        self.colTag = CALLER_TAG;
        self.versionTableName = VERSION_TABLE_NAME;
        self.colRowVersion = VERSION_ROW;
        self.colVersion = VERSION;
    }
    return self;
}

- (NSArray *) queryAllAntiharassInfo{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:6000];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@", self.tableName,self.colTag];
    FMResultSet *result = [self.database executeQuery:sql];
    if (result) {
        @try {
            while ([result next]){
                AntiharassInfo *info = [[AntiharassInfo alloc]init];
                long long parseNumber = [result longLongIntForColumn:self.colNumber];
                info.number = [PhoneConvertUtil LongToNSString:parseNumber];
                info.tag = [result intForColumn:self.colTag];
                [array addObject:info];
            }
        }
        @catch (NSException *exception) {
        }
    }
    return array;
}

#pragma mark AntiharassDBInteface

- (NSString *)getDBFilePath{
    return self.dbFile;
}

- (BOOL)connectDataBase {
    self.database = [FMDatabase databaseWithPath:self.dbFile];
    if (self.database && [self.database open]) {
        self.isDBOpen = YES;
        return YES;
    }
    return NO;
}

- (BOOL)isClosed {
    return !self.isDBOpen;
}

- (BOOL)close {
    if (self.database) {
        if ([self.database close]) {
            self.isDBOpen = NO;
            return YES;
        } else {
            self.isDBOpen = YES;
            return NO;
        }
    }
    return YES;
}

- (BOOL)reconnectDatabase {
    if (self.database && self.isDBOpen) {
        [self close];
    }
    return [self connectDataBase];
}


- (BOOL)isConnectAlive {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", VERSION_TABLE_NAME];
    FMResultSet *result = [self.database executeQuery:sql];
    @try {
        if (result && [result next]) {
            return YES;
        }
    }
    @catch (NSException *exception) {
    }
    
    return NO;
}

- (NSString *)queryVersion:(NSString *)row {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", self.versionTableName, self.colRowVersion, row];
    FMResultSet *result = [self.database executeQuery:sql];
    NSString *version = @"";
    if (result) {
        @try {
            if ([result next]) {
                version = [result stringForColumn:self.colVersion];
            }
        }
        @catch (NSException *exception) {
            
        }
        
    }
    return version;
}

@end
