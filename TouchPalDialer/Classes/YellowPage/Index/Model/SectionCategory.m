//
//  CategoryItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-2.
//
//

#import <Foundation/Foundation.h>
#import "SectionCategory.h"
#import "CategoryRowView.h"
#import "IndexConstant.h"
#import "IndexFilter.h"
#import "CTUrl.h"

@implementation SectionCategory

- (id) initWithJson: (NSDictionary*) json
{
    self = [super init];
    self.name = [json objectForKey:@"name"];
    self.style = [json objectForKey:@"style"];
    NSArray* items = [json objectForKey:@"items"];
    self.items = [[NSMutableArray alloc]init];
    for (NSDictionary* item in items) {
        CategoryItem* i = [[CategoryItem alloc]initWithJson:item];
        [self.items addObject:i];
    }
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];

    
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


- (id) validCopy
{
    SectionCategory* ret = [super validCopy];
    
    ret.name = self.name;
    ret.style = self.style;
    ret.isOpened = self.isOpened;
    
    return ret;
}

- (int) getRowHeight
{
    return INDEX_ROW_HEIGHT_CATEGORY;
}

- (int) getRowCount
{
    return (self.items.count + CATEGORY_COLUMN_COUNT - 1) / 3 ;
}

+ (NSMutableArray*) getCategoryItemsFromDictionaryArray:(NSMutableArray*)array
{
    NSMutableArray* items = [[NSMutableArray alloc]initWithCapacity:array.count];
    
    for (int i = 0; i < array.count; i++) {
        NSDictionary* dict = [array objectAtIndex:i];
        SectionCategory *item = [[SectionCategory alloc]init];
        item.isOpened = false;
        item.name = [dict objectForKey:@"name"];
        NSMutableArray* categories = [dict objectForKey:@"items"];
        item.items = [[NSMutableArray alloc]initWithCapacity:categories.count];
        
        for (int j = 0; j < categories.count; j++) {
            NSDictionary *subdata = [categories objectAtIndex:j];
            CategoryItem *subItem = [[CategoryItem alloc]init];
            subItem.title = [subdata objectForKey:@"title"];
            subItem.identifier = [subdata objectForKey:@"identifier"];
            subItem.ctUrl = [subdata objectForKey:@"link"];
            if([[subdata allKeys] containsObject:@"identifier"]) {
                subItem.ctUrl.serviceId = [subdata objectForKey:@"identifier"];
            }
            
            [item.items addObject:subItem];
        }
        
        [items addObject:item];
    }
    
    return items;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionCategory* ret = [super copyWithZone:zone];
    ret.name = [self.name copyWithZone:zone];
    ret.style = [self.style copyWithZone:zone];
    ret.items = [self.items copyWithZone:zone];
    ret.isOpened = self.isOpened;
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionCategory* ret = [super mutableCopyWithZone:zone];
    ret.name = [self.name mutableCopyWithZone:zone];
    ret.style = [self.style mutableCopyWithZone:zone];
    ret.items = [self.items mutableCopyWithZone:zone];
    ret.isOpened = self.isOpened;
    
    return ret;
}

@end
