//
//  CategorySubItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-3.
//
//

#import <Foundation/Foundation.h>
#import "CategoryItem.h"
#import "NSDictionary+Default.h"
#import "ImageUtils.h"
#import "IndexConstant.h"
#import "HighLightItem.h"
#import "IndexFilter.h"
#import "CTUrl.h"
#import "IndexJsonUtils.h"
#import "UIDataManager.h"
#import "ControllerManager.h"

@implementation CategoryItem

@synthesize iconBgColor;
@synthesize classify;
@synthesize title;

- (id) initWithJson:(NSDictionary*) json
{
    self = [super initWithJson:json];
    self.index = [json objectForKey:@"recommendIndex"];
    if (self) {
        self.classify = [json objectForKey:@"classify"];
    }
    
    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    
    CategoryItem* ret = [super copyWithZone:zone];
    ret.classify = [self.classify copyWithZone:zone];
    ret.type = [self.type copyWithZone:zone];
    ret.subItems = [self.subItems copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    CategoryItem* ret = [super mutableCopyWithZone:zone];
    ret.classify = [self.classify mutableCopyWithZone:zone];
    ret.type = [self.type mutableCopyWithZone:zone];
    ret.subItems = [self.subItems mutableCopyWithZone:zone];
    
    return ret;
}

- (UIViewController *) startWebView
{
    [self hideClickHiddenInfo];
    return [self.ctUrl startWebView];
    //    [[UIDataManager instance] addTrack:self];
}

#pragma mark- NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.classify = [aDecoder decodeObjectForKey:@"classify"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.subItems = [aDecoder decodeObjectForKey:@"subItems"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.classify forKey:@"classify"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.subItems forKey:@"subItems"];
}

@end
