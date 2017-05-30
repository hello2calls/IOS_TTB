//
//  UsageRecordDataKV.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/9/2.
//
//

#import "UsageRecordDataKV.h"

@implementation UsageRecordDataKV

- (id)initWithKey:(id)key withValue:(id)value {
    self = [super init];
    if (self) {
        self.recordKey = key;
        self.recordValue = value;
    }
    return self;
}


@end
