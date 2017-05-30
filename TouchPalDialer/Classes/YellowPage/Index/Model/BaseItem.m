//
//  BaseItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#import <Foundation/Foundation.h>
#import "BaseItem.h"
#import "CTUrl.h"
#import "IndexFilter.h"
#import "IndexJsonUtils.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "ShortCutManager.h"
#import "NSDictionary+Default.h"

@implementation BaseItem

@synthesize identifier;
@synthesize title;
@synthesize subTitle;
@synthesize iconLink;
@synthesize iconPath;
@synthesize font;
@synthesize fontColor;
@synthesize ctUrl;
@synthesize curl;
@synthesize cMonitorUrl;
@synthesize edMonitorUrl;
@synthesize filter;
@synthesize iconBgColor;
@synthesize highlightIconBgColor;
@synthesize highlightItem;

- (id) initWithJson:(NSDictionary*) json
{
    self = [super init];
    if (self) {
        self.identifier = [json objectForKey:@"identifier"];
        self.title = [json objectForKey:@"title"];
        self.subTitle = [json objectForKey:@"subTitle"];
        self.iconLink = [json objectForKey:@"iconLinkv3"] ? [json objectForKey:@"iconLinkv3"] : [json objectForKey:@"iconLink"];
        self.iconPath = [json objectForKey:@"iconPathv3"] ? [json objectForKey:@"iconPathv3"] : [json objectForKey:@"iconPath"];
        self.font = [json objectForKey:@"font"];
        self.fontColor = [json objectForKey:@"fontColor"];
        self.ctUrl = [[CTUrl alloc]initWithJson:[json objectForKey:@"link"]];

        self.ctUrl.serviceId = self.identifier;
        self.curl = [json objectForKey:@"clk_url"];
        self.cMonitorUrl = [json objectForKey:@"clk_monitor_url"];
        self.tu = [json objectForKey:@"tu"];
        self.s = [json objectForKey:@"s"];
        self.adid = [json objectForKey:@"adid"];
        self.reloadAssetAfterBack = [json objectForKey:@"reloadAssetAfterBack" withDefaultBoolValue:NO];

        if ([[json allKeys] containsObject:@"native"]) {
            self.ctUrl.nativeUrl = [json objectForKey:@"native"];
        }
        self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
        if ([json objectForKey:@"shortcutIOS"]) {
            ShortCutManager* shortcut = [[ShortCutManager alloc]initWithJson:[json objectForKey:@"shortcutIOS"]];
            if ([shortcut isValid]) {
                self.ctUrl.sendToDeskTop = YES;
                self.ctUrl.shortCutTitle = shortcut.shortCutTitle;
                self.ctUrl.shortCutIcon = shortcut.shortCutIcon;
            }
        }
        self.edMonitorUrl = [json objectForKey:@"ed_monitor_url"];
        NSString* bgColor = [json objectForKey:@"iconBgColor"];
        UIColor* defaultColor = [ImageUtils colorFromHexString:COMMON_BG_COLOR andDefaultColor:nil];
        self.iconBgColor = [ImageUtils colorFromHexString:bgColor andDefaultColor:defaultColor];

        self.highlightItem = [[HighLightItem alloc]initWithJson:json];
        self.highlightIconBgColor =[ImageUtils highlightColor:[ImageUtils colorFromHexString:STYLE_HIGHLIGHT_BG_COLOR andDefaultColor:nil]];

        if (self.highlightItem.hiddenOnclick) {
            [IndexJsonUtils addClickHiddenInfo:[NSString stringWithFormat:@"%@_%@",self.identifier, self.highlightItem.highlightStart.stringValue]];
        }
    }
    return self;
}

- (BOOL) isValid
{
    if (self.filter == nil || [self.filter isValid]) {
        return YES;
    }

    return NO;
}


- (BOOL) isHighLightValid
{

    return self.highlightItem && [self.highlightItem isValid];
}

- (void) hideClickHiddenInfo
{
    if (self.highlightItem.hiddenOnclick) {
        [IndexJsonUtils hideClickHiddenInfo:[NSString stringWithFormat:@"%@_%@",self.identifier, self.highlightItem.highlightStart.stringValue]];
    }
}

