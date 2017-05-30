//
//  SectionFind.m
//  TouchPalDialer
//
//  Created by tanglin on 15/12/17.
//
//

#import "SectionFind.h"

@implementation SectionFind

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
        self.title = [json objectForKey:@"title"];
        self.titleColor = [json objectForKey:@"titleColor"];
        self.filter = [[IndexFilter alloc]initWithJson:[json objectForKey:@"filter"]];
        
        for (NSDictionary* j in [json objectForKey:@"items"]) {
            CategoryItem* item = [[CategoryItem alloc]initWithJson:j];
            if([item isValid]) {
                [self.items addObject:item];
            }
            if (self.items.count == 3) {
                self.rightTopItem = [[RightTopItem alloc] initWithJson:[json objectForKey:@"rightTop"]];
                break;
            }
        }
    }
    
    return self;
}

#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionFind* ret = [super copyWithZone:zone];
    ret.title = [self.title copyWithZone:zone];
    ret.titleColor = [self.titleColor copyWithZone:zone];
    ret.rightTopItem = [self.rightTopItem copyWithZone:zone];
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionFind* ret = [super mutableCopyWithZone:zone];
    ret.title = [self.title mutableCopyWithZone:zone];
    ret.titleColor = [self.titleColor mutableCopyWithZone:zone];
    ret.rightTopItem = [self.rightTopItem mutableCopyWithZone:zone];
    return ret;
}
@end
