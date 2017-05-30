//
//  SkipButton.m
//  STest
//
//  Created by ALEX on 16/7/13.
//  Copyright © 2016年 ALEX. All rights reserved.
//

#import "SkipButton.h"
#import "TPDialerResourceManager.h"

@interface SkipCountDownButton : SkipButton

@end

@implementation SkipCountDownButton


- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.skipBtn setTitle:@"" forState:UIControlStateNormal];
    }
    return self;
}

- (void) setSkipButtonTitle:(NSString *)title
{
    [self.skipBtn setTitle:title forState:UIControlStateNormal];
}

- (void) updateProgress:(CGFloat)progress
{

}

@end

@interface SkipWaveButton : SkipButton

@end

@implementation SkipWaveButton{
    CAShapeLayer *_waveLayer;
    CADisplayLink *_waveDisplaylink;
    CGFloat _progress;
    CGFloat _waveHeightProgress;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.masksToBounds = YES;     
        _waveLayer = [CAShapeLayer layer];
        _waveLayer.fillColor = [UIColor colorWithRed:42/255.0 green:172/255.0 blue:255/255.0 alpha:0.8].CGColor;
        [self.layer insertSublayer:_waveLayer atIndex:0];
        _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave)];
        [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
      
        _progress  = 0.0;
        _waveHeightProgress = 0;
    }
    
    return self;
}

- (CGFloat) waveHeight
{
    if (_progress >= 1.0) {
        _progress = 1.0;
    }
    
    if (_waveHeightProgress == _progress) {
        return self.bounds.size.height -  self.bounds.size.height * _waveHeightProgress;
    }
    
    if (_waveHeightProgress > _progress) {
        _waveHeightProgress -= 0.005;
    } else {
        _waveHeightProgress += 0.005;
    }
    return self.bounds.size.height - self.bounds.size.height * _waveHeightProgress;
}

- (void) getCurrentWave
{
    static float offsetX = 0.0;
    offsetX += 0.5 / M_PI;
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat currentWavePointY = [self waveHeight];
    CGFloat y = 0;
    CGPathMoveToPoint(path, nil, 0, self.bounds.size.height);
    for (float x = 0.0f; x <=  self.bounds.size.width ; x++) {
        // 正弦波浪公式
        y = 2 * sin(M_PI * 1.1 / self.bounds.size.width * x + offsetX) + currentWavePointY;
        CGPathAddLineToPoint(path, nil, x, y);
        
    }
    //     1.29 * M_PI / waterWaveWidth
    CGPathAddLineToPoint(path, nil, self.bounds.size.width, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    _waveLayer.path = path;
    CGPathRelease(path);
}

- (void)removeFromSuperview {
    
    [_waveDisplaylink invalidate];

}

- (void) updateProgress:(CGFloat)progress
{
    _progress = progress;
    if (_progress > 1.0) {
        [_waveDisplaylink invalidate];
    }
}

- (void)dealloc {
    [_waveDisplaylink invalidate];
}
@end

@interface SkipCircleButton : SkipButton

@end

@implementation SkipCircleButton
+ (Class) layerClass
{
    return CAShapeLayer.class;
}

- (CAShapeLayer *) shapeLayer
{
    return (CAShapeLayer *)self.layer;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
        self.shapeLayer.strokeColor = [UIColor colorWithRed:11/255.0 green:179/255.0 blue:255/255.0 alpha:1].CGColor;
        self.shapeLayer.lineWidth = 1;
        self.shapeLayer.strokeEnd = 0;
    }
    return self;
}

- (UIBezierPath *) layoutPath
{
    const double startAngle = 0.75 * 2.0 * M_PI;
    const double endAngle = startAngle + 2.0 * M_PI;
    
    CGFloat width = self.frame.size.width;
    CGFloat borderWidth = self.shapeLayer.borderWidth;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2.0f, width/2.0f) radius:width/2.0f - borderWidth
          startAngle:startAngle
          endAngle:endAngle
          clockwise:YES];
}

- (void) updateProgress:(CGFloat)progress
{
    [self updatePath:progress];
}

- (void) updatePath:(CGFloat)progress
{
    // Add shape animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 1;
    //    animation.fromValue = @(self.progress);
    animation.toValue = @(progress);
    animation.delegate = self;
    [self.layer addAnimation:animation forKey:@""];
}

- (void) layoutSubviews
{
    [super layoutSubviews];

    self.shapeLayer.cornerRadius = self.frame.size.width / 2.0f;
    self.shapeLayer.path = [self layoutPath].CGPath;
}

@end

@interface SkipButton ()

@property (nonatomic,weak) NSTimer *timer;
@property (nonatomic,assign) CGFloat recordTimer;

@end

@implementation SkipButton

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIButton *skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [skipBtn setTitle:NSLocalizedString(@"launch_ad_skip_text_normalformat", @"") forState:UIControlStateNormal];
        skipBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [skipBtn setTitleColor:[TPDialerResourceManager getColorForStyle:@"tp_color_white_transparency_700"] forState:UIControlStateNormal];
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        self.skipBtn = skipBtn;
        [self addSubview:skipBtn];
        _recordTimer = 1.0;
        self.backgroundColor =  [TPDialerResourceManager getColorForStyle:@"tp_color_black_transparency_500"];
    }
    return self;
}

+ (instancetype) buttonWithType:(SkipButtonType)buttonType
{
    switch (buttonType) {
        case SkipButtonTypeCircle:
            return [[SkipCircleButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 10 - 40, 10, 40, 40)];
            break;
        case SkipButtonTypeWave:
             return [[SkipWaveButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 10 - 40, 10, 40, 40)];
            break;
        case SkipButtonTypeCountDown:
            return [[SkipCountDownButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60 - 8, 7, 60, 25)];
            break;
        case SkipButtonTypeNormal:
            return [[self alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60 - 8, 7, 60, 25)];
            break;
        default:
            break;
    }
    return nil;
}

- (void) setSkipButtonTitle:(NSString *)title
{
    NSString *strTicker = NSLocalizedString(@"launch_ad_skip_text_normalformat", @"");
    [self.skipBtn setTitle:strTicker forState:UIControlStateNormal];
}

- (void) addTarget:(nullable id)target action:(nonnull SEL)action
{
    [self.skipBtn addTarget:target action:action forControlEvents:UIControlEventTouchDown];
}


- (void) updateProgress:(CGFloat)progress
{

}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGFloat skipLabelX = 0;
    CGFloat skipLabelY = 0;
    CGFloat skipLabelW = self.frame.size.width;
    CGFloat skipLabelH = self.frame.size.height;
    self.skipBtn.frame = CGRectMake(skipLabelX, skipLabelY,skipLabelW,skipLabelH);
}
@end


