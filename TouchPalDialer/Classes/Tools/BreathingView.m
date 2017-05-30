//
//  BreathingView.m
//  TouchPalDialer
//
//  Created by 袁超 on 15/5/13.
//
//

#import "BreathingView.h"

@interface BreathingView(){
    UIView *_outCircleView;
    UIView *_middleCircleView;
    UIView *_innerCircleView;
    
    dispatch_source_t _timer;
    int _timerTicker;
}

@end

@implementation BreathingView

- (instancetype)initWithFrame:(CGRect)frame withOutCircleRadius:(NSInteger)outRadius withMiddleCircleRadius:(NSInteger)middleRadius withInnerRadius:(NSInteger)innerRadius withAllColor:(UIColor *)color{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _outCircleView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2 - outRadius, 0, outRadius * 2, outRadius * 2)];
        _outCircleView.backgroundColor = color;
        _outCircleView.layer.masksToBounds = YES;
        _outCircleView.alpha = 0.1;
        _outCircleView.layer.cornerRadius = outRadius;
        [self addSubview:_outCircleView];
        
        _middleCircleView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2 - middleRadius, outRadius - middleRadius, middleRadius * 2, middleRadius * 2)];
        _middleCircleView.backgroundColor = color;
        _middleCircleView.layer.masksToBounds = YES;
        _middleCircleView.alpha = 0.15;
        _middleCircleView.layer.cornerRadius = middleRadius;
        [self addSubview:_middleCircleView];
        
        _innerCircleView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2 - innerRadius , outRadius - innerRadius, innerRadius * 2, innerRadius * 2)];
        _innerCircleView.backgroundColor = color;
        _innerCircleView.layer.masksToBounds = YES;
        _innerCircleView.layer.cornerRadius = innerRadius;
        [self addSubview:_innerCircleView];
        
        _timer = nil;

    }
    return self;
}

- (void)startBreath {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 0.05*NSEC_PER_SEC, _timerTicker);
    float outerAlpha = _outCircleView.alpha;
    float middleAlpha = _middleCircleView.alpha;
    dispatch_source_set_event_handler(timer, ^{
        float value = fabsf((float)sin(M_PI/40*_timerTicker));
        //cootek_log(@"value: %.3f", value);
        dispatch_sync(dispatch_get_main_queue(), ^{
            _outCircleView.alpha = outerAlpha*value;
            _middleCircleView.alpha = middleAlpha*value;
        });
        _timerTicker++;
    });
    dispatch_resume(timer);
    _timer = timer;
}

- (void)stopBreath {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}
@end
