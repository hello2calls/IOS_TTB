//
//  BaseDB.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//

#import "BaseDB.h"

@implementation BaseDB

@synthesize dbFile;
@synthesize tableName;
@synthesize colNumber;
@synthesize colTitle;
@synthesize colTag;
@synthesize versionTableName;
@synthesize colRowVersion;
@synthesize colVersion;
@synthesize database;
@synthesize isDBOpen;

- (instancetype)initWithDBFile:(NSString *)db {
    self = [super init];
    if (self) {
        self.dbFile = db;
        self.tableName = CALLERID_TABLE_NAME;
        self.colNumber = NUMBER_NAME;
        self.colTitle = TITLE_NAME;
        self.colTag = TAG_NAME;
        self.versionTableName = VERSION_TABEL_NAME;
        self.colRowVersion = VERSION_ROW_NAME;
        self.colVersion = VERSION_NAME;
    }
    return self;
}

- (NSString *)getDBFilePath {
    return dbFile;
}

- (DataBaseTable)getDBType {
    return NAME_TABLE;
}

- (BOOL)connectDataBase {
    self.database = [FMDatabase databaseWithPath:dbFile];
    if (database && [database open]) {
        isDBOpen = YES;
        return YES;
    }
    return NO;
}

- (BOOL)isConnectAlive {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", @"version_tabel"];
    FMResultSet *result = [database executeQuery:sql];
    @try {
        if (result && [result next]) {
            return YES;
        }
    }
    @catch (NSException *exception) {
    }
    
    return NO;
}

- (BOOL)close {
    if (database) {
        if ([database close]) {
            isDBOpen = NO;
            return YES;
        } else {
            isDBOpen = YES;
            return NO;
        }
    }
    return YES;
}

- (BOOL)isClosed {
    return !isDBOpen;
}

- (BOOL)reconnectDatabase {
    if (database && isDBOpen) {
        [self close];
    }
    return [self connectDataBase];
}

- (BOOL)isTableExists:(NSString *)table {
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = %@", table];
    FMResultSet *result = [database executeQuery:sql];
    if (result) {
        @try {
            while ([result next]){
                // just print out what we've got in a number of formats.
                NSInteger count = [result intForColumn:@"count"];
                NSLog(@"isTableOK %d", count);
                
                if (0 == count){
                    return NO;
                } else{
                    return YES;
                }
            }

        }
        @catch (NSException *exception) {
        }
    }
    return NO;
}

- (TableItem *)queryCallerid:(long long)number{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE number = '%@'", tableName, [NSString stringWithFormat:@"%lld", number]];
    FMResultSet *result = [database executeQuery:sql];
    TableItem *item = [self convertQueryResult:result];

    return item;
}

- (TableItem*) convertQueryResult:(FMResultSet*)result {
    return nil;
}


- (NSString *)queryVersion:(NSString *)row {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", versionTableName, colRowVersion, row];
    FMResultSet *result = [database executeQuery:sql];
    NSString *version = @"";
    if (result) {
        @try {
            if ([result next]) {
                version = [result stringForColumn:colVersion];
            }
        }
        @catch (NSException *exception) {
            
        }
        
    }
    return version;
}

@end
