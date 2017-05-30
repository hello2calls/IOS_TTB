//
//  NameUpdateDB.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/10.
//
//

#import "NameUpdateDB.h"

@implementation NameUpdateDB

@synthesize colUpdateType;
@synthesize dbType;
@synthesize colNumber;
@synthesize colTitle;
@synthesize colTag;

- (instancetype)initWithDBFile:(NSString *)dbFile {
    self = [super initWithDBFile:dbFile];
    if (self) {
        self.colUpdateType = UPDATE_TYPE;
        self.dbType = NAME_UPDATE_TABLE;
    }
    return self;
}

- (TableItem *)convertQueryResult:(FMResultSet *)result {
    TableItem *item = [[TableItem alloc]init];
    @try {
        if (result && [result next]) {
            item.number = [result longLongIntForColumn:colNumber];
            item.name = [result dataForColumn:colTitle];
            item.tag = [result intForColumn:colTag];
            item.updateType = [result intForColumn:colUpdateType];
        }
    }
    @catch (NSException *exception) {
    }
    
    return item;
}

@end
