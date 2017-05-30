//
//  RightTopItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/16.
//
//

#import "RightTopItem.h"

@implementation RightTopItem

- (id) initWithJson:(NSDictionary*)json
{
    self = [super init];
    self.ctUrl = [[CTUrl alloc]initWithJson:[json objectForKey:@"link"]];
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
    self.highlightItem = [[HighLightItem alloc]initWithJson:json];
    self.text = [json objectForKey:@"text"];
    return self;
}

-(BOOL) isValid
{
    return [self.ctUrl isValid];
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    RightTopItem* ret = [[[self class] alloc] init];
    ret.filter = [self.filter copyWithZone:zone];
    ret.ctUrl = [self.ctUrl copyWithZone:zone];
    ret.highlightIconBgColor = [self.highlightIconBgColor copyWithZone:zone];
    ret.text = [self.text copyWithZone:zone];
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    RightTopItem* ret = [[[self class] alloc] init];
    ret.ctUrl = [self.ctUrl mutableCopyWithZone:zone];
    ret.filter = [self.filter mutableCopyWithZone:zone];
    ret.highlightIconBgColor = [self.highlightIconBgColor copyWithZone:zone];
    ret.highlightItem = [self.highlightItem mutableCopyWithZone:zone];
    ret.text = [self.text mutableCopyWithZone:zone];
    return ret;
}


#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.ctUrl = [aDecoder decodeObjectForKey:@"ctUrl"];
        self.filter = [aDecoder decodeObjectForKey:@"filter"];
        self.highlightIconBgColor = [aDecoder decodeObjectForKey:@"highlightIconBgColor"];
        self.highlightItem = [aDecoder decodeObjectForKey:@"highlightItem"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.ctUrl forKey:@"ctUrl"];
    [aCoder encodeObject:self.filter forKey:@"filter"];
    [aCoder encodeObject:self.highlightIconBgColor forKey:@"highlightIconBgColor"];
    [aCoder encodeObject:self.highlightItem forKey:@"highlightItem"];
}


@end
