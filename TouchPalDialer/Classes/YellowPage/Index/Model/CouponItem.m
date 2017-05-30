//
//  CouponItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#import <Foundation/Foundation.h>
#import "CouponItem.h"
#import "CTUrl.h"
#import "IndexFilter.h"

@implementation CouponItem

@synthesize price;
@synthesize priceSale;
@synthesize distance;
@synthesize join;
@synthesize discount;

- (id) initWithJson:(NSDictionary*) json
{
    self = [super initWithJson:json];
    if (self) {
        self.price = [json objectForKey:@"price"];
        self.priceSale = [json objectForKey:@"priceSale"];
        self.distance = [json objectForKey:@"dis"];
        self.join = [json objectForKey:@"join"];
        self.discount = [json objectForKey:@"discount"];
        self.discount = [json objectForKey:@"discount"];
        self.propertyList = [json objectForKey:@"properties"];
    }
    
    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    CouponItem* ret = [[[self class] alloc] init];
    ret.identifier = [self.identifier copyWithZone:zone];
    ret.title = [self.title copyWithZone:zone];
    ret.subTitle = [self.subTitle copyWithZone:zone];
    ret.ctUrl = [self.ctUrl copyWithZone:zone];
    ret.filter = [self.filter copyWithZone:zone];
    ret.price = [self.price copyWithZone:zone];
    ret.priceSale = [self.priceSale copyWithZone:zone];
    ret.distance = [self.distance copyWithZone:zone];
    ret.join = [self.join copyWithZone:zone];
    ret.discount = [self.discount copyWithZone:zone];
    ret.propertyList = [self.propertyList copyWithZone:zone];
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    CouponItem* ret = [[[self class] alloc] init];
    ret.identifier = [self.identifier mutableCopyWithZone:zone];
    ret.title = [self.title mutableCopyWithZone:zone];
    ret.subTitle = [self.subTitle mutableCopyWithZone:zone];
    ret.iconLink = [self.iconLink mutableCopyWithZone:zone];
    ret.iconPath = [self.iconPath mutableCopyWithZone:zone];
    ret.ctUrl = [self.ctUrl mutableCopyWithZone:zone];
    ret.filter = [self.filter mutableCopyWithZone:zone];
    ret.price = [self.price mutableCopyWithZone:zone];
    ret.priceSale = [self.priceSale mutableCopyWithZone:zone];
    ret.distance = [self.distance mutableCopyWithZone:zone];
    ret.join = [self.join mutableCopyWithZone:zone];
    ret.discount = [self.discount mutableCopyWithZone:zone];
    ret.propertyList = [self.propertyList mutableCopyWithZone:zone];
    
    return ret;
}

@end
