//
//  SectionRecommend.m
//  TouchPalDialer
//
//  Created by tanglin on 15-4-13.
//
//

#import <Foundation/Foundation.h>
#import "SectionRecommend.h"
#import "CategoryItem.h"
#import "IndexConstant.h"
#import "IndexData.h"
#import "SectionNewCategory.h"
#import "CTUrl.h"
#import "IndexFilter.h"

@implementation SectionRecommend

- (id) initWithArray:(NSArray*) array
{
    self = [super init];
    self.items = [[NSMutableArray alloc]init];
    for (NSDictionary* recommend in array) {
        CategoryItem* item = [[CategoryItem alloc]initWithJson:recommend];
        if ([recommend objectForKey:@"category"] && [item isValid]) {
            item.type = [[recommend objectForKey:@"category"] objectForKey:@"id"];
            if ([item isValid] && ![item.identifier isEqualToString:@"all_service"]) {
                [self.items addObject:item];
            }
        } else {
            if ([item isValid] && ![item.identifier isEqualToString:@"all_service"]) {
                [self.items addObject:item];
            }
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
    SectionRecommend* ret = [super copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionRecommend* ret = [super mutableCopyWithZone:zone];
    
    return ret;
}

@end