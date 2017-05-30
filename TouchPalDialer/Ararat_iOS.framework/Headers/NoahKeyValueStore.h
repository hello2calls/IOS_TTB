//
//  NoahKeyValueStore.h
//  NoahKeyValueStore
//
//  Created by SongchaoYuan on 15/8/24.
//  Copyright (c) 2015年 SongchaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoahKeyValueItem : NSObject

@property (nonatomic, assign) NSUInteger itemId;
@property (nonatomic, strong) id itemObject;
@property (nonatomic, strong) NSDate *createdTime;

@end

@interface NoahKeyValueStore : NSObject

- (id)initDBWithName:(NSString *)dbName;

- (id)initWithDBWithPath:(NSString *)dbPath;

- (void)createTableWithName:(NSString *)tableName;

- (BOOL)isTableExists:(NSString *)tableName;

- (void)clearTable:(NSString *)tableName;

- (void)close;

///************************ Put&Get methods *****************************************

- (void)putObject:(id)object intoTable:(NSString *)tableName;

- (void)putFirstObject:(id)object intoTable:(NSString *)tableName;

- (id)getObjectById:(NSUInteger)objectId fromTable:(NSString *)tableName;

- (NoahKeyValueItem *)getNoahKeyValueItemById:(NSUInteger)objectId fromTable:(NSString *)tableName;

- (void)putString:(NSString *)string intoTable:(NSString *)tableName;

- (NSString *)getStringById:(NSUInteger)stringId fromTable:(NSString *)tableName;

- (void)putNumber:(NSNumber *)number intoTable:(NSString *)tableName;

- (NSNumber *)getNumberById:(NSUInteger)numberId fromTable:(NSString *)tableName;

- (NSArray *)getAllItemsFromTable:(NSString *)tableName;

- (NSUInteger)getCountFromTable:(NSString *)tableName;

- (NSUInteger)getLatestIdFromTable:(NSString *)tableName;

- (void)deleteObjectById:(NSUInteger)objectId fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName;

- (void)deleteObjectByOldestCount:(NSUInteger)countNum fromTable:(NSString *)tableName;

@end
