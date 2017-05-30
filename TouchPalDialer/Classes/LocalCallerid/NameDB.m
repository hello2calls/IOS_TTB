//
//  NameDB.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/10.
//
//

#import "NameDB.h"

@implementation NameDB

@synthesize colNumber;
@synthesize colTitle;
@synthesize colTag;
@synthesize dbType;

- (instancetype)initWithDBFile:(NSString *)dbFile {
    self = [super initWithDBFile:dbFile];
    if (self) {
        self.dbType = NAME_TABLE;
    }
    return self;
}

- (DataBaseTable)getDBType {
    return dbType;
}

- (TableItem *)convertQueryResult:(FMResultSet *)result {
    TableItem *item = [[TableItem alloc]init];
    @try {
        if (result && [result next]) {
            item.number = [result longLongIntForColumn:colNumber];
            item.name = [result dataForColumn:colTitle];
            item.tag = [result intForColumn:colTag];
        }
    }
    @catch (NSException *exception) {
    }
    return item;
}



@end
