//
//  DialerGuideAnimationManager.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/18.
//
//

#import "DialerGuideAnimationManager.h"
#import "DialerGuideAnimationView.h"
#import "DialerUsageRecord.h"

@interface DialerGuideAnimationManager()<DialerGuideAnimationViewDelegate>{
    DialerGuideAnimationView *_view;
}

@end

static DialerGuideAnimationManager *instance;

@implementation DialerGuideAnimationManager

+ (void)initialize{
    instance = [[DialerGuideAnimationManager alloc]init];
}

+ (instancetype)instance{
    return instance;
}

- (void)showDialerGuideAnimation{
    if ( _view != nil )
        return;
    _view = [[DialerGuideAnimationView alloc]init];
    _view.delegate = self;
    UIWindow *uiWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [uiWindow addSubview:_view];
    [uiWindow bringSubviewToFront:_view];
    
}

- (void)onEscapeButtonPressed{
    [DialerUsageRecord recordpath:PATH_DIALER_GUIDE_ANIMATION kvs:Pair(DIALER_GUIDE_ANIMATION_ESCAPE_TIMES, @(1)), nil];
    [_view removeFromSuperview];
    _view = nil;
}

@end
