//
//  FullScreenAdItem.m
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 16/2/3.
//
//

#import <Foundation/Foundation.h>
#import "FullScreenAdItem.h"
#import "NSDictionary+Default.h"

@implementation FullScreenAdItem

- (id) initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if (self) {
        self.highlightItem.hiddenOnclick = [json objectForKey:@"hiddenAfterClick" withDefaultBoolValue:YES];
        self.tabGuide = [json objectForKey:@"tab_guide"];
        self.iconLink = [json objectForKey:@"imageIOS"];
        self.adImage = [json objectForKey:@"fullScreenAdImageLink"];
    }
    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    FullScreenAdItem *ret = [super copyWithZone:zone];
    ret.tabGuide = [self.tabGuide copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSMutableCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    FullScreenAdItem *ret = [super mutableCopyWithZone:zone];
    ret.tabGuide = [self.tabGuide mutableCopyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCoding
- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    self.tabGuide = [aDecoder decodeObjectForKey:@"tabGuide"];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.tabGuide forKey:@"tabGuide"];
}
@end