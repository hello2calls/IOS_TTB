//
//  SectionFavourite.m
//  TouchPalDialer
//
//  Created by tanglin on 15-6-25.
//
//

#import <Foundation/Foundation.h>
#import "SectionFavourite.h"
#import "CategoryItem.h"
#import "IndexFilter.h"

@implementation SectionFavourite

@synthesize title;

- (id) initWithJson: (NSDictionary*) json
{
    self = [super init];
    self.title = [json objectForKey:@"title"];
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
    NSArray* items = [json objectForKey:@"favourites"];
    self.items = [[NSMutableArray alloc]init];
    for (NSDictionary* item in items) {
        if (item == nil || ![item isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        CategoryItem* i = [[CategoryItem alloc]initWithJson:item];
        if ([i isValid]) {
            [self.items addObject:i];
        }
    }
    
    return self;
}

- (id) init
{
    self = [super init];
    if (self) {
        self.items = [[NSMutableArray alloc]init];
    }
    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionFavourite* ret = [super copyWithZone:zone];
    ret.title = [self.title copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionFavourite* ret = [super mutableCopyWithZone:zone];
    ret.title = [self.title mutableCopyWithZone:zone];
    
    return ret;
}

@end
