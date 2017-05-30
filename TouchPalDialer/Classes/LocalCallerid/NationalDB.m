//
//  NationalDB.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/6/10.
//
//

#import "NationalDB.h"

@implementation NationalDB

@synthesize dbType;
@synthesize colNumber;
@synthesize colTitle;
@synthesize colTag;

- (instancetype)initWithDBFile:(NSString *)dbFile {
    self = [super initWithDBFile:dbFile];
    if (self) {
        self.dbType = NATIONAL_TABLE;
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
        }
    }
    @catch (NSException *exception) {
    }
    return item;
}

@end
