//
//  SectionAnnouncement.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-15.
//
//

#import <Foundation/Foundation.h>
#import "SectionAnnouncement.h"
#import "CTUrl.h"
#import "IndexFilter.h"

@implementation SectionAnnouncement

- (id) initWithJson:(NSDictionary*) json
{
    self = [super init];
    
    self.style = [json objectForKey:@"style"];
    self.text = [json objectForKey:@"text"];
    self.ctUrl = [[CTUrl alloc] initWithJson:[json objectForKey:@"link"]];
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
    if([[json allKeys] containsObject:@"identifier"]) {
        self.ctUrl.serviceId = [json objectForKey:@"identifier"];
    }
    
    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionAnnouncement* ret = [super copyWithZone:zone];
    ret.style = [self.style copyWithZone:zone];
    ret.text = [self.text copyWithZone:zone];
    ret.ctUrl = [self.ctUrl copyWithZone:zone];

    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionAnnouncement* ret = [super mutableCopyWithZone:zone];
    ret.style = [self.style mutableCopyWithZone:zone];
    ret.text = [self.text mutableCopyWithZone:zone];
    ret.ctUrl = [self.ctUrl mutableCopyWithZone:zone];
    
    return ret;
}

@end