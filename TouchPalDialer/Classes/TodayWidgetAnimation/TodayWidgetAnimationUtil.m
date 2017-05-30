//
//  TodayWidgetAnimationUtil.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/7.
//
//

#import "TodayWidgetAnimationUtil.h"

@implementation TodayWidgetAnimationUtil
+ (CGFloat)getAdapt{
    if ( TPScreenHeight() < 600 )
        return 1.0f;
    else if ( TPScreenHeight() < 700 )
        return 1.1f;
    else
        return 1.2f;
}

@end
