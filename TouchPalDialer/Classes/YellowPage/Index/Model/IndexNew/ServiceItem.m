//
//  ServiceItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15/11/9.
//
//

#import "ServiceItem.h"
#import "ImageUtils.h"
#import "CTUrl.h"
#import "IndexConstant.h"
#import "IndexJsonUtils.h"

@implementation ServiceItem

- (id) initWithJson:(NSDictionary*) json
{
    self = [super initWithJson:json];
    if (self) {
        self.identifier = [json objectForKey:@"id"];
        self.title = [json objectForKey:@"tag"];
        self.isSelected = NO;

    }
    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    ServiceItem* ret = [super copyWithZone:zone];
    ret.isSelected = self.isSelected;
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    ServiceItem* ret = [super mutableCopyWithZone:zone];
    ret.isSelected = self.isSelected;
    
    return ret;
}

#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isSelected = [aDecoder decodeBoolForKey:@"isSelected"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:self.isSelected forKey:@"isSelected"];
}
@end
