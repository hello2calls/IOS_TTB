//
//  MiniBannerItem.m
//  TouchPalDialer
//
//  Created by tanglin on 16/1/20.
//
//

#import "MiniBannerItem.h"
#import "NSDictionary+Default.h"

@implementation MiniBannerItem

- (id) initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if (self) {
        self.highlightItem.hiddenOnclick = [json objectForKey:@"hiddenAfterClick" withDefaultBoolValue:YES];
        self.tabGuide = [json objectForKey:@"tab_guide"];
        self.iconLink = [json objectForKey:@"imageIOS"];
    }
    
    return self;
}


#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    MiniBannerItem* ret = [super copyWithZone:zone];
    ret.tabGuide = [self.tabGuide copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    MiniBannerItem* ret = [super mutableCopyWithZone:zone];
    ret.tabGuide = [self.tabGuide mutableCopyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    self.tabGuide = [aDecoder decodeObjectForKey:@"tabGuide"];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.tabGuide forKey:@"tabGuide"];
}

@end
