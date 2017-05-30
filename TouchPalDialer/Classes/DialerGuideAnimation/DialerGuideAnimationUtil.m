//
//  DialerGuideAnimationUtil.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/8.
//
//

#import "DialerGuideAnimationUtil.h"
#import "DialerUsageRecord.h"
#import "UserDefaultsManager.h"
#import "RootScrollViewController.h"
#import "TouchPalDialerAppDelegate.h"
#import "DialerGuideAnimationManager.h"
#import "FunctionUtility.h"
@implementation DialerGuideAnimationUtil

+ (void)waitGuideAnimation{
    if ( [UserDefaultsManager intValueForKey:DIALER_GUIDE_ANIMATION_TIMES defaultValue:0] > 0)
        return;
    [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_WAIT];
}

+ (void)dismissGuideAnimation{
    [DialerUsageRecord recordpath:PATH_DIALER_GUIDE_ANIMATION kvs:Pair(DIALER_GUIDE_ANIMATION_USE_SEARCH_TIMES, @(1)), nil];
    if ( ![UserDefaultsManager boolValueForKey:DIALER_GUIDE_ANIMATION_ONE_USER_USED defaultValue:NO] ){
        [DialerUsageRecord recordpath:PATH_DIALER_GUIDE_ANIMATION kvs:Pair(DIALER_GUIDE_ANIMATION_USED_SEARCH, @(1)), nil];
        [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_ONE_USER_USED];
    }
    if ( ![UserDefaultsManager boolValueForKey:DIALER_GUIDE_ANIMATION_ONE_USER_SHOWN defaultValue:NO] ){
        if ( [UserDefaultsManager boolValueForKey:DIALER_GUIDE_ANIMATION_HAS_SHOWN defaultValue:NO] ){
            [DialerUsageRecord recordpath:PATH_DIALER_GUIDE_ANIMATION kvs:Pair(DIALER_GUIDE_ANIMATION_SHOWN_USED_SEARCH, @(1)), nil];
            [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_ONE_USER_SHOWN];
        }
    }
    if ( [UserDefaultsManager intValueForKey:DIALER_GUIDE_ANIMATION_TIMES defaultValue:0] > 0)
        return;
    [self setGuideAnimationOver];
}

+(void)shouldReFreshLocalNoah{
    [UserDefaultsManager setBoolValue:YES forKey:DIALER_GUIDE_ANIMATION_SHOULD_SHOW];
    [[NSNotificationCenter defaultCenter] postNotificationName:N_NOAH_LOAD_CONFIG_SUCCESS object:nil];

}

+ (void)showGuideAnimation{
    [FunctionUtility popToRootViewWithIndex:1];
    [[DialerGuideAnimationManager instance]showDialerGuideAnimation];
    [self setGuideAnimationOver];
}

+ (void)setGuideAnimationOver{
    int time = [UserDefaultsManager intValueForKey:DIALER_GUIDE_ANIMATION_TIMES defaultValue:0];
    [UserDefaultsManager setIntValue:time+1 forKey:DIALER_GUIDE_ANIMATION_TIMES];
    int timeInterval = [[NSDate date] timeIntervalSince1970];
    [UserDefaultsManager setIntValue:timeInterval forKey:DIALER_GUIDE_ANIMATION_FIRST_TIME];
}



@end