- (BOOL) shouldShowHighLight
{
    if (self.highlightItem.hiddenOnclick) {
        return [IndexJsonUtils shouldHideClickHiddenInfo:[NSString stringWithFormat:@"%@_%@",self.identifier, self.highlightItem.highlightStart.stringValue]];
    }
    return [self isHighLightValid];
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    BaseItem* ret = [[[self class] alloc] init];
    ret.identifier = [self.identifier copyWithZone:zone];
    ret.title = [self.title copyWithZone:zone];
    ret.subTitle = [self.subTitle copyWithZone:zone];
    ret.iconLink = [self.iconLink copyWithZone:zone];
    ret.iconPath = [self.iconPath copyWithZone:zone];
    ret.font = [self.font copyWithZone:zone];
    ret.fontColor = [self.fontColor copyWithZone:zone];
    ret.ctUrl = [self.ctUrl copyWithZone:zone];
    ret.cMonitorUrl = [self.cMonitorUrl copyWithZone:zone];
    ret.edMonitorUrl = [self.edMonitorUrl copyWithZone:zone];
    ret.filter = [self.filter copyWithZone:zone];
    ret.iconBgColor = [self.iconBgColor copyWithZone:zone];
    ret.highlightIconBgColor = [self.highlightIconBgColor copyWithZone:zone];
    ret.highlightItem = [self.highlightItem copyWithZone:zone];
//    ret.curl = [self.curl copyWithZone:zone];
    ret.s = [self.s copyWithZone:zone];
    ret.tu = [self.s copyWithZone:zone];
    ret.adid = [self.adid copyWithZone:zone];
    ret.reloadAssetAfterBack = self.reloadAssetAfterBack;

    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    BaseItem* ret = [[[self class] alloc] init];
    ret.identifier = [self.identifier mutableCopyWithZone:zone];
    ret.title = [self.title mutableCopyWithZone:zone];
    ret.subTitle = [self.subTitle mutableCopyWithZone:zone];
    ret.iconLink = [self.iconLink mutableCopyWithZone:zone];
    ret.iconPath = [self.iconPath mutableCopyWithZone:zone];
    ret.font = [self.font copyWithZone:zone];
    ret.fontColor = [self.fontColor copyWithZone:zone];
    ret.ctUrl = [self.ctUrl mutableCopyWithZone:zone];
    ret.cMonitorUrl = [self.cMonitorUrl mutableCopyWithZone:zone];
    ret.edMonitorUrl = [self.edMonitorUrl mutableCopyWithZone:zone];
    ret.filter = [self.filter mutableCopyWithZone:zone];
    ret.iconBgColor = [self.iconBgColor copyWithZone:zone];
    ret.highlightIconBgColor = [self.highlightIconBgColor copyWithZone:zone];
    ret.highlightItem = [self.highlightItem mutableCopyWithZone:zone];
//    ret.curl = [self.curl mutableCopyWithZone:zone];
    ret.s = [self.s mutableCopyWithZone:zone];
    ret.tu = [self.tu mutableCopyWithZone:zone];
    ret.adid = [self.adid mutableCopyWithZone:zone];
    ret.reloadAssetAfterBack = self.reloadAssetAfterBack;

    return ret;
}

#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subTitle = [aDecoder decodeObjectForKey:@"subTitle"];
        self.filter = [aDecoder decodeObjectForKey:@"filter"];
        self.iconLink = [aDecoder decodeObjectForKey:@"iconLinkv3"] ? [aDecoder decodeObjectForKey:@"iconLinkv3"] : [aDecoder decodeObjectForKey:@"iconLink"];
        self.iconPath = [aDecoder decodeObjectForKey:@"iconPathv3"] ? [aDecoder decodeObjectForKey:@"iconPathv3"] : [aDecoder decodeObjectForKey:@"iconPath"];
        self.font = [aDecoder decodeObjectForKey:@"font"];
        self.fontColor = [aDecoder decodeObjectForKey:@"fontColor"];
        self.ctUrl = [aDecoder decodeObjectForKey:@"ctUrl"];
        self.cMonitorUrl = [aDecoder decodeObjectForKey:@"cMonitorUrl"];
        self.edMonitorUrl = [aDecoder decodeObjectForKey:@"edMonitorUrl"];
        self.filter = [aDecoder decodeObjectForKey:@"filter"];
        self.iconBgColor = [aDecoder decodeObjectForKey:@"iconBgColor"];
        self.highlightIconBgColor = [aDecoder decodeObjectForKey:@"highlightIconBgColor"];
        self.highlightItem = [aDecoder decodeObjectForKey:@"highlightItem"];
//        self.curl = [aDecoder decodeObjectForKey:@"curl"];
        self.s = [aDecoder decodeObjectForKey:@"s"];
        self.tu = [aDecoder decodeObjectForKey:@"tu"];
        self.adid = [aDecoder decodeObjectForKey:@"adid"];
        self.reloadAssetAfterBack = [aDecoder decodeBoolForKey:@"reloadAssetAfterBack"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subTitle forKey:@"subTitle"];
    [aCoder encodeObject:self.filter forKey:@"filter"];
    [aCoder encodeObject:self.iconLink forKey:@"iconLink"];
    [aCoder encodeObject:self.iconPath forKey:@"iconPath"];
    [aCoder encodeObject:self.font forKey:@"font"];
    [aCoder encodeObject:self.fontColor forKey:@"fontColor"];
    [aCoder encodeObject:self.ctUrl forKey:@"ctUrl"];
    [aCoder encodeObject:self.cMonitorUrl forKey:@"cMonitorUrl"];
    [aCoder encodeObject:self.edMonitorUrl forKey:@"edMonitorUrl"];
    [aCoder encodeObject:self.iconBgColor forKey:@"iconBgColor"];
    [aCoder encodeObject:self.highlightIconBgColor forKey:@"highlightIconBgColor"];
    [aCoder encodeObject:self.highlightItem forKey:@"highlightItem"];
//    [aCoder encodeObject:self.curl forKey:@"curl"];
    [aCoder encodeObject:self.s forKey:@"s"];
    [aCoder encodeObject:self.tu forKey:@"tu"];
    [aCoder encodeObject:self.adid forKey:@"adid"];
    [aCoder encodeBool:self.reloadAssetAfterBack forKey:@"reloadAssetAfterBack"];
}

@end
