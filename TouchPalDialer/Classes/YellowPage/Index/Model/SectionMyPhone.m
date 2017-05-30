//
//  SectionMyPhone.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/7.
//
//

#import "SectionMyPhone.h"

@implementation SectionMyPhone

-(id) init
{
    self = [super init];
    if (self) {
        self.myPhone = nil;
    }
    return self;
}

-(BOOL) isValid
{
    return YES;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionMyPhone* ret = [super copyWithZone:zone];
    ret.myPhone = [self.myPhone copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionMyPhone* ret = [super mutableCopyWithZone:zone];
    ret.myPhone = [self.myPhone mutableCopyWithZone:zone];
    
    return ret;
}


@end
