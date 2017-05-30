//
//  SectionFooter.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#import <Foundation/Foundation.h>
#import "SectionFooter.h"
#import "IndexFilter.h"

@implementation SectionFooter

- (id) initWithJson:(NSDictionary*)json
{
    self = [super init];
    self.normal = [json objectForKey:@"normal"];
    self.crazy = [json objectForKey:@"crazy"];
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];

    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionFooter* ret = [super copyWithZone:zone];
    ret.normal = [self.normal copyWithZone:zone];
    ret.crazy = [self.crazy copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionFooter* ret = [super mutableCopyWithZone:zone];
    ret.normal = [self.normal mutableCopyWithZone:zone];
    ret.crazy = [self.crazy mutableCopyWithZone:zone];
    
    return ret;
}

@end