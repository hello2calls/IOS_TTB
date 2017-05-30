//
//  BannerItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/5.
//
//

#import "BannerItem.h"

@implementation BannerItem

- (id) initWithJson:(NSDictionary*) json
{
    self = [super initWithJson:json];
    
    return self;
}


#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    BannerItem* ret = [super copyWithZone:zone];
    ret.tu = [self.tu copyWithZone:zone];
    ret.s = [self.s copyWithZone:zone];
    ret.adid = [self.adid copyWithZone:zone];
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    BannerItem* ret = [super mutableCopyWithZone:zone];
    ret.tu = [self.tu mutableCopyWithZone:zone];
    ret.s = [self.s mutableCopyWithZone:zone];
    ret.adid = [self.adid mutableCopyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tu = [aDecoder decodeObjectForKey:@"tu"];
        self.s = [aDecoder decodeObjectForKey:@"s"];
        self.adid = [aDecoder decodeObjectForKey:@"adid"];
    }
    
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.tu forKey:@"tu"];
    [aCoder encodeObject:self.s forKey:@"s"];
    [aCoder encodeObject:self.adid forKey:@"adid"];
}


@end
