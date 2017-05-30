//
//  SectionBase.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-22.
//
//

#import <Foundation/Foundation.h>
#import "SectionBase.h"
#import "IndexFilter.h"
#import "BaseItem.h"

@implementation SectionBase

@synthesize items;

- (instancetype)init
{
    self = [super init];
    if (self) {
        items = [NSMutableArray new];
    }
    return self;
}

- (BOOL) isValid
{
    if (self.filter == nil || [self.filter isValid]) {
        if (!items || items.count > 0) {
            return YES;
        }

    }

    return NO;
}

- (id) validCopy
{
    return [self mutableCopy];
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionBase* ret = [[[self class] allocWithZone:zone] init];
    ret.filter = [self.filter copyWithZone:zone];
    ret.items = [self.items copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionBase* ret = [[[self class] allocWithZone:zone] init];
    ret.filter = [self.filter mutableCopyWithZone:zone];
    ret.items = [self.items mutableCopyWithZone:zone];
    
    return ret;
}

@end