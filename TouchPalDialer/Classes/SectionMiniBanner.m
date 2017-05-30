
//
//  SectionMiniBanner.m
//  TouchPalDialer
//
//  Created by tanglin on 16/1/20.
//
//

#import "SectionMiniBanner.h"
#import "IndexFilter.h"
#import "MiniBannerItem.h"
#import "NSDictionary+Default.h"
#import "IndexJsonUtils.h"

@implementation SectionMiniBanner

-(id) init
{
    self = [super init];
    if (self) {
        self.items = [NSMutableArray new];
    }
    return self;
}

-(id)initWithJson:(NSDictionary *)json
{
    self = [self init];
    if (self) {
        self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
        if ([self.filter isValid]) {
            for (NSDictionary* j in [json objectForKey:@"mini_banners"]) {
                MiniBannerItem* item = [[MiniBannerItem alloc]initWithJson:j];
                item.highlightItem.highlightStart = [[json objectForKey:@"filter"] objectForKey:@"start"];
                item.highlightItem.highlightDuration = [[json objectForKey:@"filter"] objectForKey:@"duration"];
                
                if (item.highlightItem.hiddenOnclick) {
                    [IndexJsonUtils addClickHiddenInfo:[NSString stringWithFormat:@"%@_%@",item.identifier, item.highlightItem.highlightStart.stringValue]];
                }
                if([item isValid] && [item shouldShowHighLight]) {
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
    SectionMiniBanner* ret = [super copyWithZone:zone];
    ret.tabGuideIcon = [self.tabGuideIcon copyWithZone:zone];
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionMiniBanner* ret = [super mutableCopyWithZone:zone];
    ret.tabGuideIcon = [self.tabGuideIcon mutableCopyWithZone:zone];
    return ret;
}
@end
