//
//  AntiharassDB.h
//  TouchPalDialer
//
//  Created by game3108 on 15/9/8.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "AntiharassInfo.h"

#define CALLERID_TABLE_NAME @"callerid_table"
#define CALLER_NUMBER @"number"
#define CALLER_NAME @"name"
#define CALLER_TAG @"tag"

#define VERSION_TABLE_NAME @"version_table"
#define VERSION_ROW @"version_row"
#define VERSION @"version"

@protocol AntiharassDBInteface <NSObject>
- (NSString *)getDBFilePath;
- (BOOL)connectDataBase;
- (BOOL)isConnectAlive;
- (BOOL)isClosed;
- (BOOL)close;
- (BOOL)reconnectDatabase;
- (NSString *)queryVersion:(NSString *)row;
@end

@interface AntiharassDB : NSObject<AntiharassDBInteface>

@property (nonatomic,retain) FMDatabase *database;
@property (nonatomic,assign) BOOL isDBOpen;
@property (nonatomic,copy) NSString *dbFile;
@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, copy) NSString *colNumber;
@property (nonatomic, copy) NSString *colName;
@property (nonatomic, copy) NSString *colTag;
@property (nonatomic, copy) NSString *versionTableName;
@property (nonatomic, copy) NSString *colRowVersion;
@property (nonatomic, copy )NSString *colVersion;
- (instancetype) initWithDBFile:(NSString *)dbFile;
- (NSArray *) queryAllAntiharassInfo;
@end
