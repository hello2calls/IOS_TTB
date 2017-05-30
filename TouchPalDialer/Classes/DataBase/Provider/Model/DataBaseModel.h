//
//  DataBaseModel.h
//  AddressBook_DB
//
//  Created by Alice on 11-7-7.
//  Copyright 2011 CooTek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "WhereDataModel.h"
#import "LabelDataModel.h"
#import "BasicUtil.h"
#import "AdvancedCalllog.h"


typedef enum {
    DataBaseExecutionModeNew,
    DataBaseExecutionModeForSearch,
    DataBaseExecutionModeForeground,
    DataBaseExecutionModeBackground,
} DataBaseExecutionMode;

@interface DataBaseModel : NSObject {
	sqlite3 *databaseForSearch;
	sqlite3 *foregroundDatabase;
    sqlite3 *backgroundDatabase;
}

@property (assign) sqlite3 *databaseForSearch;
@property (assign) sqlite3 *foregroundDatabase;
@property (assign) sqlite3 *backgroundDatabase;

+ (BOOL)executeSingleScript:(const char*)script OnDatabase:(sqlite3*)db;

+ (BOOL)executeScriptOnDatabase:(sqlite3*)db
            ForOriginalVersion:(NSInteger) originalVersion;

- (void)initSqliteDataBase;

+ (NSString *)getKGroupByKeyPersonId;

+ (NSString *)getKGroupByKeyPhoneNumber;

+ (NSString *)getKGroupByKeyCallTime;

+ (NSString *)getKOrderByKeyCallTime;

+ (NSString *)getKOrderByKeyCallCount;

+ (NSString *)getKOrderByKeyValueDesc;

+ (NSString *)getKOrderByKeyValueAsc;

+ (NSString *)getKWhereKeyCallTime;

+ (NSString *)getKWhereKeyPhoneNumber;

+ (NSString *)getKWhereKeyPersonID;

+ (NSString *)getKWhereKeyCallType;

+ (NSString *)getKWhereSameDay;

+ (NSString *)getKWhereOperationLike;

+ (NSString *)getKWhereOperationLargerThen;

+ (NSString *)getKWhereOperationEqual;

+ (NSString *)getKWhereOperationSmall;

+ (NSString *)getKWhereOperationLarger;

+ (DataBaseModel *)instance;

+ (BOOL)isExistsWhereKey:(NSString *)fieldKey;

+ (NSString *)getWhereCause:(NSArray *)where
                 DeleteFlag:(BOOL)flag;

+ (BOOL )getKWhereKeyType:(NSString *)whereby_key;

+ (NSString *)switchOperString:(NSString *)oper
                  CompareValue:(NSString *)value
                       withKey:(NSString *)key;

+ (BOOL)isExistsGroupByKey:(NSString *)fieldKey;

+ (NSString *)getGroupByCause:(NSArray *)groupby;

+ (BOOL)isExistsOrderByKey:(NSString *)fieldKey;

+ (NSString *)getOrderByCause:(NSArray *)orderby;

+ (NSString *)getFormatNumber:(NSString *)number;

+ (void) execute:(DataBaseExecutionMode) mode
      inDatabase:(void (^)(sqlite3* db))block;

@end
