//
//  SectionSearch.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#import <Foundation/Foundation.h>
#import "SectionSearch.h"
#import "NSDictionary+Default.h"
#import "CTUrl.h"
#import "IndexFilter.h"

@implementation SectionSearch

- (id) initWithJson:(NSDictionary *)json
{
    self = [super init];
    
    self.tips = [json objectForKey:@"tips"];
    self.input = @"";
    self.ctUrl = [[CTUrl alloc]initWithJson:[json objectForKey:@"link"]];
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
    if([[json allKeys] containsObject:@"identifier"]) {
        self.ctUrl.serviceId = [json objectForKey:@"identifier"];
    }
    
    return self;
}

-(BOOL) isValid
{
    return [self.filter isValid];
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionSearch* ret = [super copyWithZone:zone];
    ret.tips = [self.tips copyWithZone:zone];
    ret.input = [self.input copyWithZone:zone];
    ret.city = [self.city copyWithZone:zone];
    ret.ctUrl = [self.ctUrl copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionSearch* ret = [super mutableCopyWithZone:zone];
    ret.tips = [self.tips mutableCopyWithZone:zone];
    ret.input = [self.input mutableCopyWithZone:zone];
    ret.city = [self.city mutableCopyWithZone:zone];
    ret.ctUrl = [self.ctUrl mutableCopyWithZone:zone];
    
    return ret;
}

@end