//
//  SectionBanner.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-14.
//
//

#import <Foundation/Foundation.h>
#import "SectionBanner.h"
#import "CTUrl.h"
#import "IndexFilter.h"
#import "BannerItem.h"

@implementation SectionBanner

- (id) initWithJson:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        self.items = [NSMutableArray new];
        BannerItem* item = [[BannerItem alloc] initWithJson:json];
        item.iconLink = [json objectForKey:@"image"];
        item.ctUrl = [[CTUrl alloc]initWithJson:[json objectForKey:@"link"]];
        if([[json allKeys] containsObject:@"identifier"]) {
            item.ctUrl.serviceId = [json objectForKey:@"identifier"];
        }
        self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
        if([item isValid]) {
            [self.items addObject:item];
        }

    }

    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionBanner* ret = [super copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionBanner* ret = [super mutableCopyWithZone:zone];
    return ret;
}

@end
