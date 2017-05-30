//
//  SectionService.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/12.
//
//

#import "SectionService.h"
#import "ServiceItem.h"

@implementation SectionService

- (id) init
{
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc]init];
    }
    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionService* ret = [super copyWithZone:zone];
    ret.name = [self.name copyWithZone:zone];
    ret.identify = [self.identify copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionService* ret = [super mutableCopyWithZone:zone];
    ret.name = [self.name mutableCopyWithZone:zone];
    ret.identify = [self.identify mutableCopyWithZone:zone];
    
    return ret;
}

@end
