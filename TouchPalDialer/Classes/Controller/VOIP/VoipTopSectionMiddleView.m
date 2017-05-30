//
//  VoipTopSectionMiddleView.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-5.
//
//

#import "VoipTopSectionMiddleView.h"
#import "TPDialerResourceManager.h"
#import "VoipConsts.h"

@implementation VoipTopSectionMiddleView {
    dispatch_source_t _timer;
    int _timerTicker;
    
}

@synthesize outter = _outter;
@synthesize middle = _middle;
@synthesize inner = _inner;
@synthesize innerImageView = _innerImageView;
- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
    
        self.backgroundColor = [UIColor clearColor];
        UIView *outCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        outCircle.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_middleView_outCircle_bg_color"];
        outCircle.layer.masksToBounds = YES;
        outCircle.layer.cornerRadius = frame.size.width/2;
        [self addSubview:outCircle];
        _outter = outCircle;
        
        float middleWidth = frame.size.width - 30*WIDTH_ADAPT;
        UIView *middleCircle = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - middleWidth)/2, (frame.size.height - middleWidth)/2, middleWidth, middleWidth)];
        middleCircle.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_middleView_middleCircle_bg_color"];
        middleCircle.layer.masksToBounds = YES;
        middleCircle.layer.cornerRadius = middleWidth/2;
        [self addSubview:middleCircle];
        _middle = middleCircle;
        
        
        float innerWidth = frame.size.width - 50*WIDTH_ADAPT;
        UIView *innerCircle = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - innerWidth)/2, (frame.size.height - innerWidth)/2, innerWidth, innerWidth)];
        innerCircle.backgroundColor = [TPDialerResourceManager getColorForStyle:@"voip_middleView_innerCircle_bg_color"];
        innerCircle.layer.masksToBounds = YES;
        innerCircle.layer.cornerRadius = innerWidth/2;
        [self addSubview:innerCircle];
        _inner = innerCircle;
        
        UIImageView *innerCircleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, innerCircle.frame.size.width, innerCircle.frame.size.height)];
        _innerImageView = innerCircleImageView;
        [innerCircle addSubview:innerCircleImageView];
        self.circleColor = [TPDialerResourceManager getColorForStyle:@"outgoing_circle_inner_color"];
        _timer = nil;
    }
    
    return self;
}

- (void)setCircleColor:(UIColor *)circleColor {
    _inner.backgroundColor = circleColor;
    _inner.alpha = 0.5;
    _middle.backgroundColor = circleColor;
    _middle.alpha = 0.15;
    _outter.backgroundColor = circleColor;
    _outter.alpha = 0.05;
}

- (void)setInnerCircleImage:(UIImage *)image{
    _innerImageView.image = image;
}


- (void)beginBreathing {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 0.05*NSEC_PER_SEC, _timerTicker);
    float outerAlpha = _outter.alpha;
    float middleAlpha = _middle.alpha;
    dispatch_source_set_event_handler(timer, ^{
        float value = fabsf((float)sin(M_PI/40*_timerTicker));
        //cootek_log(@"value: %.3f", value);
        dispatch_sync(dispatch_get_main_queue(), ^{
            _outter.alpha = outerAlpha*value;
            _middle.alpha = middleAlpha*value;
        });
        _timerTicker++;
    });
    dispatch_resume(timer);
    _timer = timer;
}

- (void)stopBreathing {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)dealloc {

}

@end
