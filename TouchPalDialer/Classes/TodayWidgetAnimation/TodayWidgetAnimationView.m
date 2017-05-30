//
//  TodayWidgetAnimationView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/1.
//
//

#import "TodayWidgetAnimationView.h"

@implementation TodayWidgetAnimationView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        _ifAnimation = NO;
        
        _heightAdapt = [TodayWidgetAnimationUtil getAdapt];
        
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    }
    
    return self;
}

- (void)doAnimation{
    _ifAnimation = YES;
    [self startAnimation];
}

- (void)startAnimation{
    
}

- (void)refreshView{
    _ifAnimation = NO;
    [self stopAnimation];
}

- (void)stopAnimation{
    
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if ( !_ifAnimation ){
        [self refreshView];
        return;
    }
    [self doNextAnimation:animationID finished:finished context:context];
}

- (void)doNextAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
}


@end
