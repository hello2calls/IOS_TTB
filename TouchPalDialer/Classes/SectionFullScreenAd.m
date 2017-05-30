//
//  SectionFullScreenAd.m
//  TouchPalDialer
//
//  Created by Tengchuan Wang on 16/2/3.
//
//

#import <Foundation/Foundation.h>
#import "SectionFullScreenAd.h"
#import "IndexFilter.h"
#import "FullScreenAdItem.h"
#import "IndexJsonUtils.h"
#import "NSDictionary+Default.h"

@implementation SectionFullScreenAd

- (id) init
{
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithJson:(NSDictionary *)json
{
    self = [self init];
    if (self) {
        self.filter = [[IndexFilter alloc] initWithJson:[json objectForKey:@"filter"]];
        if ([self.filter isValid]) {
            for (NSDictionary *j in [json objectForKey:@"full_screen_ads"]) {
                FullScreenAdItem *item = [[FullScreenAdItem alloc] initWithJson:j];
                item.highlightItem.highlightStart = [[json objectForKey:@"filter"] objectForKey:@"start"];
                item.highlightItem.highlightDuration = [[json objectForKey:@"filter"] objectForKey:@"duration"];

                if (item.highlightItem.hiddenOnclick) {
                    [IndexJsonUtils addClickHiddenInfo:[NSString stringWithFormat:@"%@_%@", item.identifier, item.highlightItem.highlightStart.stringValue]];
                }
                if ([item isValid] && [item shouldShowHighLight]) {
                    [self.items addObject:item];
                    if ([item.tabGuide objectForKey:@"enable" withDefaultBoolValue:NO] && !self.tabGuideIcon) {
                        self.tabGuideIcon = item.iconLink;
                    }
                }
            }
        }
    }

    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionFullScreenAd *ret = [super copyWithZone:zone];
    ret.tabGuideIcon = [self.tabGuideIcon copyWithZone:zone];
    return ret;
}

#pragma mark- NSMutableCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionFullScreenAd *ret = [super mutableCopyWithZone:zone];
    ret.tabGuideIcon = [self.tabGuideIcon mutableCopyWithZone:zone];
    return ret;
}
@end
