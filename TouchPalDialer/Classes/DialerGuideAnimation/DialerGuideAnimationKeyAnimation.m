//
//  DialerGuideAnimationKeyAnimationView.m
//  TouchPalDialer
//
//  Created by game3108 on 15/8/19.
//
//

#import "DialerGuideAnimationKeyAnimation.h"
#import "TPDialerResourceManager.h"

@interface DialerGuideAnimationKeyAnimation(){
    NSTimer *_timer;
    NSInteger _animationNumber;
    
    float _alphaA;
    float _alphaB;
    
    float _radiusA;
    float _radiusB;
    
    BOOL _ifAnimation;
    
    UIImage *_animationImage;
}

@end

@implementation DialerGuideAnimationKeyAnimation

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self drawAnimation];
}

- (void) drawAnimation{
    if ( !_ifAnimation )
        return;
    float posX = self.frame.size.width/2;
    float posY = self.frame.size.height/2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect frameRect;
    if ( _alphaA != 0 ){
        frameRect = CGRectMake(posX-_radiusA/2, posY-_radiusA/2, _radiusA, _radiusA);
        CGContextSetLineWidth(context, 0);
        CGContextAddEllipseInRect(context, frameRect);
        CGContextClip(context);
        CGContextSetAlpha(context,_alphaA);
        CGContextDrawImage(context, frameRect, [_animationImage CGImage]);
        CGContextStrokePath(context);
    }
    if ( _alphaB != 0 ){
        frameRect = CGRectMake(posX-_radiusB/2, posY-_radiusB/2, _radiusB, _radiusB);
        CGContextSetLineWidth(context, 0);
        CGContextAddEllipseInRect(context, frameRect);
        CGContextClip(context);
        CGContextSetAlpha(context,_alphaB);
        CGContextDrawImage(context, frameRect, [_animationImage CGImage]);
        CGContextStrokePath(context);
    }
}

- (void)startAnimation{
    _animationNumber = 0;
    _ifAnimation = YES;
    _animationImage = [TPDialerResourceManager getImage:@"T9keyPad_numberKey_ht@2x.png"];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(doAnimation) userInfo:nil repeats:YES];
}

- (void)doAnimation{
    _animationNumber += 1;
    if ( _animationNumber >= 30 )
        [self stopAnimation];
    
    if ( _animationNumber <= 20 ){
        float valueA = fabsf((float)sin(M_PI/20*_animationNumber));
        _radiusA = self.frame.size.width/20*_animationNumber;
        _alphaA = 0.3*valueA;
    }else{
        _radiusA = 0;
        _alphaA = 0;
    }
    
    if ( _animationNumber >= 10 ){
        float valueB = fabsf((float)sin(M_PI/20*(_animationNumber-10)));
        _radiusB = self.frame.size.width/20*(_animationNumber-10);
        _alphaB = 0.3*valueB;
    }else{
        _radiusB = 0;
        _alphaB = 0;
    }
    
    if ( _animationNumber == 20 )
        [self showViewAnimation];
    
    [self setNeedsDisplay];
}

- (void)stopAnimation{
    if ( _timer != nil && [_timer isValid]){
        [_timer invalidate];
        _timer = nil;
        _ifAnimation = NO;
    }
    [self setNeedsDisplay];
}

- (void)showViewAnimation{
    if ( _delegate != nil )
        [_delegate showViewAnimation];
}

-(void)dealloc{
    if ( _timer != nil && [_timer isValid]){
        [_timer invalidate];
        _timer = nil;
        _ifAnimation = NO;
    }
    _delegate = nil;
}

@end
