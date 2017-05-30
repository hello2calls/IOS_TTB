//
//  TaskAnimationManager.m
//  TouchPalDialer
//
//  Created by tanglin on 16/7/15.
//
//

#import "TaskAnimationManager.h"

TaskAnimationManager* _taskAnimationInstance;
@implementation TaskAnimationManager

+ (void)initialize
{
    _taskAnimationInstance  = [[TaskAnimationManager alloc] init];
}

+ (TaskAnimationManager *)instance
{
    return _taskAnimationInstance;
}


@end
