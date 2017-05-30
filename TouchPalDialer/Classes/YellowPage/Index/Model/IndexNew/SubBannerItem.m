//
//  SubBannerItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/12.
//
//

#import "SubBannerItem.h"
#import "IndexFilter.h"
#import "IndexJsonUtils.h"
#import "UIDataManager.h"
#import "DialerUsageRecord.h"
#import "TPAnalyticConstants.h"


@implementation SubBannerItem

- (id) initWithJson:(NSDictionary*)json
{
    self = [super initWithJson:json];
    if (self) {
        if([[json allKeys] containsObject:@"identifier"]) {
            self.ctUrl.serviceId = [json objectForKey:@"identifier"];
            self.identifier = [json objectForKey:@"identifier"];
        }
        self.titleColor = [json objectForKey:@"titleColor"];
        self.subTitleColor = [json objectForKey:@"subTitleColor"];
        self.desc = [json objectForKey:@"desc"];
        self.descColor = [json objectForKey:@"descColor"];
        self.image = [json objectForKey:@"image"];
        self.bigImage = [json objectForKey:@"bigImage"];
    }
    
    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SubBannerItem* ret = [[[self class] alloc] init];
    ret.titleColor = [self.titleColor copyWithZone:zone];
    ret.identifier = [self.identifier copyWithZone:zone];
    ret.subTitleColor = [self.subTitleColor copyWithZone:zone];
    ret.desc = [self.desc copyWithZone:zone];
    ret.descColor = [self.descColor copyWithZone:zone];
    ret.iconBgColor = [self.iconBgColor copyWithZone:zone];
    ret.image = [self.image copyWithZone:zone];
    ret.bigImage = [self.bigImage copyWithZone:zone];
    ret.highlightIconBgColor = [self.highlightIconBgColor copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SubBannerItem* ret = [[[self class] alloc] init];
    ret.titleColor = [self.titleColor mutableCopyWithZone:zone];
    ret.subTitleColor = [self.subTitleColor mutableCopyWithZone:zone];
    ret.desc = [self.desc mutableCopyWithZone:zone];
    ret.descColor = [self.descColor mutableCopyWithZone:zone];
    ret.identifier = [self.identifier mutableCopyWithZone:zone];
    ret.iconBgColor = [self.iconBgColor copyWithZone:zone];
    ret.image = [self.image copyWithZone:zone];
    ret.bigImage = [self.bigImage copyWithZone:zone];
    ret.highlightIconBgColor = [self.highlightIconBgColor copyWithZone:zone];
    ret.highlightItem = [self.highlightItem mutableCopyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.titleColor = [aDecoder decodeObjectForKey:@"titleColor"];
        self.subTitleColor = [aDecoder decodeObjectForKey:@"subTitleColor"];
        self.desc = [aDecoder decodeObjectForKey:@"desc"];
        self.descColor = [aDecoder decodeObjectForKey:@"descColor"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.iconBgColor = [aDecoder decodeObjectForKey:@"iconBgColor"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.bigImage = [aDecoder decodeObjectForKey:@"bigImage"];
        self.highlightIconBgColor = [aDecoder decodeObjectForKey:@"highlightIconBgColor"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.titleColor forKey:@"titleColor"];
    [aCoder encodeObject:self.subTitleColor forKey:@"subTitleColor"];
    [aCoder encodeObject:self.desc forKey:@"desc"];
    [aCoder encodeObject:self.descColor forKey:@"descColor"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.iconBgColor forKey:@"iconBgColor"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.bigImage forKey:@"bigImage"];
    [aCoder encodeObject:self.highlightIconBgColor forKey:@"highlightIconBgColor"];
    [aCoder encodeObject:self.highlightItem forKey:@"highlightItem"];
}
@end
