//
//  TodayWidgetAnimationSecondView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/9/1.
//
//

#import "TodayWidgetAnimationSecondView.h"
#import "TPDialerResourceManager.h"
#import "FunctionUtility.h"
#import "TodayWidgetSecondViewFirstAnimationView_iOS10.h"
#import "TodayWidgetSecondViewSecondAnimationView_iOS10.h"
#import "TodayWidgetSecondViewFirstAnimationView.h"
#import "TodayWidgetSecondViewSecondAnimationView.h"

@interface TodayWidgetAnimationSecondView()<TodayWidgetAnimationViewDelegate>{
    TodayWidgetAnimationView *_firstAniView;
    TodayWidgetAnimationView *_secondAniView;
}

@end

@implementation TodayWidgetAnimationSecondView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if ( self ){
        
        UIImageView *bgView = [[UIImageView alloc]initWithFrame:CGRectMake((TPScreenWidth()-223*HEIGHT_ADAPT)/2, (TPScreenHeight()-477*HEIGHT_ADAPT)/2, 223*HEIGHT_ADAPT, 477*HEIGHT_ADAPT)];
        bgView.image = [TPDialerResourceManager getImage:@"today_widget_phone@2x.png"];
        [self addSubview:bgView];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10 ) {
             _firstAniView = [[TodayWidgetSecondViewFirstAnimationView_iOS10 alloc]initWithFrame:CGRectMake((bgView.frame.size.width-192*HEIGHT_ADAPT)/2, (bgView.frame.size.height-341*HEIGHT_ADAPT)/2, 192*HEIGHT_ADAPT, 341*HEIGHT_ADAPT)];
             _secondAniView = [[TodayWidgetSecondViewSecondAnimationView_iOS10 alloc]initWithFrame:CGRectMake(0, _firstAniView.frame.size.height, _firstAniView.frame.size.width, _firstAniView.frame.size.height)];
        } else {
             _firstAniView = [[TodayWidgetSecondViewFirstAnimationView alloc]initWithFrame:CGRectMake((bgView.frame.size.width-192*HEIGHT_ADAPT)/2, (bgView.frame.size.height-341*HEIGHT_ADAPT)/2, 192*HEIGHT_ADAPT, 341*HEIGHT_ADAPT)];
             _secondAniView = [[TodayWidgetSecondViewSecondAnimationView alloc]initWithFrame:CGRectMake(0, _firstAniView.frame.size.height, _firstAniView.frame.size.width, _firstAniView.frame.size.height)];
        }
              _firstAniView.layer.masksToBounds = YES;
        [bgView addSubview:_firstAniView];
        
       
        [_firstAniView addSubview:_secondAniView];
        
    }
    
    return self;
}

- (void)startAnimation{
    _firstAniView.delegate = self;
    [_firstAniView doAnimation];
}

- (void)stopAnimation{
    _firstAniView.delegate = nil;
    [_firstAniView refreshView];
    [_secondAniView refreshView];
    _secondAniView.frame = CGRectMake(0, _firstAniView.frame.size.height, _firstAniView.frame.size.width, _firstAniView.frame.size.height);
    _firstAniView.layer.masksToBounds = YES;

}

- (void)dealloc{
    _firstAniView.delegate = nil;
}

#pragma mark TodayWidgetAnimationViewDelegate
- (void)onAnimationOver:(NSInteger)num{
    [self startSecondAnimation];
}

- (void)startSecondAnimation{
    CGRect oldFrame = _secondAniView.frame;

    [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _secondAniView.frame = CGRectMake(0, 0, oldFrame.size.width, oldFrame.size.height);
                     }
                     completion:^(BOOL finish){
                         if ( finish )
                             _firstAniView.layer.masksToBounds = NO;
                             [_secondAniView doAnimation];
                     }];
}

@end
