//
//  FlowWaterWaveView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/1/29.
//
//

#import "FlowWaterWaveView.h"

@interface FlowWaterWaveView(){
    UIColor __strong *_currentWaterColor;
    
    float a;
    float b;
    
    BOOL jia;
    
    NSTimer *timer;
}

@end


@implementation FlowWaterWaveView

- (id)initWithFrame:(CGRect)frame andColor:(UIColor*)bgColor andY:(NSInteger)y andA:(float)aPos andB:(float)bPos
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = frame.size.width/2;
        
        a = aPos;
        b = bPos;
        jia = NO;
        
        _currentWaterColor = bgColor;
        _currentLinePointY = y;
        
    }
    return self;
}

- (void)addTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
}

-(void)animateWave
{
    if (jia) {
        a += 0.1;
    }else{
        a -= 0.1;
    }
    
    
    if (a<=1) {
        jia = YES;
    }
    
    if (a>=3) {
        jia = NO;
    }
    
    
    b+=0.1;
    
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    //画水
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [_currentWaterColor CGColor]);
    
    float y=_currentLinePointY;
    float loopWith = rect.size.width*3/4;
    CGPathMoveToPoint(path, NULL, 0, y);
    for( float x=0; x<=rect.size.width; x++){
        y= a * sin( x/loopWith*M_PI + 4*b/M_PI ) * 5 + (rect.size.height - _currentLinePointY);
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, rect.size.width, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height - _currentLinePointY);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
    
}

- (void)removeTimer{
    [timer invalidate];
}

@end
