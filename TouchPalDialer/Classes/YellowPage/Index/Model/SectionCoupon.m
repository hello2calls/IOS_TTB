//
//  SectionCoupon.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#import <Foundation/Foundation.h>
#import "SectionCoupon.h"

@implementation SectionCoupon
@synthesize coupon;
@synthesize isFirst;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.coupon = [CouponItem new];
        self.isFirst = NO;
    }
    
    return self;
}
- (id) initWithJson: (NSDictionary*) json
{
    self = [super init];
    self.coupon = [[CouponItem alloc]initWithJson:json];
    self.isFirst = NO;
    
    return self;
}

- (BOOL) isValid
{
    if ([coupon isValid]) {
        return YES;
    }
    return NO;
}

- (id) validCopy
{
    SectionCoupon* ret = [super validCopy];
    
    ret.coupon = [self.coupon mutableCopy];
    ret.queryId = [self.queryId mutableCopy];
    ret.title = [self.title mutableCopy];
    ret.isFirst = self.isFirst;
    
    return ret;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionCoupon* ret = [super copyWithZone:zone];
    ret.coupon = [self.coupon copyWithZone:zone];
    ret.queryId = [self.queryId copyWithZone:zone];
    ret.title = [self.title copyWithZone:zone];
    ret.isFirst = self.isFirst;
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionCoupon* ret = [super mutableCopyWithZone:zone];
    ret.coupon = [self.coupon mutableCopyWithZone:zone];
    ret.queryId = [self.queryId mutableCopyWithZone:zone];
    ret.title = [self.title mutableCopyWithZone:zone];
    ret.isFirst = self.isFirst;
    
    return ret;
}


@end