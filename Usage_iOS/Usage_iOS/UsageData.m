//
//  UsageData.m
//  CooTekUsageApis
//
//  Created by ZhangNan on 14-7-24.
//  Copyright (c) 2014年 hello. All rights reserved.
//

#import "UsageData.h"

@implementation UsageRecord
@synthesize type;
@synthesize path;
@synthesize values;
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.path forKey:@"path"];
    [aCoder encodeObject:self.values forKey:@"values"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.path = [aDecoder decodeObjectForKey:@"path"];
        self.values = [aDecoder decodeObjectForKey:@"values"];
    }
    return self;
}
@end
