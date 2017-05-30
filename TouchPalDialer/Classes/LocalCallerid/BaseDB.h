//
//  BaseDB.h
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/9.
//
//
#import "TableItem.h"
#import "FMDatabase.h"

#define CALLERID_TABLE_NAME @"callerid_table"
#define NUMBER_NAME @"number"
#define TITLE_NAME @"name"
#define TAG_NAME @"tag"
#define UPDATE_TYPE @"update_type"
#define VERSION_TABEL_NAME @"version_table"
#define VERSION_ROW_NAME @"version_row"
#define VERSION_NAME @"version"

typedef enum {
    UNKNOW_TABLE,
    NATIONAL_TABLE,
    NATIONAL_UPDATE_TABLE,
    NAME_TABLE,
    NAME_UPDATE_TABLE,
} DataBaseTable;

@protocol DataBaseInteface <NSObject>

- (NSString*)getDBFilePath;
- (DataBaseTable)getDBType;
- (BOOL)connectDataBase;
- (BOOL)isConnectAlive;
- (BOOL)close;
- (BOOL)isClosed;
- (BOOL)reconnectDatabase;
- (BOOL)isTableExists:(NSString*)tableName;
- (TableItem*)queryCallerid:(long long)number;
- (NSString*)queryVersion:(NSString*)row;

@end



@interface BaseDB : NSObject <DataBaseInteface>


@property (nonatomic, assign)BOOL isDBOpen;
@property (nonatomic, copy)NSString *dbFile;
@property (nonatomic, copy)NSString *tableName;
@property (nonatomic, copy)NSString *colNumber;
@property (nonatomic, copy)NSString *colTitle;
@property (nonatomic, copy)NSString *colTag;
@property (nonatomic, copy)NSString *versionTableName;
@property (nonatomic, copy)NSString *colRowVersion;
@property (nonatomic, copy)NSString *colVersion;
@property (nonatomic, retain)FMDatabase *database;

- (instancetype)initWithDBFile:(NSString*)dbFile;
- (TableItem*) convertQueryResult:(FMResultSet*)result;

@end
