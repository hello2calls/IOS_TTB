//
//  SectionMyTask.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/8.
//
//

#import "SectionMyTask.h"
#import "IndexFilter.h"
#import "MyTaskItem.h"

@implementation SectionMyTask

- (id) initWithJson:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        NSArray* tasks = [json objectForKey:@"tasks"];
        for (NSDictionary* task in tasks) {
            MyTaskItem* item = [MyTaskItem new];
            NSDictionary* rewards = [task objectForKey:@"rewards"];
            item.title = [task objectForKey:@"title"];
            for (NSDictionary* dic in rewards) {
                if(dic.allKeys.count >0)
                {
                    [item.rewards setObject:[dic objectForKey:@"amount"] forKey:[dic objectForKey:@"type"]];
                }
            }
            item.iconLink = [task objectForKey:@"iconLink"];
            item.ctUrl = [[CTUrl alloc]initWithJson:[task objectForKey:@"link"]];
            [self.items addObject:item];
        }
       
    }
    
    return self;
}

- (BOOL) isValid
{
    if (self.filter == nil || [self.filter isValid]) {
        if(self.items && self.items.count > 0) {
            return YES;
        }
    }
    return NO;
}


#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    SectionMyTask* ret = [super copyWithZone:zone];
    ret.items = [self.items copyWithZone:zone];
    ret.isShowing = self.isShowing;
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    SectionMyTask* ret = [super mutableCopyWithZone:zone];
    ret.items = [self.items mutableCopyWithZone:zone];
    ret.isShowing = self.isShowing;
    
    return ret;
}

@end
