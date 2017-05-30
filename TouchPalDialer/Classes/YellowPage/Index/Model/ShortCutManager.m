//
//  ShortCutManager.m
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 16/5/17.
//
//

#import <Foundation/Foundation.h>
#import "ShortCutManager.h"
#import "NSDictionary+Default.h"

@implementation ShortCutManager

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    self.sendToDeskTop = [json objectForKey:@"sendToDeskTop" withDefaultBoolValue:NO];
    self.shortCutTitle = [json objectForKey:@"shortCutTitle"];
    self.shortCutIcon = [json objectForKey:@"shortCutIcon"];
    return self;
}

- (BOOL)isValid
{
    if (self.sendToDeskTop && self.shortCutTitle && self.shortCutIcon) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    ShortCutManager* ret = [[[self class] alloc] init];
    ret.sendToDeskTop = self.sendToDeskTop;
    ret.shortCutTitle = [self.shortCutTitle copyWithZone:zone];
    ret.shortCutIcon = [self.shortCutIcon copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    ShortCutManager* ret = [[[self class] alloc] init];
    ret.sendToDeskTop = self.sendToDeskTop;
    ret.shortCutTitle = [self.shortCutTitle mutableCopyWithZone:zone];
    ret.shortCutIcon = [self.shortCutIcon mutableCopyWithZone:zone];
    
    return ret;
}


#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.sendToDeskTop = [aDecoder decodeBoolForKey:@"sendToDeskTop"];
        self.shortCutTitle = [aDecoder decodeObjectForKey:@"shortCutTitle"];
        self.shortCutIcon = [aDecoder decodeObjectForKey:@"shortCutIcon"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:self.sendToDeskTop forKey:@"sendToDeskTop"];
    [aCoder encodeObject:self.shortCutTitle forKey:@"shortCutTitle"];
    [aCoder encodeObject:self.shortCutIcon forKey:@"shortCutIcon"];
}

@end
