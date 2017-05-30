//
//  SectionNewCategory.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#import <Foundation/Foundation.h>
#import "SectionNewCategory.h"
#import "NewCategoryItem.h"
#import "UIDataManager.h"
#import "IndexConstant.h"
#import "IndexFilter.h"

@implementation SectionNewCategory

- (id) initWithJson: (NSDictionary*) json
{
    self = [super init];
    self.title = [json objectForKey:@"title"];
    self.count = [json objectForKey:@"count"];
    NSArray* items = [json objectForKey:@"categories"];
    self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
    self.items = [[NSMutableArray alloc]init];
    
    NSMutableArray* moreData = [[NSMutableArray alloc]init];
    for (NSDictionary* item in items) {
        if (item == nil || ![item isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NewCategoryItem* i = [[NewCategoryItem alloc]initWithJson:item];
        if ([i isValid]) {
            if (self.items.count <= self.count.intValue) {
                [self.items addObject:i];
                if (self.items.count == self.count.intValue + 1) {
                    NewCategoryItem* moreItem = [i mutableCopy];
                    moreItem.type = NEW_CATEGORY_TYPE_ITEMMORE;
                    moreItem.title = NEW_CATEGORY_MORE_TITLE;
                    moreItem.font = @"";
                    moreItem.subTitle = @"";
                    moreItem.iconLink = [NSString stringWithFormat:@"%@%@",YP_DEBUG_SERVER, NEW_CATEGORY_MORE_ICON_PATH];
                    moreItem.iconPath = NEW_CATEGORY_MORE_ICON_PATH;
                    [self.items addObject:moreItem];
                    [moreData addObject:i];
                }
            } else {
                [moreData addObject:i];
            }
        }
    }
   
    
    if (moreData.count > 1) {
        if (self.items.count >= 2) {
            [self.items removeObjectAtIndex:self.items.count - 2];
        }
        [[UIDataManager instance] setCategoryExtendData:moreData];
    } else if(moreData.count == 1){
        [self.items removeLastObject];
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
    SectionNewCategory* ret = [super copyWithZone:zone];
    ret.title = [self.title copyWithZone:zone];
    ret.count = [self.count copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionNewCategory* ret = [super mutableCopyWithZone:zone];
    ret.title = [self.title mutableCopyWithZone:zone];
    ret.count = [NSNumber numberWithInteger:[self.count intValue]];
    
    return ret;
}

@end
