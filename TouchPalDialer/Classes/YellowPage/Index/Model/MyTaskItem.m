//
//  MyTaskItem.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/26.
//
//

#import "MyTaskItem.h"

@implementation MyTaskItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rewards = [NSMutableDictionary new];
    }
    return self;
}
#pragma mark- NSCopying
- (id) copyWithZone:(NSZone *)zone
{
    
    MyTaskItem* ret = [super copyWithZone:zone];
    ret.rewards = [self.rewards copyWithZone:zone];
    ret.isShowing = self.isShowing;
    
    return ret;
}

#pragma mark- NSCopying
- (id) mutableCopyWithZone:(NSZone *)zone
{
    MyTaskItem* ret = [super mutableCopyWithZone:zone];
    ret.rewards = [self.rewards mutableCopyWithZone:zone];
    ret.isShowing = self.isShowing;
    
    return ret;
}

@end
