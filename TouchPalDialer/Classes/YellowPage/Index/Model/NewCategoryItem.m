//
//  NewCategoryItem.m
//  TouchPalDialer
//
//  Created by tanglin on 15-7-1.
//
//

#import <Foundation/Foundation.h>
#import "NewCategoryItem.h"
#import "SubCategoryItem.h"
#import "IndexConstant.h"
#import "IndexFilter.h"
#import "HighLightItem.h"
#import "IndexJsonUtils.h"

@implementation NewCategoryItem
@synthesize title;
- (id) initWithJson:(NSDictionary*) json
{
    self = [super initWithJson:json];
    if(self) {
        self.title = [json objectForKey:@"name"];
        self.subTitle = [json objectForKey:@"subName"];
        self.identifier = [json objectForKey:@"categoryId"];
        NSMutableArray* sections = [json objectForKey:@"sections"];
        if (sections != nil && sections.count > 0) {
            self.subItems = [[NSMutableArray alloc] initWithCapacity:sections.count];
            for (NSDictionary* section in sections) {
                SubCategoryItem* item = [[SubCategoryItem alloc]initWithJson:section];
                if ([item isValid]) {
                    [self.subItems addObject:item];
                    if (self.type == nil) {
                        self.type = item.type;
                    }
                }

            }
        } else {
            self.subItems = nil;
        }
    }
    return self;
}
- (id) init
{
    self = [super init];
    self.subItems = [[NSMutableArray alloc]init];
    
    return self;
}

- (BOOL) isValid
{
    if (self.subItems == nil || self.subItems.count == 0 || ![self.filter isValid]) {
        return NO;
    }
    
    for (SubCategoryItem* item in self.subItems) {
        if ([item isValid]) {
            return YES;
        }
    }
    
    return NO;
}
@end
