//
//  SectionFindNews.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/23.
//
//

#import "SectionFindNews.h"
#import "UIDataManager.h"
#import "SectionCoupon.h"
#import "IndexConstant.h"


@implementation SectionFindNews

- (id) initWithJson: (NSDictionary*) json
{
    self = [super init];
    if (self) {
        self.title = FIND_NEWS_TITLE;
        NSArray* finds = [json objectForKey:@"cts"];
        BOOL isAds = NO;
        if(finds.count == 0 ){
            finds = [json objectForKey:@"ads"];
            isAds = YES;
        }
        self.items = [NSMutableArray new];
        
        for (NSDictionary* item in finds) {
            FindNewsItem* find = nil;
            if (isAds) {
                find = [[FindNewsItem alloc]initWithDavinicJson:item];
                find.category = CategoryADDavinci;
            } else {
               find = [[FindNewsItem alloc]initWithJson:item];
                find.category = CategoryNews;
            }
            
            if([find isValid]) {
                [self.items addObject:find];
                find.queryId = [json objectForKey:@"s"];
                find.tu = [json objectForKey:@"tu"];
            }
        }
        
        if (self.items.count > 0) {
            self.queryId = [json objectForKey:@"s"];
        }
    }
    
    return self;
}


- (id) validCopy
{
    SectionCoupon* ret = [super validCopy];
    ret.queryId = [self.queryId mutableCopy];
    ret.title = [self.title mutableCopy];
    
    return ret;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionCoupon* ret = [super copyWithZone:zone];
    ret.queryId = [self.queryId copyWithZone:zone];
    ret.title = [self.title copyWithZone:zone];
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionCoupon* ret = [super mutableCopyWithZone:zone];
    ret.queryId = [self.queryId mutableCopyWithZone:zone];
    ret.title = [self.title mutableCopyWithZone:zone];
    
    return ret;
}
@end
