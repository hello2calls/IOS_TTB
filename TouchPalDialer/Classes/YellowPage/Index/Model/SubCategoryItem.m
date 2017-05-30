//
//  SubCategoryItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-2.
//
//

#import <Foundation/Foundation.h>
#import "SubCategoryItem.h"
#import "CategoryItem.h"
#import "IndexConstant.h"

@implementation SubCategoryItem

- (id) initWithJson:(NSDictionary*) json
{
    self = [super initWithJson:json];
    self.type = [json objectForKey:@"type"];
    self.index = [json objectForKey:@"index"];
    if ([self.type isEqualToString:NEW_CATEGORY_TYPE_ITEMCATEGORY]) {
        NSMutableArray* items = [json objectForKey:@"itemCategories"];
        self.cellCategories = [[NSMutableArray alloc] init];
        for (NSDictionary* item in items) {
            CategoryItem* categoryItem = [[CategoryItem alloc]initWithJson:item];
            if ([categoryItem isValid]) {
                [self.cellCategories addObject:categoryItem];
            }
        }
    } else if ([self.type isEqualToString:NEW_CATEGORY_TYPE_ITEMRECOMMEND]) {
        NSMutableArray* items = [json objectForKey:@"itemRecommands"];
        self.cellCategories = [[NSMutableArray alloc] init];
        for (NSDictionary* item in items) {
            CategoryItem* categoryItem = [[CategoryItem alloc]initWithJson:item];
            if ([categoryItem isValid]) {
                [self.cellCategories addObject:categoryItem];
            }
        }
    }
    return self;
}

- (BOOL) isValid
{
    if (self.cellCategories == nil || self.cellCategories.count == 0) {
        return NO;
    }
    
    for (CategoryItem* item in self.cellCategories) {
        if ([item isValid]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SubCategoryItem* ret = [super copyWithZone:zone];
    ret.cellCategories = [self.cellCategories copyWithZone:zone];
    ret.type = [self.type copyWithZone:zone];
    ret.index = [NSNumber numberWithInteger:[self.index intValue]];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SubCategoryItem* ret = [super mutableCopyWithZone:zone];
    ret.cellCategories = [self.cellCategories mutableCopyWithZone:zone];
    ret.type = [self.type mutableCopyWithZone:zone];
    ret.index = [NSNumber numberWithInteger:[self.index intValue]];
    
    return ret;
}

@end