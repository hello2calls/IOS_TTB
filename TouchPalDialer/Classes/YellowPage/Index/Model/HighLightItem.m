//
//  HighLightItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-17.
//
//

#import <Foundation/Foundation.h>
#import "HighLightItem.h"

@implementation HighLightItem

- (id) initWithJson:(NSDictionary*) json
{
    self = [super init];
    if (self) {
        self.type = [json objectForKey:@"highlightStyle"];
        self.hotKey = [json objectForKey:@"highlightText"];
        self.highlightStart = [json objectForKey:@"highlightStart"];
        self.highlightDuration = [json objectForKey:@"highlightDuration"];
        self.hiddenOnclick = [[json objectForKey:@"hiddenOnclick"] boolValue];
    }
    
    return self;
}

-(BOOL) isValid
{
    if (self.type == nil
        || self.type.length <= 0) {
        return NO;
    }
    
    long long now = [[NSDate date] timeIntervalSince1970];
    if (self.highlightStart != nil) {
        if (self.highlightStart.longLongValue > now) {
            return NO;
        }
        
        if (self.highlightDuration != nil && self.highlightStart.longLongValue + self.highlightDuration.longLongValue <= now) {
            return NO;
        }
    }
    return YES;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    HighLightItem* ret = [[[self class] alloc] init];
    ret.type = [self.type copyWithZone:zone];
    ret.hotKey = [self.hotKey copyWithZone:zone];
    ret.highlightStart =  [NSNumber numberWithInteger:[self.highlightStart intValue]];
    ret.highlightDuration = [NSNumber numberWithInteger:[self.highlightDuration intValue]];
    ret.hiddenOnclick = self.hiddenOnclick;
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    HighLightItem* ret = [[[self class] alloc] init];
    ret.type = [self.type mutableCopyWithZone:zone];
    ret.hotKey = [self.hotKey mutableCopyWithZone:zone];
    ret.highlightStart =  [NSNumber numberWithInteger:[self.highlightStart intValue]];
    ret.highlightDuration = [NSNumber numberWithInteger:[self.highlightDuration intValue]];
    ret.hiddenOnclick = self.hiddenOnclick;
    return ret;
}


#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.hotKey = [aDecoder decodeObjectForKey:@"hotKey"];
        self.highlightStart = [aDecoder decodeObjectForKey:@"highlightStart"];
        self.highlightDuration = [aDecoder decodeObjectForKey:@"highlightDuration"];
        self.hiddenOnclick = [[aDecoder decodeObjectForKey:@"hiddenOnclick"] boolValue];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.hotKey forKey:@"hotKey"];
    [aCoder encodeObject:self.hotKey forKey:@"highlightStart"];
    [aCoder encodeObject:self.hotKey forKey:@"highlightDuration"];
    [aCoder encodeObject:self.hotKey forKey:@"hiddenOnclick"];
}

@end